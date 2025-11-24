// file: chatbot.dart
import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../utils/app_localizations.dart';

/// Chatbot screen for UIT Assistant
/// - Uses provider for local state
/// - Replace lucide-react icons with Material Icons equivalents:
///   MessageCircle -> Icons.chat_bubble_outline
///   Send -> Icons.send
///   Paperclip -> Icons.attach_file
///   Mic -> Icons.mic
///   MoreVertical -> Icons.more_vert
///   ArrowLeft -> Icons.arrow_back
///
/// To integrate: push this screen or toggle with your bottom nav state.
class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> with TickerProviderStateMixin {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  late ChatbotProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = ChatbotProvider();
    // Add sample messages (5-7 messages)
    _provider.loadSampleConversation();
    _provider.addListener(_onProviderUpdate);
  }

  void _onProviderUpdate() {
    // whenever messages change, scroll to bottom smoothly
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom(animated: true);
      });
    }
  }

  @override
  void dispose() {
    _provider.removeListener(_onProviderUpdate);
    _textController.dispose();
    _scrollController.dispose();
    _provider.dispose();
    super.dispose();
  }

  Future<void> _scrollToBottom({bool animated = false}) async {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position.maxScrollExtent;
    if (animated) {
      await _scrollController.animateTo(
        pos,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(pos);
    }
  }

  void _onSend() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _provider.sendUserMessage(text);
    _textController.clear();
    // Simulate AI response after a short delay with typing indicator
    _provider.setAiTyping(true);
    Future.delayed(const Duration(milliseconds: 900), () async {
      // Keep typing for a bit
      await Future.delayed(const Duration(milliseconds: 800));
      _provider.setAiTyping(false);
      _provider.addAiMessage(_provider.generateAiReply(text));
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChangeNotifierProvider<ChatbotProvider>.value(
      value: _provider,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0A0E27) : null,
        // Bottom navigation included to show active tab; you can tie this to app nav
        //bottomNavigationBar: _BottomNavBar(activeIndex: 1), // 1 => Chatbot
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, loc, isDark),
              const SizedBox(height: 8),
              Expanded(
                child: Stack(
                  children: [
                    // Background (light: gradient, dark: solid)
                    Container(
                      decoration: isDark
                          ? const BoxDecoration(color: Color(0xFF0A0E27))
                          : const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF2F6BFF),
                            Color(0xFFA355F7),
                          ],
                        ),
                      ),
                    ),

                    // Chat content area
                    Column(
                      children: [
                        // Messages area
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(18),
                              topRight: Radius.circular(18),
                            ),
                            child: Container(
                              color: isDark
                                  ? Colors.transparent
                                  : Colors.white.withOpacity(0.06),
                              child: Consumer<ChatbotProvider>(
                                builder: (context, provider, _) {
                                  if (provider.messages.isEmpty && !provider.isAiTyping) {
                                    return _buildEmptyState(isDark, loc);
                                  }

                                  return NotificationListener<ScrollNotification>(
                                    onNotification: (notification) {
                                      // optional: hide keyboard when dragging
                                      if (notification is UserScrollNotification &&
                                          notification.direction != ScrollDirection.idle) {
                                        FocusScope.of(context).unfocus();
                                      }
                                      return false;
                                    },
                                    child: ListView.builder(
                                      controller: _scrollController,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      itemCount: provider.messages.length + (provider.isAiTyping ? 1 : 0),
                                      itemBuilder: (context, index) {
                                        if (provider.isAiTyping && index == provider.messages.length) {
                                          return Align(
                                            alignment: Alignment.centerLeft,
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 8),
                                              child: _AiTypingIndicator(isDark: isDark),
                                            ),
                                          );
                                        }

                                        final msg = provider.messages[index];
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 6),
                                          child: MessageTile(
                                            message: msg,
                                            isDark: isDark,
                                            onLongPress: msg.isUser
                                                ? () => _showMessageOptions(context, msg, provider)
                                                : null,
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),

                        // Suggestion chips
                        Consumer<ChatbotProvider>(
                          builder: (context, provider, _) {
                            return AnimatedOpacity(
                              opacity: 1.0,
                              duration: const Duration(milliseconds: 300),
                              child: Container(
                                color: isDark ? Colors.transparent : Colors.white.withOpacity(0.02),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: provider.suggestions.map((s) {
                                    return ActionChip(
                                      label: Text(s, style: TextStyle(color: isDark ? Colors.white : Colors.white)),
                                      backgroundColor: isDark ? Colors.white12 : Colors.white24,
                                      onPressed: () {
                                        // insert suggestion as message
                                        _textController.text = s;
                                        _textController.selection = TextSelection.fromPosition(TextPosition(offset: s.length));
                                      },
                                    );
                                  }).toList(),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Input area (fixed above bottom nav)
              _buildInputArea(isDark),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildHeader(BuildContext context, AppLocalizations loc, bool isDark) {
    return AppBar(
      backgroundColor: isDark ? Colors.transparent : Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        color: isDark ? Colors.white : Colors.black87,
        onPressed: () {
          Navigator.of(context).maybePop();
        },
      ),
      title: Text(
        'UIT Assistant',
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert),
          color: isDark ? Colors.white : Colors.black87,
          onPressed: () {
            // show options menu
            showModalBottomSheet(
              context: context,
              backgroundColor: isDark ? const Color(0xFF0A0E27) : Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              builder: (_) => SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.delete_outline),
                      title: const Text('Xóa toàn bộ chat'),
                      onTap: () {
                        Provider.of<ChatbotProvider>(context, listen: false).clearMessages();
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text('Giới thiệu UIT Assistant'),
                      onTap: () {
                        Navigator.pop(context);
                        _showIntroDialog(context);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark, AppLocalizations loc) {
    return Center(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Big bot icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: isDark ? Colors.white12 : Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Icon(
                  Icons.smart_toy,
                  size: 64,
                  color: isDark ? Colors.white : Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Xin chào! Mình là UIT Assistant',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bạn có thể hỏi: "Xem lịch học", "Tra cứu điểm", "Thông báo mới"...',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.white70,
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              children: const [
                Chip(label: Text('Xem lịch học')),
                Chip(label: Text('Tra cứu điểm')),
                Chip(label: Text('Thông báo mới')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(bool isDark) {
    final provider = Provider.of<ChatbotProvider>(context, listen: false);

    return Container(
      color: isDark ? const Color(0xFF0A0E27) : Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12), // bottom padding to sit above bottom nav
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Input row
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Attach button
              IconButton(
                onPressed: () {
                  // implement attach -> open file or record voice
                  _showAttachOptions(context);
                },
                icon: Icon(Icons.attach_file, color: isDark ? Colors.white70 : Colors.black54),
              ),

              // Expanded textarea
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 120),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? Colors.white12 : Colors.grey.shade200,
                      ),
                    ),
                    child: Scrollbar(
                      child: TextField(
                        controller: _textController,
                        maxLines: 4,
                        minLines: 1,
                        textInputAction: TextInputAction.newline,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                        decoration: InputDecoration(
                          hintText: 'Hỏi UIT Assistant...',
                          hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black45),
                          border: InputBorder.none,
                        ),
                        onChanged: (_) {
                          setState(() {});
                        },
                        onSubmitted: (_) {
                          // don't send on enter by default since new lines may be desired
                        },
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Send button
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _textController,
                builder: (context, value, child) {
                  final enabled = value.text.trim().isNotEmpty;
                  return GestureDetector(
                    onTap: enabled ? _onSend : null,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: enabled
                            ? const LinearGradient(
                          colors: [Color(0xFF2F6BFF), Color(0xFF60A5FA)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                            : LinearGradient(
                          colors: [Colors.grey.shade300, Colors.grey.shade300],
                        ),
                      ),
                      child: Icon(
                        Icons.send,
                        color: enabled ? Colors.white : Colors.white70,
                        size: 20,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAttachOptions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF0A0E27) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.attach_file),
              title: const Text('Đính kèm tệp'),
              onTap: () {
                Navigator.pop(context);
                // TODO: open file picker
              },
            ),
            ListTile(
              leading: const Icon(Icons.mic),
              title: const Text('Gửi ghi âm'),
              onTap: () {
                Navigator.pop(context);
                // TODO: start voice recording
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMessageOptions(BuildContext context, ChatMessage msg, ChatbotProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.content_copy),
              title: const Text('Sao chép'),
              onTap: () {
                Clipboard.setData(ClipboardData(text: msg.text));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã sao chép')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Xóa'),
              onTap: () {
                provider.deleteMessage(msg.id);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Hủy'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showIntroDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF0A0E27) : Colors.white,
        title: const Text('Giới thiệu UIT Assistant'),
        content: const Text(
            'UIT Assistant giúp sinh viên tra cứu lịch học, điểm, thông báo và nhiều tính năng hỗ trợ khác. Hỏi thử: "Xem lịch học"'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng')),
        ],
      ),
    );
  }
}

/// Simple bottom nav with Chatbot active (index 1)
class _BottomNavBar extends StatelessWidget {
  final int activeIndex;
  const _BottomNavBar({required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final routes = ['/home', '/chatbot', '/account'];
    return BottomNavigationBar(
      currentIndex: activeIndex,
      backgroundColor: isDark ? const Color(0xFF0A0E27) : Colors.white,
      selectedItemColor: const Color(0xFF2F6BFF),
      unselectedItemColor: isDark ? Colors.white70 : Colors.black54,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Trang chủ'),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Hỗ trợ'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Tài khoản'),
      ],
      onTap: (index) {
        // TODO: integrate navigation
        if (index == activeIndex) return; // tránh reload trang hiện tại

        // Trang chủ và chatbot đã có route trong main.dart
        if (index == 0) {
          Navigator.pushReplacementNamed(context, '/home');
        } else if (index == 1) {

        } else {
          // TODO: mở trang tài khoản sau
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Trang tài khoản đang phát triển')),
          );
        }
      },
    );
  }
}

/// Message model
class ChatMessage {
  final String id;
  final String text;
  final DateTime createdAt;
  final bool isUser;
  ChatMessage({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.isUser,
  });
}

/// Provider for chatbot state
class ChatbotProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  bool _isAiTyping = false;
  bool get isAiTyping => _isAiTyping;

  List<String> suggestions = [
    'Xem lịch học',
    'Tra cứu điểm',
    'Thông báo mới',
    'Hướng dẫn đăng ký học phần',
  ];

  bool get isTyping => _isAiTyping;

  void setAiTyping(bool v) {
    _isAiTyping = v;
    notifyListeners();
  }

  void addMessage(ChatMessage msg) {
    _messages.add(msg);
    notifyListeners();
  }

  void addAiMessage(String text) {
    final msg = ChatMessage(
      id: UniqueKey().toString(),
      text: text,
      createdAt: DateTime.now(),
      isUser: false,
    );
    _messages.add(msg);
    notifyListeners();
  }

  void sendUserMessage(String text) {
    final msg = ChatMessage(
      id: UniqueKey().toString(),
      text: text,
      createdAt: DateTime.now(),
      isUser: true,
    );
    _messages.add(msg);
    notifyListeners();
  }

  void deleteMessage(String id) {
    _messages.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }

  String generateAiReply(String userText) {
    // Simple rule-based mock replies for demo purposes
    final t = userText.toLowerCase();
    if (t.contains('lịch') || t.contains('tkb')) {
      return 'Lịch học của bạn: Thứ 2 8:00 - Lập trình, Thứ 4 10:00 - CSDL. Muốn xem chi tiết nào không?';
    } else if (t.contains('điểm') || t.contains('tra cứu')) {
      return 'Điểm học kỳ: Môn Lập trình: 8.5, CSDL: 7.0. Bạn muốn gửi bảng điểm về email không?';
    } else if (t.contains('thông báo')) {
      return 'Có 2 thông báo mới: (1) Nghỉ Lễ 30/4, (2) Nộp học phí trước 10/5.';
    } else if (t.contains('hướng dẫn') || t.contains('đăng ký')) {
      return 'Hướng dẫn đăng ký học phần: Vào hệ thống học vụ -> Đăng ký học phần -> Chọn môn -> Xác nhận.';
    } else {
      return 'Mình chưa rõ lắm. Bạn muốn mình tra cứu thông tin cụ thể nào?';
    }
  }

  void loadSampleConversation() {
    // Add 5-7 sample messages
    _messages.clear();
    _messages.addAll([
      ChatMessage(
          id: UniqueKey().toString(),
          text: 'Xin chào! Mình là UIT Assistant. Mình có thể giúp gì cho bạn hôm nay?',
          createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
          isUser: false),
      ChatMessage(
          id: UniqueKey().toString(),
          text: 'Chào bạn, mình muốn xem lịch học kỳ này.',
          createdAt: DateTime.now().subtract(const Duration(minutes: 11)),
          isUser: true),
      ChatMessage(
          id: UniqueKey().toString(),
          text: 'Bạn học ngành gì và năm mấy? Mình sẽ lấy lịch tương ứng.',
          createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
          isUser: false),
      ChatMessage(
          id: UniqueKey().toString(),
          text: 'Mình học CNTT năm 3.',
          createdAt: DateTime.now().subtract(const Duration(minutes: 9)),
          isUser: true),
      ChatMessage(
          id: UniqueKey().toString(),
          text: 'Đã tìm lịch: Thứ 2 - Lập trình 8:00; Thứ 4 - CSDL 10:00. Muốn thêm nhắc nhở không?',
          createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
          isUser: false),
    ]);
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}

/// Message tile with animations and styling
class MessageTile extends StatefulWidget {
  final ChatMessage message;
  final bool isDark;
  final VoidCallback? onLongPress;
  const MessageTile({required this.message, required this.isDark, this.onLongPress, super.key});

  @override
  State<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.isUser;
    final isDark = widget.isDark;

    final bubble = SizeTransition(
      sizeFactor: CurvedAnimation(parent: _anim, curve: Curves.easeOut),
      axisAlignment: 0.0,
      child: FadeTransition(
        opacity: _anim,
        child: Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isUser
                    ? const Color(0xFF2F6BFF)
                    : (isDark
                    ? Colors.white10
                    : const Color.fromRGBO(47, 107, 255, 0.06)), // ai bubble bg for light
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isUser ? 16 : 6),
                  topRight: Radius.circular(isUser ? 6 : 16),
                  bottomLeft: const Radius.circular(16),
                  bottomRight: const Radius.circular(16),
                ),
                border: isUser
                    ? null
                    : Border.all(
                  color: const Color.fromRGBO(47, 107, 255, 0.3),
                ),
                boxShadow: isDark && isUser
                    ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.message.text,
                    style: TextStyle(
                      color: isUser ? Colors.white : (isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(widget.message.createdAt),
                        style: TextStyle(
                          fontSize: 10,
                          color: isUser ? Colors.white70 : Colors.white60,
                        ),
                      ),
                      if (isUser) const SizedBox(width: 6),
                      if (isUser)
                        Icon(
                          Icons.check,
                          size: 12,
                          color: Colors.white70,
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

    return GestureDetector(
      onLongPress: widget.onLongPress,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nếu AI (bên trái): avatar rồi bubble
          if (!widget.message.isUser) ...[
            Padding(
              padding: const EdgeInsets.only(right: 8, left: 4),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: widget.isDark ? Colors.white12 : Colors.white,
                child: Icon(Icons.smart_toy, color: widget.isDark ? Colors.white : const Color(0xFF2F6BFF)),
              ),
            ),
            // Bắt buộc Expanded để bubble không overflow
            Expanded(child: bubble),
          ] else ...[
            // Nếu user (bên phải): bubble rồi avatar
            Expanded(child: bubble),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 4),
              child: CircleAvatar(
                radius: 18,
                child: Icon(Icons.person),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

/// Typing indicator (3 dots)
class _AiTypingIndicator extends StatefulWidget {
  final bool isDark;
  const _AiTypingIndicator({required this.isDark, super.key});

  @override
  State<_AiTypingIndicator> createState() => _AiTypingIndicatorState();
}

class _AiTypingIndicatorState extends State<_AiTypingIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _dot1;
  late final Animation<double> _dot2;
  late final Animation<double> _dot3;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
    _dot1 = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.2, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.2), weight: 50),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.66, curve: Curves.easeInOut)));
    _dot2 = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.2, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.2), weight: 50),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.16, 0.82, curve: Curves.easeInOut)));
    _dot3 = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.2, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.2), weight: 50),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.32, 1.0, curve: Curves.easeInOut)));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.isDark ? Colors.white12 : Colors.white.withOpacity(0.08);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(radius: 12, child: Icon(Icons.smart_toy, size: 14)),
          const SizedBox(width: 8),
          SizedBox(
            width: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                FadeTransition(opacity: _dot1, child: _dot()),
                FadeTransition(opacity: _dot2, child: _dot()),
                FadeTransition(opacity: _dot3, child: _dot()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot() => Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle));
}
