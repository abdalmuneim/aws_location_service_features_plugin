/// Connection settings read by the data layer on every request.
///
/// The object is mutable on purpose: keep one instance for the lifetime of
/// the app and update its fields (for example from a settings screen), and a
/// new API key, region or language applies to the next request without
/// rebuilding any repository.
class AwsLocationConfig {
  AwsLocationConfig({
    required this.apiKey,
    required this.region,
    this.language = 'en',
    this.politicalView,
  });

  /// Amazon Location API key, used by Maps, Places and Routes.
  String apiKey;

  /// AWS region of the API key, e.g. `eu-north-1`.
  String region;

  /// Preferred language (BCP 47) for Places results and route instructions.
  String language;

  /// ISO 3166-1 alpha-3 political view for maps and places, or null for the
  /// default view.
  String? politicalView;

  /// Regions where the Maps, Places and Routes v2 APIs are available.
  static const List<String> supportedRegions = [
    'us-east-1',
    'us-east-2',
    'us-west-2',
    'ca-central-1',
    'sa-east-1',
    'eu-central-1',
    'eu-west-1',
    'eu-west-2',
    'eu-north-1',
    'eu-south-1',
    'eu-south-2',
    'ap-northeast-1',
    'ap-southeast-1',
    'ap-southeast-2',
    'ap-southeast-5',
    'ap-south-1',
    'me-central-1',
  ];

  /// A selection of languages for Places and Routes results (BCP 47), with
  /// each language's own name.
  static const Map<String, String> languages = {
    'en': 'English',
    'ar': 'العربية',
    'fr': 'Français',
    'de': 'Deutsch',
    'es': 'Español',
    'it': 'Italiano',
    'pt': 'Português',
    'tr': 'Türkçe',
    'ru': 'Русский',
    'zh': '中文',
    'ja': '日本語',
    'hi': 'हिन्दी',
  };

  /// Political views supported by Amazon Location (ISO 3166-1 alpha-3).
  static const Map<String, String> politicalViews = {
    'ARG': 'Argentina',
    'CYP': 'Cyprus',
    'EGY': 'Egypt',
    'GEO': 'Georgia',
    'GRC': 'Greece',
    'IND': 'India',
    'KEN': 'Kenya',
    'MAR': 'Morocco',
    'PSE': 'Palestine',
    'RUS': 'Russia',
    'SDN': 'Sudan',
    'SRB': 'Serbia',
    'SUR': 'Suriname',
    'SYR': 'Syria',
    'TUR': 'Turkey',
    'TZA': 'Tanzania',
    'URY': 'Uruguay',
    'VNM': 'Vietnam',
  };
}
