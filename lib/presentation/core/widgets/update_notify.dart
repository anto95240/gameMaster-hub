import 'package:flutter/material.dart';
import 'dart:html' as html;

class UpdateNotifier extends StatefulWidget {
  final Widget child;
  
  const UpdateNotifier({Key? key, required this.child}) : super(key: key);

  @override
  State<UpdateNotifier> createState() => _UpdateNotifierState();
}

class _UpdateNotifierState extends State<UpdateNotifier> {
  bool _updateAvailable = false;

  @override
  void initState() {
    super.initState();
    _setupServiceWorkerListener();
  }

  void _setupServiceWorkerListener() {
    // Écoute les messages du service worker
    html.window.navigator.serviceWorker?.addEventListener('message', (event) {
      final messageEvent = event as html.MessageEvent;
      final data = messageEvent.data;
      
      if (data is Map && data['type'] == 'NEW_VERSION_AVAILABLE') {
        setState(() {
          _updateAvailable = true;
        });
      }
    });
  }

  void _reloadApp() {
    html.window.location.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_updateAvailable)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(8),
              color: Colors.blue.shade700,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.system_update,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Nouvelle version disponible !',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Rechargez pour profiter des nouveautés',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _reloadApp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue.shade700,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Recharger'),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _updateAvailable = false;
                        });
                      },
                      icon: const Icon(Icons.close, color: Colors.white),
                      tooltip: 'Plus tard',
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}