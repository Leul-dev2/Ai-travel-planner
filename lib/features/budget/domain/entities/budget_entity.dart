// ─── Budget Entity ──────────────────────────────────────────────────
// Domain entities for budget tracking and expense management.

import 'package:equatable/equatable.dart';

class ExpenseEntity extends Equatable {
  final String id;
  final String category; // hotel, food, transport, activity, other
  final double amount;
  final String currency;
  final String description;
  final int? dayNumber;
  final String paidBy; // userId
  final DateTime createdAt;

  const ExpenseEntity({
    required this.id,
    required this.category,
    required this.amount,
    this.currency = 'USD',
    required this.description,
    this.dayNumber,
    required this.paidBy,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, category, amount];
}

class BudgetSummary extends Equatable {
  final double totalBudget;
  final double totalSpent;
  final String currency;
  final Map<String, double> spendingByCategory;
  final List<ExpenseEntity> expenses;

  const BudgetSummary({
    required this.totalBudget,
    required this.totalSpent,
    required this.currency,
    this.spendingByCategory = const {},
    this.expenses = const [],
  });

  double get remaining => totalBudget - totalSpent;
  double get percentUsed =>
      totalBudget > 0 ? totalSpent / totalBudget : 0;
  bool get isOverBudget => totalSpent > totalBudget;

  @override
  List<Object?> get props => [totalBudget, totalSpent, currency];
}
