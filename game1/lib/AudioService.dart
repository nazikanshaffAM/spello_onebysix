import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'ApiService.dart'; // Import the API service to send the file

class AudioService {
  final AudioRecorder _recorder = AudioRecorder();
  String? _filePath;

  ///  Starts recording and saves as `.wav`
  Future<String?> startRecording() async {
    if (await _recorder.hasPermission()) {
      Directory appDir = await getApplicationDocumentsDirectory();
      String filePath = '${appDir.path}/recorded_audio.wav';

      await _recorder.start(const RecordConfig(
        encoder: AudioEncoder.wav, // Save as .wav
        sampleRate: 16000, // 16kHz sample rate
        numChannels: 1, // Mono audio
      ), path: filePath);

      _filePath = filePath;
      print("🎙 Recording started: $filePath");
      return filePath;
    } else {
      print(" Permission denied for recording.");
      return null;
    }
  }

  ///  Stops recording
  Future<String?> stopRecording() async {
    if (await _recorder.isRecording()) {
      await _recorder.stop();
      print(" Recording stopped. File saved at: $_filePath");
      return _filePath;
    } else {
      print(" No active recording to stop.");
      return null;
    }
  }

  /// 📡 Sends recorded audio to backend
  Future<void> sendAudioToBackend() async {
    if (_filePath != null && File(_filePath!).existsSync()) {
      print(" Sending audio to backend...");
      await ApiService.uploadAudio(_filePath!);
    } else {
      print(" No audio file found to send.");
    }
  }
}
