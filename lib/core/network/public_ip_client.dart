import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class PublicIp {
  const PublicIp({required this.address, required this.source});

  final String address;
  final String source;
}

class PublicIpException implements Exception {
  const PublicIpException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract interface class PublicIpService {
  Future<PublicIp> fetch();
}

class PublicIpClient implements PublicIpService {
  PublicIpClient({http.Client? client})
    : _client = client ?? http.Client(),
      _ownsClient = client == null;

  final http.Client _client;
  final bool _ownsClient;

  @override
  Future<PublicIp> fetch() async {
    try {
      final response = await _client
          .get(Uri.https('api.ipify.org', '/', {'format': 'json'}))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) {
        throw PublicIpException(
          'The public IP service returned status ${response.statusCode}.',
        );
      }

      final decoded = jsonDecode(response.body);
      final address = decoded is Map<String, dynamic>
          ? decoded['ip']?.toString().trim()
          : null;
      if (address == null || address.isEmpty) {
        throw const PublicIpException(
          'The public IP service returned an invalid response.',
        );
      }

      return PublicIp(address: address, source: 'ipify');
    } on TimeoutException {
      throw const PublicIpException('The public IP request timed out.');
    } on FormatException {
      throw const PublicIpException(
        'The public IP service returned an invalid response.',
      );
    } on http.ClientException catch (error) {
      throw PublicIpException('Could not reach the public IP service: $error');
    }
  }

  void close() {
    if (_ownsClient) _client.close();
  }
}
