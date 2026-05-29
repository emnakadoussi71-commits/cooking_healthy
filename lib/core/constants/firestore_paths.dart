class FirestorePaths {
  static String user(String uid) => 'users/$uid';
  static const String users = 'users';

  static String recipe(String id) => 'recipes/$id';
  static const String recipes = 'recipes';

  static String favoriteItem(String uid, String recipeId) =>
      'favorites/$uid/items/$recipeId';
  static String favorites(String uid) => 'favorites/$uid/items';

  static String nutritionEntry(String uid, String date) =>
      'nutritionLogs/$uid/entries/$date';
  static String nutritionLogs(String uid) => 'nutritionLogs/$uid/entries';

  static const String dietPlans = 'dietPlans';
  static const String advice = 'advice';
}
