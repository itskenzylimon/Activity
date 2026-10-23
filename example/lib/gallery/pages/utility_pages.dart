import 'dart:convert';
import 'package:activity/activity.dart';
import 'package:flutter/material.dart';
import '../controllers.dart';
import '../widgets.dart';

class ValidationPage extends StatefulWidget {
  const ValidationPage({super.key});
  @override
  State<ValidationPage> createState() => _ValidationPageState();
}

class _ValidationPageState extends State<ValidationPage> {
  final email = TextEditingController(text: 'itskenzylimon@gmail.com'),
      age = TextEditingController(text: '25'),
      username = TextEditingController(text: 'kenzy'),
      url = TextEditingController(text: 'https://example.com');
  SchemaResponse? result;
  final validator = SchemaValidator(
    {
      'email': {'required': true, 'type': String, 'email': true},
      'age': {'required': true, 'type': int, 'min': 18, 'max': 120},
      'username': {
        'required': true,
        'notEmpty': true,
        'minLength': 3,
        'custom': (dynamic value, Map<String, dynamic> data) =>
            value == 'admin' ? 'This username is reserved.' : null,
      },
      'website': {'url': true},
    },
    allowUnknownKeys: false,
    customErrors: {
      'email.email': 'Enter a valid email address.',
      'age.type': 'Age must be a whole number.',
      'age.min': 'You must be at least 18.',
    },
  );
  void validate() {
    final output = validator.validate({
      'email': email.text,
      'age': int.tryParse(age.text) ?? age.text,
      'username': username.text,
      'website': url.text,
      'undeclared': 'This key is omitted.',
    });
    setState(() => result = output);
    GalleryScope.of(context).console.add(
      'Validator',
      output.valid
          ? 'Validation passed; undeclared keys removed.'
          : 'Validation failed; ${output.errors.length} field(s); payload omitted',
      error: !output.valid,
    );
  }

  @override
  void dispose() {
    email.dispose();
    age.dispose();
    username.dispose();
    url.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GalleryPage(
    'validation',
    children: [
      DemoCard(
        title: 'Validate a real payload',
        description:
            'Try an invalid email, age under 18, username “admin”, or relative website URL.',
        code:
            "final validator = SchemaValidator({\n  'email': {'required': true, 'email': true},\n  'age': {'type': int, 'min': 18},\n  'username': {'custom': (value, data) =>\n    value == 'admin' ? 'Reserved' : null},\n}, allowUnknownKeys: false);\nfinal result = validator.validate(payload);",
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ResponsivePair(
              first: TextField(
                key: const ValueKey('validator-email'),
                controller: email,
                decoration: InputDecoration(
                  labelText: 'Email',
                  errorText: result?.errors['email'],
                ),
              ),
              second: TextField(
                controller: age,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Age',
                  errorText: result?.errors['age'],
                ),
              ),
            ),
            const SizedBox(height: 18),
            ResponsivePair(
              first: TextField(
                controller: username,
                decoration: InputDecoration(
                  labelText: 'Username',
                  errorText: result?.errors['username'],
                ),
              ),
              second: TextField(
                controller: url,
                decoration: InputDecoration(
                  labelText: 'Website',
                  errorText: result?.errors['website'],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  key: const ValueKey('validate-payload'),
                  onPressed: validate,
                  child: const Text('Validate payload'),
                ),
                TextButton(
                  onPressed: () {
                    email.text = 'not-an-email';
                    age.text = '15';
                    username.text = 'admin';
                    url.text = '/relative';
                    validate();
                  },
                  child: const Text('Fill invalid example'),
                ),
                TextButton(
                  onPressed: () {
                    email.text = 'itskenzylimon@gmail.com';
                    age.text = '25';
                    username.text = 'Kenzy';
                    url.text = 'https://example.com';
                    setState(() => result = null);
                  },
                  child: const Text('Reset form'),
                ),
              ],
            ),
            if (result != null) ...[
              const SizedBox(height: 20),
              Pill(
                result!.valid
                    ? 'Valid payload'
                    : '${result!.errors.length} validation errors',
                color: result!.valid ? Colors.green : Colors.red,
              ),
              const SizedBox(height: 16),
              CodeBlock(
                const JsonEncoder.withIndent('  ').convert({
                  'valid': result!.valid,
                  'schema': result!.schema,
                  'errors': result!.errors,
                }),
              ),
            ],
          ],
        ),
      ),
      const Guidance(
        doText:
            'Use allowUnknownKeys: false for an allowlist view, return null on successful custom validation, and still validate on the server.',
        dontText:
            'Do not assume a valid URL is reachable, syntactic IP checks prove connectivity, or client validation makes remote writes safe.',
      ),
    ],
  );
}

const envSample = '''# Public client configuration
HOST="example.com" # comments can follow quotes
API_URL=https://\${HOST}/v1
RETRIES=3
FEATURE_ENABLED=yes
TIMEOUT=30s
WELCOME='Hello # Activity'
''';

class SilentEnvLogger implements EnvLogger {
  const SilentEnvLogger();
  @override
  void info(String message) {}
  @override
  void warn(String message) {}
  @override
  void error(String message, [Object? err, StackTrace? st]) {}
}

class EnvironmentPage extends StatefulWidget {
  const EnvironmentPage({super.key});
  @override
  State<EnvironmentPage> createState() => _EnvironmentPageState();
}

class _EnvironmentPageState extends State<EnvironmentPage> {
  final source = TextEditingController(text: envSample);
  String output =
      'Parse the sample to inspect expanded values and typed getters.';
  bool failed = false;
  void inspect(ENVSetup env) => setState(() {
    failed = false;
    output = const JsonEncoder.withIndent('  ').convert({
      'values': env.values,
      'typed': {
        'retries': env.getInt('RETRIES', defaultValue: 0),
        'enabled': env.getBool('FEATURE_ENABLED', defaultValue: false),
        'timeoutSeconds': env
            .getDuration('TIMEOUT', defaultValue: Duration.zero)
            .inSeconds,
        'endpoint': env.getUri('API_URL', defaultValue: Uri()).toString(),
      },
    });
  });
  @override
  void dispose() {
    source.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GalleryPage(
    'environment',
    children: [
      DemoCard(
        title: 'Parse & expand .env text',
        description:
            'Edit this public sample. Typed getters reject invalid present values; defaults only fill missing keys.',
        code:
            "final env = ENVSetup();\nenv.loadString(contents);\nfinal retries = env.getInt('RETRIES', defaultValue: 3);\nfinal enabled = env.getBool('FEATURE_ENABLED');\nfinal timeout = env.getDuration('TIMEOUT');\nfinal endpoint = env.getUri('API_URL');",
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              key: const ValueKey('env-source'),
              controller: source,
              minLines: 7,
              maxLines: 12,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              decoration: const InputDecoration(labelText: 'Environment text'),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  key: const ValueKey('parse-env'),
                  onPressed: () {
                    try {
                      final env = ENVSetup(logger: const SilentEnvLogger());
                      env.loadString(source.text);
                      inspect(env);
                    } catch (error) {
                      setState(() {
                        failed = true;
                        output = error.toString();
                      });
                    }
                  },
                  child: const Text('Parse configuration'),
                ),
                OutlinedButton(
                  onPressed: () async {
                    try {
                      final env = ENVSetup(logger: const SilentEnvLogger());
                      await env.loadAsset('assets/sample.env');
                      if (!mounted) return;
                      inspect(env);
                    } catch (error) {
                      if (mounted) {
                        setState(() {
                          failed = true;
                          output = error.toString();
                        });
                      }
                    }
                  },
                  child: const Text('Load bundled asset'),
                ),
                TextButton(
                  onPressed: () => source.text = envSample,
                  child: const Text('Restore sample'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (failed)
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Pill('Configuration error', color: Colors.red),
              ),
            CodeBlock(output),
          ],
        ),
      ),
      const DemoCard(
        title: 'Platform adapters',
        code:
            "await env.loadAsset('assets/sample.env'); // All Flutter targets\nawait env.loadFile('/path/to/.env'); // Native file systems only\nenv.merge({'RETRIES': '5'}, overrideExisting: true);",
        child: Text(
          'Assets and text parsing work on every Flutter target. Native file/process access is conditionally imported; loadFile warns and does nothing on web. This gallery uses only bundled public sample data.',
        ),
      ),
      const Guidance(
        doText:
            'Use assets, loadString or merge for public application settings. Enforce scheme and host if your endpoint must be absolute.',
        dontText:
            'Do not put production secrets in an app asset or treat a relative URI returned by getUri as an absolute service endpoint.',
      ),
    ],
  );
}

class HelpersPage extends StatefulWidget {
  const HelpersPage({super.key});
  @override
  State<HelpersPage> createState() => _HelpersPageState();
}

class _HelpersPageState extends State<HelpersPage> {
  final text = TextEditingController(text: 'Hello Activity Gallery');
  String uuid = UniqueID.generateUuid();
  @override
  void dispose() {
    text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final input = text.text, c = GalleryScope.of(context).lab;
    return GalleryPage(
      'helpers',
      children: [
        DemoCard(
          title: 'String transformation workbench',
          code:
              "text.camelCase;\ntext.snakeCase;\ntext.kebabCase;\ntext.slugify;\ntext.title();\ntext.reverse;\ntext.isNumeric;",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: text,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Text to transform',
                ),
              ),
              const SizedBox(height: 18),
              for (final result in [
                ('camelCase', input.camelCase),
                ('PascalCase', input.pascalCase),
                ('snake_case', input.snakeCase),
                ('kebab-case', input.kebabCase),
                ('slugify', input.slugify),
                ('Title', input.title()),
                ('Reverse (code points)', input.reverse),
                (
                  'Numeric / alphabetic',
                  '${input.isNumeric} / ${input.isAlpha}',
                ),
              ])
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 130,
                        child: Text(
                          result.$1,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SelectableText(
                          result.$2,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        DemoCard(
          title: 'Fresh UUIDs',
          description:
              'Each press generates a new cryptographically random version 4 identifier.',
          code:
              "final first = UniqueID.generateUuid();\nfinal second = UniqueID.generateUuid();\n// Generated afresh for every call.",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(
                uuid,
                key: const ValueKey('generated-uuid'),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 15),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => setState(() => uuid = UniqueID.generateUuid()),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Generate UUID'),
              ),
            ],
          ),
        ),
        DemoCard(
          title: 'Date & duration helpers',
          code:
              "date.addDuration(Duration(days: 1));\nfinal day = date.startOfDay;\ndate(day);\nfinal sameDay = date.isSameDay(other);",
          child: ActivitySelector<PlaygroundController, DateTime>(
            controller: c,
            select: (c) => c.date.value,
            builder: (_, date, child) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date.toIso8601String(),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(date.isUtc ? 'UTC date' : 'Local date'),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.tonal(
                      onPressed: () =>
                          c.date.addDuration(const Duration(days: 1)),
                      child: const Text('Add one day'),
                    ),
                    OutlinedButton(
                      onPressed: () => c.date(c.date.startOfDay),
                      child: const Text('Start of day'),
                    ),
                    TextButton(
                      onPressed: c.date.reset,
                      child: const Text('Reset date'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        DemoCard(
          title: 'Logging levels',
          description:
              'The console shows the demonstration entry; Logger also emits using its configured output policy.',
          code:
              "final logger = Logger(printInRelease: false);\nlogger.info('Ready');\nlogger.warn('Review this state');\nlogger.error('Operation failed');",
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final level in [
                LogLevel.info,
                LogLevel.warn,
                LogLevel.error,
                LogLevel.success,
              ])
                OutlinedButton(
                  onPressed: () {
                    Logger(
                      enabled: true,
                      enableColors: false,
                      printInRelease: false,
                    ).log(level, 'Gallery ${level.name} example');
                    GalleryScope.of(context).console.add(
                      'Logger',
                      '${level.name}: gallery example',
                      error: level == LogLevel.error,
                    );
                    showConsole(context);
                  },
                  child: Text('Log ${level.name}'),
                ),
            ],
          ),
        ),
        const Guidance(
          doText:
              'Use immutable data and document UTC/local semantics. Use explicit value comparisons and suitable formatting for your domain.',
          dontText:
              'Do not treat code-point string helpers as grapheme segmentation or assume adding 24 hours always means the next local calendar day.',
        ),
      ],
    );
  }
}
