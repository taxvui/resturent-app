part of 'dashboard_view.dart';

class DashboardViewNotifier extends ChangeNotifier {
  //---------------check button function----------------------
  bool isPrivacyChecked = true;
  void checkPrivacy([bool? value]) {
    isPrivacyChecked = value ?? !isPrivacyChecked;
    notifyListeners();
  }

  //--------------------dropdown value------------------
  final dropdownValues = <String, int?>{
    'Today': null,
    'Weekly': null,
    'Monthly': null,
    'Yearly': null,
  };
  void handleDropdownChange(MapEntry<String, int?> data) {
    dropdownValues[data.key] = data.value;
    notifyListeners();
  }

  //----------------------filter------------------
  DateFilterDropdownItem? selectedFilter;
}

final dashboardViewProvider =
    ChangeNotifierProvider((ref) => DashboardViewNotifier());
