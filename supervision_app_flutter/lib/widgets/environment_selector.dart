import 'package:flutter/material.dart';
import '../config/app_config.dart';

class EnvironmentSelector extends StatefulWidget {
  final Widget child;
  
  const EnvironmentSelector({
    super.key,
    required this.child,
  });

  @override
  State<EnvironmentSelector> createState() => _EnvironmentSelectorState();
}

class _EnvironmentSelectorState extends State<EnvironmentSelector> {
  AppEnvironment? _selectedEnvironment;
  bool _showSelector = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          widget.child,
          if (_showSelector)
            Positioned(
              top: 50,
              right: 16,
              child: Card(
                elevation: 8,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  width: 280,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'API Environment',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                _showSelector = false;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Current: ${AppConfigExtension.effectiveBaseUrl}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ...AppEnvironment.values.map((env) {
                        return RadioListTile<AppEnvironment>(
                          title: Text(_getEnvironmentName(env)),
                          subtitle: Text(
                            AppConfig.getBaseUrlForEnvironment(env),
                            style: const TextStyle(fontSize: 11),
                          ),
                          value: env,
                          groupValue: _selectedEnvironment,
                          onChanged: (value) {
                            setState(() {
                              _selectedEnvironment = value;
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                        );
                      }),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _selectedEnvironment != null
                                  ? () {
                                      AppConfigExtension.setBaseUrlOverride(
                                        AppConfig.getBaseUrlForEnvironment(_selectedEnvironment!),
                                      );
                                      setState(() {
                                        _showSelector = false;
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Switched to ${_getEnvironmentName(_selectedEnvironment!)}',
                                          ),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  : null,
                              child: const Text('Apply'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                AppConfigExtension.setBaseUrlOverride(null);
                                setState(() {
                                  _selectedEnvironment = null;
                                  _showSelector = false;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Reset to auto-detect'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: const Text('Auto'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        mini: true,
        onPressed: () {
          setState(() {
            _showSelector = !_showSelector;
          });
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.settings_ethernet, size: 16),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
    );
  }

  String _getEnvironmentName(AppEnvironment env) {
    switch (env) {
      case AppEnvironment.realDevice:
        return 'Real Device';
      case AppEnvironment.androidEmulator:
        return 'Android Emulator';
      case AppEnvironment.localhost:
        return 'Localhost';
    }
  }
}
