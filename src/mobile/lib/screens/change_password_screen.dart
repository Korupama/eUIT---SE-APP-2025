import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    // Mock success
    if (!mounted) return;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mật khẩu đã được đổi.')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.darkBackground : const Color(0xFFF7F8FC);
    final card = isDark ? AppTheme.darkCard : AppTheme.lightCard;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đổi mật khẩu'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: bg,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _oldCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Mật khẩu cũ'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập mật khẩu cũ' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _newCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Mật khẩu mới'),
                  validator: (v) => (v == null || v.length < 6) ? 'Mật khẩu phải có ít nhất 6 ký tự' : null,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator()) : const Text('Đổi mật khẩu'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

