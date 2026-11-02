
import 'package:flutter/material.dart';
import 'package:firebase_app_update/firebase_app_update.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase App Update Example',
      theme: ThemeData(
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
      ),
      home: const UpdateExamplePage(),
    );
  }
}

class UpdateExamplePage extends StatefulWidget {
  const UpdateExamplePage({super.key});

  @override
  State<UpdateExamplePage> createState() =>
      _UpdateExamplePageState();
}

class _UpdateExamplePageState extends State<UpdateExamplePage> {
  String _status = 'Ready to check for updates';
  bool _checking = false;

  Future<void> _checkUpdate() async {
    setState(() {
      _checking = true;
      _status = 'Checking for updates...';
    });

    try {
      final manager = UpdateManager();
      final result = await manager.checkAndShowUpdate(context);

      if (!mounted) return;

      setState(() {
        _status = result == null
            ? 'Unable to check for updates'
            : switch (result.type) {
          UpdateType.none => 'App is up to date',
          UpdateType.soft =>
          'Optional update: ${result.version}',
          UpdateType.force =>
          'Required update: ${result.version}',
        };
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _status = 'Error: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _checking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Package Demo')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_status, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _checking ? null : _checkUpdate,
                child: Text(
                  _checking ? 'Checking...' : 'Check for Updates',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
