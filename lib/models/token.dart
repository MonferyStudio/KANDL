import 'package:flutter/material.dart';

/// Types of tokens that can be placed on stocks
enum TokenType {
  dividend,  // Generates passive income based on stock performance
  robot,     // Automatically trades (buys low, sells high)
}

/// A token that can be placed on a stock
class Token {
  final String id;
  final TokenType type;
  String? placedOnCompanyId; // null if not placed

  Token({
    required this.id,
    required this.type,
    this.placedOnCompanyId,
  });

  /// Whether the token is currently placed on a stock
  bool get isPlaced => placedOnCompanyId != null;

  /// Get display name
  String get name {
    switch (type) {
      case TokenType.dividend:
        return 'Dividend Token';
      case TokenType.robot:
        return 'Trading Bot';
    }
  }

  /// Get icon
  String get icon {
    switch (type) {
      case TokenType.dividend:
        return '💎';
      case TokenType.robot:
        return '🤖';
    }
  }

  /// Get description
  String get description {
    switch (type) {
      case TokenType.dividend:
        return 'Earns passive income based on stock price gains each day.';
      case TokenType.robot:
        return 'Automatically buys when price drops and sells when it rises.';
    }
  }

  /// Get color
  Color get color {
    switch (type) {
      case TokenType.dividend:
        return const Color(0xFF22D3EE); // Cyan
      case TokenType.robot:
        return const Color(0xFFF97316); // Orange
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.index,
    'placedOnCompanyId': placedOnCompanyId,
  };

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      id: json['id'],
      type: TokenType.values[json['type']],
      placedOnCompanyId: json['placedOnCompanyId'],
    );
  }
}
