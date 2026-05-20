import '../app_config/_app_config.dart';

abstract class DAPIEndpoints {
  // Base urls
  static const String baseURL = AppConfig.baseUrl;
  static final String apiURL = '$baseURL/api/v1';
  static String? imageUrl(String? path) {
    if (path == null) return null;
    return "$baseURL/$path";
  }

  //-----------------------------Endpoints-----------------------------//
  static const String modules = '/module-check';

  // Auth Endpoints
  static const String signin = '/sign-in';
  static const String signout = '/sign-out';
  static const String signup = '/sign-up';
  static const String submitotp = '/submit-otp';
  static const String resendotp = '/resend-otp';
  static const String resetPassOtp = '/send-reset-code';
  static const String resetPassword = '/password-reset';
  static String userBusiness([int? id]) {
    return '/business${id != null ? '/$id' : ''}';
  }

  static String currencies([int? id]) {
    return '/currencies${id != null ? '/$id' : ''}';
  }

  static String subscriptionPlans = '/plans';
  static String nextInvoice = '/new-invoice';
  static String businessCategories([int? id]) {
    return '/business-categories${id != null ? '/$id' : ''}';
  }

  static String businessPaymentMethods([int? id]) {
    return '/payment-types${id != null ? '/$id' : ''}';
  }

  static const String notificationList = '/notifications';

  // Staff Designation Endpoint
  static String designations([int? id]) {
    return '/designations${id != null ? '/$id' : ''}';
  }

  static String staffs([int? id]) {
    return '/staffs${id != null ? '/$id' : ''}';
  }

  // Staff Role Permission
  static String rolePermissions([int? id]) {
    return '/role-permission${id != null ? '/$id' : ''}';
  }

  // Items Endpoint
  static String items([int? id]) {
    return '/products${id != null ? '/$id' : ''}';
  }

  static String stocks([int? id]) {
    return '/stocks${id != null ? '/$id' : ''}';
  }

  static String stockReport = '/stock-report';

  static String adjustStock(int id) {
    return '/stock-update/$id';
  }

  static String itemCategories([int? id]) {
    return '/categories${id != null ? '/$id' : ''}';
  }

  static String itemMenus([int? id]) {
    return '/menus${id != null ? '/$id' : ''}';
  }

  static String itemUnits([int? id]) {
    return '/units${id != null ? '/$id' : ''}';
  }

  static String ingredients([int? id]) {
    return '/ingredients${id != null ? '/$id' : ''}';
  }

  static String modifierGroups([int? id]) {
    return '/modifier-groups${id != null ? '/$id' : ''}';
  }

  static String itemModifier([int? id]) {
    return '/modifiers${id != null ? '/$id' : ''}';
  }

  // Party Endpoint
  static String parties([int? id]) {
    return '/parties${id != null ? '/$id' : ''}';
  }

  static String get deliveryAddress {
    return '/delivery-address';
  }

  static String partyLedger(int partyId) {
    return '${parties()}/view-ledger/$partyId';
  }

  static String transactions = '/transactions';
  static String transactionReport = '/transaction-report';

  // Purchase Endpoint
  static String purchase([int? id]) {
    return '/purchase${id != null ? '/$id' : ''}';
  }

  static String purchaseReport = '/purchase-report';

  // Sale Endpoint
  static String sale([int? id]) {
    return '/sales${id != null ? '/$id' : ''}';
  }

  // KOT Orders
  static final kotOrder = (
    list: '/kots',
    reports: '/kot-reports',
    orderStaus: (int id) => '/kots/kot-status/$id',
    itemStatus: (int id) => '/kots/cooking-status/$id',
    orderCancelReasons: '/kots/cancel-reasons',
  );

  static String kotPay(int id) {
    return '/sales/kot-pay/$id';
  }

  static String saleReport = '/sales-report';

  // Quotation Endpoint
  static String quotation([int? id]) {
    return '/quotations${id != null ? '/$id' : ''}';
  }

  static String quotationReport = '/quotation-report';

  // Due Endpoint
  static String dueList([int? id]) {
    return '/dues-list${id != null ? '/$id' : ''}';
  }

  static String dueReport = '/due-reports';

  static String dueCollectionList([int? id]) {
    return '/dues${id != null ? '/$id' : ''}';
  }

  static String dueCollectionReport = '/due-collects-report';

  // Table Endpoint
  static String tables([int? id]) {
    return '/tables${id != null ? '/$id' : ''}';
  }

  //  Area Endpont
  static String areas([int? id]) {
    return '/areas${id != null ? '/$id' : ''}';
  }

  // Tax Endpoint
  static String taxes([int? id]) {
    return '/taxes${id != null ? '/$id' : ''}';
  }

  static String coupons([int? id]) {
    return '/coupons${id != null ? '/$id' : ''}';
  }

  // Income Expense Endpoint
  static String incomes([int? id]) {
    return '/incomes${id != null ? '/$id' : ''}';
  }

  static String incomeReport = '/income-report';

  static String incomeCategories([int? id]) {
    return '/income-categories${id != null ? '/$id' : ''}';
  }

  static String expenses([int? id]) {
    return '/expenses${id != null ? '/$id' : ''}';
  }

  static String expenseReport = '/expense-report';

  static String expenseCategories([int? id]) {
    return '/expense-categories${id != null ? '/$id' : ''}';
  }

  // HRM Endpoint
  static final hrm = (
    departments: ([int? id]) => '/departments${id != null ? '/$id' : ''}',
    designations: ([int? id]) => '/designations${id != null ? '/$id' : ''}',
    shifts: ([int? id]) => '/shifts${id != null ? '/$id' : ''}',
    employees: ([int? id]) => '/employees${id != null ? '/$id' : ''}',
    holidays: ([int? id]) => '/holidays${id != null ? '/$id' : ''}',
    attendances: ([int? id]) => '/attendances${id != null ? '/$id' : ''}',
    payrolls: ([int? id]) => '/payrolls${id != null ? '/$id' : ''}',
    leaveTypes: ([int? id]) => '/leave-types${id != null ? '/$id' : ''}',
    leaves: ([int? id]) => '/leaves${id != null ? '/$id' : ''}',
    reports: (
      attendances: '/attendance-reports',
      payrolls: '/payroll-reports',
      leaves: '/leave-reports',
    ),
  );

  // Kitchen Endpoint
  static final kitchen = (
    kitchens: ([int? id]) => '/kitchens${id != null ? '/$id' : ''}',
    status: (int id) => '/kitchens/status/$id',
    unassignedProduct: '/kitchens/unassigned-product',
    assignItems: (int id) => '/kitchens/item-assign/$id',
    deleteItem: (int id) => '/kitchens/item-delete/$id',
  );

  static String moneyInOut = '/money-in-out';
  static String lossProfit = '/loss-profit-report';

  // Common Endpoint
  static String termsConditions = '/term-condition';
  static String privacyPolicy = '/privacy-policy';
  static String aboutUs = '/about-us';
  static String dashboardSummary = '/summary';
  static String dashboardChart = '/dashboard-chart';
  //-----------------------------Endpoints-----------------------------//
}
