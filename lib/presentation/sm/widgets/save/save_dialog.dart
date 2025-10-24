import 'package:flutter/material.dart';

class SaveDialog extends StatefulWidget {
  final dynamic save;
  const SaveDialog({this.save});

  @override
  State<SaveDialog> createState() => _SaveDialogState();
}

class _SaveDialogState extends State<SaveDialog> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.save != null) {
      _nameController.text = widget.save.name;
      _descController.text = widget.save.description ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.save != null ? 'Modifier la sauvegarde' : 'Nouvelle sauvegarde'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nom')),
          TextField(controller: _descController, decoration: const InputDecoration(labelText: 'Description')),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, {
            'name': _nameController.text,
            'description': _descController.text,
          }),
          child: const Text('Valider'),
        ),
      ],
    );
  }
}
