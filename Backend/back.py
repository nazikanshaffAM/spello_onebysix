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

def get_random_target_word():
    target_word_list = ["Think", "This", "Rabbit", "Lemon", "Snake", "Ship", "Cheese", "Juice", "Zebra", "Violin", "Fish", "Water",
             "Yellow", "Sing", "Tiger", "Dinosaur", "Pencil", "Banana", "Kite", "Goat"]
    random.shuffle(target_word_list)
    return random.choice(target_word_list)

#get one target word from the list
target_word = get_random_target_word()



#API endpoint to send the target word to frontend
@app.route('/get-target-word', methods=['GET'])
def get_target_word():
    return jsonify({"target_word": target_word})




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
    # Get audio data from the request (expecting audio in WAV format)
    audio_file = request.files['audio']

    # Read the audio file
    audio_data = audio_file.read()

    # Process audio with Vosk model
    recognizer.AcceptWaveform(audio_data)
    result = json.loads(recognizer.Result())
    spoken_word = result.get("text", "").strip().capitalize()

    # Calculate accuracy
    accuracy = calculate_accuracy(target_word, spoken_word)

    # Return the accuracy to the client
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



    # Find user by email, exclude MongoDB "_id" field from response
    user = collection.find_one({"email": email}, {"_id": 0})



    return jsonify(user)




if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)