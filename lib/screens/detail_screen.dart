import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/post_service.dart';
import '../widgets/glass_widgets.dart';

class DetailScreen extends StatefulWidget {
  final Post post;
  const DetailScreen({super.key, required this.post});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final PostService _service = PostService();
  late Future<List<Comment>> _commentsFuture;

  // Pasangan warna gradien untuk foto profil
  static const List<List<Color>> _avatarGradients = [
    [Color(0xFF42A5F5), Color(0xFF1E88E5)],
    [Color(0xFFAB47BC), Color(0xFF7E57C2)],
    [Color(0xFF26C6DA), Color(0xFF26A69A)],
    [Color(0xFFFF7043), Color(0xFFFFA726)],
    [Color(0xFFEC407A), Color(0xFFF06292)],
    [Color(0xFF66BB6A), Color(0xFF9CCC65)],
  ];

  @override
  void initState() {
    super.initState();
    _commentsFuture = _service.fetchComments(widget.post.id);
  }

  void _retry() {
    setState(() {
      _commentsFuture = _service.fetchComments(widget.post.id);
    });
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF5A300),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAvatar(int id) {
    final g = _avatarGradients[id % _avatarGradients.length];
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: g,
        ),
        boxShadow: [
          BoxShadow(
            color: g.last.withAlpha(90),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Icon(Icons.person, color: Colors.white, size: 28),
    );
  }

  Widget _buildCommentItem(Comment c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatar(c.id),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  c.email,
                  style: const TextStyle(fontSize: 10, color: Colors.black87),
                ),
                const SizedBox(height: 6),
                Text(
                  c.body,
                  style: const TextStyle(
                      fontSize: 14, height: 1.35, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComments() {
    return FutureBuilder<List<Comment>>(
      future: _commentsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Column(
            children: [
              Text('Gagal memuat komentar: ${snapshot.error}'),
              const SizedBox(height: 8),
              ElevatedButton(onPressed: _retry, child: const Text('Coba Lagi')),
            ],
          );
        }

        final comments = snapshot.data ?? const <Comment>[];
        if (comments.isEmpty) {
          return const Text('Belum ada komentar.');
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: comments.map(_buildCommentItem).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leadingWidth: 120,
          leading: const Align(
            alignment: Alignment.centerLeft,
            child: AppBackButton(),
          ),
          title: const Text(
            'Detail Info',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassCard(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.post.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [_chip('Info'), _chip('Penting')],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      widget.post.body,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade800,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GlassCard(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Komentar',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    _buildComments(),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}