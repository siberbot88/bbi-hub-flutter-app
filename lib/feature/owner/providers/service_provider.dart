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
  ServiceModel? _selected; // untuk halaman detail

  // ---- filter & search ----
  String? _statusFilter; // 'pending' | 'accept' | 'in progress' | 'completed' | 'cancelled' | null
  String _search = '';

  // ---- getters ----
  bool get loading => _loading;
  String? get lastError => _lastError;
  String? get error => _lastError; // alias jika UI lama masih pakai 'error'
  List<ServiceModel> get items => List.unmodifiable(_items);
  ServiceModel? get selected => _selected;

  String? get statusFilter => _statusFilter;
  String get search => _search;

  /// List sudah difilter status dan teks
  List<ServiceModel> get filteredItems {
    Iterable<ServiceModel> list = _items;

    if (_statusFilter != null && _statusFilter!.isNotEmpty) {
      final want = _statusFilter!.toLowerCase();
      list = list.where((e) => e.status.toLowerCase() == want);
    }

    final q = _search.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((e) => e._searchJoin.contains(q));
    }

    return List.unmodifiable(list);
  }

  /* =================== Actions =================== */

  /// Ganti filter status. Jika [fetch] true, otomatis tarik data dari server.
  Future<void> setStatusFilter(String? status, {bool fetch = true}) async {
    _statusFilter = status;
    notifyListeners();
    if (fetch) await fetchServices();
  }

  /// Set kata kunci pencarian (client-side)
  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  /// GET /services
  Future<void> fetchServices({
    String? status,
    bool includeExtras = true,
    String? workshopUuid,
    String? code,
    String? dateFrom, // 'YYYY-MM-DD'
    String? dateTo,   // 'YYYY-MM-DD'
  }) async {
    _loading = true;
    _lastError = null;
    notifyListeners();

    try {
      final list = await _api.fetchServices(
        status: status ?? _statusFilter,
        includeExtras: includeExtras,
        workshopUuid: workshopUuid,
        code: code,
        dateFrom: dateFrom,
        dateTo: dateTo,
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

  /// Alias agar kompatibel dengan pemanggilan lama
  Future<void> fetch({String? status, bool? includeExtras}) =>
      fetchServices(status: status, includeExtras: includeExtras ?? true);

  /// GET /services/{id}
  Future<ServiceModel?> fetchDetail(String id) async {
    _loading = true;
    _lastError = null;
    notifyListeners();

    try {
      final detail = await _api.fetchServiceDetail(id);
      _selected = detail;

      // sinkronkan dengan list kalau sudah ada
      final idx = _items.indexWhere((e) => e.id == detail.id);
      if (idx >= 0) {
        _items[idx] = detail;
      } else {
        _items.insert(0, detail);
      }

      return detail;
    } catch (e) {
      _lastError = e.toString();
      if (kDebugMode) print('fetchDetail error: $e');
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// PATCH /services/{id}  {status: ...}
  Future<void> updateStatus({
    required String id,
    required String status,
  }) async {
    _lastError = null;
    notifyListeners();

    try {
      await _api.updateServiceStatus(id, status);

      // Update lokal secara optimis
      final idx = _items.indexWhere((e) => e.id == id);
      if (idx >= 0) {
        final s = _items[idx];
        _items[idx] = ServiceModel(
          id: s.id,
          code: s.code,
          name: s.name,
          description: s.description,
          price: s.price,
          scheduledDate: s.scheduledDate,
          estimatedTime: s.estimatedTime,
          status: status,
          customerUuid: s.customerUuid,
          workshopUuid: s.workshopUuid,
          vehicleId: s.vehicleId,
          customer: s.customer,
          vehicle: s.vehicle,
          workshopName: s.workshopName,
        );
      }
      if (_selected?.id == id) {
        final s = _selected!;
        _selected = ServiceModel(
          id: s.id,
          code: s.code,
          name: s.name,
          description: s.description,
          price: s.price,
          scheduledDate: s.scheduledDate,
          estimatedTime: s.estimatedTime,
          status: status,
          customerUuid: s.customerUuid,
          workshopUuid: s.workshopUuid,
          vehicleId: s.vehicleId,
          customer: s.customer,
          vehicle: s.vehicle,
          workshopName: s.workshopName,
        );
      }

      notifyListeners();
    } catch (e) {
      _lastError = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// POST /services  (buat dummy)
  Future<ServiceModel> createDummy({
    required String workshopUuid,
    String? customerUuid,
    String? vehicleUuid,
    required String name,
    String? description,
    num? price,
    required DateTime scheduledDate,
    DateTime? estimatedTime,
    String status = 'pending',
  }) async {
    _lastError = null;
    notifyListeners();

    try {
      final created = await _api.createServiceDummy(
        workshopUuid: workshopUuid,
        customerUuid: customerUuid,
        vehicleUuid: vehicleUuid,
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

  /// Bersihkan state
  void clear() {
    _items = [];
    _selected = null;
    _lastError = null;
    _statusFilter = null;
    _search = '';
    notifyListeners();
  }

  /// Hitung jumlah item per status (dari list lokal)
  int countByStatus(String s) =>
      _items.where((e) => e.status.toLowerCase() == s.toLowerCase()).length;
}

/* ===========================================================
   ============== SAFE ACCESS HELPERS (NO CRASH) =============
   ===========================================================
   Membuat pencarian fleksibel:
   - Kalau `ServiceModel` punya nested object (customer/workshop/vehicle), ambil dari sana.
   - Kalau datanya "flat" (misal customerName, vehiclePlateNumber, workshopName), juga dicoba.
   - Jika field tidak ada, aman (try-catch) dan return null.
*/

extension _ServiceModelSearch on ServiceModel {
  // Gabungan string untuk pencarian cepat (lowercase)
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
        try {
          final n = c.name;
          if (n is String && n.isNotEmpty) return n;
        } catch (_) {}
        try {
          final n = c['name'];
          if (n is String && n.isNotEmpty) return n;
        } catch (_) {}
      }
      try {
        final n = d.customerName;
        if (n is String && n.isNotEmpty) return n;
      } catch (_) {}
      try {
        final n = d['customerName'];
        if (n is String && n.isNotEmpty) return n;
      } catch (_) {}
      return null;
    } catch (_) {
      return null;
    }
  }

  String? get _vehiclePlateSafe {
    try {
      final d = (this as dynamic);
      final v = d.vehicle;
      if (v != null) {
        try {
          final p = v.plateNumber ?? v.plate;
          if (p is String && p.isNotEmpty) return p;
        } catch (_) {}
        try {
          final p = v['plate_number'] ?? v['plate'];
          if (p is String && p.isNotEmpty) return p;
        } catch (_) {}
      }
      try {
        final p = d.vehiclePlateNumber ?? d.vehiclePlate ?? d.plateNumber ?? d.plate;
        if (p is String && p.isNotEmpty) return p;
      } catch (_) {}
      try {
        final p = d['vehiclePlateNumber'] ??
            d['vehiclePlate'] ??
            d['plate_number'] ??
            d['plate'];
        if (p is String && p.isNotEmpty) return p;
      } catch (_) {}
      return null;
    } catch (_) {
      return null;
    }
  }

  String? get _vehicleBrandSafe {
    try {
      final d = (this as dynamic);
      final v = d.vehicle;
      if (v != null) {
        try {
          final b = v.brand;
          if (b is String && b.isNotEmpty) return b;
        } catch (_) {}
        try {
          final b = v['brand'];
          if (b is String && b.isNotEmpty) return b;
        } catch (_) {}
      }
      try {
        final b = d.vehicleBrand ?? d.brand;
        if (b is String && b.isNotEmpty) return b;
      } catch (_) {}
      try {
        final b = d['vehicleBrand'] ?? d['brand'];
        if (b is String && b.isNotEmpty) return b;
      } catch (_) {}
      return null;
    } catch (_) {
      return null;
    }
  }

  String? get _vehicleModelSafe {
    try {
      final d = (this as dynamic);
      final v = d.vehicle;
      if (v != null) {
        try {
          final m = v.model;
          if (m is String && m.isNotEmpty) return m;
        } catch (_) {}
        try {
          final m = v['model'];
          if (m is String && m.isNotEmpty) return m;
        } catch (_) {}
      }
      try {
        final m = d.vehicleModel ?? d.model;
        if (m is String && m.isNotEmpty) return m;
      } catch (_) {}
      try {
        final m = d['vehicleModel'] ?? d['model'];
        if (m is String && m.isNotEmpty) return m;
      } catch (_) {}
      return null;
    } catch (_) {
      return null;
    }
  }

  String? get _vehicleNameSafe {
    try {
      final d = (this as dynamic);
      final v = d.vehicle;
      if (v != null) {
        try {
          final n = v.name;
          if (n is String && n.isNotEmpty) return n;
        } catch (_) {}
        try {
          final n = v['name'];
          if (n is String && n.isNotEmpty) return n;
        } catch (_) {}
      }
      try {
        final n = d.vehicleName;
        if (n is String && n.isNotEmpty) return n;
      } catch (_) {}
      try {
        final n = d['vehicleName'];
        if (n is String && n.isNotEmpty) return n;
      } catch (_) {}
      return null;
    } catch (_) {
      return null;
    }
  }

  String? get _workshopNameSafe {
    try {
      final d = (this as dynamic);
      final w = d.workshop;
      if (w != null) {
        try {
          final n = w.name;
          if (n is String && n.isNotEmpty) return n;
        } catch (_) {}
        try {
          final n = w['name'];
          if (n is String && n.isNotEmpty) return n;
        } catch (_) {}
      }
      try {
        final n = d.workshopName;
        if (n is String && n.isNotEmpty) return n;
      } catch (_) {}
      try {
        final n = d['workshopName'];
        if (n is String && n.isNotEmpty) return n;
      } catch (_) {}
      return null;
    } catch (_) {
      return null;
    }
  }
}
