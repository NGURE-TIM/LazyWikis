/// Route name constants for type-safe navigation
class RouteNames {
  static const String dashboard = '/';
  static const String newGuide = '/guide/new';
  static const String editGuide = '/guide/:id';
  static const String settings = '/settings';

  /// Generate edit guide route with ID
  static String editGuideWithId(String id) => '/guide/$id';
}
