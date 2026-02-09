// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wiki_connection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WikiConnection _$WikiConnectionFromJson(Map<String, dynamic> json) =>
    WikiConnection(
      wikiUrl: json['wikiUrl'] as String,
      botUsername: json['botUsername'] as String,
      encryptedPassword: json['encryptedPassword'] as String,
      rememberMe: json['rememberMe'] as bool? ?? false,
      lastConnected: json['lastConnected'] == null
          ? null
          : DateTime.parse(json['lastConnected'] as String),
    );

Map<String, dynamic> _$WikiConnectionToJson(WikiConnection instance) =>
    <String, dynamic>{
      'wikiUrl': instance.wikiUrl,
      'botUsername': instance.botUsername,
      'encryptedPassword': instance.encryptedPassword,
      'rememberMe': instance.rememberMe,
      'lastConnected': instance.lastConnected?.toIso8601String(),
    };
