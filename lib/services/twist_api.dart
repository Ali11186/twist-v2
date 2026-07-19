import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class TwistApi {
  static const _base = 'https://api.twistmena.com';

  String sessionId;
  String authorization = '';
  String accessToken = '';
  String tgToken = '';
  String tgRefreshToken = '';
  String tgDeviceId = '26284330';

  TwistApi() : sessionId = _uuid();

  static String _uuid() {
    final r = Random();
    const chars = '0123456789abcdef';
    String block(int n) => List.generate(n, (_) => chars[r.nextInt(16)]).join();
    return '${block(8)}-${block(4)}-${block(4)}-${block(4)}-${block(12)}';
  }

  Map<String, String> get _headers => {
        'user-agent': 'Twist-Mobile/11.2.10 (Android; 12; SM-A217F; music; ar-AE)',
        'app_version': '11.2.10',
        'appversion': '11.2.10',
        'channel': 'mobileapp',
        'content-type': 'application/json',
        'platform': 'android',
        'accept': 'application/json',
        'accept-language': 'ar',
        'device_id': 'SP1A.210812.016',
        'tgdeviceid': tgDeviceId,
        'device_token': '',
        'tg-token': tgToken,
        'tg-refresh-token': tgRefreshToken,
        'access-token': accessToken,
        'sessionid': sessionId,
        if (authorization.isNotEmpty) 'authorization': 'Bearer $authorization',
      };

  static String normalizePhone(String raw) {
    final trimmed = raw.trim().replaceAll(' ', '');
    if (trimmed.startsWith('01')) return '2$trimmed';
    if (trimmed.startsWith('+2')) return trimmed.substring(1);
    return trimmed.replaceAll('+', '');
  }

  Future<bool> sendCode(String phone) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/music/Dlogin/sendCode'),
        headers: _headers,
        body: jsonEncode({'dial': phone}),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> verifyCode(String phone, String code) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/music/Dlogin/verify'),
        headers: _headers,
        body: jsonEncode({
          'dial': phone,
          'verifyCode': code,
          'socialServiceName': '',
          'socialServiceToken': '',
        }),
      );
      if (res.statusCode != 200) return false;

      final data = jsonDecode(res.body);
      String? token;
      if (data is Map) {
        token = data['token'] ?? data['authorization'];
      }
      token ??= res.headers['authorization']?.replaceFirst('Bearer ', '');
      if (token == null) return false;

      authorization = token.replaceFirst('Bearer ', '');
      if (data is Map) {
        accessToken = data['accessToken'] ?? '';
        tgToken = data['tgToken'] ?? data['tg_token'] ?? '';
        tgRefreshToken = data['tgRefreshToken'] ?? data['tg_refresh_token'] ?? '';
        tgDeviceId = data['tgDeviceId'] ?? data['tg_device_id'] ?? tgDeviceId;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<int> getBalance() async {
    try {
      final res = await http.get(
        Uri.parse('$_base/music/user/loyalty/balance/details'),
        headers: _headers,
      );
      if (res.statusCode != 200) return 0;
      final data = jsonDecode(res.body);
      if (data is Map) return int.tryParse('${data['balance'] ?? 0}') ?? 0;
      if (data is List && data.isNotEmpty) {
        return int.tryParse('${data[0]['balance'] ?? 0}') ?? 0;
      }
    } catch (_) {}
    return 0;
  }

  Future<List<Achievement>> getAchievements() async {
    try {
      final res = await http.get(
        Uri.parse('$_base/music/user/loyalty/achievements/v2'),
        headers: _headers,
      );
      if (res.statusCode != 200) return [];
      final data = jsonDecode(res.body);
      final categories = data is Map ? (data['badges'] ?? []) : (data is List ? data : []);
      final all = <Achievement>[];
      for (final cat in categories) {
        final tasks = (cat is Map ? cat['badges'] : null) ?? [];
        for (final t in tasks) {
          if (t is Map) {
            all.add(Achievement(
              id: '${t['id']}',
              name: t['title'] ?? t['name'] ?? 'مهمة',
              rewarded: t['rewarded'] == true,
              coins: int.tryParse('${t['coins'] ?? 0}') ?? 0,
            ));
          }
        }
      }
      return all;
    } catch (_) {
      return [];
    }
  }

  Future<bool> completeAchievement(String taskId) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/music/loyalty/action/$taskId'),
        headers: _headers,
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> redeem(String redeemCode) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/music/loyalty/redeem/$redeemCode'),
        headers: _headers,
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

class Achievement {
  final String id;
  final String name;
  final bool rewarded;
  final int coins;
  Achievement({required this.id, required this.name, required this.rewarded, this.coins = 0});
}

class RedeemOption {
  final int cost;
  final int units;
  final String code;
  const RedeemOption(this.cost, this.units, this.code);

  static const all = [
    RedeemOption(100, 50, 'EAND_50_UNITS_ID_9'),
    RedeemOption(200, 100, 'EAND_100_UNITS_ID_10'),
    RedeemOption(300, 150, 'EAND_150_UNITS_ID_11'),
    RedeemOption(600, 300, 'EAND_300_UNITS_ID_12'),
    RedeemOption(1000, 500, 'EAND_500_UNITS_ID_13'),
    RedeemOption(2000, 1000, 'EAND_1000_UNITS_ID_15'),
  ];

  static List<RedeemOption> availableFor(int balance) =>
      all.where((o) => balance >= o.cost).toList();
}
