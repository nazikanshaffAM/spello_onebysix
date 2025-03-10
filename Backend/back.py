import os
import json
import random
import vosk
from rapidfuzz.distance import Levenshtein
from flask import Flask, request, jsonify
from pymongo import MongoClient
from werkzeug.security import check_password_hash, generate_password_hash
from flask_cors import CORS
app = Flask(__name__)
CORS(app, supports_credentials=True)  # Enable credentials for session cookies
app.secret_key = 'spello_secret_key'  # Required for session management


# path to the downloaded model
MODEL_PATH = "vosk-model-small-en-us-0.15"

# Load Vosk Model
if not os.path.exists(MODEL_PATH):
    raise ValueError("Model not found! Please download and extract it.")

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
    selected_sounds = request.args.get('sounds', '').lower().split(',')

    # Get email from session instead of from query parameters
    email = session.get('user_email')

    if not email:
        return jsonify({"error": "User not logged in. Please log in first."}), 401

    # Retrieve custom words from the user's profile
    user = collection.find_one({"email": email})
    if not user:
        return jsonify({"error": "User not found"}), 404

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


# API Endpoint to receive audio
@app.route('/speech-to-text', methods=['POST'])
def speech_to_text():
    # Check if user is logged in
    email = session.get('user_email')
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
MONGO_URI = "mongodb+srv://spello:spello100@spellodb.8zvmy.mongodb.net/?retryWrites=true&w=majority&appName=spelloDB"


# connect to mongoDB
client = MongoClient(MONGO_URI)
db = client["spello_database"]  # added database name
collection = db["sp1"]  # added collection name


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
        'scores': []
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


# Route to delete the last inserted user
@app.route("/delete_last_user", methods=["DELETE"])
def delete_last_user():
    # Find the last inserted user
    # Note: This assumes your MongoDB documents have a natural insertion order
    # For a more reliable approach, you might want to add a timestamp field
    last_user = collection.find_one({}, sort=[("_id", -1)])

    if not last_user:
        return jsonify({"error": "No users found in the database"}), 404

    # Delete the last user
    result = collection.delete_one({"_id": last_user["_id"]})

    if result.deleted_count == 1:
        return jsonify({
            "message": "Last user deleted successfully",
            "deleted_user": {
                "name": last_user.get("name"),
                "email": last_user.get("email"),
                "age": last_user.get("age"),
                "gender": last_user.get("gender")
            }
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
    # Get email from form data or JSON
    email = request.form.get('email') if request.form else request.json.get('email')

    if not email:
        return jsonify({'error': 'Email is required'}), 400

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

    # Track attempts and lives
    attempts = user.get('attempts', 0) + 1
    lives = user.get('lives', 5)

    if accuracy < 50:
        lives -= 1

    # Check if score exceeds threshold for level up
    if total_score >= 2000 and level == 1:
        level = 2

    # If 5 successful or failed attempts are reached, save the game state and reset lives
    if attempts >= 5 or lives <= 0:
        collection.update_one({'email': email}, {'$set': {
            'total_score': total_score,
            'level': level,
            'attempts': 0,
            'lives': 5,
            'scores': user.get('scores', []) + [
                {'target_word': target_word, 'spoken_word': spoken_word, 'accuracy': accuracy, 'score': score}]}
        })
        # Reset game state: New target word, reset attempts/lives for the next round
        session_data['target_word'] = ''
        session_data['spoken_word'] = ''
        return jsonify({
            'message': 'Game over or successful round. Game reset. New target word is ready.',
            'total_score': total_score,
            'level': level,
            'spoken_word': spoken_word,
            'target_word': target_word,
            'accuracy': accuracy
        })

    # Save progress after each attempt
    collection.update_one({'email': email}, {'$set': {
        'attempts': attempts,
        'lives': lives,
        'total_score': total_score,
        'level': level,
        'scores': user.get('scores', []) + [
            {'target_word': target_word, 'spoken_word': spoken_word, 'accuracy': accuracy, 'score': score}]
    }})

    return jsonify({
        'accuracy': accuracy,
        'score': score,
        'lives': lives,
        'total_score': total_score,
        'level': level,
        'spoken_word': spoken_word,
        'target_word': target_word
    })



if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)