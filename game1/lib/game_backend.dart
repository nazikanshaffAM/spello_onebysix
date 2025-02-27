import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

class GameBackend {
  /// Function to handle audio upload
  Future<Response> uploadAudio(Request request) async {
    try {
      // Read the request body (audio bytes)
      final bytes = await request.read().expand((element) => element).toList();

      if (bytes.isEmpty) {
        print(" Audio file not received.");
        return Response.badRequest(body: jsonEncode({"error": "Audio file not received"}));
      }

      // Save the audio file in .wav format
      final file = File('uploaded_audio.wav');
      await file.writeAsBytes(bytes);

      print(" Audio received and saved as uploaded_audio.wav");

      // Generate a random integer between 50 - 100
      int randomValue = 50 + Random().nextInt(51);
      print(" Generated value: $randomValue");

      // Return the random value as response
      return Response.ok(jsonEncode({"randomValue": randomValue}),
          headers: {'Content-Type': 'application/json'});
    } catch (e) {
      print(" Error processing request: $e");
      return Response.internalServerError(body: jsonEncode({"error": "Server error"}));
    }
  }

  /// API Routes
  final Router _router = Router();

  /// Initializes backend and starts the server
  Future<void> startServer() async {
    _router.post('/upload-audio', uploadAudio);

    final handler = Pipeline().addMiddleware(logRequests()).addHandler(_router);

    try {
      final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, 8080);
      print(' Server running on http://${server.address.host}:${server.port}');
    } catch (e) {
      print(" Failed to start server: $e");
    }
  }
}
