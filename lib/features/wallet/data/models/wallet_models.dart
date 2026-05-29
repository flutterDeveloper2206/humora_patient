import 'package:equatable/equatable.dart';

class PaymentIntentRequest extends Equatable {
  final double amount;
  final String currencyId;
  final String description;
  final String idempotencyKey;

  const PaymentIntentRequest({
    required this.amount,
    required this.currencyId,
    required this.description,
    required this.idempotencyKey,
  });

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'currencyId': currencyId,
        'description': description,
        'idempotencyKey': idempotencyKey,
      };

  @override
  List<Object?> get props => [amount, currencyId, description, idempotencyKey];
}

class PaymentIntentResponse extends Equatable {
  final String paymentIntentId;
  final String clientSecret;
  final double amount;
  final String currencyId;
  final String? currencyName;
  final String? currencySymbol;

  const PaymentIntentResponse({
    required this.paymentIntentId,
    required this.clientSecret,
    required this.amount,
    required this.currencyId,
    this.currencyName,
    this.currencySymbol,
  });

  factory PaymentIntentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentIntentResponse(
      paymentIntentId: json['paymentIntentId']?.toString() ?? '',
      clientSecret: json['clientSecret']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currencyId: json['currencyId']?.toString() ?? '',
      currencyName: json['currencyName']?.toString(),
      currencySymbol: json['currencySymbol']?.toString(),
    );
  }

  @override
  List<Object?> get props =>
      [paymentIntentId, clientSecret, amount, currencyId, currencyName, currencySymbol];
}

class WalletBalanceResponse extends Equatable {
  final String walletId;
  final double balance;
  final double holdBalance;
  final double availableBalance;
  final String? currencyId;
  final String? currencyName;
  final String? currencySymbol;

  const WalletBalanceResponse({
    required this.walletId,
    required this.balance,
    required this.holdBalance,
    required this.availableBalance,
    this.currencyId,
    this.currencyName,
    this.currencySymbol,
  });

  factory WalletBalanceResponse.fromJson(Map<String, dynamic> json) {
    return WalletBalanceResponse(
      walletId: json['walletId']?.toString() ?? '',
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      holdBalance: (json['holdBalance'] as num?)?.toDouble() ?? 0,
      availableBalance: (json['availableBalance'] as num?)?.toDouble() ?? 0,
      currencyId: json['currencyId']?.toString(),
      currencyName: json['currencyName']?.toString(),
      currencySymbol: json['currencySymbol']?.toString(),
    );
  }

  static const empty = WalletBalanceResponse(
    walletId: '00000000-0000-0000-0000-000000000000',
    balance: 0,
    holdBalance: 0,
    availableBalance: 0,
  );

  bool get hasWallet =>
      walletId != '00000000-0000-0000-0000-000000000000' &&
      walletId.isNotEmpty;

  String get displaySymbol => currencySymbol ?? '₹';

  @override
  List<Object?> get props => [
        walletId,
        balance,
        holdBalance,
        availableBalance,
        currencyId,
        currencyName,
        currencySymbol,
      ];
}

class WalletTransactionItem extends Equatable {
  final int transactionType;
  final int source;
  final int status;
  final double amount;
  final double balanceBefore;
  final double balanceAfter;
  final String? currencySymbol;
  final String? referenceId;
  final DateTime? createdDate;

  const WalletTransactionItem({
    required this.transactionType,
    required this.source,
    required this.status,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    this.currencySymbol,
    this.referenceId,
    this.createdDate,
  });

  factory WalletTransactionItem.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    final rawDate = json['createdDate']?.toString();
    if (rawDate != null && rawDate.isNotEmpty) {
      parsedDate = DateTime.tryParse(rawDate);
    }

    return WalletTransactionItem(
      transactionType: (json['transactionType'] as num?)?.toInt() ?? 0,
      source: (json['source'] as num?)?.toInt() ?? 0,
      status: (json['status'] as num?)?.toInt() ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      balanceBefore: (json['balanceBefore'] as num?)?.toDouble() ?? 0,
      balanceAfter: (json['balanceAfter'] as num?)?.toDouble() ?? 0,
      currencySymbol: json['currencySymbol']?.toString(),
      referenceId: json['referenceId']?.toString(),
      createdDate: parsedDate,
    );
  }

  bool get isCredit =>
      transactionType == 1 || transactionType == 5; // Credit or Refund

  String get title => _transactionTypeLabel(transactionType);

  String get subtitle => _sourceLabel(source);

  String get statusLabel => _statusLabel(status);

  String amountDisplay(String symbol) {
    final prefix = isCredit ? '+' : '−';
    return '$prefix$symbol${amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2)}';
  }

  static String _transactionTypeLabel(int type) {
    switch (type) {
      case 1:
        return 'Credit';
      case 2:
        return 'Debit';
      case 3:
        return 'Hold';
      case 4:
        return 'Release';
      case 5:
        return 'Refund';
      default:
        return 'Transaction';
    }
  }

  static String _sourceLabel(int source) {
    switch (source) {
      case 1:
        return 'Stripe top-up';
      case 2:
        return 'Consultation';
      case 3:
        return 'Refund';
      case 4:
        return 'Admin credit';
      case 5:
        return 'Hold';
      case 6:
        return 'Hold release';
      default:
        return 'Wallet';
    }
  }

  static String _statusLabel(int status) {
    switch (status) {
      case 1:
        return 'Completed';
      case 2:
        return 'Pending';
      case 3:
        return 'Failed';
      case 4:
        return 'Reversed';
      default:
        return '';
    }
  }

  @override
  List<Object?> get props => [
        transactionType,
        source,
        status,
        amount,
        balanceBefore,
        balanceAfter,
        currencySymbol,
        referenceId,
        createdDate,
      ];
}

class WalletTransactionsResponse extends Equatable {
  final int skip;
  final int take;
  final int totalCount;
  final List<WalletTransactionItem> items;

  const WalletTransactionsResponse({
    required this.skip,
    required this.take,
    required this.totalCount,
    required this.items,
  });

  factory WalletTransactionsResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = rawItems is List
        ? rawItems
            .whereType<Map<String, dynamic>>()
            .map(WalletTransactionItem.fromJson)
            .toList()
        : <WalletTransactionItem>[];

    return WalletTransactionsResponse(
      skip: (json['skip'] as num?)?.toInt() ?? 0,
      take: (json['take'] as num?)?.toInt() ?? 20,
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
      items: items,
    );
  }

  @override
  List<Object?> get props => [skip, take, totalCount, items];
}
