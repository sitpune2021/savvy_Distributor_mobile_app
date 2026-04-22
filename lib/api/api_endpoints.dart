class ApiEndpoints {
  static const String login = "/login";
  static const String logout = "/logout";
  static const String resetPassword = "/reset-password";

  static const String orderSummary = "/distributor/orders/summary";

  static const String labels = "/labels?type=distributor";
  static const String plant = "/plant";
  static const String orderRequest = "/distributor/orders";
  static const String pendingOrder =
      "/distributor/orders?step=requested&status=pending";
  static const String approvedOrder = "/";

  static const String orderList = "/distributor/orders";
}
