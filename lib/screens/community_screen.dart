import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quit_smoke/utils/user_preferences.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  _CommunityScreenState createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  List<Map<String, dynamic>> _posts = [];

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    final response = await Supabase.instance.client
        .from('community_posts')
        .select()
        .order('created_at', ascending: false);
    setState(() {
      _posts = List<Map<String, dynamic>>.from(response);
    });
  }

  Future<void> _createPost(String title, String content) async {
    final userProfile = await UserPreferences.getUserProfile();
    final nickname = userProfile?['nickname'] ?? 'Anonymous';

    await Supabase.instance.client.from('community_posts').insert({
      'title': title,
      'content': content,
      'author_nickname': nickname,
    });

    _loadPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('커뮤니티'),
        backgroundColor: const Color(0xFF2F80ED),
      ),
      body: ListView.builder(
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];
          return ListTile(
            title: Text(post['title']),
            subtitle: Text(post['author_nickname']),
            onTap: () {
              // 게시물 상세 보기 화면으로 이동
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 새 게시물 작성 다이얼로그 표시
          _showCreatePostDialog();
        },
        backgroundColor: const Color(0xFF2F80ED),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreatePostDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('새 게시물 작성'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: '제목'),
              ),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: '내용'),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                _createPost(titleController.text, contentController.text);
                Navigator.pop(context);
              },
              child: const Text('게시'),
            ),
          ],
        );
      },
    );
  }
}
