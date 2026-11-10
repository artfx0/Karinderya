import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../models/cart_item.dart';
import '../models/customer.dart';
import '../models/dish.dart';
import '../models/order.dart';
import '../models/seed_data.dart';
import '../models/shift_record.dart';
import '../models/staff_member.dart';

class KarinderyaController extends ChangeNotifier {
  // Screen & Navigation
  ScreenState _screen = ScreenState.splash;
  UserRole _role = UserRole.staff;
  bool _kitchenMode = false;
  int _staffTabIndex = 0; // 0: Menu, 1: Orders, 2: History, 3: Shift, 4: Settings
  int _ownerTabIndex = 0; // 0: Sales, 1: Menu Setup, 2: Staff, 3: Utang

  // Core Data
  late List<Dish> _dishes;
  late List<Order> _orders;
  late List<Customer> _customers;
  late List<StaffMember> _staff;
  final List<CartItem> _cart = [];

  // Active User & Shift Tracking
  String _currentStaffName = 'Ana Reyes';
  String _currentStaffId = 'staff-2';
  ShiftRecord? _currentShift;

  // Owner Analytics & Filter State
  DateTime _selectedSalesDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  DishCategory _ownerMenuCategory = DishCategory.ulam;
  String _ownerMenuSearchQuery = '';
  OwnerMenuSortOption _ownerMenuSort = OwnerMenuSortOption.defaultOrder;
  OwnerMenuAvailabilityFilter _ownerMenuAvailability = OwnerMenuAvailabilityFilter.all;
  String _ownerStaffSearchQuery = '';
  String _ownerUtangSearchQuery = '';

  // Active Order Context
  String _activeTableNum = '04';
  OrderKind _activeOrderKind = OrderKind.dineIn;
  int _orderCounter = 1043;
  double _dailyGoal = 5000.0;
  DishCategory _selectedCategory = DishCategory.all;
  String _searchQuery = '';
  OrderStatus _selectedOrderTab = OrderStatus.preparing;

  // Last completed transaction info for Cash & Success screens
  double _lastTotalPaid = 0.0;
  double _lastChange = 0.0;
  String _lastOrderNum = '';
  PaymentMethod _lastPaymentMethod = PaymentMethod.cash;
  String? _lastReferenceNumber;

  // Owner PIN for voiding/refunding transactions
  static const String ownerPin = '1234';

  KarinderyaController() {
    _dishes = List.from(SeedData.initialDishes);
    _orders = List.from(SeedData.initialOrders);
    _customers = List.from(SeedData.initialCustomers);
    _staff = List.from(SeedData.initialStaff);

    // Initialize initial shift for sample staff cashier
    _currentShift = ShiftRecord(
      cashierId: _currentStaffId,
      cashierName: _currentStaffName,
      startedAt: DateTime.now().subtract(const Duration(hours: 3)),
      startingFloat: 1000.0,
      cashSales: 400.0,
      gcashSales: 240.0,
      mayaSales: 0.0,
      utangIssued: 220.0,
      utangCollected: 0.0,
      ordersCount: 4,
    );
  }

  // Getters
  ScreenState get screen => _screen;
  UserRole get role => _role;
  bool get kitchenMode => _kitchenMode;
  int get staffTabIndex => _staffTabIndex;
  int get ownerTabIndex => _ownerTabIndex;

  String get currentStaffName => _currentStaffName;
  String get currentStaffId => _currentStaffId;
  ShiftRecord? get currentShift => _currentShift;

  List<Dish> get dishes => List.unmodifiable(_dishes);
  List<CartItem> get cart => List.unmodifiable(_cart);
  List<Order> get orders => List.unmodifiable(_orders);
  List<Customer> get customers => List.unmodifiable(_customers);
  List<StaffMember> get staff => List.unmodifiable(_staff);

  String get activeTableNum => _activeTableNum;
  OrderKind get activeOrderKind => _activeOrderKind;
  String get activeOrderNumber => _orderCounter.toString();
  double get dailyGoal => _dailyGoal;
  DishCategory get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  OrderStatus get selectedOrderTab => _selectedOrderTab;

  double get lastTotalPaid => _lastTotalPaid;
  double get lastChange => _lastChange;
  String get lastOrderNum => _lastOrderNum;
  PaymentMethod get lastPaymentMethod => _lastPaymentMethod;
  String? get lastReferenceNumber => _lastReferenceNumber;

  Order? get lastCompletedOrder {
    try {
      return _orders.firstWhere((o) => o.id == _lastOrderNum);
    } catch (_) {
      return _orders.isNotEmpty ? _orders.first : null;
    }
  }

  // Cart Calculations
  double get cartTotal => _cart.fold(0.0, (sum, item) => sum + item.lineTotal);
  int get cartItemCount => _cart.fold(0, (sum, item) => sum + item.quantity);
  bool get isCartEmpty => _cart.isEmpty;

  // Filtered Dishes
  List<Dish> get filteredDishes {
    return _dishes.where((dish) {
      final matchesCategory = _selectedCategory == DishCategory.all || dish.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty || dish.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  // Filtered Orders
  List<Order> get ordersBySelectedStatus {
    return _orders.where((order) => !order.isVoided && order.status == _selectedOrderTab).toList();
  }

  int getOrderCountByStatus(OrderStatus status) {
    return _orders.where((order) => !order.isVoided && order.status == status).length;
  }

  // Notifications: Low stock (< 25% cap or <= 2) and ready orders
  List<Dish> get lowStockDishes {
    return _dishes.where((d) => d.isAvailable && (d.stock <= 2 || d.stockRatio < 0.25)).toList();
  }

  List<Order> get readyOrders {
    return _orders.where((o) => !o.isVoided && o.status == OrderStatus.ready).toList();
  }

  // Owner Reactive Sales Date Filtering
  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  bool _isSameCalendarDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  DateTime get selectedSalesDate => _dateOnly(_selectedSalesDate);

  bool get isSelectedSalesDateToday => _isSameCalendarDate(_selectedSalesDate, DateTime.now());

  void setSalesDate(DateTime date) {
    _selectedSalesDate = _dateOnly(date);
    notifyListeners();
  }

  List<Order> get ordersForSelectedDate {
    return _orders
        .where((o) => !o.isVoided && _isSameCalendarDate(o.createdAt, _selectedSalesDate))
        .toList();
  }

  double get totalSalesForSelectedDate {
    return ordersForSelectedDate.fold(0.0, (sum, o) => sum + o.total);
  }

  double get paidSalesForSelectedDate {
    return ordersForSelectedDate
        .where((o) => o.payStatus == PaymentStatus.paid)
        .fold(0.0, (sum, o) => sum + o.total);
  }

  double get cashSalesForSelectedDate {
    return ordersForSelectedDate
        .where((o) => o.paymentMethod == PaymentMethod.cash)
        .fold(0.0, (sum, o) => sum + o.total);
  }

  double get utangSalesForSelectedDate {
    return ordersForSelectedDate
        .where((o) => o.payStatus == PaymentStatus.onDebt)
        .fold(0.0, (sum, o) => sum + o.total);
  }

  ({String name, int count, double revenue})? get topDishForSelectedDate {
    final counts = <String, int>{};
    final revenues = <String, double>{};
    for (final order in ordersForSelectedDate) {
      for (final item in order.items) {
        final name = item.dish.name;
        counts[name] = (counts[name] ?? 0) + item.quantity;
        revenues[name] = (revenues[name] ?? 0.0) + item.lineTotal;
      }
    }
    if (counts.isEmpty) return null;
    final topEntry = counts.entries.reduce((a, b) => a.value >= b.value ? a : b);
    return (
      name: topEntry.key,
      count: topEntry.value,
      revenue: revenues[topEntry.key] ?? 0.0,
    );
  }

  // Owner Menu Setup: Strictly Categorized + Search & Sort State
  DishCategory get ownerMenuCategory => _ownerMenuCategory;
  String get ownerMenuSearchQuery => _ownerMenuSearchQuery;
  OwnerMenuSortOption get ownerMenuSort => _ownerMenuSort;
  OwnerMenuAvailabilityFilter get ownerMenuAvailability => _ownerMenuAvailability;

  bool get hasActiveOwnerMenuFilter =>
      _ownerMenuSort != OwnerMenuSortOption.defaultOrder ||
      _ownerMenuAvailability != OwnerMenuAvailabilityFilter.all;

  void setOwnerMenuCategory(DishCategory category) {
    if (category == DishCategory.all) return;
    _ownerMenuCategory = category;
    notifyListeners();
  }

  void setOwnerMenuSearchQuery(String query) {
    _ownerMenuSearchQuery = query;
    notifyListeners();
  }

  void setOwnerMenuSort(OwnerMenuSortOption sort) {
    _ownerMenuSort = sort;
    notifyListeners();
  }

  void setOwnerMenuAvailability(OwnerMenuAvailabilityFilter availability) {
    _ownerMenuAvailability = availability;
    notifyListeners();
  }

  void resetOwnerMenuFilters() {
    _ownerMenuSort = OwnerMenuSortOption.defaultOrder;
    _ownerMenuAvailability = OwnerMenuAvailabilityFilter.all;
    notifyListeners();
  }

  int getOwnerDishCountForCategory(DishCategory category) {
    final query = _ownerMenuSearchQuery.trim().toLowerCase();
    return _dishes.where((dish) {
      if (dish.category != category) return false;
      if (query.isNotEmpty && !dish.name.toLowerCase().contains(query)) return false;
      if (_ownerMenuAvailability == OwnerMenuAvailabilityFilter.availableOnly && dish.isSoldOut) {
        return false;
      }
      if (_ownerMenuAvailability == OwnerMenuAvailabilityFilter.soldOutOnly && !dish.isSoldOut) {
        return false;
      }
      return true;
    }).length;
  }

  List<Dish> get filteredOwnerDishes {
    final query = _ownerMenuSearchQuery.trim().toLowerCase();
    final filtered = _dishes.where((dish) {
      if (dish.category != _ownerMenuCategory) return false;
      if (query.isNotEmpty && !dish.name.toLowerCase().contains(query)) return false;
      if (_ownerMenuAvailability == OwnerMenuAvailabilityFilter.availableOnly && dish.isSoldOut) {
        return false;
      }
      if (_ownerMenuAvailability == OwnerMenuAvailabilityFilter.soldOutOnly && !dish.isSoldOut) {
        return false;
      }
      return true;
    }).toList();

    switch (_ownerMenuSort) {
      case OwnerMenuSortOption.defaultOrder:
        break;
      case OwnerMenuSortOption.nameAZ:
        filtered.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      case OwnerMenuSortOption.priceLowToHigh:
        filtered.sort((a, b) => a.price.compareTo(b.price));
      case OwnerMenuSortOption.priceHighToLow:
        filtered.sort((a, b) => b.price.compareTo(a.price));
      case OwnerMenuSortOption.stockLowToHigh:
        filtered.sort((a, b) => a.stock.compareTo(b.stock));
      case OwnerMenuSortOption.stockHighToLow:
        filtered.sort((a, b) => b.stock.compareTo(a.stock));
    }

    return filtered;
  }

  // Owner Staff Directory Search
  String get ownerStaffSearchQuery => _ownerStaffSearchQuery;

  void setOwnerStaffSearchQuery(String query) {
    _ownerStaffSearchQuery = query;
    notifyListeners();
  }

  List<StaffMember> get filteredStaff {
    final query = _ownerStaffSearchQuery.trim().toLowerCase();
    if (query.isEmpty) return List.unmodifiable(_staff);
    return _staff.where((s) => s.name.toLowerCase().contains(query)).toList();
  }

  // Owner Utang Ledger: Search & Auto-Clear Settled Debts (balance > 0)
  String get ownerUtangSearchQuery => _ownerUtangSearchQuery;

  void setOwnerUtangSearchQuery(String query) {
    _ownerUtangSearchQuery = query;
    notifyListeners();
  }

  List<Customer> get activeDebtors {
    final query = _ownerUtangSearchQuery.trim().toLowerCase();
    return _customers.where((c) {
      if (c.balance <= 0) return false;
      if (query.isEmpty) return true;
      return c.name.toLowerCase().contains(query) ||
          c.contactInfo.toLowerCase().contains(query);
    }).toList();
  }

  // State Transition Handlers
  void setScreen(ScreenState newScreen) {
    _screen = newScreen;
    notifyListeners();
  }

  void setRole(UserRole newRole) {
    _role = newRole;
    notifyListeners();
  }

  void toggleKitchenMode() {
    _kitchenMode = !_kitchenMode;
    notifyListeners();
  }

  void setStaffTabIndex(int index) {
    _staffTabIndex = index;
    notifyListeners();
  }

  void setOwnerTabIndex(int index) {
    _ownerTabIndex = index;
    notifyListeners();
  }

  void setSelectedCategory(DishCategory category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedOrderTab(OrderStatus status) {
    _selectedOrderTab = status;
    notifyListeners();
  }

  // Backend-Determined Authentication (No Demo Toggles)
  bool loginWithCredentials(String email, String password) {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPassword = password.trim();

    // Check Owner Account
    if (cleanEmail == SeedData.demoOwnerEmail &&
        (cleanPassword == SeedData.demoOwnerPassword || cleanPassword == 'owner123')) {
      _role = UserRole.owner;
      _currentStaffName = 'Aling Nena';
      _currentStaffId = 'owner-1';
      _screen = ScreenState.owner;
      notifyListeners();
      return true;
    }

    // Check Staff Accounts
    if (cleanEmail == SeedData.demoStaffEmail &&
        (cleanPassword == SeedData.demoStaffPassword || cleanPassword == 'staff123')) {
      _role = UserRole.staff;
      _currentStaffName = 'Ana Reyes';
      _currentStaffId = 'staff-2';
      _startShiftForCurrentStaff();
      _screen = ScreenState.staff;
      notifyListeners();
      return true;
    }

    // Check custom staff members
    final staffMatch = _staff.where((s) => s.name.toLowerCase() == cleanEmail || cleanEmail.startsWith(s.name.split(' ')[0].toLowerCase()));
    if (staffMatch.isNotEmpty && cleanPassword.isNotEmpty) {
      final staffUser = staffMatch.first;
      _role = staffUser.role;
      _currentStaffName = staffUser.name;
      _currentStaffId = staffUser.id;
      if (_role == UserRole.staff) {
        _startShiftForCurrentStaff();
        _screen = ScreenState.staff;
      } else {
        _screen = ScreenState.owner;
      }
      notifyListeners();
      return true;
    }

    return false;
  }

  void _startShiftForCurrentStaff() {
    _currentShift = ShiftRecord(
      cashierId: _currentStaffId,
      cashierName: _currentStaffName,
      startedAt: DateTime.now(),
      startingFloat: 1000.0,
    );
  }

  void logout() {
    _cart.clear();
    _screen = ScreenState.login;
    _staffTabIndex = 0;
    _ownerTabIndex = 0;
    _selectedSalesDate = _dateOnly(DateTime.now());
    _ownerMenuCategory = DishCategory.ulam;
    _ownerMenuSearchQuery = '';
    _ownerMenuSort = OwnerMenuSortOption.defaultOrder;
    _ownerMenuAvailability = OwnerMenuAvailabilityFilter.all;
    _ownerStaffSearchQuery = '';
    _ownerUtangSearchQuery = '';
    notifyListeners();
  }

  // Cart Operations
  bool addToCart(Dish dish) {
    if (dish.isSoldOut) return false;

    final index = _cart.indexWhere((item) => item.dish.id == dish.id);
    final currentQty = index >= 0 ? _cart[index].quantity : 0;

    // Check against available stock
    if (currentQty >= dish.stock) {
      return false;
    }

    if (index >= 0) {
      _cart[index] = _cart[index].copyWith(quantity: currentQty + 1);
    } else {
      _cart.add(CartItem(dish: dish, quantity: 1));
    }
    notifyListeners();
    return true;
  }

  void removeFromCart(String dishId) {
    _cart.removeWhere((item) => item.dish.id == dishId);
    notifyListeners();
  }

  void updateCartQuantity(String dishId, int delta) {
    final index = _cart.indexWhere((item) => item.dish.id == dishId);
    if (index < 0) return;

    final newQty = _cart[index].quantity + delta;
    if (newQty <= 0) {
      _cart.removeAt(index);
    } else {
      final dish = _cart[index].dish;
      if (newQty <= dish.stock) {
        _cart[index] = _cart[index].copyWith(quantity: newQty);
      }
    }
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  void startNewOrder({required OrderKind kind, String tableNum = '04'}) {
    _activeOrderKind = kind;
    _activeTableNum = kind == OrderKind.takeout ? 'Takeout' : (tableNum.isEmpty ? '04' : tableNum);
    _cart.clear();
    _staffTabIndex = 0; // Go to menu
    notifyListeners();
  }

  // Payment Operations
  void prepareCashPayment() {
    _screen = ScreenState.cashPayment;
    notifyListeners();
  }

  void completeCashPayment(double cashReceived) {
    final total = cartTotal;
    final change = cashReceived - total;

    _deductCartStock();

    final newOrder = Order(
      id: _orderCounter.toString(),
      tableNum: _activeTableNum,
      kind: _activeOrderKind,
      items: List.from(_cart),
      total: total,
      status: OrderStatus.preparing,
      payStatus: PaymentStatus.paid,
      paymentMethod: PaymentMethod.cash,
      staffId: _currentStaffId,
      staffName: _currentStaffName,
      createdAt: DateTime.now(),
    );
    _orders.insert(0, newOrder);

    // Update active shift record
    if (_currentShift != null) {
      _currentShift = _currentShift!.copyWith(
        cashSales: _currentShift!.cashSales + total,
        ordersCount: _currentShift!.ordersCount + 1,
      );
    }

    _lastTotalPaid = total;
    _lastChange = change >= 0 ? change : 0;
    _lastOrderNum = _orderCounter.toString();
    _lastPaymentMethod = PaymentMethod.cash;
    _lastReferenceNumber = null;
    _orderCounter++;

    _cart.clear();
    _screen = ScreenState.success;
    notifyListeners();
  }

  void completeDigitalPayment({
    required PaymentMethod method,
    required String referenceNumber,
  }) {
    final total = cartTotal;
    _deductCartStock();

    final newOrder = Order(
      id: _orderCounter.toString(),
      tableNum: _activeTableNum,
      kind: _activeOrderKind,
      items: List.from(_cart),
      total: total,
      status: OrderStatus.preparing,
      payStatus: PaymentStatus.paid,
      paymentMethod: method,
      referenceNumber: referenceNumber.trim(),
      staffId: _currentStaffId,
      staffName: _currentStaffName,
      createdAt: DateTime.now(),
    );
    _orders.insert(0, newOrder);

    // Update shift record
    if (_currentShift != null) {
      if (method == PaymentMethod.gcash) {
        _currentShift = _currentShift!.copyWith(
          gcashSales: _currentShift!.gcashSales + total,
          ordersCount: _currentShift!.ordersCount + 1,
        );
      } else if (method == PaymentMethod.maya) {
        _currentShift = _currentShift!.copyWith(
          mayaSales: _currentShift!.mayaSales + total,
          ordersCount: _currentShift!.ordersCount + 1,
        );
      }
    }

    _lastTotalPaid = total;
    _lastChange = 0.0;
    _lastOrderNum = _orderCounter.toString();
    _lastPaymentMethod = method;
    _lastReferenceNumber = referenceNumber.trim();
    _orderCounter++;

    _cart.clear();
    _screen = ScreenState.success;
    notifyListeners();
  }

  bool recordUtang(String customerName) {
    if (customerName.trim().isEmpty || _cart.isEmpty) return false;

    final total = cartTotal;
    _deductCartStock();

    // Check if customer exists or create new
    final existingIndex = _customers.indexWhere(
      (c) => c.name.toLowerCase() == customerName.trim().toLowerCase(),
    );

    if (existingIndex >= 0) {
      final existing = _customers[existingIndex];
      _customers[existingIndex] = existing.copyWith(
        balance: existing.balance + total,
        originalTotal: existing.originalTotal + total,
        openOrders: existing.openOrders + 1,
      );
    } else {
      _customers.insert(
        0,
        Customer(
          id: 'cust-${DateTime.now().millisecondsSinceEpoch}',
          name: customerName.trim(),
          balance: total,
          originalTotal: total,
          openOrders: 1,
          date: 'Today',
        ),
      );
    }

    final newOrder = Order(
      id: _orderCounter.toString(),
      tableNum: _activeTableNum,
      kind: _activeOrderKind,
      items: List.from(_cart),
      total: total,
      status: OrderStatus.preparing,
      payStatus: PaymentStatus.onDebt,
      paymentMethod: PaymentMethod.utang,
      customerName: customerName.trim(),
      staffId: _currentStaffId,
      staffName: _currentStaffName,
      createdAt: DateTime.now(),
    );
    _orders.insert(0, newOrder);

    // Update shift record
    if (_currentShift != null) {
      _currentShift = _currentShift!.copyWith(
        utangIssued: _currentShift!.utangIssued + total,
        ordersCount: _currentShift!.ordersCount + 1,
      );
    }

    _lastTotalPaid = total;
    _lastChange = 0.0;
    _lastOrderNum = _orderCounter.toString();
    _lastPaymentMethod = PaymentMethod.utang;
    _lastReferenceNumber = null;
    _orderCounter++;

    _cart.clear();
    _screen = ScreenState.success;
    notifyListeners();
    return true;
  }

  void _deductCartStock() {
    for (final item in _cart) {
      final dishIndex = _dishes.indexWhere((d) => d.id == item.dish.id);
      if (dishIndex >= 0) {
        final currentStock = _dishes[dishIndex].stock;
        final newStock = (currentStock - item.quantity).clamp(0, _dishes[dishIndex].cap);
        _dishes[dishIndex] = _dishes[dishIndex].copyWith(
          stock: newStock,
          isAvailable: newStock > 0 ? _dishes[dishIndex].isAvailable : false,
        );
      }
    }
  }

  // Order Progression
  void advanceOrderStatus(String orderId) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index < 0) return;

    final currentOrder = _orders[index];
    if (currentOrder.status == OrderStatus.preparing) {
      _orders[index] = currentOrder.copyWith(status: OrderStatus.ready);
    } else if (currentOrder.status == OrderStatus.ready) {
      _orders[index] = currentOrder.copyWith(status: OrderStatus.served);
    }
    notifyListeners();
  }

  // Owner PIN Override: Voiding / Refunding an Order
  bool verifyOwnerPin(String pin) {
    return pin.trim() == ownerPin;
  }

  bool voidOrder({
    required String orderId,
    required String reason,
    required String pin,
  }) {
    if (!verifyOwnerPin(pin)) return false;

    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index < 0) return false;

    final order = _orders[index];
    if (order.isVoided) return false;

    // Restore dish stock quantities
    for (final item in order.items) {
      final dishIndex = _dishes.indexWhere((d) => d.id == item.dish.id);
      if (dishIndex >= 0) {
        final currentStock = _dishes[dishIndex].stock;
        final restoredStock = (currentStock + item.quantity).clamp(0, _dishes[dishIndex].cap);
        _dishes[dishIndex] = _dishes[dishIndex].copyWith(
          stock: restoredStock,
          isAvailable: true,
        );
      }
    }

    // Mark as voided
    _orders[index] = order.copyWith(
      isVoided: true,
      voidReason: reason,
    );

    // Adjust shift totals and customer ledger if applicable
    if (_currentShift != null) {
      if (order.paymentMethod == PaymentMethod.cash) {
        _currentShift = _currentShift!.copyWith(
          cashSales: (_currentShift!.cashSales - order.total).clamp(0.0, double.infinity),
        );
      } else if (order.paymentMethod == PaymentMethod.gcash) {
        _currentShift = _currentShift!.copyWith(
          gcashSales: (_currentShift!.gcashSales - order.total).clamp(0.0, double.infinity),
        );
      } else if (order.paymentMethod == PaymentMethod.maya) {
        _currentShift = _currentShift!.copyWith(
          mayaSales: (_currentShift!.mayaSales - order.total).clamp(0.0, double.infinity),
        );
      } else if (order.paymentMethod == PaymentMethod.utang) {
        _currentShift = _currentShift!.copyWith(
          utangIssued: (_currentShift!.utangIssued - order.total).clamp(0.0, double.infinity),
        );
        if (order.customerName != null) {
          final custIndex = _customers.indexWhere(
            (c) => c.name.toLowerCase() == order.customerName!.toLowerCase(),
          );
          if (custIndex >= 0) {
            final cust = _customers[custIndex];
            _customers[custIndex] = cust.copyWith(
              balance: (cust.balance - order.total).clamp(0.0, double.infinity),
              openOrders: (cust.openOrders - 1).clamp(0, 999),
            );
          }
        }
      }
    }

    notifyListeners();
    return true;
  }

  // Shift Drawer Helpers
  void updateStartingFloat(double float) {
    if (_currentShift != null) {
      _currentShift = _currentShift!.copyWith(startingFloat: float);
      notifyListeners();
    }
  }

  void updateCountedCash(double countedCash) {
    if (_currentShift != null) {
      _currentShift = _currentShift!.copyWith(actualCountedCash: countedCash);
      notifyListeners();
    }
  }

  void endCurrentShift() {
    if (_currentShift != null) {
      _currentShift = _currentShift!.copyWith(endedAt: DateTime.now());
      notifyListeners();
    }
  }

  // Owner Operations
  void settleCustomerDebt(String customerId, double amount) {
    final index = _customers.indexWhere((c) => c.id == customerId);
    if (index < 0) return;

    final current = _customers[index];
    final newBalance = (current.balance - amount).clamp(0.0, double.infinity);
    _customers[index] = current.copyWith(
      balance: newBalance,
      openOrders: newBalance <= 0 ? 0 : current.openOrders,
    );

    // If staff recorded this cash debt payment during their shift
    if (_currentShift != null) {
      _currentShift = _currentShift!.copyWith(
        utangCollected: _currentShift!.utangCollected + amount,
      );
    }

    notifyListeners();
  }

  void addDebtor({
    required String name,
    required String contactInfo,
    required double initialDebt,
  }) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final now = DateTime.now();
    final formattedDate = '${months[now.month - 1]} ${now.day}, ${now.year}';

    _customers.insert(
      0,
      Customer(
        id: 'cust-${now.millisecondsSinceEpoch}',
        name: name.trim(),
        contactInfo: contactInfo.trim(),
        balance: initialDebt,
        originalTotal: initialDebt,
        openOrders: 1,
        date: formattedDate,
      ),
    );
    notifyListeners();
  }

  void toggleDishAvailability(String dishId) {
    final index = _dishes.indexWhere((d) => d.id == dishId);
    if (index >= 0) {
      _dishes[index] = _dishes[index].copyWith(
        isAvailable: !_dishes[index].isAvailable,
      );
      notifyListeners();
    }
  }

  void updateDishStock(String dishId, int newStock) {
    final index = _dishes.indexWhere((d) => d.id == dishId);
    if (index >= 0) {
      final clamped = newStock.clamp(0, _dishes[index].cap);
      _dishes[index] = _dishes[index].copyWith(
        stock: clamped,
        isAvailable: clamped > 0,
      );
      notifyListeners();
    }
  }

  void updateDishCap(String dishId, int newCap) {
    final index = _dishes.indexWhere((d) => d.id == dishId);
    if (index >= 0 && newCap >= 0) {
      _dishes[index] = _dishes[index].copyWith(
        cap: newCap,
        stock: _dishes[index].stock > newCap ? newCap : _dishes[index].stock,
      );
      notifyListeners();
    }
  }

  void addDish(Dish dish) {
    _dishes.add(dish);
    notifyListeners();
  }

  void toggleStaffShift(String staffId) {
    final index = _staff.indexWhere((s) => s.id == staffId);
    if (index >= 0) {
      _staff[index] = _staff[index].copyWith(onShift: !_staff[index].onShift);
      notifyListeners();
    }
  }

  void addStaff(StaffMember member) {
    _staff.add(member);
    notifyListeners();
  }

  void updateDailyGoal(double newGoal) {
    if (newGoal > 0) {
      _dailyGoal = newGoal;
      notifyListeners();
    }
  }
}
