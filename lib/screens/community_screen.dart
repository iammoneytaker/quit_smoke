import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quit_smoke/theme/app_theme.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  _CommunityScreenState createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final TextEditingController _postController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final List<Map<String, dynamic>> _posts = [];
  int _currentPage = 1;
  final int _postsPerPage = 10;
  bool _isLoading = false;
  final bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      if (!_isLoading && _hasMore) {
        _loadPosts();
      }
    }
  }

  Future<void> _loadPosts() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    final supabase = Supabase.instance.client;
    final subscription =
        supabase.from('messages').on(SupabaseEventTypes.all, (payload) {
      setState(() {
        _postController.add(payload.newRecord);
      });
    }).subscribe();

    // Handle subscription cancellation when the widget is disposed
    @override
    void dispose() {
      supabase.removeSubscription(subscription);
      super.dispose();
    }

    // try {
    //   final response = await Supabase.instance.client
    //       .from('posts')
    //       .select('*, comments(*)')
    //       .order('created_at', ascending: false)
    //       .range((_currentPage - 1) * _postsPerPage,
    //           _currentPage * _postsPerPage - 1)
    //       .execute();

    //   if (response.data != null) {
    //     setState(() {
    //       if (_currentPage == 1) {
    //         _posts = List<Map<String, dynamic>>.from(response.data);
    //       } else {
    //         _posts.addAll(List<Map<String, dynamic>>.from(response.data));
    //       }
    //       _currentPage++;
    //       _hasMore = response.data.length == _postsPerPage;
    //     });
    //   }
    // } catch (e) {
    //   print('Error loading posts: $e');
    // } finally {
    //   setState(() {
    //     _isLoading = false;
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('커뮤니티'),
        backgroundColor: AppTheme.backgroundColor,
        foregroundColor: AppTheme.textColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _posts.length + (_hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < _posts.length) {
                  return _buildPostItem(_posts[index]);
                } else if (_hasMore) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
          _buildPostInput(),
        ],
      ),
    );
  }

  Widget _buildPostItem(Map<String, dynamic> post) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: AppTheme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post['content'],
              style: const TextStyle(color: AppTheme.textColor, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              DateTime.parse(post['created_at']).toString().split('.')[0],
              style: const TextStyle(
                  color: AppTheme.subtleTextColor, fontSize: 12),
            ),
            const SizedBox(height: 16),
            _buildCommentSection(post),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentSection(Map<String, dynamic> post) {
    List<dynamic> comments = post['comments'] ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('댓글 (${comments.length})',
            style: const TextStyle(
                color: AppTheme.textColor, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...comments.map((comment) => _buildCommentItem(comment)),
        _buildCommentInput(post['id']),
      ],
    );
  }

  Widget _buildCommentItem(Map<String, dynamic> comment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        comment['content'],
        style: const TextStyle(color: AppTheme.textColor, fontSize: 14),
      ),
    );
  }

  Widget _buildCommentInput(int postId) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _commentController,
            decoration: InputDecoration(
              hintText: '댓글 입력',
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
          onPressed: () => _submitComment(postId),
        ),
      ],
    );
  }

  Widget _buildPostInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: AppTheme.cardColor,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _postController,
              decoration: InputDecoration(
                hintText: '내용 입력',
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
            onPressed: _submitPost,
          ),
        ],
      ),
    );
  }

  void _submitPost() async {
    if (_postController.text.isNotEmpty) {
      print(Supabase.instance.client.auth.currentUser);
      try {
        final response = await Supabase.instance.client.from('posts').insert({
          'user_id': Supabase.instance.client.auth.currentUser!.id,
          'content': _postController.text,
          'created_at': DateTime.now().toIso8601String(),
        }).execute();
      } catch (e) {
        print('Exception while submitting post: $e');
        // Show error message to user
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('게시물 작성 중 오류가 발생했습니다: 잠시 후 다시 시도해주세요.')),
        );
      }
    }
  }

  void _submitComment(int postId) async {
    if (_commentController.text.isNotEmpty) {
      try {
        await Supabase.instance.client.from('comments').insert({
          'post_id': postId,
          'user_id': Supabase.instance.client.auth.currentUser!.id,
          'content': _commentController.text,
        }).execute();
        _commentController.clear();
        _currentPage = 1;
        _posts.clear();
        _loadPosts();
      } catch (e) {
        print('Error submitting comment: $e');
      }
    }
  }
}
