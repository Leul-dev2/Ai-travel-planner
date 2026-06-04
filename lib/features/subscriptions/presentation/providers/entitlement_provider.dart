import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/entitlement_entity.dart';

final entitlementProvider = StreamProvider<EntitlementEntity>((ref) {
  final authState = ref.watch(authStateProvider);
  final userId = authState.user?.id;

  if (userId == null || userId.isEmpty) {
    return Stream.value(EntitlementEntity.free());
  }

  final docRef = FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('subscriptions')
      .doc('current');

  return docRef.snapshots().map((snapshot) {
    if (!snapshot.exists || snapshot.data() == null) {
      return EntitlementEntity.free();
    }
    return EntitlementEntity.fromJson(snapshot.data()!);
  });
});
