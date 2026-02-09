import 'package:json_annotation/json_annotation.dart';

part 'wiki_connection.g.dart';

@JsonSerializable()
class WikiConnection {
  final String wikiUrl; // "https://wiki.example.com"
  final String botUsername; // "admin@LazyWikis"
  final String encryptedPassword; // Encrypted bot password
  final bool rememberMe; // Store credentials?
  final DateTime? lastConnected;

  WikiConnection({
    required this.wikiUrl,
    required this.botUsername,
    required this.encryptedPassword,
    this.rememberMe = false,
    this.lastConnected,
  });

  // CopyWith method
  WikiConnection copyWith({
    String? wikiUrl,
    String? botUsername,
    String? encryptedPassword,
    bool? rememberMe,
    DateTime? lastConnected,
  }) {
    return WikiConnection(
      wikiUrl: wikiUrl ?? this.wikiUrl,
      botUsername: botUsername ?? this.botUsername,
      encryptedPassword: encryptedPassword ?? this.encryptedPassword,
      rememberMe: rememberMe ?? this.rememberMe,
      lastConnected: lastConnected ?? this.lastConnected,
    );
  }

  factory WikiConnection.fromJson(Map<String, dynamic> json) =>
      _$WikiConnectionFromJson(json);
  Map<String, dynamic> toJson() => _$WikiConnectionToJson(this);
}
