class Currency {
  final String code;
  final String name;
  final String symbol;

  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
  });

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'name': name,
      'symbol': symbol,
    };
  }

  factory Currency.fromMap(Map<String, dynamic> map) {
    return Currency(
      code: map['code'],
      name: map['name'],
      symbol: map['symbol'],
    );
  }
}

class CurrencyData {
  static const List<Currency> currencies = [
    // Major Currencies
    Currency(code: 'USD', name: 'US Dollar', symbol: '\$'),
    Currency(code: 'EUR', name: 'Euro', symbol: '€'),
    Currency(code: 'GBP', name: 'British Pound', symbol: '£'),
    Currency(code: 'JPY', name: 'Japanese Yen', symbol: '¥'),
    Currency(code: 'CNY', name: 'Chinese Yuan', symbol: '¥'),
    Currency(code: 'INR', name: 'Indian Rupee', symbol: '₹'),
    Currency(code: 'AUD', name: 'Australian Dollar', symbol: 'A\$'),
    Currency(code: 'CAD', name: 'Canadian Dollar', symbol: 'C\$'),
    Currency(code: 'CHF', name: 'Swiss Franc', symbol: 'CHF'),
    Currency(code: 'SEK', name: 'Swedish Krona', symbol: 'kr'),
    Currency(code: 'NZD', name: 'New Zealand Dollar', symbol: 'NZ\$'),
    Currency(code: 'SGD', name: 'Singapore Dollar', symbol: 'S\$'),
    Currency(code: 'HKD', name: 'Hong Kong Dollar', symbol: 'HK\$'),
    Currency(code: 'NOK', name: 'Norwegian Krone', symbol: 'kr'),
    Currency(code: 'KRW', name: 'South Korean Won', symbol: '₩'),
    Currency(code: 'TRY', name: 'Turkish Lira', symbol: '₺'),
    Currency(code: 'RUB', name: 'Russian Ruble', symbol: '₽'),
    Currency(code: 'BRL', name: 'Brazilian Real', symbol: 'R\$'),
    Currency(code: 'ZAR', name: 'South African Rand', symbol: 'R'),
    Currency(code: 'MXN', name: 'Mexican Peso', symbol: '\$'),

    // Middle East & Africa
    Currency(code: 'AED', name: 'UAE Dirham', symbol: 'د.إ'),
    Currency(code: 'SAR', name: 'Saudi Riyal', symbol: '﷼'),
    Currency(code: 'EGP', name: 'Egyptian Pound', symbol: '£'),
    Currency(code: 'NGN', name: 'Nigerian Naira', symbol: '₦'),
    Currency(code: 'KES', name: 'Kenyan Shilling', symbol: 'KSh'),

    // Asia Pacific
    Currency(code: 'BDT', name: 'Bangladeshi Taka', symbol: '৳'),
    Currency(code: 'PKR', name: 'Pakistani Rupee', symbol: '₨'),
    Currency(code: 'LKR', name: 'Sri Lankan Rupee', symbol: 'Rs'),
    Currency(code: 'THB', name: 'Thai Baht', symbol: '฿'),
    Currency(code: 'MYR', name: 'Malaysian Ringgit', symbol: 'RM'),
    Currency(code: 'IDR', name: 'Indonesian Rupiah', symbol: 'Rp'),
    Currency(code: 'PHP', name: 'Philippine Peso', symbol: '₱'),
    Currency(code: 'VND', name: 'Vietnamese Dong', symbol: '₫'),

    // Europe
    Currency(code: 'PLN', name: 'Polish Zloty', symbol: 'zł'),
    Currency(code: 'CZK', name: 'Czech Koruna', symbol: 'Kč'),
    Currency(code: 'HUF', name: 'Hungarian Forint', symbol: 'Ft'),
    Currency(code: 'RON', name: 'Romanian Leu', symbol: 'lei'),
    Currency(code: 'DKK', name: 'Danish Krone', symbol: 'kr'),

    // Americas
    Currency(code: 'ARS', name: 'Argentine Peso', symbol: '\$'),
    Currency(code: 'CLP', name: 'Chilean Peso', symbol: '\$'),
    Currency(code: 'COP', name: 'Colombian Peso', symbol: '\$'),
    Currency(code: 'PEN', name: 'Peruvian Sol', symbol: 'S/'),
  ];

  static Currency getCurrencyByCode(String code) {
    return currencies.firstWhere(
      (currency) => currency.code == code,
      orElse: () => currencies[0], // Default to USD
    );
  }
}
