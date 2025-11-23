class QuickAction {
  final String label;
  final String type; // could be used for navigation key
  final String? textIcon;
  final String? iconName; // store icon name, resolved in UI
  QuickAction({required this.label, required this.type, this.textIcon, this.iconName});
}

