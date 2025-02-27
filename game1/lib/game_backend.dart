import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';

class GameBackend {
  final _router = Router();

  GameBackend() {
    _router.get('/random', _getRandomValue);
  }

  // Generate a random number between 50 and 100
  Response _getRandomValue(Request request) {
    final random = Random();
    int value = 50 + random.nextInt(51); // Range: 50 to 100
    return Response.ok(value.toString()); // Send as response
  }

  // Start the backend server
  Future<void> startServer({int port = 8080}) async {
    final handler = Pipeline().addMiddleware(logRequests()).addHandler(_router);
    final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);
    print('✅ Backend running on http://${server.address.host}:${server.port}');
  }
}
