import 'package:flutter/material.dart';
import 'package:klaviyo_flutter/klaviyo_flutter.dart';

void main() {
  runApp(const SampleApp());
}

class SampleApp extends StatelessWidget {
  const SampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends StatefulWidget {
  const ExampleHomePage({super.key});

  @override
  State<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage> {
  final _apiKeyController =
      TextEditingController(text: 'YOUR_KLAVIYO_PUBLIC_API_KEY');
  final _emailController = TextEditingController(text: 'mobile@example.com');
  final _externalIdController = TextEditingController(text: 'user-42');
  final _phoneController = TextEditingController(text: '+15555550123');
  final _tokenController = TextEditingController(text: 'demo-token');
  final List<String> _log = <String>[];

  bool _isRunning = false;

  bool get _isInitialized => Klaviyo.instance.isInitialized;

  @override
  void dispose() {
    _apiKeyController.dispose();
    _emailController.dispose();
    _externalIdController.dispose();
    _phoneController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _initializeSdk() async {
    await _run('Initialize SDK', () async {
      await Klaviyo.instance.initialize(_apiKeyController.text.trim());
    });
  }

  Future<void> _identifyProfileBulk() async {
    await _run('Bulk profile update', () async {
      final profile = KlaviyoProfile(
        id: _externalIdController.text.trim().isEmpty
            ? null
            : _externalIdController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        city: 'Berlin',
        country: 'Germany',
        zip: '10117',
        timezone: 'Europe/Berlin',
        latitude: 52.520008,
        longitude: 13.404954,
        properties: {
          'app_version': 'example-1.0.0',
        },
      );
      await Klaviyo.instance.updateProfile(profile);
    });
  }

  Future<void> _identifyProfileIncremental() async {
    await _run('Individual profile setters', () async {
      await Klaviyo.instance.setFirstName('Ada');
      await Klaviyo.instance.setLastName('Lovelace');
      await Klaviyo.instance.setOrganization('Analytical Engine Co.');
      await Klaviyo.instance.setCity('London');
    });
  }

  Future<void> _logPurchaseEvent() async {
    await _run('Log \$successful_payment event', () async {
      await Klaviyo.instance.logEvent('\$successful_payment', {
        '\$value': 42.0,
        'currency': 'USD',
        'source': 'example_app',
      });
    });
  }

  Future<void> _sendPushToken() async {
    await _run('Register push token', () async {
      await Klaviyo.instance.sendTokenToKlaviyo(_tokenController.text.trim());
    });
  }

  Future<void> _simulatePushOpen() async {
    await _run('Handle push payload', () async {
      final opened = await Klaviyo.instance.handlePush({
        '_k': 'mock-klaviyo-marker',
        'body': 'Hello from Klaviyo',
      });
      _appendLog('Push handled: $opened');
    });
  }

  Future<void> _setBadgeCount() async {
    await _run('Set badge count', () async {
      await Klaviyo.instance.setBadgeCount(3);
    });
  }

  Future<void> _resetProfile() async {
    await _run('Reset profile', () async {
      await Klaviyo.instance.resetProfile();
    });
  }

  Future<void> _fetchIdentifiers() async {
    await _run('Fetch profile identifiers', () async {
      final externalId = await Klaviyo.instance.getExternalId();
      final email = await Klaviyo.instance.getEmail();
      final phone = await Klaviyo.instance.getPhoneNumber();
      _appendLog('Current profile => id:$externalId email:$email phone:$phone');
    });
  }

  Future<void> _run(String label, Future<void> Function() operation) async {
    if (_isRunning) return;
    setState(() {
      _isRunning = true;
    });
    try {
      await operation();
      _appendLog('$label succeeded');
    } catch (error, stackTrace) {
      _appendLog('$label failed: $error');
      // ignore: avoid_print
      print(stackTrace);
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }

  void _appendLog(String message) {
    setState(() {
      _log.insert(0, '${DateTime.now().toIso8601String()} • $message');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Klaviyo Flutter Example'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                _isInitialized ? 'Initialized' : 'Not initialized',
                style: TextStyle(
                  color: _isInitialized ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _Section(
              title: 'Setup',
              children: [
                TextField(
                  controller: _apiKeyController,
                  decoration: const InputDecoration(
                    labelText: 'Public API key',
                    helperText: 'Found in Klaviyo dashboard',
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _isRunning ? null : _initializeSdk,
                  child: const Text('Initialize SDK'),
                ),
              ],
            ),
            _Section(
              title: 'Profile identification',
              children: [
                TextField(
                  controller: _externalIdController,
                  decoration: const InputDecoration(labelText: 'External ID'),
                ),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: _phoneController,
                  decoration:
                      const InputDecoration(labelText: 'Phone (+E.164)'),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: _isRunning || !_isInitialized
                          ? null
                          : _identifyProfileBulk,
                      child: const Text('Bulk update (KlaviyoProfile)'),
                    ),
                    OutlinedButton(
                      onPressed: _isRunning || !_isInitialized
                          ? null
                          : _identifyProfileIncremental,
                      child: const Text('Individual setters'),
                    ),
                    OutlinedButton(
                      onPressed: _isRunning || !_isInitialized
                          ? null
                          : _fetchIdentifiers,
                      child: const Text('Fetch identifiers'),
                    ),
                  ],
                ),
              ],
            ),
            _Section(
              title: 'Events',
              children: [
                ElevatedButton(
                  onPressed:
                      _isRunning || !_isInitialized ? null : _logPurchaseEvent,
                  child: const Text('Log \$successful_payment event'),
                ),
              ],
            ),
            _Section(
              title: 'Push & notifications',
              children: [
                TextField(
                  controller: _tokenController,
                  decoration: const InputDecoration(labelText: 'Push token'),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed:
                          _isRunning || !_isInitialized ? null : _sendPushToken,
                      child: const Text('Register push token'),
                    ),
                    OutlinedButton(
                      onPressed: _isRunning || !_isInitialized
                          ? null
                          : _simulatePushOpen,
                      child: const Text('Handle push payload'),
                    ),
                    OutlinedButton(
                      onPressed:
                          _isRunning || !_isInitialized ? null : _setBadgeCount,
                      child: const Text('Set badge count (iOS)'),
                    ),
                  ],
                ),
              ],
            ),
            _Section(
              title: 'Session management',
              children: [
                ElevatedButton(
                  onPressed:
                      _isRunning || !_isInitialized ? null : _resetProfile,
                  child: const Text('Reset profile'),
                ),
              ],
            ),
            _Section(
              title: 'Log output',
              children: [
                Container(
                  height: 220,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _log.isEmpty
                      ? const Center(child: Text('No events yet'))
                      : ListView.builder(
                          reverse: true,
                          itemCount: _log.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              dense: true,
                              title: Text(_log[index]),
                            );
                          },
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}
