enum ScreenState {
  splash,
  login,
  staff,
  owner,
  cashPayment,
  success,
}

enum UserRole {
  staff,
  owner,
}

enum DishCategory {
  all,
  ulam,
  rice,
  soup,
  drinks,
}

enum OrderStatus {
  preparing,
  ready,
  served,
}

enum PaymentStatus {
  paid,
  unpaid,
  onDebt,
}

enum PaymentMethod {
  cash,
  gcash,
  maya,
  utang,
}

enum OrderKind {
  dineIn,
  takeout,
}
