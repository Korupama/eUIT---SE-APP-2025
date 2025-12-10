import 'package:flutter/material.dart';
import '../models/quick_action.dart';
import '../theme/app_theme.dart';
import '../utils/app_localizations.dart';

class QuickActionsSettingsModal extends StatefulWidget {
  final List<QuickAction> enabledActions;
  final List<QuickAction> allAvailableActions;
  final Function(List<QuickAction>) onSave;

  const QuickActionsSettingsModal({
    Key? key,
    required this.enabledActions,
    required this.allAvailableActions,
    required this.onSave,
  }) : super(key: key);

  @override
  State<QuickActionsSettingsModal> createState() =>
      _QuickActionsSettingsModalState();
}

class _QuickActionsSettingsModalState extends State<QuickActionsSettingsModal> {
  late List<QuickAction> _orderedActions;
  late Set<String> _enabledActionTypes;

  @override
  void initState() {
    super.initState();
    _orderedActions = List.from(widget.enabledActions);
    _enabledActionTypes = widget.enabledActions.map((a) => a.type).toSet();
  }

  void _toggleAction(QuickAction action) {
    setState(() {
      if (_enabledActionTypes.contains(action.type)) {
        _enabledActionTypes.remove(action.type);
        _orderedActions.removeWhere((a) => a.type == action.type);
      } else {
        _enabledActionTypes.add(action.type);
        _orderedActions.add(action);
      }
    });
  }

  void _resetToDefaults() {
    setState(() {
      _orderedActions = List.from(widget.enabledActions);
      _enabledActionTypes = widget.enabledActions.map((a) => a.type).toSet();
    });
  }

  void _save() {
    widget.onSave(_orderedActions);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0E27) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark
                      ? Colors.white.withAlpha(13)
                      : Colors.grey.shade200,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tùy chỉnh thao tác nhanh',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Chọn những thao tác bạn muốn hiển thị',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 16),

                // Available actions
                ...widget.allAvailableActions.map((action) {
                  final isEnabled = _enabledActionTypes.contains(action.type);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withAlpha(13)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isEnabled
                            ? AppTheme.bluePrimary
                            : (isDark
                                  ? Colors.white.withAlpha(26)
                                  : Colors.grey.shade300),
                        width: isEnabled ? 2 : 1,
                      ),
                    ),
                    child: CheckboxListTile(
                      value: isEnabled,
                      onChanged: (_) => _toggleAction(action),
                      title: Text(
                        AppLocalizations.of(context).t(action.label),
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      secondary: _getIconForAction(action.iconName),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      activeColor: AppTheme.bluePrimary,
                      checkColor: Colors.white,
                    ),
                  );
                }).toList(),

                const SizedBox(height: 24),
                Text(
                  'Kéo để sắp xếp thứ tự (tính năng đang phát triển)',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),

          // Footer buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? Colors.white.withAlpha(13)
                      : Colors.grey.shade200,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _resetToDefaults,
                    style: TextButton.styleFrom(
                      foregroundColor: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                    child: const Text('Khôi phục mặc định'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.bluePrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Lưu',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getIconForAction(String? iconName) {
    IconData? icon;
    switch (iconName) {
      case 'school_outlined':
        icon = Icons.school_outlined;
        break;
      case 'calendar_today_outlined':
        icon = Icons.calendar_today_outlined;
        break;
      case 'monetization_on_outlined':
        icon = Icons.monetization_on_outlined;
        break;
      case 'edit_document':
        icon = Icons.edit_document;
        break;
      case 'check_box_outlined':
        icon = Icons.check_box_outlined;
        break;
      case 'description_outlined':
        icon = Icons.description_outlined;
        break;
      case 'workspace_premium_outlined':
        icon = Icons.workspace_premium_outlined;
        break;
      default:
        icon = Icons.circle_outlined;
    }
    return Icon(icon, color: AppTheme.bluePrimary, size: 24);
  }
}
