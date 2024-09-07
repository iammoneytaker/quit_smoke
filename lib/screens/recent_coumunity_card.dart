import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quitSmoke/theme/app_theme.dart';
import 'package:quitSmoke/screens/community_screen.dart';

class RecentMessagesCard extends StatefulWidget {
  const RecentMessagesCard({super.key});

  @override
  _RecentMessagesCardState createState() => _RecentMessagesCardState();
}

class _RecentMessagesCardState extends State<RecentMessagesCard> {
  List<Map<String, dynamic>> _recentMessages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentMessages();
  }

  Future<void> _loadRecentMessages() async {
    final response = await Supabase.instance.client
        .from('messages')
        .select()
        .order('created_at', ascending: false)
        .limit(2)
        .execute();

    if (response.data != null) {
      setState(() {
        _recentMessages = List<Map<String, dynamic>>.from(response.data);
        _isLoading = false;
      });
    }
  }

  void _navigateToCommunityScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CommunityScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _navigateToCommunityScreen,
      child: Card(
        color: AppTheme.cardColor,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '최근 커뮤니티 글',
                style: TextStyle(color: AppTheme.textColor, fontSize: 18),
              ),
              const SizedBox(height: 8),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _recentMessages.isEmpty
                      ? const Text(
                          '최근 글이 없습니다.',
                          style: TextStyle(
                              color: AppTheme.subtleTextColor, fontSize: 14),
                        )
                      : Column(
                          children: _recentMessages.map((message) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message['content'],
                                    style: const TextStyle(
                                        color: AppTheme.textColor,
                                        fontSize: 16),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '작성자: ${message['nickname']}',
                                    style: const TextStyle(
                                        color: AppTheme.subtleTextColor,
                                        fontSize: 14),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerRight,
                child: Icon(Icons.arrow_forward, color: AppTheme.textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
