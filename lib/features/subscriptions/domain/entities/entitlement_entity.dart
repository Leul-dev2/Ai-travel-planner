import 'package:equatable/equatable.dart';

enum SubscriptionPlan { free, pro, ultimate }

class EntitlementEntity extends Equatable {
  final SubscriptionPlan plan;
  final String status; // active, past_due, canceled
  final DateTime? updatedAt;

  const EntitlementEntity({
    required this.plan,
    required this.status,
    this.updatedAt,
  });

  bool get isProOrHigher => plan == SubscriptionPlan.pro || plan == SubscriptionPlan.ultimate;
  bool get isUltimate => plan == SubscriptionPlan.ultimate;
  bool get isActive => status == 'active';

  // Feature gates
  bool get canUseOfflineMaps => isProOrHigher && isActive;
  bool get canUseUnlimitedChat => isProOrHigher && isActive;
  bool get canCollaborate => isProOrHigher && isActive;
  bool get hasDedicatedSupport => isUltimate && isActive;

  factory EntitlementEntity.free() {
    return const EntitlementEntity(
      plan: SubscriptionPlan.free,
      status: 'active',
    );
  }

  factory EntitlementEntity.fromJson(Map<String, dynamic> json) {
    final planStr = json['plan'] as String?;
    final plan = _parsePlan(planStr);
    
    return EntitlementEntity(
      plan: plan,
      status: json['status'] as String? ?? 'active',
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
    );
  }

  static SubscriptionPlan _parsePlan(String? plan) {
    switch (plan?.toLowerCase()) {
      case 'ultimate': return SubscriptionPlan.ultimate;
      case 'pro': return SubscriptionPlan.pro;
      default: return SubscriptionPlan.free;
    }
  }

  @override
  List<Object?> get props => [plan, status, updatedAt];
}
