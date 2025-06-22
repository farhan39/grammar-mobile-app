class AppStrings {
  static const String categoryNameRequired = "Category name is required";
  static const String add = "Add";
  static const String done = "Done";
  static const String edit = "Edit";

  static String getPngIconPath(String iconName) {
    return "assets/images/$iconName.png";
  }

  static String getUnselectedBottomNavIcon(String iconName) {
    return "assets/images/${iconName}_unselected.png";
  }

  static String getSelectedBottomNavIcon(String iconName) {
    return "assets/images/${iconName}_selected.png";
  }

  static String getSvgIconPath(String iconName) {
    return "assets/images/$iconName.svg";
  }

  static String getDarkPngIconPath(String iconName) {
    return "assets/images/${iconName}_dark.png";
  }

  static String getAppErrorText({
    required String userFriendlyMessage,
    String? error,
    String? action,
    String? contactInfo,
    String? errorCode,
    bool showErrorDetails = false,
  }) {
    String baseMessage = userFriendlyMessage;

    String actionMessage = action != null ? ' Suggested action: $action.' : '';

    String contactMessage = contactInfo != null
        ? ' For further assistance, contact us at $contactInfo.'
        : ' If the issue continues, please contact support.';

    String details = '';
    if (showErrorDetails) {
      details = errorCode != null
          ? ' [Error Code: $errorCode]'
          : (error != null ? ' [Details: $error]' : '');
    }

    return '$baseMessage$actionMessage$contactMessage$details';
  }

  static String getError({
    required String userFriendlyMessage,
    String? error,
    String? action,
    String? contactInfo,
    String? errorCode,
    bool showErrorDetails = false,
  }) {
    Map<String, String> commonSuggestions = {
      'NETWORK_ERROR': 'Please check your internet connection.',
      'AUTH_ERROR': 'Try logging in again.',
      'SERVER_ERROR': 'Wait a few minutes and retry.',
    };

    String suggestion =
        (errorCode != null && commonSuggestions.containsKey(errorCode))
            ? ' ${commonSuggestions[errorCode]}'
            : '';

    String message = getAppErrorText(
      userFriendlyMessage: '$userFriendlyMessage$suggestion',
      error: error,
      action: action,
      contactInfo: contactInfo,
      errorCode: errorCode,
      showErrorDetails: showErrorDetails,
    );

    return message;
  }
}
