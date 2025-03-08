import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

class GameBackend {
  /// Function to handle audio upload
  String getWritablePath() {
    final directory = Directory.systemTemp;
    return '${directory.path}/uploaded_audio.wav';
  }

  Future<Response> uploadAudio(Request request) async {
    try {
      final bytes = await request.read().expand((element) => element).toList();

      if (bytes.isEmpty) {
        print(" Audio file not received.");
        return Response.badRequest(body: jsonEncode({"error": "Audio file not received"}));
      }

      // Save to a writable directory
      final filePath = getWritablePath();
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      print(" Audio received and saved at: $filePath");

      int randomValue = 50 + Random().nextInt(51);
      print(" Generated value: $randomValue");

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

    final handler = Pipeline().addMiddleware(logRequests()).addHandler(_router.call);

    try {
      final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, 8080);
      print(' Server running on http://${server.address.host}:${server.port}');
    } catch (e) {
      print(" Failed to start server: $e");
    }
  }
}
