import { useState, useEffect } from "react";
import axios from "axios";
import Recorder from "recorder-js";

function App() {
  const [word, setWord] = useState("water bottle");
  const [message, setMessage] = useState("");
  const [accuracy, setAccuracy] = useState(null);
  const [recorder, setRecorder] = useState(null);
  const [isRecording, setIsRecording] = useState(false);

  useEffect(() => {
    navigator.mediaDevices.getUserMedia({ audio: true }).then((stream) => {
      const rec = new Recorder(new AudioContext(), { type: "audio/webm" });
      rec.init(stream);
      setRecorder(rec);
    });
  }, []);

  const startRecording = () => {
    if (recorder) {
      recorder.start();
      setIsRecording(true);
      setMessage("Recording... Speak now!");
    }
  };

  const stopRecording = async () => {
    if (recorder) {
      const { blob } = await recorder.stop();
      setIsRecording(false);
      setMessage("Processing...");

      // Send audio to Flask backend
      const formData = new FormData();
      formData.append("file", blob, "audio.webm");

      try {
        const response = await axios.post("http://127.0.0.1:5000/evaluate", formData, {
          headers: { "Content-Type": "multipart/form-data" },
        });

        setAccuracy(response.data.accuracy);
        if (response.data.accuracy === 100) {
          setMessage("🎉 Perfect! You said it correctly!");
        } else {
          setMessage(`❌ Try again! You said: '${response.data.spoken}'`);
        }
      } catch (error) {
        setMessage("Error processing speech. Try again.");
      }
    }
  };

  return (
    <div className="flex flex-col items-center justify-center h-screen bg-gray-100 text-gray-900">
      <h1 className="text-2xl font-bold mb-4">🎤 Pronounce: "{word}"</h1>
      <button
        onMouseDown={startRecording}
        onMouseUp={stopRecording}
        className={`px-6 py-3 rounded-md text-white ${
          isRecording ? "bg-red-500" : "bg-blue-500"
        } transition duration-300`}
      >
        {isRecording ? "Recording..." : "Hold to Speak"}
      </button>
      {accuracy !== null && <p className="mt-4 text-lg">Accuracy: {accuracy}%</p>}
      <p className="mt-2">{message}</p>
    </div>
  );
}

export default App;
