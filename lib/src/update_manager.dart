import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_update_service.dart';
import 'update_result.dart';

class UpdateManager {
  UpdateManager({AppUpdateService? service})
    : _service = service ?? AppUpdateService();

  final AppUpdateService _service;

  Future<UpdateResult?> checkAndShowUpdate(
    BuildContext context, {
    bool showUpToDateMessage = false,
    bool showErrorMessage = false,
  }) async {
    try {
      final result = await _service.checkForUpdate();

      if (!context.mounted) return result;

      if (result.type == UpdateType.none) {
        if (showUpToDateMessage) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Your app is up to date.')),
          );
        }
        return result;
      }

      await _showUpdateDialog(context, result);
      return result;
    } on UpdateCheckException catch (e) {
      if (showErrorMessage && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to check for updates: $e')),
        );
      }
      return null;
    }
  }

  Future<void> _showUpdateDialog(
    BuildContext context,
    UpdateResult result,
  ) async {
    final isForce = result.type == UpdateType.force;

    await showDialog<void>(
      context: context,
      barrierDismissible: !isForce,
      builder: (dialogContext) {
        return PopScope(
          canPop: !isForce,
          child: AlertDialog(
            title: Text(isForce ? 'Update required' : 'Update available'),
            content: Text(
              result.message.isNotEmpty
                  ? result.message
                  : 'Version ${result.version} is available.',
            ),
            actions: [
              if (!isForce)
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Later'),
                ),
              FilledButton(
                onPressed: () async {
                  final uri = Uri.tryParse(result.storeUrl);

                  if (uri == null ||
                      !uri.hasAuthority ||
                      !{'https', 'http'}.contains(uri.scheme)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('The app store URL is invalid.'),
                      ),
                    );
                    return;
                  }

                  final opened = await launchUrl(
                    uri,
                    mode: LaunchMode.externalApplication,
                  );

                  if (!opened && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Unable to open the app store.'),
                      ),
                    );
                  }
                },
                child: const Text('Update now'),
              ),
            ],
          ),
        );
      },
    );
  }
}
