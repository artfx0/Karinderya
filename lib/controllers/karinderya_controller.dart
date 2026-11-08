import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../models/cart_item.dart';
import '../models/customer.dart';
import '../models/dish.dart';
import '../models/order.dart';
import '../models/seed_data.dart';
import '../models/staff_member.dart';

class KarinderyaController extends ChangeNotifier {
  // Screen & Navigation
  ScreenState _screen = ScreenState.splash;
  UserRole _role = UserRole.staff;
  bool _kitchenMode = false;
  int _staffTabIndex = 0; // 0: Menu, 1: Orders, 2: New Order, 3: Utang, 4: Account
  int _ownerTabIndex = 0; // 0: Sales, 1: Menu Setup, 2: Staff, 3: Utang

  // Core Data
  late List<Dish> _dishes;
  late List<Order> _orders;
  late List<Customer> _customers;
  late List<StaffMember> _staff;
  final List<CartItem> _cart = [];

  // Active Order Context
  String _activeTableNum = '04';
  OrderKind _activeOrderKind = OrderKind.dineIn;
  int _orderCounter = 1042;
  double _dailyGoal = 5000.0;
  DishCategory _selectedCategory = DishCategory.all;
  String _searchQuery = '';
  OrderStatus _selectedOrderTab = OrderStatus.preparing;

  // Last completed transaction info for Cash & Success screens
  double _lastTotalPaid = 0.0;
  double _lastChange = 0.0;
  String _lastOrderNum = '';

  KarinderyaController() {
    _dishes = List.from(SeedData.initialDishes);
    _orders = List.from(SeedData.initialOrders);
    _customers = List.from(SeedData.initialCustomers);
    _staff = List.from(SeedData.initialStaff);
  }

  // Getters
  ScreenState get screen => _screen;
  UserRole get role => _role;
  bool get kitchenMode => _kitchenMode;
  int get staffTabIndex => _staffTabIndex;
  int get ownerTabIndex => _ownerTabIndex;

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
    return _orders.where((order) => order.status == _selectedOrderTab).toList();
  }

  int getOrderCountByStatus(OrderStatus status) {
    return _orders.where((order) => order.status == status).length;
  }

  // Notifications: Low stock (< 25% cap or <= 2) and ready orders
  List<Dish> get lowStockDishes {
    return _dishes.where((d) => d.isAvailable && (d.stock <= 2 || d.stockRatio < 0.25)).toList();
  }

  List<Order> get readyOrders {
    return _orders.where((o) => o.status == OrderStatus.ready).toList();
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

  void login(UserRole role) {
    _role = role;
    _screen = role == UserRole.owner ? ScreenState.owner : ScreenState.staff;
    notifyListeners();
  }

  void logout() {
    _cart.clear();
    _screen = ScreenState.login;
    _staffTabIndex = 0;
    _ownerTabIndex = 0;
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

  // Payment & Utang Operations
  void prepareCashPayment() {
    _screen = ScreenState.cashPayment;
    notifyListeners();
  }

  void completeCashPayment(double cashReceived) {
    final total = cartTotal;
    final change = cashReceived - total;

    // Deduct stock from dishes
    _deductCartStock();

    // Create completed order
    final newOrder = Order(
      id: _orderCounter.toString(),
      tableNum: _activeTableNum,
      kind: _activeOrderKind,
      items: List.from(_cart),
      total: total,
      status: OrderStatus.preparing,
      payStatus: PaymentStatus.paid,
      createdAt: DateTime.now(),
    );
    _orders.insert(0, newOrder);

    _lastTotalPaid = total;
    _lastChange = change >= 0 ? change : 0;
    _lastOrderNum = _orderCounter.toString();
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
      customerName: customerName.trim(),
      createdAt: DateTime.now(),
    );
    _orders.insert(0, newOrder);

    _orderCounter++;
    _cart.clear();
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
