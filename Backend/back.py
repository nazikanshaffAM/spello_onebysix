import os
import json
import random
import vosk
from rapidfuzz.distance import Levenshtein
from flask import Flask, request, jsonify
from pymongo import MongoClient

app = Flask(__name__)

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

    # If no words match the criteria, use all words
    if not filtered_words:
        filtered_words = list(word_sound_mapping.keys())

    # Choose a random word from the filtered list
    target_word = random.choice(filtered_words)
    session_data['target_word'] = target_word

    return jsonify({
        "target_word": target_word,
        # "contains_sounds": word_sound_mapping[target_word]
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


# add route to store details in the database
@app.route("/store_user", methods=["POST"])
def store_user():
    data = request.json

    # Validate required fields
    required_fields = ["name", "email", "age", "gender", ]
    if not all(field in data for field in required_fields):
        return jsonify({"error": "All fields (name, email, age, gender) are required"}), 400

    user = {
        "name": data["name"],
        "email": data["email"],
        "age": data["age"],
        "gender": data["gender"],
    }

    # Insert user data into the database
    result = collection.insert_one(user)
    user["_id"] = str(result.inserted_id)  # Convert ObjectId to string

    return jsonify({"message": "User data stored successfully!", "user": user})

# Route to get all stored users from the database
@app.route("/get_users", methods=["GET"])
def get_users():
    # Retrieve all users from the database
    users = collection.find({}, {"_id": 0})  # Exclude MongoDB's default "_id" field

    user_list = list(users)  # Convert cursor to a list
    return jsonify({"users": user_list})


#get one user based on email
@app.route("/get_user", methods=["GET"])
def get_user():
    email = request.args.get("email")  # Get email from query parameters

    if not email:
        return jsonify({"error": "Email is required"}), 400

    # Find user by email, exclude MongoDB "_id" field from response
    user = collection.find_one({"email": email}, {"_id": 0})

    if not user:
        return jsonify({"error": "User not found"}), 404

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


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)