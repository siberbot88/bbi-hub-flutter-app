import 'package:flutter/foundation.dart';
import 'package:bengkel_online_flutter/core/services/api_service.dart';
import 'package:bengkel_online_flutter/core/models/service.dart';

/// Provider untuk Work Order / Service
class ServiceProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  // ---- state dasar ----
  bool _loading = false;
  String? _lastError;
  List<ServiceModel> _items = [];

  // ---- filter & search ----
  String? _statusFilter;
  String _search = '';

  // ---- getters ----
  bool get loading => _loading;
  String? get lastError => _lastError;
  String? get error => _lastError;
  List<ServiceModel> get items => List.unmodifiable(_items);

  String? get statusFilter => _statusFilter;
  String get search => _search;

  List<ServiceModel> get filteredItems {
    Iterable<ServiceModel> list = _items;

    if (_statusFilter != null && _statusFilter!.isNotEmpty) {
      final want = _statusFilter!.toLowerCase();
      list = list.where((e) => (e.status ?? '').toLowerCase() == want);
    }

    final q = _search.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((e) => e._searchJoin.contains(q));
    }

    return List.unmodifiable(list);
  }

  Future<void> setStatusFilter(String? status, {bool fetch = true}) async {
    _statusFilter = status;
    notifyListeners();
    if (fetch) await fetchServices();
  }

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  Future<void> fetchServices({String? status}) async {
    _loading = true;
    _lastError = null;
    notifyListeners();

    try {
      final list = await _api.fetchServices(
        status: status ?? _statusFilter,
        includeExtras: true,
      );
      _items = list;
    } catch (e) {
      _lastError = e.toString();
      if (kDebugMode) print('fetchServices error: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> fetch({String? status, bool? includeExtras}) =>
      fetchServices(status: status);

  Future<void> updateStatus({
    required String id,
    required String status,
  }) async {
    _lastError = null;
    notifyListeners();

    try {
      await _api.updateServiceStatus(id, status);
      await fetchServices();
    } catch (e) {
      _lastError = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<ServiceModel> createDummy({
    required String workshopUuid,
    required String customerUuid,
    required String vehicleId,
    required String name,
    String? description,
    num? price,
    required DateTime scheduledDate,
    required DateTime estimatedTime,
    String status = 'pending',
  }) async {
    _lastError = null;
    notifyListeners();

    try {
      final created = await _api.createServiceDummy(
        workshopUuid: workshopUuid,
        customerUuid: customerUuid,
        vehicleId: vehicleId,
        name: name,
        description: description,
        price: price,
        scheduledDate: scheduledDate,
        estimatedTime: estimatedTime,
        status: status,
      );
      _items.insert(0, created);
      notifyListeners();
      return created;
    } catch (e) {
      _lastError = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void clear() {
    _items = [];
    _lastError = null;
    _statusFilter = null;
    _search = '';
    notifyListeners();
  }

  int countByStatus(String s) =>
      _items.where((e) => (e.status ?? '').toLowerCase() == s.toLowerCase()).length;
}

/* ================= SAFE ACCESS HELPERS ================= */

extension _ServiceModelSearch on ServiceModel {
  String get _searchJoin {
    final parts = <String>[
      _s(code),
      _s(name),
      _s(description),
      _s(_customerNameSafe),
      _s(_vehiclePlateSafe),
      _s(_vehicleBrandSafe),
      _s(_vehicleModelSafe),
      _s(_vehicleNameSafe),
      _s(_workshopNameSafe),
    ];
    return parts.where((e) => e.isNotEmpty).join(' | ').toLowerCase();
  }

  String _s(String? v) => (v ?? '').trim();

  String? get _customerNameSafe {
    try {
      final d = (this as dynamic);
      final c = d.customer;
      if (c != null) {
        try { final n = c.name; if (n is String && n.isNotEmpty) return n; } catch (_) {}
        try { final n = c['name']; if (n is String && n.isNotEmpty) return n; } catch (_) {}
      }
      try { final n = d.customerName; if (n is String && n.isNotEmpty) return n; } catch (_) {}
      try { final n = d['customerName']; if (n is String && n.isNotEmpty) return n; } catch (_) {}
      return null;
    } catch (_) { return null; }
  }

  String? get _vehiclePlateSafe {
    try {
      final d = (this as dynamic);
      final v = d.vehicle;
      if (v != null) {
        try { final p = v.plateNumber ?? v.plate; if (p is String && p.isNotEmpty) return p; } catch (_) {}
        try { final p = v['plate_number'] ?? v['plate']; if (p is String && p.isNotEmpty) return p; } catch (_) {}
      }
      try { final p = d.vehiclePlateNumber ?? d.vehiclePlate ?? d.plateNumber ?? d.plate; if (p is String && p.isNotEmpty) return p; } catch (_) {}
      try { final p = d['vehiclePlateNumber'] ?? d['vehiclePlate'] ?? d['plate_number'] ?? d['plate']; if (p is String && p.isNotEmpty) return p; } catch (_) {}
      return null;
    } catch (_) { return null; }
  }

  String? get _vehicleBrandSafe {
    try {
      final d = (this as dynamic);
      final v = d.vehicle;
      if (v != null) {
        try { final b = v.brand; if (b is String && b.isNotEmpty) return b; } catch (_) {}
        try { final b = v['brand']; if (b is String && b.isNotEmpty) return b; } catch (_) {}
      }
      try { final b = d.vehicleBrand ?? d.brand; if (b is String && b.isNotEmpty) return b; } catch (_) {}
      try { final b = d['vehicleBrand'] ?? d['brand']; if (b is String && b.isNotEmpty) return b; } catch (_) {}
      return null;
    } catch (_) { return null; }
  }

  String? get _vehicleModelSafe {
    try {
      final d = (this as dynamic);
      final v = d.vehicle;
      if (v != null) {
        try { final m = v.model; if (m is String && m.isNotEmpty) return m; } catch (_) {}
        try { final m = v['model']; if (m is String && m.isNotEmpty) return m; } catch (_) {}
      }
      try { final m = d.vehicleModel ?? d.model; if (m is String && m.isNotEmpty) return m; } catch (_) {}
      try { final m = d['vehicleModel'] ?? d['model']; if (m is String && m.isNotEmpty) return m; } catch (_) {}
      return null;
    } catch (_) { return null; }
  }

  String? get _vehicleNameSafe {
    try {
      final d = (this as dynamic);
      final v = d.vehicle;
      if (v != null) {
        try { final n = v.name; if (n is String && n.isNotEmpty) return n; } catch (_) {}
        try { final n = v['name']; if (n is String && n.isNotEmpty) return n; } catch (_) {}
      }
      try { final n = d.vehicleName; if (n is String && n.isNotEmpty) return n; } catch (_) {}
      try { final n = d['vehicleName']; if (n is String && n.isNotEmpty) return n; } catch (_) {}
      return null;
    } catch (_) { return null; }
  }

  String? get _workshopNameSafe {
    try {
      final d = (this as dynamic);
      final w = d.workshop;
      if (w != null) {
        try { final n = w.name; if (n is String && n.isNotEmpty) return n; } catch (_) {}
        try { final n = w['name']; if (n is String && n.isNotEmpty) return n; } catch (_) {}
      }
      try { final n = d.workshopName; if (n is String && n.isNotEmpty) return n; } catch (_) {}
      try { final n = d['workshopName']; if (n is String && n.isNotEmpty) return n; } catch (_) {}
      return null;
    } catch (_) { return null; }
  }
}
