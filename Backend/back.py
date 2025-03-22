import os
import json
import random
import vosk
from rapidfuzz.distance import Levenshtein
from flask import Flask, request, jsonify, session
from flask_pymongo import PyMongo
from werkzeug.security import check_password_hash, generate_password_hash
from flask_cors import CORS
from datetime import datetime, timedelta
from collections import defaultdict


app = Flask(__name__)
CORS(app, supports_credentials=True)  # Enable credentials for session cookies
app.secret_key = 'spello_secret_key'  # Required for session management


# path to the downloaded model
MODEL_PATH = os.path.join(os.path.dirname(__file__), 'vosk-model-small-en-us-0.15')

# Load Vosk Model
if not os.path.exists(MODEL_PATH):
    raise ValueError(f"Vosk model directory not found at: {MODEL_PATH}")

model = vosk.Model(MODEL_PATH)
recognizer = vosk.KaldiRecognizer(model, 16000)  # rate is 16kHz

#creating a dictionary to store targeted words
session_data = {}

# comprehensive word list organized by sounds (first five sounds: p, b, t, d, k)
sound_word_lists = {
    "p": [ "Pencil", "Paper",  "Park", "Pink", "Pillow", "Happy", "Apple", "Capture", "Monkey", "Ship" ],

    "b": [ "Book",  "Ball", "Balloon", "Banana", "Basket", "Rabbit", "Robot", "Cabbage", "About", "Crab"  ],

    "t": [ "Table", "Turtle", "Tiger", "Talk", "Taxi", "Water", "Button", "Kettle", "Battery",  "Cat"  ],

    "d": [ "Dog", "Door", "Desk", "Dance", "Dish", "Hidden", "Ladder", "Garden", "Shadow", "Bird" ],

    "k": [ "King", "Kite", "Key","Kitchen", "Kangaroo", "Monkey", "Cookie", "Pocket", "Basket", "Bark" ]
}

# Create a word sound mapping dictionary for easy lookup
word_sound_mapping = {}
for sound, words in sound_word_lists.items():
    for word in words:
        if word not in word_sound_mapping:
            word_sound_mapping[word] = []
        word_sound_mapping[word].append(sound)


#API endpoint to send the target word to frontend based on selected sounds
@app.route('/get-target-word', methods=['GET'])
def get_target_word():
    # Get selected sounds from query parameters
    query_sounds = request.args.get('sounds', '').lower().split(',')

    # Get email from session instead of from query parameters
    email = session.get('user_email')

    if not email:
        return jsonify({"error": "User not logged in. Please log in first."}), 401

    # Retrieve custom words from the user's profile
    user = collection.find_one({"email": email})
    if not user:
        return jsonify({"error": "User not found"}), 404

    # Determine which sounds to use
    selected_sounds = query_sounds if query_sounds and query_sounds[0] != '' else user.get('selected_sounds', [])

    custom_words = user.get("custom_words", [])

    # Filter words that contain at least one of the selected sounds
    filtered_words = []

    if not selected_sounds or selected_sounds[0] == '':
        # If no sounds are selected, use all words
        filtered_words = list(word_sound_mapping.keys())
    else:
        # Filter words containing the selected sounds
        for snd in selected_sounds:
            if snd in sound_word_lists:
                filtered_words.extend(sound_word_lists[snd])

        # Remove duplicates
        filtered_words = list(set(filtered_words))

    # Add custom words to the filtered list
    filtered_words.extend(custom_words)

    # If no words match the criteria, use all words
    if not filtered_words:
        filtered_words = list(word_sound_mapping.keys())

    # Choose a random word from the filtered list
    target_word = random.choice(filtered_words)
    session_data['target_word'] = target_word

    return jsonify({
        "target_word": target_word,
    })


# Function to calculate similarity percentage
def calculate_accuracy(target, spoken):
    if not spoken:
        return 0  # No spoken word detected
    distance = Levenshtein.distance(target, spoken)
    max_length = max(len(target), len(spoken))
    accuracy = ((max_length - distance) / max_length) * 100
    return round(accuracy, 2)

#change password
@app.route('/change_password', methods=['POST'])
def change_password():
    # Get email from session
    email = session.get('user_email')
    if not email:
        # If not in session, try from query parameters
        email = request.args.get("email")

    if not email:
        return jsonify({"error": "User not logged in. Please log in first."}), 401

    data = request.json

    # Validate required fields
    if not data or not data.get('current_password') or not data.get('new_password'):
        return jsonify({"error": "Current password and new password are required"}), 400

    current_password = data.get('current_password')
    new_password = data.get('new_password')

    # Find user in database
    user = collection.find_one({"email": email})
    if not user:
        return jsonify({"error": "User not found"}), 404

    # Verify current password
    if not check_password_hash(user['password'], current_password):
        return jsonify({"error": "Current password is incorrect"}), 401

    # Hash the new password
    hashed_password = generate_password_hash(new_password)

    # Update the password
    result = collection.update_one(
        {"email": email},
        {"$set": {"password": hashed_password}}
    )

    if result.modified_count == 1:
        return jsonify({"message": "Password changed successfully"}), 200
    else:
        return jsonify({"error": "Failed to change password"}), 500



#update user details

@app.route('/update_user', methods=['PUT'])
def update_user():
    # Get email from session
    email = session.get('user_email')
    if not email:
        # If not in session, try from query parameters
        email = request.args.get("email")

    if not email:
        return jsonify({"error": "User not logged in. Please log in first."}), 401

    # Get JSON data from request
    data = request.json
    if not data:
        return jsonify({"error": "No data provided"}), 400

    # Find user in database
    user = collection.find_one({"email": email})
    if not user:
        return jsonify({"error": "User not found"}), 404

    # Fields that can be updated
    updatable_fields = ["name", "age", "gender"]
    update_data = {}

    # Extract fields to update
    for field in updatable_fields:
        if field in data:
            update_data[field] = data[field]

    # If no valid fields to update
    if not update_data:
        return jsonify({"message": "No valid fields to update"}), 400

    # Update user in database
    result = collection.update_one(
        {"email": email},
        {"$set": update_data}
    )

    if result.modified_count == 1:
        # Get updated user data
        updated_user = collection.find_one({"email": email}, {"password": 0})
        # Convert ObjectId to string
        updated_user['_id'] = str(updated_user['_id'])

        return jsonify({
            "message": "User details updated successfully",
            "user": updated_user
        })
    elif result.matched_count == 1:
        return jsonify({"message": "No changes made to user details"}), 200
    else:
        return jsonify({"error": "Failed to update user details"}), 500


# API Endpoint to receive audio
@app.route('/speech-to-text', methods=['POST'])
def speech_to_text():
    # Check if user is logged in
    email = session.get('user_email')

    if not email:
        # If not in session, try from query parameters
        email = request.args.get("email")

    if not email:
        return jsonify({"error": "User not logged in. Please log in first."}), 401

    if 'audio' not in request.files:
        return jsonify({"error": "No audio file provided"}), 400

    audio_file = request.files['audio']
    if audio_file.filename == '':
        return jsonify({"error": "Empty file uploaded"}), 400

    audio_data = audio_file.read()
    if not audio_data:
        return jsonify({"error": "Audio data missing"}), 400

    recognizer.AcceptWaveform(audio_data)
    result = json.loads(recognizer.Result())
    spoken_word = result.get("text", "").strip().capitalize()
    target_word = session_data.get('target_word', '')

    # Store the spoken word in session_data for use in play-game route
    session_data['spoken_word'] = spoken_word

    accuracy = calculate_accuracy(target_word, spoken_word)

    # Store accuracy in session_data for use in play-game route
    session_data['accuracy'] = accuracy

    return jsonify({
        "spoken_word": spoken_word,
        "target_word": target_word,
        "accuracy": accuracy
    })


# Helper function to get dates for the past week
def get_past_week_dates():
    today = datetime.now().date()
    dates = []
    for i in range(7):
        dates.append((today - timedelta(days=i)).strftime('%Y-%m-%d'))
    return dates


# 1. Weekly Streak Endpoint
@app.route('/dashboard/streak', methods=['GET'])
def get_weekly_streak():
    # Get email from session
    email = session.get('user_email')
    if not email:
        return jsonify({"error": "User not logged in. Please log in first."}), 401

    # Find user in database
    user = collection.find_one({"email": email})
    if not user:
        return jsonify({"error": "User not found"}), 404

    # Get streak information
    current_streak = user.get('current_streak', 0)
    max_streak = user.get('max_streak', 0)

    return jsonify({
        "current_streak": current_streak,
        "max_streak": max_streak
    })


# 2. Average Accuracy Score Endpoint
@app.route('/dashboard/average-accuracy', methods=['GET'])
def get_average_accuracy():
    # Get email from session
    email = session.get('user_email')
    if not email:
        return jsonify({"error": "User not logged in. Please log in first."}), 401

    # Find user in database
    user = collection.find_one({"email": email})
    if not user:
        return jsonify({"error": "User not found"}), 404

    # Calculate average accuracy from scores array
    scores = user.get('scores', [])
    if not scores:
        return jsonify({
            "average_accuracy": 0,
            "total_attempts": 0
        })

    accuracy_sum = sum(score.get('accuracy', 0) for score in scores)
    average_accuracy = round(accuracy_sum / len(scores), 2)

    return jsonify({
        "average_accuracy": average_accuracy,
        "total_attempts": len(scores)
    })

# 3. Words Mastered Endpoint
@app.route('/dashboard/words-mastered', methods=['GET'])
def get_words_mastered():
    # Get email from session
    email = session.get('user_email')
    if not email:
        return jsonify({"error": "User not logged in. Please log in first."}), 401

    # Find user in database
    user = collection.find_one({"email": email})
    if not user:
        return jsonify({"error": "User not found"}), 404

    # Find all words with accuracy >= 75%
    scores = user.get('scores', [])
    if not scores:
        return jsonify({
            "words_mastered": 0,
            "mastered_list": []
        })


    # Create a dictionary to track the highest accuracy for each word
    word_accuracy = {}
    for score in scores:
        target_word = score.get('target_word', '')
        accuracy = score.get('accuracy', 0)

        # Update dictionary if this is a higher accuracy or first time seeing word
        if target_word not in word_accuracy or accuracy > word_accuracy[target_word]:
            word_accuracy[target_word] = accuracy

    # Count words with accuracy >= 75%
    mastered_words = [word for word, accuracy in word_accuracy.items() if accuracy >= 75]

    return jsonify({
        "words_mastered": len(mastered_words),
        "mastered_list": mastered_words
    })


# 4. User Level Endpoint
@app.route('/dashboard/level', methods=['GET'])
def get_user_level():
    # Get email from session
    email = session.get('user_email')
    if not email:
        return jsonify({"error": "User not logged in. Please log in first."}), 401

    # Find user in database
    user = collection.find_one({"email": email})
    if not user:
        return jsonify({"error": "User not found"}), 404

    # Get user level and total score
    level = user.get('level', 1)
    total_score = user.get('total_score', 0)

    # Calculate progress to next level
    progress_to_next_level = 0
    if level == 1:
        # Level 1 to 2 requires 2000 points
        progress_to_next_level = min(total_score / 2000 * 100, 100)

    return jsonify({
        "current_level": level,
        "total_score": total_score,
        "progress_to_next_level": round(progress_to_next_level, 2)
    })


# 5. Weekly Accuracy Trend Endpoint
@app.route('/dashboard/weekly-trend', methods=['GET'])
def get_weekly_accuracy_trend():
    # Get email from session
    email = session.get('user_email')
    if not email:
        return jsonify({"error": "User not logged in. Please log in first."}), 401

    # Find user in database
    user = collection.find_one({"email": email})
    if not user:
        return jsonify({"error": "User not found"}), 404

    # Get today's date and calculate date 7 days ago
    today = datetime.now().date()
    week_ago = today - timedelta(days=6)  # Include today, so 6 days back

    # Get scores from user
    scores = user.get('scores', [])

    # Check if scores have timestamps
    if scores and 'timestamp' not in scores[0]:
        # Initialize with empty data for testing
        past_week_dates = get_past_week_dates()
        daily_data = []
        for date in past_week_dates:
            daily_data.append({
                "date": date,
                "average_accuracy": 0,
                "attempts": 0
            })
        return jsonify({
            "daily_trend": daily_data,
            "message": "Historical data not available. Start practicing to see your weekly trend."
        })

    # Group scores by day
    daily_scores = defaultdict(list)
    for score in scores:
        if 'timestamp' not in score:
            continue

        try:
            score_date = datetime.strptime(score['timestamp'], '%Y-%m-%d').date()
            if score_date >= week_ago and score_date <= today:
                date_str = score_date.strftime('%Y-%m-%d')
                daily_scores[date_str].append(score.get('accuracy', 0))
        except ValueError:
            # Skip records with invalid date format
            continue

    # Calculate daily averages
    daily_trend = []
    for i in range(7):
        date = (week_ago + timedelta(days=i)).strftime('%Y-%m-%d')
        day_scores = daily_scores.get(date, [])

        if day_scores:
            avg_accuracy = round(sum(day_scores) / len(day_scores), 2)
        else:
            avg_accuracy = 0

        daily_trend.append({
            "date": date,
            "average_accuracy": avg_accuracy,
            "attempts": len(day_scores)
        })

    return jsonify({
        "daily_trend": daily_trend
    })


# Endpoint to get a comprehensive dashboard with all metrics
@app.route('/dashboard', methods=['GET'])
def get_dashboard():
    # Get email from session
    email = session.get('user_email')
    if not email:
        return jsonify({"error": "User not logged in. Please log in first."}), 401

    # Find user in database
    user = collection.find_one({"email": email})
    if not user:
        return jsonify({"error": "User not found"}), 404

    # Get streak information
    current_streak = user.get('current_streak', 0)
    max_streak = user.get('max_streak', 0)

    # Calculate average accuracy
    scores = user.get('scores', [])
    if scores:
        accuracy_sum = sum(score.get('accuracy', 0) for score in scores)
        average_accuracy = round(accuracy_sum / len(scores), 2)
        total_attempts = len(scores)
    else:
        average_accuracy = 0
        total_attempts = 0

    # Count mastered words
    word_accuracy = {}
    for score in scores:
        target_word = score.get('target_word', '')
        accuracy = score.get('accuracy', 0)

        if target_word not in word_accuracy or accuracy > word_accuracy[target_word]:
            word_accuracy[target_word] = accuracy

    mastered_words = [word for word, accuracy in word_accuracy.items() if accuracy >= 75]

    # Get level information
    level = user.get('level', 1)
    total_score = user.get('total_score', 0)

    # Calculate progress to next level
    progress_to_next_level = 0
    if level == 1:
        # Level 1 to 2 requires 2000 points
        progress_to_next_level = min(total_score / 2000 * 100, 100)

    # Get weekly trend
    today = datetime.now().date()
    week_ago = today - timedelta(days=6)

    daily_scores = defaultdict(list)
    for score in scores:
        if 'timestamp' not in score:
            continue

        try:
            score_date = datetime.strptime(score['timestamp'], '%Y-%m-%d').date()
            if score_date >= week_ago and score_date <= today:
                date_str = score_date.strftime('%Y-%m-%d')
                daily_scores[date_str].append(score.get('accuracy', 0))
        except ValueError:
            continue

    daily_trend = []
    for i in range(7):
        date = (week_ago + timedelta(days=i)).strftime('%Y-%m-%d')
        day_scores = daily_scores.get(date, [])

        if day_scores:
            avg_accuracy = round(sum(day_scores) / len(day_scores), 2)
        else:
            avg_accuracy = 0

        daily_trend.append({
            "date": date,
            "average_accuracy": avg_accuracy,
            "attempts": len(day_scores)
        })

    # Return comprehensive dashboard
    return jsonify({
        "streak": {
            "current_streak": current_streak,
            "max_streak": max_streak
        },
        "accuracy": {
            "average_accuracy": average_accuracy,
            "total_attempts": total_attempts
        },
        "words_mastered": {
            "count": len(mastered_words),
            "list": mastered_words
        },
        "level": {
            "current_level": level,
            "total_score": total_score,
            "progress_to_next_level": round(progress_to_next_level, 2)
        },
        "weekly_trend": daily_trend
    })


@app.route('/update_selected_sounds', methods=['POST'])
def update_selected_sounds():
    data = request.json
    print("Received update_selected_sounds request with data:", data)

    # Get email from session
    email = session.get('user_email')
    if not email:
        # If not in session, try from request
        email = data.get('email')
        print("Using email from request:", email)

    if not email or 'selected_sounds' not in data:
        print("Missing required fields")
        return jsonify({"error": "Email and selected_sounds are required"}), 400

    selected_sounds = data.get('selected_sounds', [])
    print("Selected sounds to be saved:", selected_sounds)

    # Update the user document with selected sounds
    result = collection.update_one(
        {"email": email},
        {"$set": {"selected_sounds": selected_sounds}}
    )

    print("MongoDB update result:", result.modified_count)

    if result.modified_count == 1:
        print("Update successful")
        return jsonify({"message": "Selected sounds updated successfully"}), 200
    elif collection.find_one({"email": email}):
        print("User found but no changes made")
        return jsonify({"message": "No changes to selected sounds"}), 200
    else:
        print("User not found")
        return jsonify({"error": "User not found"}), 404

@app.route('/check_sounds/<email>', methods=['GET'])
def check_sounds(email):
    user = collection.find_one({"email": email})
    if not user:
        return jsonify({"error": "User not found"}), 404

    return jsonify({
        "selected_sounds": user.get("selected_sounds", []),
        "email": user.get("email")
    })




@app.route("/add-custom-word", methods=["POST"])
def add_custom_word():
    # Get email from session
    email = session.get('user_email')
    if not email:
        return jsonify({"error": "User not logged in. Please log in first."}), 401

    data = request.json
    custom_word = data.get("custom_word")

    if not custom_word:
        return jsonify({"error": "Custom word is required"}), 400

    # Find the user and update their custom words
    user = collection.find_one({"email": email})
    if not user:
        return jsonify({"error": "User not found"}), 404

    # Add custom word to the user's profile
    if "custom_words" not in user:
        collection.update_one({"email": email}, {"$set": {"custom_words": [custom_word]}})
    else:
        # Avoid adding duplicates
        if custom_word not in user["custom_words"]:
            collection.update_one({"email": email}, {"$push": {"custom_words": custom_word}})

    return jsonify({"message": f"Custom word '{custom_word}' added successfully!"})


@app.route("/remove-custom-word", methods=["POST"])
def remove_custom_word():
    # Get email from session
    email = session.get('user_email')

    if not email:
        # If not in session, try from query parameters
        email = request.args.get("email")

    if not email:
        return jsonify({"error": "User not logged in. Please log in first."}), 401

    data = request.json
    custom_word = data.get("custom_word")

    if not custom_word:
        return jsonify({"error": "Custom word is required"}), 400

    # Find the user and update their custom words
    user = collection.find_one({"email": email})
    if not user:
        return jsonify({"error": "User not found"}), 404

    if "custom_words" not in user or custom_word not in user["custom_words"]:
        return jsonify({"error": "Custom word not found"}), 404

    # Remove custom word from the user's profile
    collection.update_one({"email": email}, {"$pull": {"custom_words": custom_word}})

    return jsonify({"message": f"Custom word '{custom_word}' removed successfully!"})


# ----------------------------------------------------------------------------------------------------------------------
# Initializing database

# mongodb connection string
app.config["MONGO_URI"] = "mongodb+srv://spello:spello100@spellodb.8zvmy.mongodb.net/spello_database?retryWrites=true&w=majority"

# connect to mongoDB
mongo = PyMongo(app)
collection = mongo.db.sp1

@app.route("/")
def home():
    return jsonify({"message": "Connected MongoDB Successfully"})


# registering user
@app.route('/register', methods=['POST'])  # to register
def register():
    data = request.json

    # Validate required fields
    required_fields = ["name", "email", "password"]
    if not all(field in data for field in required_fields):
        return jsonify({"error": "Name, email, and password are required"}), 400

    # Optional fields
    age = data.get('age', '')
    gender = data.get('gender', '')

    email = data.get('email')
    password = data.get('password')
    name = data.get('name', '')

    # Check if user already exists
    if collection.find_one({'email': email}):
        return jsonify({'message': 'User already exists'}), 409

    # Hash the password
    hashed_password = generate_password_hash(password)

    # Create user object
    user = {
        'email': email,
        'password': hashed_password,
        'name': name,
        'age': age,
        'gender': gender,
        'custom_words': [],
        'total_score': 0,
        'level': 1,
        'attempts': 0,
        'lives': 5,
        'scores': [],
        'current_streak': 0,
        'max_streak': 0,
        'last_practice_date': ''
    }

    # Insert new user
    result = collection.insert_one(user)

    # Create response without password
    user_response = {
        'name': name,
        'email': email,
        'age': age,
        'gender': gender,
        '_id': str(result.inserted_id)
    }

    return jsonify({
        'message': 'User registered successfully',
        'user': user_response
    }), 201


# login
@app.route('/login', methods=['POST'])  # to login
def login():
    data = request.json

    if not data or not data.get('email') or not data.get('password'):
        return jsonify({'message': 'Email and password are required'}), 400

    email = data.get('email')
    password = data.get('password')

    # Find user in database
    user = collection.find_one({'email': email})

    if not user:
        return jsonify({'message': 'User not found'}), 404

    # Check password
    if check_password_hash(user['password'], password):
        # Store email in session after successful login
        session['user_email'] = email

        # Don't send password in response
        user_data = {
            'email': user['email'],
            'name': user.get('name', ''),
            'age': user.get('age', ''),
            'gender': user.get('gender', '')
        }
        return jsonify({
            'message': 'Login successful',
            'user': user_data
        }), 200
    else:
        return jsonify({'message': 'Invalid password'}), 401


# Route to logout user
@app.route('/logout', methods=['POST'])
def logout():
    # Remove user email from session
    session.pop('user_email', None)
    return jsonify({'message': 'Logged out successfully'}), 200


# add route to store details in the database
@app.route('/get_users', methods=['GET'])  # to get all the user details
def get_users():
    # Retrieve all users but exclude passwords and convert ObjectId to string
    users_cursor = collection.find({}, {"password": 0})

    # Convert cursor to list and handle ObjectId
    users_list = []
    for user in users_cursor:
        user['_id'] = str(user['_id'])  # Convert ObjectId to string
        users_list.append(user)

    return jsonify({"users": users_list})


#get one user based on email
@app.route('/get_user', methods=['GET'])  # get user accordint to email
def get_user():
    # Get email from session
    email = session.get('user_email')
    if not email:
        # If not in session, try from query parameters
        email = request.args.get("email")

    if not email:
        return jsonify({"error": "Email is required or user not logged in"}), 400

    # Find user by email, exclude password from response
    user = collection.find_one({"email": email}, {"password": 0})

    if not user:
        return jsonify({"error": "User not found"}), 404

    # Convert ObjectId to string
    user['_id'] = str(user['_id'])

    return jsonify(user)


@app.route('/delete_user', methods=['DELETE'])  # to delete user according to email
def delete_user():
    # Get email from session for currently logged-in user
    email = session.get('user_email')
    if not email:
        # If not in session, try from query parameters
        email = request.args.get("email")

    if not email:
        return jsonify({"error": "Email is required or user not logged in"}), 400

    # Find the user first to return their info
    user = collection.find_one({"email": email})

    if not user:
        return jsonify({"error": "User not found"}), 404

    # Delete the user
    result = collection.delete_one({"email": email})

    if result.deleted_count == 1:
        # If the deleted user was the logged in user, clear session
        if session.get('user_email') == email:
            session.pop('user_email', None)

        # Create a response excluding the password
        deleted_user = {
            "name": user.get("name"),
            "email": user.get("email"),
            "age": user.get("age"),
            "gender": user.get("gender")
        }
        return jsonify({
            "message": "User deleted successfully",
            "deleted_user": deleted_user
        })
    else:
        return jsonify({"error": "Failed to delete the user"}), 500


# Route to delete the last inserted user
@app.route('/delete_last_user', methods=['DELETE'])  # to delete last user
def delete_last_user():
    # Find the last inserted user
    last_user = collection.find_one({}, sort=[("_id", -1)])

    if not last_user:
        return jsonify({"error": "No users found in the database"}), 404

    # Delete the last user
    result = collection.delete_one({"_id": last_user["_id"]})

    if result.deleted_count == 1:
        # If the deleted user was the logged in user, clear session
        if session.get('user_email') == last_user.get("email"):
            session.pop('user_email', None)

        # Create a response excluding the password
        deleted_user = {
            "name": last_user.get("name"),
            "email": last_user.get("email"),
            "age": last_user.get("age"),
            "gender": last_user.get("gender")
        }
        return jsonify({
            "message": "Last user deleted successfully",
            "deleted_user": deleted_user
        })
    else:
        return jsonify({"error": "Failed to delete the last user"}), 500


# game logics--Hangman

def calculate_score(accuracy, level):
    if level == 1:
        if accuracy > 75:
            return 100
        elif accuracy >= 50:
            return int((accuracy - 50) * 4)
        else:
            return 0
    elif level >= 2:
        if accuracy > 85:
            return 100
        elif accuracy >= 50:
            return int((accuracy - 50) * 2)
        else:
            return 0



@app.route('/play-game', methods=['POST'])
def play_game():
    # Get email from session instead of form data
    email = session.get('user_email')

    if not email:
        return jsonify({'error': 'User not logged in. Please log in first.'}), 401

    user = collection.find_one({'email': email})
    if not user:
        return jsonify({'error': 'User not found'}), 404

    # Retrieve the spoken word and accuracy from session_data (set by speech_to_text)
    spoken_word = session_data.get('spoken_word', '').strip().capitalize()
    accuracy = session_data.get('accuracy', 0)

    if not spoken_word:
        return jsonify({'error': 'No spoken word found. Please provide speech input first.'}), 400

    target_word = session_data.get('target_word', '')
    level = user.get('level', 1)
    score = calculate_score(accuracy, level)

    # Increment total score
    total_score = user.get('total_score', 0) + score

    # Get current timestamp
    current_time = datetime.now().strftime('%Y-%m-%d')

    # Track attempts and lives
    attempts = user.get('attempts', 0) + 1
    lives = user.get('lives', 5)

    if accuracy < 50:
        lives -= 1

    # Check if score exceeds threshold for level up
    if total_score >= 2000 and level == 1:
        level = 2

    # Update streak information
    last_practice_date = user.get('last_practice_date', '')
    current_streak = user.get('current_streak', 0)
    max_streak = user.get('max_streak', 0)

    if last_practice_date != current_time:
        # New day of practice
        if last_practice_date:
            last_date = datetime.strptime(last_practice_date, '%Y-%m-%d').date()
            today = datetime.now().date()
            days_diff = (today - last_date).days

            if days_diff == 1:
                # Consecutive day
                current_streak += 1
                if current_streak > max_streak:
                    max_streak = current_streak
            elif days_diff > 1:
                # Streak broken
                current_streak = 1
        else:
            # First time practicing
            current_streak = 1
            max_streak = 1

    # If 5 successful or failed attempts are reached, save the game state and reset lives
    if attempts >= 5 or lives <= 0:
        collection.update_one({'email': email}, {'$set': {
            'total_score': total_score,
            'level': level,
            'attempts': 0,
            'lives': 5,
            'scores': user.get('scores', []) + [
                {'target_word': target_word, 'spoken_word': spoken_word, 'accuracy': accuracy, 'score': score,
                 'timestamp': current_time}],
            'last_practice_date': current_time,
            'current_streak': current_streak,
            'max_streak': max_streak
        }})
        # Reset game state: New target word, reset attempts/lives for the next round
        session_data['target_word'] = ''
        session_data['spoken_word'] = ''
        return jsonify({
            'message': 'Game over or successful round. Game reset. New target word is ready.',
            'total_score': total_score,
            'level': level,
            'spoken_word': spoken_word,
            'target_word': target_word,
            'accuracy': accuracy,
            'current_streak': current_streak
        })

    # Save progress after each attempt
    collection.update_one({'email': email}, {'$set': {
        'attempts': attempts,
        'lives': lives,
        'total_score': total_score,
        'level': level,
        'scores': user.get('scores', []) + [
            {'target_word': target_word, 'spoken_word': spoken_word, 'accuracy': accuracy, 'score': score,
             'timestamp': current_time}],
        'last_practice_date': current_time,
        'current_streak': current_streak,
        'max_streak': max_streak
    }})

    return jsonify({
        'accuracy': accuracy,
        'score': score,
        'lives': lives,
        'total_score': total_score,
        'level': level,
        'spoken_word': spoken_word,
        'target_word': target_word,
        'current_streak': current_streak
    })

# check for deplyment 3
if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)