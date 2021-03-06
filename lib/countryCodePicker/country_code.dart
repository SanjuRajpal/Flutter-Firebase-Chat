import 'package:flutter/cupertino.dart';
import 'country_localizations.dart';
import 'country_codes.dart';
mixin ToAlias {}

@deprecated
class CElement = CountryCode with ToAlias;

/// Country element. This is the element that contains all the information
class CountryCode {
  /// the name of the country
  String name;

  /// the flag of the country
  final String flagUri;

  /// the country code (IT,AF..)
  final String code;

  /// the dial code (+39,+93..)
  final String dialCode;

  CountryCode({
    this.name,
    this.flagUri,
    this.code,
    this.dialCode,
  });

  factory CountryCode.fromCode(String isoCode) {
    final Map<String, String> jsonCode = codes.firstWhere(
          (code) => code['code'] == isoCode,
      orElse: () => null,
    );

    if (jsonCode == null) {
      return null;
    }

    return CountryCode.fromJson(jsonCode);
  }

  CountryCode localize(BuildContext context) {
    return this
      ..name =
          CountryLocalizations.of(context)?.translate(this.code) ?? this.name;
  }

  factory CountryCode.fromJson(Map<String, dynamic> json) {
    return CountryCode(
      name: json['name'],
      code: json['code'],
      dialCode: json['dial_code'],
      flagUri: 'assets/flags/${json['code'].toLowerCase()}.png',
    );
  }

  @override
  String toString() => "$dialCode";

  String toLongString([BuildContext context]) =>
      "$dialCode ${toCountryStringOnly(context)}";

  String toCountryStringOnly([BuildContext context]) {
    if (context != null) {
      return CountryLocalizations.of(context)?.translate(code) ?? name;
    }
    return '$name';
  }
}