import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/post.dart';

class PostService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  static const Duration _timeout = Duration(seconds: 15);

  /// GET /posts
  Future<List<Post>> fetchPosts() async {
    // 1. Buat alamat
    final Uri url = Uri.parse('$baseUrl/posts');

    // 2. Kirim request
    final http.Response response = await http.get(url).timeout(_timeout);

    // 3. Cek status code
    if (response.statusCode == 200) {
      // 4. Ubah JSON menjadi objek
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((json) => Post.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Gagal memuat pengumuman (kode: ${response.statusCode})');
    }
  }

  /// GET /posts/{id}/comments
  Future<List<Comment>> fetchComments(int postId) async {
    // 1. Buat alamat
    final Uri url = Uri.parse('$baseUrl/posts/$postId/comments');

    // 2. Kirim request
    final http.Response response = await http.get(url).timeout(_timeout);

    // 3. Cek status code
    if (response.statusCode == 200) {
      // 4. Ubah JSON menjadi objek
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((json) => Comment.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Gagal memuat komentar (kode: ${response.statusCode})');
    }
  }

  /// POST /posts
  Future<Post> createPost(Post post) async {
    // 1. Buat alamat
    final Uri url = Uri.parse('$baseUrl/posts');

    // 2. Kirim request
    final http.Response response = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode(post.toJson()),
        )
        .timeout(_timeout);

    // 3. Cek status code (JSONPlaceholder mengembalikan 201)
    if (response.statusCode == 201 || response.statusCode == 200) {
      // 4. Ubah JSON menjadi objek
      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;
      return Post.fromJson(json);
    } else {
      throw Exception('Gagal membuat pengumuman (kode: ${response.statusCode})');
    }
  }
}