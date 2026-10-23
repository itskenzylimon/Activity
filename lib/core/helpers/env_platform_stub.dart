Future<String> readFile(String path) =>
    Future.error(UnsupportedError('Use loadAsset or loadString on web.'));
Map<String, String> get environment => const {};
