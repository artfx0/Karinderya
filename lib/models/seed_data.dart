import 'app_state.dart';
import 'dish.dart';
import 'order.dart';
import 'cart_item.dart';
import 'customer.dart';
import 'staff_member.dart';

class SeedData {
  // Demo Login Credentials
  static const String demoStaffEmail = 'staff@karinderya.ph';
  static const String demoStaffPassword = 'staff';
  static const String demoOwnerEmail = 'owner@karinderya.ph';
  static const String demoOwnerPassword = 'owner';

  // Seed Dishes
  static List<Dish> get initialDishes => [
        const Dish(
          id: 'dish-1',
          name: 'Chicken Adobo',
          price: 90.0,
          category: DishCategory.ulam,
          stock: 12,
          cap: 15,
          image: 'assets/adobo.svg',
          isAvailable: true,
        ),
        const Dish(
          id: 'dish-2',
          name: 'Pork Sinigang',
          price: 110.0,
          category: DishCategory.soup,
          stock: 8,
          cap: 12,
          image: 'assets/sinigang.svg',
          isAvailable: true,
        ),
        const Dish(
          id: 'dish-3',
          name: 'Lumpiang Shanghai',
          price: 60.0,
          category: DishCategory.ulam,
          stock: 5,
          cap: 20,
          image: 'assets/lumpia.svg',
          isAvailable: true,
        ),
        const Dish(
          id: 'dish-4',
          name: 'Steamed Rice',
          price: 20.0,
          category: DishCategory.rice,
          stock: 20,
          cap: 25,
          image: 'assets/rice.svg',
          isAvailable: true,
        ),
        const Dish(
          id: 'dish-5',
          name: 'Pinakbet Tagalog',
          price: 75.0,
          category: DishCategory.ulam,
          stock: 0,
          cap: 10,
          image: 'assets/adobo.svg',
          isAvailable: false, // Initial sold-out item to demonstrate ribbons
        ),
        const Dish(
          id: 'dish-6',
          name: 'Sago’t Gulaman',
          price: 25.0,
          category: DishCategory.drinks,
          stock: 15,
          cap: 20,
          image: 'assets/rice.svg',
          isAvailable: true,
        ),
      ];

  // Seed Orders
  static List<Order> get initialOrders {
    final dishes = initialDishes;
    return [
      Order(
        id: '1040',
        tableNum: '02',
        kind: OrderKind.dineIn,
        items: [
          CartItem(dish: dishes[0], quantity: 1), // Adobo 90
          CartItem(dish: dishes[3], quantity: 1), // Rice 20
        ],
        total: 110.0,
        status: OrderStatus.preparing,
        payStatus: PaymentStatus.paid,
        createdAt: DateTime.now().subtract(const Duration(minutes: 18)),
      ),
      Order(
        id: '1041',
        tableNum: 'Takeout',
        kind: OrderKind.takeout,
        items: [
          CartItem(dish: dishes[1], quantity: 2), // Sinigang 220
          CartItem(dish: dishes[3], quantity: 1), // Rice 20
        ],
        total: 240.0,
        status: OrderStatus.ready,
        payStatus: PaymentStatus.paid,
        createdAt: DateTime.now().subtract(const Duration(minutes: 32)),
      ),
      Order(
        id: '1039',
        tableNum: '01',
        kind: OrderKind.dineIn,
        items: [
          CartItem(dish: dishes[2], quantity: 2), // Lumpia 120
          CartItem(dish: dishes[1], quantity: 1), // Sinigang 110
          CartItem(dish: dishes[3], quantity: 3), // Rice 60
        ],
        total: 290.0,
        status: OrderStatus.served,
        payStatus: PaymentStatus.paid,
        createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 10)),
      ),
      Order(
        id: '1038',
        tableNum: '03',
        kind: OrderKind.dineIn,
        items: [
          CartItem(dish: dishes[0], quantity: 2), // Adobo 180
          CartItem(dish: dishes[3], quantity: 2), // Rice 40
        ],
        total: 220.0,
        status: OrderStatus.served,
        payStatus: PaymentStatus.onDebt,
        customerName: 'Mang Kanor',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];
  }

  // Seed Customer Debts
  static List<Customer> get initialCustomers => [
        const Customer(
          id: 'cust-1',
          name: 'Mang Kanor',
          balance: 350.0,
          originalTotal: 500.0,
          openOrders: 2,
          date: 'Nov 6, 2026',
        ),
        const Customer(
          id: 'cust-2',
          name: 'Ate Gina',
          balance: 120.0,
          originalTotal: 120.0,
          openOrders: 1,
          date: 'Nov 7, 2026',
        ),
        const Customer(
          id: 'cust-3',
          name: 'Tito Boy',
          balance: 240.0,
          originalTotal: 300.0,
          openOrders: 1,
          date: 'Nov 7, 2026',
        ),
        const Customer(
          id: 'cust-4',
          name: 'Kuya Jojo',
          balance: 0.0,
          originalTotal: 280.0,
          openOrders: 0,
          date: 'Nov 5, 2026', // Fully paid
        ),
      ];

  // Seed Staff Members
  static List<StaffMember> get initialStaff => [
        const StaffMember(
          id: 'staff-1',
          name: 'Aling Nena',
          role: UserRole.owner,
          onShift: true,
        ),
        const StaffMember(
          id: 'staff-2',
          name: 'Ana Reyes',
          role: UserRole.staff,
          onShift: true,
        ),
        const StaffMember(
          id: 'staff-3',
          name: 'Benjie Santos',
          role: UserRole.staff,
          onShift: false,
        ),
      ];
}
