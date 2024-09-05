import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quit_smoke/utils/user_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quit_smoke/theme/app_theme.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  _CommunityScreenState createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();

  Timer? _debounce;
  bool _isSending = false;

  final int _limit = 20;
  int _offset = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  int? _replyToId;
  final Map<int, bool> _expandedReplies = {};

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      _loadMessages();
    }
  }

  Future<void> _refreshMessages() async {
    setState(() {
      _offset = 0;
      _hasMore = true;
    });
    await _loadMessages();
  }

  Future<void> _loadMessages() async {
    if (_isLoading || !_hasMore) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await Supabase.instance.client
          .from('messages')
          .select('''
          *,
          replies:messages!parent_id(
            id,
            content,
            created_at,
            nickname,
            user_id
          )
        ''')
          .is_('parent_id', null)
          .order('created_at', ascending: false)
          .range(_offset, _offset + _limit - 1)
          .execute();

      if (response.data != null) {
        final List<Map<String, dynamic>> newMessages =
            List<Map<String, dynamic>>.from(response.data);
        setState(() {
          if (_offset == 0) {
            _messages = newMessages;
          } else {
            _messages.addAll(newMessages);
          }
          _offset += newMessages.length;
          _hasMore = newMessages.length == _limit;
        });
      } else {
        _showErrorSnackBar('데이터가 존재하지 않습니다.');
      }
    } catch (e) {
      print('Error loading messages: $e');
      _showErrorSnackBar('메시지 로딩 실패: 네트워크 연결을 확인해주세요.또는 잠시 후 시도해주세요.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: '다시 시도',
          onPressed: _refreshMessages,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('커뮤니티'),
        backgroundColor: AppTheme.backgroundColor,
        foregroundColor: AppTheme.textColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshMessages,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length + (_hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < _messages.length) {
                  return _buildMessageItem(_messages[index]);
                } else if (_hasMore) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageItem(Map<String, dynamic> message) {
    final replies = message['replies'] as List<dynamic>? ?? [];
    final isExpanded = _expandedReplies[message['id'] as int] ?? false;
    final visibleReplies = isExpanded ? replies : replies.take(2).toList();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: AppTheme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${message['nickname'] ?? 'Anonymous'}#${message['user_id']?.toString().substring(0, 4) ?? ''}',
              style: const TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message['content'] ?? '',
              style: const TextStyle(color: AppTheme.textColor, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              DateTime.parse(
                      message['created_at'] ?? DateTime.now().toIso8601String())
                  .toString()
                  .split('.')[0],
              style: const TextStyle(
                color: AppTheme.subtleTextColor,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => _replyToMessage(
                  message['nickname'] ?? 'Anonymous',
                  message['user_id'] ?? '',
                  message['id']),
              child: const Text('답글 달기'),
            ),
            if (replies.isNotEmpty) ...[
              const Divider(),
              ...visibleReplies.map((reply) => _buildReplyItem(reply)),
              if (replies.length > 2 && !isExpanded)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _expandedReplies[message['id'] as int] = true;
                    });
                  },
                  child: Text('답글 ${replies.length - 2}개 더 보기'),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReplyItem(Map<String, dynamic> reply) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${reply['nickname'] ?? 'Anonymous'}#${reply['user_id']?.toString().substring(0, 4) ?? ''}',
            style: const TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            reply['content'] ?? '',
            style: const TextStyle(color: AppTheme.textColor, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            DateTime.parse(
                    reply['created_at'] ?? DateTime.now().toIso8601String())
                .toString()
                .split('.')[0],
            style: const TextStyle(
              color: AppTheme.subtleTextColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _replyToMessage(String nickname, String userId, int parentId) {
    setState(() {
      _messageController.text = '@$nickname#${userId.substring(0, 4)} ';
      _messageController.selection = TextSelection.fromPosition(
          TextPosition(offset: _messageController.text.length));
      _replyToId = parentId;
    });
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: AppTheme.cardColor,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: '메시지 입력',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                filled: true,
                fillColor: AppTheme.backgroundColor,
              ),
              style: const TextStyle(color: AppTheme.textColor),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: AppTheme.primaryColor),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!_isSending && _messageController.text.isNotEmpty) {
        _isSending = true;
        _performSend().then((_) {
          _isSending = false;
        });
      }
    });
  }

  Future<void> _performSend() async {
    if (_messageController.text.isNotEmpty) {
      try {
        final userProfile = await UserPreferences.getUserProfile();
        final nickname = userProfile?['nickname'] ?? 'Anonymous';
        final userId = await UserPreferences.getUserId();

        final messageData = {
          'content': _messageController.text,
          'created_at': DateTime.now().toIso8601String(),
          'nickname': nickname,
          'user_id': userId,
        };

        if (_replyToId != null) {
          messageData['parent_id'] = _replyToId;
        }

        await Supabase.instance.client.from('messages').insert(messageData);

        _messageController.clear();
        setState(() {
          _replyToId = null;
        });
        await _refreshMessages();
      } catch (e) {
        print('메시지 전송 중 오류 발생: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('메시지 전송 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.')),
        );
      }
    }
  }
}
