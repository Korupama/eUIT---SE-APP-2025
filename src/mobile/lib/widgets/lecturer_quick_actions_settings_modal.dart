import 'package:flutter/material.dart';
import '../models/quick_action.dart';
import '../theme/app_theme.dart';

/// Professional Modal Bottom Sheet for Lecturer Quick Actions Customization
/// Based on Material Design 3 and modern UX patterns
class LecturerQuickActionsSettingsModal extends StatefulWidget {
  final List<QuickAction> enabledActions;
  final List<QuickAction> allAvailableActions;
  final Function(List<QuickAction>) onSave;

  const LecturerQuickActionsSettingsModal({
    Key? key,
    required this.enabledActions,
    required this.allAvailableActions,
    required this.onSave,
  }) : super(key: key);

  @override
  State<LecturerQuickActionsSettingsModal> createState() =>
      _LecturerQuickActionsSettingsModalState();
}

class _LecturerQuickActionsSettingsModalState
    extends State<LecturerQuickActionsSettingsModal> {
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
      _orderedActions = List.from(widget.allAvailableActions);
      _enabledActionTypes =
          widget.allAvailableActions.map((a) => a.type).toSet();
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(20),
            ),
          ),

          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tùy chỉnh truy cập nhanh',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Chọn các thao tác bạn muốn hiển thị',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                // Counter Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.bluePrimary.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.bluePrimary.withAlpha(50),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${_enabledActionTypes.length}/${widget.allAvailableActions.length}',
                    style: const TextStyle(
                      color: AppTheme.bluePrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                ...widget.allAvailableActions.map((action) {
                  final isEnabled = _enabledActionTypes.contains(action.type);
                  return Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark
                          ? (isEnabled
                              ? AppTheme.bluePrimary.withAlpha(12)
                              : Colors.white.withAlpha(8))
                          : (isEnabled
                              ? AppTheme.bluePrimary.withAlpha(12)
                              : Colors.grey.shade50),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isEnabled
                            ? AppTheme.bluePrimary.withAlpha(100)
                            : (isDark
                                ? Colors.white.withAlpha(20)
                                : Colors.grey.shade200),
                        width: isEnabled ? 2 : 1,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _toggleAction(action),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              // Icon Container
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: isEnabled
                                      ? AppTheme.bluePrimary.withAlpha(25)
                                      : (isDark
                                          ? Colors.grey.shade800.withAlpha(50)
                                          : Colors.grey.shade100),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isEnabled
                                        ? AppTheme.bluePrimary.withAlpha(50)
                                        : Colors.transparent,
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  _getIconForAction(action.iconName),
                                  color: isEnabled
                                      ? AppTheme.bluePrimary
                                      : (isDark
                                          ? Colors.grey.shade400
                                          : Colors.grey.shade600),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Label
                              Expanded(
                                child: Text(
                                  action.label,
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),

                              // Checkbox
                              Checkbox(
                                value: isEnabled,
                                onChanged: (_) => _toggleAction(action),
                                activeColor: AppTheme.bluePrimary,
                                checkColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),

                // Footer Note
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    '💡 Tip: Chọn tối thiểu 4 thao tác để có trải nghiệm tốt nhất',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? Colors.grey.shade500
                          : Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          // Footer buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withAlpha(5)
                  : Colors.grey.shade50,
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
                // Reset Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: _resetToDefaults,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade700,
                      side: BorderSide(
                        color: isDark
                            ? Colors.grey.shade700
                            : Colors.grey.shade300,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Đặt lại',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Save Button
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.bluePrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shadowColor: AppTheme.bluePrimary.withAlpha(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Lưu thay đổi',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
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

  IconData _getIconForAction(String? iconName) {
    switch (iconName) {
      case 'calendar_today_outlined':
        return Icons.calendar_today_outlined;
      case 'groups_outlined':
        return Icons.groups_outlined;
      case 'edit_document':
        return Icons.edit_document;
      case 'rate_review':
        return Icons.rate_review;
      case 'description_outlined':
        return Icons.description_outlined;
      case 'event_note':
        return Icons.event_note;
      case 'event_busy':
        return Icons.event_busy;
      case 'event_available':
        return Icons.event_available;
      default:
        return Icons.circle_outlined;
    }
  }
}

