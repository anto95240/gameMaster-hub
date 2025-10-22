import 'package:flutter/material.dart';

import 'package:gamemaster_hub/presentation/sm/widgets/add_player_dialog/player_form_fields.dart';
import 'package:gamemaster_hub/presentation/sm/widgets/add_player_dialog/player_submit_handler.dart';

class AddPlayerDialog extends StatefulWidget {
  final int saveId; // ← ajouté

  const AddPlayerDialog({super.key, required this.saveId});

  @override
  State<AddPlayerDialog> createState() => _AddPlayerDialogState();
}

class _AddPlayerDialogState extends State<AddPlayerDialog> {
  final _formKey = GlobalKey<FormState>();
  final PlayerFormData formData = PlayerFormData();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final dialogWidth = width * 0.95;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: dialogWidth,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Ajouter un joueur", style: TextStyle(fontSize: 22)),
                  const SizedBox(height: 16),
                  PlayerFormFields(formData: formData),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Annuler"),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => handlePlayerSubmit(
                          context,
                          _formKey,
                          formData,
                          widget.saveId, // ← ajouté
                        ),
                        child: const Text("Ajouter"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
