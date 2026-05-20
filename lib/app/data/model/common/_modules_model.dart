class ModulesModel {
  final bool customDomainAddon;
  final bool hrmAddon;
  final bool restaurantOnlineStore;
  final bool restaurantWebAddon;

  ModulesModel({
    required this.customDomainAddon,
    required this.hrmAddon,
    required this.restaurantOnlineStore,
    required this.restaurantWebAddon,
  });

  factory ModulesModel.fromJson(Map<String, dynamic> json) => ModulesModel(
    customDomainAddon: json["CustomDomainAddon"] == true,
    hrmAddon: json["HrmAddon"] == true,
    restaurantOnlineStore: json["RestaurantOnlineStore"] == true,
    restaurantWebAddon: json["RestaurantWebAddon"] == true,
  );
}
