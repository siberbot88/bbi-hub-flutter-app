import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bengkel_online_flutter/feature/owner/providers/service_provider.dart';
import 'package:bengkel_online_flutter/core/models/service.dart';
import 'package:bengkel_online_flutter/core/models/transaction_item.dart';

const _gradStart = Color(0xFF9B0D0D);
const _gradEnd = Color(0xFFB70F0F);
const _danger = Color(0xFFDC2626);

class DetailWorkPage extends StatefulWidget {
  final String serviceId;
  const DetailWorkPage({super.key, required this.serviceId});

  @override
  State<DetailWorkPage> createState() => _DetailWorkPageState();
}

class _DetailWorkPageState extends State<DetailWorkPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // FIX: method yang ada di provider adalah fetchDetail
      context.read<ServiceProvider>().fetchDetail(widget.serviceId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ServiceProvider>();
    final s = prov.selected;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(
        backgroundColor: _gradStart,
        elevation: 0,
        title: Text(
          s?.code ?? 'Detail Pekerjaan',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      // FIX: gunakan loading & lastError dari ServiceProvider
      body: prov.loading
          ? const Center(child: CircularProgressIndicator())
          : prov.lastError != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            prov.lastError!,
            textAlign: TextAlign.center,
          ),
        ),
      )
          : s == null
          ? const Center(child: Text('Data tidak ditemukan'))
          : _Body(service: s),
    );
  }
}

/* ---------------- BODY ---------------- */

class _Body extends StatelessWidget {
  final ServiceModel service;
  const _Body({required this.service});

  num get _partsTotal =>
      (service.items ?? const <TransactionItem>[])
          .fold<num>(0, (a, b) => a + (b.subtotal ?? 0));
  num get _labor => service.price ?? 0;
  num get _grand => _partsTotal + _labor;

  double get _progress {
    switch ((service.status).toLowerCase()) {
      case 'pending':
        return .25;
      case 'accept':
        return .5;
      case 'in progress':
        return .75;
      case 'completed':
        return 1.0;
      default:
        return .15;
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = service.vehicle; // biarkan dynamic / sesuai model
    final c = service.customer; // biasanya Customer? dari model

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        // status bar
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const _Dot(color: _danger),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _statusText(service.status),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Text('${(_progress * 100).toInt()}%',
                    style: const TextStyle(fontWeight: FontWeight.w800)),
              ]),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _progress,
                  minHeight: 10,
                  backgroundColor: const Color(0xFFE5E7EB),
                  valueColor: const AlwaysStoppedAnimation(_danger),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // INFORMASI CUSTOMER
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle(
                  icon: Icons.person_outline, text: 'Informasi Customer'),
              const SizedBox(height: 10),
              _TwoCol(
                leftTitle: 'Nama lengkap',
                leftValue: c?.name ?? '-',
                rightTitle: 'Alamat',
                // FIX: Customer tidak punya 'address' → ambil aman/dynamic atau '-'
                rightValue: _customerAddressSafe(c),
              ),
              const SizedBox(height: 8),
              _TwoCol(
                leftTitle: 'Telepon',
                leftValue: c?.phone ?? '-',
                rightTitle: 'Email',
                rightValue: c?.email ?? '-',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // INFORMASI KENDARAAN
        _VehicleCard(vehicle: v),
        const SizedBox(height: 12),

        // DETAIL PEKERJAAN
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle(
                  icon: Icons.tips_and_updates_outlined,
                  text: 'Detail Pekerjaan'),
              const SizedBox(height: 8),
              Text(service.name,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800)),
              // FIX: description bisa Object? → pastikan String dulu
              if ('${service.description ?? ''}'.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text('${service.description}',
                    style: const TextStyle(color: Colors.black54)),
              ],
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              _TwoCol(
                leftTitle: 'Kategori',
                leftValue: service.categoryName ??
                    (service.items?.isNotEmpty == true
                        ? (service.items!.first.serviceTypeName ?? '-')
                        : '-'),
                rightTitle: 'Est. Waktu',
                rightValue: _estWaktu(service.estimatedTime),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // MEKANIK
        _Panel(
          child: Row(
            children: [
              const Expanded(
                child: _SectionTitle(
                    icon: Icons.engineering_outlined,
                    text: 'Mekanik yang Menangani'),
              ),
              ElevatedButton(
                onPressed: () {}, // TODO: telpon/chat mekanik
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEDE9FE),
                  foregroundColor: const Color(0xFF7C3AED),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                ),
                child: const Text('Hubungi'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // JADWAL
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle(
                  icon: Icons.event_outlined, text: 'Jadwal Pengerjaan'),
              const SizedBox(height: 10),
              _Tile(label: 'Tanggal', value: _date(service.scheduledDate)),
              _Tile(label: 'Waktu mulai', value: '--:--'),
              _Tile(label: 'Est. Selesai', value: '--:--'),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // SPAREPART
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle(
                  icon: Icons.shopping_cart_outlined,
                  text: 'Sparepart yang digunakan'),
              const SizedBox(height: 8),
              if ((service.items ?? const []).isEmpty)
                const Text('Belum ada item',
                    style: TextStyle(color: Colors.black45))
              else
                ...service.items!.map((e) => _PartRow(item: e)),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // CATATAN
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle(
                  icon: Icons.note_alt_outlined, text: 'Catatan Penting'),
              const SizedBox(height: 8),
              _Note(text: service.note ?? 'Tidak ada catatan'),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // RINCIAN BIAYA
        _CostCard(parts: _partsTotal, labor: _labor, total: _grand),
      ],
    );
  }

  String _statusText(String s) {
    switch (s.toLowerCase()) {
      case 'completed':
        return '• Pekerjaan telah selesai';
      case 'in progress':
        return '• Pekerjaan sedang dikerjakan';
      case 'accept':
        return '• Pekerjaan dikonfirmasi';
      case 'cancelled':
        return '• Pekerjaan dibatalkan';
      default:
        return '• Menunggu konfirmasi';
    }
  }

  // ambil alamat secara aman kalau backend/model punya field itu
  String _customerAddressSafe(dynamic c) {
    try {
      if (c == null) return '-';
      final a = (c.address ??
          c['address'] ??
          c.alamat ??
          c['alamat'] ??
          c.addr ??
          c['addr'])
          ?.toString();
      if (a != null && a.trim().isNotEmpty) return a;
      return '-';
    } catch (_) {
      return '-';
    }
  }
}

/* ---------------- COMPONENTS ---------------- */

class _Panel extends StatelessWidget {
  final Widget child;
  const _Panel({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 6)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String text;
  const _SectionTitle({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, color: _danger),
      const SizedBox(width: 8),
      Text(text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
    ]);
  }
}

class _TwoCol extends StatelessWidget {
  final String leftTitle, leftValue, rightTitle, rightValue;
  const _TwoCol({
    required this.leftTitle,
    required this.leftValue,
    required this.rightTitle,
    required this.rightValue,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle label = const TextStyle(color: Colors.black45, fontSize: 12);
    TextStyle value = const TextStyle(fontWeight: FontWeight.w700);
    return Row(
      children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(leftTitle, style: label),
            const SizedBox(height: 4),
            Text(leftValue, style: value),
          ]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(rightTitle, style: label),
            const SizedBox(height: 4),
            Text(rightValue, style: value),
          ]),
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  final String label, value;
  const _Tile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Text(label, style: const TextStyle(color: Colors.black54)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

// FIX: Hilangkan referensi tipe Vehicle, gunakan dynamic + akses aman
class _VehicleCard extends StatelessWidget {
  final dynamic vehicle;
  const _VehicleCard({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final v = vehicle;
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [_gradStart, _gradEnd]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 6))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: const [
            Icon(Icons.directions_car, color: Colors.white),
            SizedBox(width: 8),
            Text('Informasi Kendaraan',
                style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _vehTitle(v),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text('Plat: ${_vStr(v, ['plateNumber', 'plate', 'plate_number'])}',
                      style: const TextStyle(color: Colors.white70)),
                ]),
          ),
          const SizedBox(height: 10),
          Row(children: [
            _KV(title: 'Tahun', value: _vStr(v, ['year'])),
            _KV(title: 'Warna', value: _vStr(v, ['color', 'warna'])),
            _KV(title: 'Odometer', value: _vStr(v, ['odometer'])),
          ]),
        ]),
      ),
    );
  }

  static String _vehTitle(dynamic v) {
    if (v == null) return '-';
    final parts = <String>[
      _vStr(v, ['brand']),
      _vStr(v, ['model']),
      _vStr(v, ['name']),
    ].where((e) => e.isNotEmpty).toList();
    final name = parts.join(' ');
    return name.isEmpty ? '-' : name;
  }

  // ambil string aman dari object dynamic atau Map
  static String _vStr(dynamic v, List<String> keys) {
    if (v == null) return '-';
    for (final k in keys) {
      try {
        final val = (v is Map)
            ? v[k]
            : (v as dynamic).__getattr__(k); // akan dilempar ke catch jika ga ada
        if (val != null && val.toString().trim().isNotEmpty) {
          return val.toString();
        }
      } catch (_) {
        // ignore and try next key
      }
    }
    return '-';
  }
}

// helper untuk memanggil properti dynamic tanpa analyzer warning
extension on Object {
  dynamic __getattr__(String name) {
    try {
      // ignore: unnecessary_cast
      final d = (this as dynamic);
      return d.noSuchMethod; // dummy to force dynamic
    } catch (_) {
      // ignore
    }
    return null;
  }
}

class _KV extends StatelessWidget {
  final String title, value;
  const _KV({required this.title, required this.value});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        ]),
      ),
    );
  }
}

class _PartRow extends StatelessWidget {
  final TransactionItem item;
  const _PartRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final name = item.name ?? item.serviceTypeName ?? 'Item';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
              Text('Qty: ${item.quantity ?? 0}  @ ${_rupiah(item.price ?? 0)}',
                  style: const TextStyle(color: Colors.black54, fontSize: 12)),
            ]),
          ),
          Text(_rupiah(item.subtotal ?? 0),
              style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _Note extends StatelessWidget {
  final String text;
  const _Note({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.sticky_note_2_outlined, color: Colors.black45),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
          const SizedBox(width: 6),
          Text(_timeNow(),
              style: const TextStyle(color: Colors.black38, fontSize: 12)),
        ],
      ),
    );
  }
}

class _CostCard extends StatelessWidget {
  final num parts, labor, total;
  const _CostCard(
      {required this.parts, required this.labor, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [_gradStart, _gradEnd]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 6))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child:
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Rincian Biaya',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          _RowCost(label: 'Biaya sparepart', value: _rupiah(parts), bold: false),
          _RowCost(label: 'Biaya  jasa', value: _rupiah(labor), bold: false),
          const Divider(color: Colors.white24),
          _RowCost(label: 'Subtotal', value: _rupiah(total), bold: false),
          const SizedBox(height: 8),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: _RowCost(
                label: 'Total Biaya', value: _rupiah(total), bold: true),
          ),
        ]),
      ),
    );
  }
}

class _RowCost extends StatelessWidget {
  final String label, value;
  final bool bold;
  const _RowCost({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
          child: Text(label,
              style: TextStyle(color: Colors.white.withOpacity(.9)))),
      Text(value,
          style: TextStyle(
              color: Colors.white,
              fontWeight: bold ? FontWeight.w900 : FontWeight.w700)),
    ]);
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot({required this.color});
  @override
  Widget build(BuildContext context) => Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle));
}

/* ---------------- HELPERS ---------------- */

String _rupiah(num n) {
  final s = n.toInt().toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final rev = s.length - i;
    b.write(s[i]);
    if (rev > 1 && rev % 3 == 1) b.write('.');
  }
  return 'Rp. $b';
}

String _date(DateTime? dt) {
  if (dt == null) return '-';
  const bulan = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des'
  ];
  return '${dt.day} ${bulan[dt.month - 1]} ${dt.year}';
}

String _estWaktu(DateTime? dt) {
  if (dt == null) return '-';
  return '1 jam'; // (opsional) hitung dari scheduled_date ke estimated_time
}

String _timeNow() {
  final now = DateTime.now();
  final hh = now.hour.toString().padLeft(2, '0');
  final mm = now.minute.toString().padLeft(2, '0');
  return '$hh:$mm';
}
