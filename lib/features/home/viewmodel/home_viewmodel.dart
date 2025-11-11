import 'package:flutter/foundation.dart';
import 'package:opicproject/features/post/data/post_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final PostRepository repository = PostRepository.shared;

  List<Map<String, dynamic>> posts = [];

  Future<void> loadPosts() async {
    posts = await repository.getAllPosts();
    notifyListeners();
  }
}
