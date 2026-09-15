import 'dart:io';

Future<void> main(List<String> args) async {
  final root = Directory(args.isEmpty ? 'build/web' : args.first);
  final port = args.length > 1 ? int.tryParse(args[1]) ?? 8080 : 8080;
  if (!root.existsSync()) {
    stderr.writeln('Missing ${root.path}. Build the web app first.');
    exitCode = 1;
    return;
  }
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  stdout.writeln('Verify IT is running at http://127.0.0.1:$port');
  await for (final request in server) {
    var path = request.uri.path == '/' ? '/index.html' : request.uri.path;
    path = Uri.decodeComponent(path).replaceAll('..', '');
    final file = File(
      '${root.path}${Platform.pathSeparator}${path.substring(1).replaceAll('/', Platform.pathSeparator)}',
    );
    if (!file.existsSync()) {
      request.response.statusCode = HttpStatus.notFound;
      request.response.write('Not found');
    } else {
      final extension = file.path.split('.').last;
      request.response.headers.contentType = switch (extension) {
        'html' => ContentType.html,
        'css' => ContentType('text', 'css', charset: 'utf-8'),
        'js' => ContentType('text', 'javascript', charset: 'utf-8'),
        'json' || 'map' => ContentType.json,
        _ => ContentType.binary,
      };
      request.response.add(await file.readAsBytes());
    }
    await request.response.close();
  }
}
