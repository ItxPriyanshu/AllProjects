import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

final newsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final dio = Dio();

  try {
    final response = await dio.get(
      'https://team-orbital.onrender.com/news',
      options: Options(receiveTimeout: const Duration(seconds: 15)),
    );

    if (response.statusCode == 200) {
      final data = response.data;
      final newsList = data is List ? data : [];

      return List<Map<String, dynamic>>.from(
        newsList.map((item) => {
              'title': item['title']?.toString() ?? 'Health News',
              'description': item['description']?.toString() ?? '',
              'image': item['image']?.toString() ?? '',
              'url': item['url']?.toString() ?? '',
            }),
      );
    }

    return [];
  } catch (e) {
    return [];
  }
});