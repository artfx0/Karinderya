import 'app_state.dart';

class StaffMember {
  final String id;
  final String name;
  final UserRole role;
  final bool onShift;

  const StaffMember({
    required this.id,
    required this.name,
    required this.role,
    this.onShift = true,
  });

  String get avatarInitials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'ST';
  }

  StaffMember copyWith({
    String? id,
    String? name,
    UserRole? role,
    bool? onShift,
  }) {
    return StaffMember(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      onShift: onShift ?? this.onShift,
    );
  }
}
