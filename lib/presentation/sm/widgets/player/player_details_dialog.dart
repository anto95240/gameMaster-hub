import 'package:flutter/material.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/joueurs/joueurs_sm_state.dart';
import 'package:gamemaster_hub/presentation/sm/widgets/player/player_info/player_info_header.dart';
import 'package:gamemaster_hub/presentation/sm/widgets/player/player_stats_form.dart';
import 'package:gamemaster_hub/presentation/sm/widgets/player/player_actions.dart';
import 'package:gamemaster_hub/presentation/sm/widgets/player/player_info_form.dart';

class PlayerDetailsDialog extends StatefulWidget {
  final JoueurSmWithStats item;
  final int saveId;

  const PlayerDetailsDialog({
    super.key,
    required this.item,
    required this.saveId,
  });

  @override
  State<PlayerDetailsDialog> createState() => _PlayerDetailsDialogState();
}

class _PlayerDetailsDialogState extends State<PlayerDetailsDialog> {
  bool isEditing = false;
  late GlobalKey<PlayerInfoFormState> _playerInfoFormKey;
  late GlobalKey<PlayerStatsFormState> _playerStatsFormKey;
  late JoueurSmWithStats _currentItem;

  @override
  void initState() {
    super.initState();
    _playerInfoFormKey = GlobalKey<PlayerInfoFormState>();
    _playerStatsFormKey = GlobalKey<PlayerStatsFormState>();
    _currentItem = widget.item;
  }

  void toggleEditing(bool val) => setState(() => isEditing = val);
  
  void onUpdateSuccess() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: screenWidth * 0.9,
        height: screenHeight * 0.9,
        constraints: const BoxConstraints(
          maxWidth: 800,
          maxHeight: 900,
          minWidth: 600,
          minHeight: 500,
        ),
        child: Column(
          children: [
            PlayerInfoHeader(
              item: _currentItem,
              isEditing: isEditing,
              onEditingChanged: toggleEditing,
              nameController: _playerInfoFormKey.currentState?.nameController,
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PlayerInfoForm(
                      key: _playerInfoFormKey,
                      item: _currentItem,
                      isEditing: isEditing,
                      onEditingChanged: toggleEditing,
                    ),
                    const SizedBox(height: 16),
                    PlayerStatsForm(
                      key: _playerStatsFormKey,
                      item: _currentItem,
                      isEditing: isEditing,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            PlayerActions(
              item: _currentItem,
              isEditing: isEditing,
              onCancel: () => toggleEditing(false),
              onEditChanged: toggleEditing,
              saveId: widget.saveId,
              playerInfoFormKey: _playerInfoFormKey,
              playerStatsFormKey: _playerStatsFormKey,
              onUpdateSuccess: onUpdateSuccess,
            ),
          ],
        ),
      ),
    );
  }
}
