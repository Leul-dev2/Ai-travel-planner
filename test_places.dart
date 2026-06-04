import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  final query = "Eiffel Tower, Paris";
  final apiKey = "AIzaSyAe-HY6TXIc22K928mX9DmU7UjIZpwiDYk"; // From user's .env

  final searchUrl = 'https://maps.googleapis.com/maps/api/place/textsearch/json';
  try {
    final searchRes = await dio.get(searchUrl, queryParameters: {
      'query': query,
      'key': apiKey,
    });
    print(searchRes.statusCode);
    print(searchRes.data['status']);
    if (searchRes.data['error_message'] != null) {
      print(searchRes.data['error_message']);
    }
  } catch (e) {
    print(e);
  }
}
