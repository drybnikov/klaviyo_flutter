import 'package:flutter/material.dart';
import 'package:klaviyo_flutter/klaviyo_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// make sure to add keys from your Klaviyo workspace.
  await Klaviyo.instance.initialize(
    'appId',
  );
  runApp(SampleApp());
}

class SampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Klaviyo example app'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton(
              onPressed: () async {
                await Klaviyo.instance.logEvent(
                  '\$successful_payment',
                  {'\$value': 'paymentValue'},
                );
              },
              child: Text('Send Klaviyo SUCCESSFUL_PAYMENT event'),
            ),
            TextButton(
              onPressed: () async {
                final result = await Klaviyo.instance
                    .handlePush({'_k': '', 'body': 'Hey'});
                print('result:$result');
              },
              child: Text('Handle Klaviyo push'),
            )
          ],
        ),
      ),
    );
  }
}
