class RazorpayConfig {
  /// Public Key ID (Safe for client checkout presentation)
  static const String keyId = 'rzp_test_TdqsuRubACTXNN';

  /// Payment Currency
  static const String currency = 'INR';

  /// Brand Merchant Name
  static const String merchantName = 'PYP - Pick Your Photographer';

  /// Backend Cloud Functions Base URL (Configure with deployed project ID)
  /// e.g. https://us-central1-YOUR_PROJECT_ID.cloudfunctions.net
  static const String backendBaseUrl = 'https://us-central1-pyp-app.cloudfunctions.net';
}

