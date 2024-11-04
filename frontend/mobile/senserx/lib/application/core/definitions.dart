
class Definitions {
  static const String OPERATION_MODE_KEY = "operation_mode";
  static const String USER_ID = "uid";
  static const String LAST_SYNC_TIME = "last_sync_time";
  static const String APP_THEME = "app_theme";

  static const List<Map<String, String>> sharedPreferenceKeys = [
    {
      'key': OPERATION_MODE_KEY,
      'description': 'Stores the current operation mode (checkin/checkout)',
    },
    {
      'key': USER_ID,
      'description': 'Stores the ID of the currently logged in user',
    },
    {
      'key': LAST_SYNC_TIME,
      'description': 'Stores the timestamp of the last data synchronization',
    },
    {
      'key': APP_THEME,
      'description': 'Stores the preferred app theme.',
    },
  ];

  static String getSharedPrefKey(String keyName) {
    final keyMap = sharedPreferenceKeys.firstWhere(
          (keyMap) => keyMap['key'] == keyName,
      orElse: () => {'key': ''},
    );
    return keyMap['key'] ?? '';
  }
}