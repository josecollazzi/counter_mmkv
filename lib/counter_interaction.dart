enum PartOfTheApp {
  flutterCode,
  iosSwiftHomeWidget,
  androidKotlinHomeWidget,
}

/// our combinations are:
///
/// user press button in the app, and the app persist the code using mmkv
/// user press button in the ios native widget, and the app (flutter code) persist using mmkv
/// user press button in the ios native widget, and the widget (swift code) persist using mmkv
/// user press button in the android native widget, and the app (flutter code) persist using mmkv
/// user press button in the android native widget, and the widget (kotlin code) persist using mmkv
class CounterInteraction {
  final int counterValue;
  final PartOfTheApp interactionButtonLocation;
  final PartOfTheApp persistedLogicLocation;

  CounterInteraction({
    required this.counterValue,
    required this.interactionButtonLocation,
    required this.persistedLogicLocation});

  Map<String, dynamic> toJson() {
    return {
      'counterValue': counterValue,
      'interactionButtonLocation': interactionButtonLocation.name,
      'persistedLogicLocation': persistedLogicLocation.name,
    };
  }


  static CounterInteraction fromJson(Map<String, dynamic> json) {
    return CounterInteraction(
      counterValue: json['counterValue'],
      interactionButtonLocation: PartOfTheApp.values.byName(json['interactionButtonLocation']),
      persistedLogicLocation: PartOfTheApp.values.byName(json['persistedLogicLocation']),
    );
  }
}



