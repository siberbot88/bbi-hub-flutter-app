import 'package:flutter/foundation.dart';
import 'package:bengkel_online_flutter/core/services/api_service.dart';
import 'package:bengkel_online_flutter/core/models/service.dart';
import 'package:bengkel_online_flutter/core/providers/service_provider.dart';
import 'package:bengkel_online_flutter/core/models/employment.dart';
import 'package:bengkel_online_flutter/core/models/dashboard_stats.dart';

/// Provider khusus ADMIN
/// Extend ServiceProvider supaya:
/// - state list, detail, loading, pagination tetap 1 sumber
/// - tapi endpoint & aksi-aksi admin pakai route /admins/services
class AdminServiceProvider extends ServiceProvider {
  final ApiService _adminApi = ApiService();

  /// Override hook: sekarang list service pakai endpoint ADMIN
  /// GET /v1/admins/services
  @override
  Future<Map<String, dynamic>> performFetchServicesRaw({
    String? status,
    bool includeExtras = true,
    String? workshopUuid,
    String? code,
    String? dateFrom,
    String? dateTo,
    int page = 1,
    int perPage = 10,
  }) {
    print("DEBUG: fetching services with dateFrom=$dateFrom, dateTo=$dateTo, status=$status");
    return _adminApi.adminFetchServicesRaw(
      page: page,
      perPage: perPage,
      status: status ?? statusFilter,
      workshopUuid: workshopUuid,
      code: code,
      dateFrom: dateFrom,
      dateTo: dateTo,
    );
  }

  /// Override hook detail: sekarang pakai /v1/admins/services/{id}
  @override
  Future<ServiceModel> performFetchServiceDetail(String id) {
    return _adminApi.adminFetchServiceDetail(id);
  }

  /// Helper simpel kalau mau refresh pakai page sekarang
  Future<void> refreshAdmin({int? page}) {
    return fetchServices(page: page ?? currentPage);
  }

  /* ==================== ADMIN FLOW ACTIONS ==================== */

  /// ADMIN: ACCEPT service
  /// Backend rule:
  /// - acceptance_status = accepted
  /// - status auto in progress
  /// - optional: sekaligus assign mechanic
  Future<void> acceptServiceAsAdmin(
      String id, {
        String? mechanicUuid,
        bool refresh = true,
      }) async {
    try {
      await _adminApi.adminAcceptService(
        id,
        mechanicUuid: mechanicUuid,
      );

      // Optimistic local update - immediately update local state
      _updateLocalServiceAcceptance(id, 'accepted', newStatus: 'in_progress');

      if (refresh) {
        // Refresh detail for the specific service
        await fetchDetail(id);
      }
    } catch (e) {
      if (kDebugMode) print('acceptServiceAsAdmin error: $e');
      rethrow;
    }
  }

  /// ADMIN: DECLINE service
  /// Wajib kirim reason, kalau reason == 'lainnya' wajib reasonDescription
  Future<void> declineServiceAsAdmin(
      String id, {
        required String reason,
        String? reasonDescription,
        bool refresh = true,
      }) async {
    try {
      await _adminApi.adminDeclineService(
        id,
        reason: reason,
        reasonDescription: reasonDescription,
      );

      // Optimistic local update - immediately update local state
      _updateLocalServiceAcceptance(id, 'declined', newReason: reason, newReasonDescription: reasonDescription);

      if (refresh) {
        // Refresh detail for the specific service
        await fetchDetail(id);
      }
    } catch (e) {
      if (kDebugMode) print('declineServiceAsAdmin error: $e');
      rethrow;
    }
  }

  /// Helper to update local service state optimistically
  void _updateLocalServiceAcceptance(
    String id, 
    String newAcceptanceStatus, {
    String? newStatus,
    String? newReason,
    String? newReasonDescription,
  }) {
    final idx = findItemIndex(id);
    if (idx >= 0) {
      final oldService = items[idx];
      final updatedService = ServiceModel(
        id: oldService.id,
        code: oldService.code,
        name: oldService.name,
        description: oldService.description,
        price: oldService.price,
        scheduledDate: oldService.scheduledDate,
        estimatedTime: oldService.estimatedTime,
        status: newStatus ?? oldService.status,
        type: oldService.type,
        acceptanceStatus: newAcceptanceStatus,
        acceptedAt: newAcceptanceStatus == 'accepted' ? DateTime.now() : oldService.acceptedAt,
        completedAt: oldService.completedAt,
        customerUuid: oldService.customerUuid,
        workshopUuid: oldService.workshopUuid,
        vehicleId: oldService.vehicleId,
        mechanicUuid: oldService.mechanicUuid,
        customer: oldService.customer,
        vehicle: oldService.vehicle,
        workshopName: oldService.workshopName,
        mechanic: oldService.mechanic,
        items: oldService.items,
        note: oldService.note,
        categoryName: oldService.categoryName,
        reason: newReason ?? oldService.reason,
        reasonDescription: newReasonDescription ?? oldService.reasonDescription,
        feedbackMechanic: oldService.feedbackMechanic,
        createdAt: oldService.createdAt,
        updatedAt: DateTime.now(),
      );
      
      // Use parent's protected method to update item
      updateLocalItemAt(idx, updatedService);
    }
  }

  /// ADMIN: Assign mechanic
  /// Rules backend:
  /// - hanya boleh kalau acceptance_status == 'accepted'
  /// - status auto jadi 'in progress'
  Future<void> assignMechanicAsAdmin(
      String id,
      String mechanicUuid, {
        bool refresh = true,
      }) async {
    try {
      await _adminApi.adminAssignMechanic(
        id,
        mechanicUuid: mechanicUuid,
      );

      if (refresh) {
        await fetchDetail(id);
        await fetchServices(page: currentPage);
      }
    } catch (e) {
      if (kDebugMode) print('assignMechanicAsAdmin error: $e');
      rethrow;
    }
  }

  /// ADMIN: Delete service
  Future<void> deleteServiceAsAdmin(
      String id, {
        bool refresh = true,
      }) async {
    try {
      await _adminApi.adminDeleteService(id);

      if (refresh) {
        await fetchServices(page: currentPage);
      }
    } catch (e) {
      if (kDebugMode) print('deleteServiceAsAdmin error: $e');
      rethrow;
    }
  }

  /// ADMIN: Update Service Status safely (wraps ApiService)
  Future<void> updateServiceStatusAsAdmin(String id, String status) async {
      await _adminApi.adminUpdateServiceStatus(id, status);
      await fetchDetail(id); // refresh logic
  }
  /// ADMIN: Fetch Dashboard Stats
  Future<DashboardStats> fetchDashboardStats({String? workshopUuid}) {
    return _adminApi.adminFetchDashboardStats(workshopUuid: workshopUuid);
  }

  /// ADMIN: Fetch Employee List
  Future<List<Employment>> fetchEmployees({
    int page = 1, 
    int perPage = 15,
    String? search,
    String? role,
    String? workshopUuid,
  }) {
    return _adminApi.adminFetchEmployees(
      page: page, 
      perPage: perPage,
      search: search,
      role: role,
      workshopUuid: workshopUuid,
    );
  }
  /// ADMIN: Create Walk-in Service
  Future<ServiceModel> createWalkInService({
    required String workshopUuid,
    required String name,
    required DateTime scheduledDate,
    String? categoryName,
    num? price,
    String? description,
    
    // Customer Info (Walk-in)
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    
    // Vehicle Info
    String? vehiclePlate,
    String? vehicleBrand,
    String? vehicleModel,
    int? vehicleYear,
    int? vehicleOdometer,
  }) async {
    try {
      final created = await _adminApi.adminCreateWalkInService(
        workshopUuid: workshopUuid,
        name: name,
        scheduledDate: scheduledDate,
        categoryName: categoryName,
        price: price,
        description: description,
        
        customerName: customerName ?? 'Walk-in Customer',
        customerPhone: customerPhone ?? '',
        customerEmail: customerEmail,
        
        vehiclePlate: vehiclePlate ?? '',
        vehicleBrand: vehicleBrand,
        vehicleModel: vehicleModel,
        vehicleYear: vehicleYear,
        vehicleOdometer: vehicleOdometer,
        
        // Status is handled by backend (default accepted)
      );
      
      // Update local list
      addLocalItem(created);
      // notifyListeners() is called inside addLocalItem
      
      return created;
    } catch (e) {
      if (kDebugMode) print('createWalkInService error: $e');
      rethrow;
    }
  }
}

