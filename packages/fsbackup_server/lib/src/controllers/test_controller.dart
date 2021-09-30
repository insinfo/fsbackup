// import 'dart:async' show Future;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';
import '../cors.dart';
// import 'package:shelf/shelf_io.dart' as shelf_io;

class TestController {
  // By exposing a [Router] for an object, it can be mounted in other routers.
  Router get router {
    final router = Router();

    // get request to "/test"
    router.get('/', (Request req) {
      return Response.ok("The Test Controller", headers: cors);
    });

    // get request to "/test/<param>?query=????"
    router.get('/<param>', (Request req, String param) {
      print(req.url.queryParameters["query"]); // acessing a url query
      return Response.ok(param, headers: cors);
    });

    // catch all for "/test"
    router.all('/<ignored|.*>', (Request request) => Response.notFound('null'));

    return router;
  }
}
