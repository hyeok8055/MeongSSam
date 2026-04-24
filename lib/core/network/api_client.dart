abstract interface class ApiClient {
  Future<Map<String, dynamic>> get(String path);
}
