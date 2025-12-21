# Data Dummy untuk Pengujian & Demo Admin BBI Hub

Dokumen ini berisi data dummy yang konsisten untuk digunakan saat simulasi atau presentasi fitur Admin. Anda dapat menyalin data ini ke dalam format Word atau PDF jika diperlukan.

---

## **1. Data Pelanggan (Customers)**

| No | Nama Pelanggan | No. Telepon | Email (Opsional) | Alamat Singkat |
| :--- | :--- | :--- | :--- | :--- |
| 1 | **Budi Santoso** | 0812-3456-7890 | budi.s@gmail.com | Jl. Mawar No. 10 |
| 2 | **Siti Aminah** | 0813-9988-7766 | siti.am@yahoo.com | Perum. Griya Asri B3 |
| 3 | **Andi Pratama** | 0857-1122-3344 | andi.p@gmail.com | Jl. Sudirman Kav. 5 |
| 4 | **Dewi Lestari** | 0878-5566-4433 | dewi.l@outlook.com | Apt. Melati Lt. 12 |
| 5 | **Rahmat Hidayat** | 0821-2233-4455 | rahmat.h@gmail.com | Jl. Kenanga No. 88 |

---

## **2. Data Kendaraan (Vehicles)**

*Disarankan untuk menghubungkan kendaraan ini dengan pelanggan di atas saat input.*

| Pemilik | Brand | Model | Tahun | Plat Nomor (License Plate) | Transmisi |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Budi Santoso | Toyota | Avanza Veloz | 2019 | **B 1234 ABC** | Manual |
| Siti Aminah | Honda | Brio Satya | 2021 | **D 5678 XYZ** | Matic |
| Andi Pratama | Mitsubishi | Pajero Sport | 2020 | **L 9012 DEF** | Matic |
| Dewi Lestari | Daihatsu | Sigra | 2018 | **B 3456 GHI** | Manual |
| Rahmat Hidayat | Suzuki | Ertiga | 2022 | **N 7890 JKL** | Matic |

---

## **3. Data Mekanik (Staff)**

| Nama Mekanik | Spesialisasi | Status Saat Ini | Jumlah Job (Hari ini) |
| :--- | :--- | :--- | :--- |
| **Joko Susilo** | Mesin & Tune Up | *Available* | 2 |
| **Dimas Anggara** | Kelistrikan & AC | *Busy* | 4 |
| **Hendra Setiawan** | Kaki-kaki & Ban | *Available* | 1 |
| **Fajar Nugraha** | Umum (General) | *Busy* | 3 |

---

## **4. Skenario Servis (Service Flows)**

Gunakan data ini untuk mendemonstrasikan berbagai status pesanan di dashboard admin.

### **Skenario A: Booking Baru Masuk (Tab "Scheduled")**
*Kondisi: Pelanggan booking dari aplikasi, Admin perlu Accept & Assign.*

*   **Tipe**: `Booking`
*   **Nama Pelanggan**: Budi Santoso (Toyota Avanza)
*   **Keluhan/Service**: "Bunyi asing di bagian mesin saat digas, sekalian ganti oli."
*   **Kategori**: Servis Ringan
*   **Jadwal**: Hari ini, Jam 14:00
*   **Status Awal**: `Pending` (Belum di-assign)
*   **Aksi Admin**:
    1.  Buka tab "Service Booking".
    2.  Klik **"Terima Jadwal"**.
    3.  Pilih Mekanik: **Joko Susilo**.
    4.  Simpan -> Status berubah jadi `In Progress` / `Scheduled`.

### **Skenario B: Walk-in Service (Datang Langsung)**
*Kondisi: Pelanggan datang langsung ke bengkel tanpa janji.*

*   **Tipe**: `On-Site` (Walk-in)
*   **Nama Pelanggan**: Siti Aminah (Honda Brio)
*   **Keluhan/Service**: "Ganti Kampas Rem Depan & Belakang"
*   **Kategori**: Kaki-kaki
*   **Aksi Admin**:
    1.  Klik tombol **"+" (Tambah Servis)**.
    2.  Pilih "Walk-in".
    3.  Input data Siti Aminah & Honda Brio.
    4.  Langsung Assign ke: **Hendra Setiawan**.
    5.  Status langsung `In Progress`.

### **Skenario C: Servis Selesai & Pembayaran (Invoice)**
*Kondisi: Mekanik sudah selesai, Admin membuat tagihan.*

*   **Pelanggan**: Andi Pratama (Pajero Sport)
*   **Status Servis**: `In Progress` -> Ubah ke `Completed`.
*   **Input Sparepart & Jasa (Transaction Items)**:
    1.  **Jasa Tune Up** - Rp 150.000 (Qty: 1)
    2.  **Oli Mesin 4L** - Rp 450.000 (Qty: 1)
    3.  **Filter Oli** - Rp 45.000 (Qty: 1)
*   **Total Tagihan**: Rp 645.000
*   **Aksi Admin**:
    1.  Klik "Selesaikan Servis".
    2.  Input item-item di atas ke dalam Invoice.
    3.  Pilih Metode Bayar: `Tunai` / `Transfer`.
    4.  Klik **"Bayar & Cetak Invoice"**.

### **Skenario D: Servis Dibatalkan (Rejected)**
*Kondisi: Jadwal penuh atau sparepart tidak tersedia.*

*   **Pelanggan**: Rahmat Hidayat (Suzuki Ertiga)
*   **Service**: Ganti Kaca Film
*   **Aksi Admin**:
    1.  Lihat detail booking.
    2.  Klik **"Tolak" / "Decline"**.
    3.  Isi Alasan: "Stok kaca film sedang kosong, mohon reschedule minggu depan."

---

## **5. Data Sparepart (Inventory Dummy)**

Gunakan data ini saat input item transaksi di Invoice.

| Kode Barang | Nama Barang | Harga Jual (Rp) | Stok |
| :--- | :--- | :--- | :--- |
| OLI-001 | Oli Shell Helix HX7 (1L) | 85.000 | 24 |
| OLI-002 | Oli Pertamina Fastron (1L) | 75.000 | 30 |
| FLT-001 | Filter Oli Avanza/Xenia | 35.000 | 15 |
| FLT-002 | Filter Udara Honda Jazz/Brio | 60.000 | 10 |
| KAM-001 | Kampas Rem Depan (Set) | 250.000 | 8 |
| BUSI-01 | Busi NGK Default | 25.000 | 50 |
| JASA-01 | Jasa Service Ringan | 100.000 | - |
| JASA-02 | Jasa Service Berat | 250.000 | - |
| JASA-03 | Jasa Cuci Mobil | 40.000 | - |

---

## **Tips Simulasi**
1.  **Reset**: Jika ingin mengulang demo dari awal, pastikan status servis dikembalikan atau buat data baru.
2.  **Notifikasi**: Jelaskan bahwa setiap perubahan status (Pending -> Process -> Done) mengirim notifikasi ke aplikasi Owner (simulasi).
