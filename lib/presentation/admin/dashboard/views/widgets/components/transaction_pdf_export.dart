import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:paket44/core/theme/app_colors.dart';
import 'package:paket44/presentation/admin/dashboard/controllers/admin_dashboard_controller.dart';

/// PDF export dialog and generation logic for transactions.
class TransactionPdfExport {
  static void showExportDialog(
      BuildContext context, AdminDashboardController controller) {
    final selectedMode = 'all'.obs;
    final nisC = TextEditingController();
    final rxRange = Rxn<DateTimeRange>();
    final statuses = <String>[
      'pending', 'approved', 'dipinjam', 'terlambat', 'dikembalikan', 'rejected'
    ];
    final selectedStatuses = <String>[].obs;

    // Pre-select based on current UI filter
    final currentFilter = controller.selectedTransactionStatus.value;
    if (currentFilter != 'Semua') {
      if (currentFilter == 'Ditolak') {
        selectedStatuses.add('rejected');
      } else {
        selectedStatuses.add(currentFilter.toLowerCase());
      }
    }

    Future<void> pickRange() async {
      final picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2000),
        lastDate: DateTime.now(),
      );
      if (picked != null) rxRange.value = picked;
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Pilih opsi cetak',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Obx(() => Column(
                    children: [
                      RadioListTile<String>(
                        title: const Text('Semua transaksi'),
                        value: 'all',
                        groupValue: selectedMode.value,
                        onChanged: (v) => selectedMode.value = v ?? '',
                      ),
                      RadioListTile<String>(
                        title: const Text('Transaksi per NIS'),
                        value: 'nis',
                        groupValue: selectedMode.value,
                        onChanged: (v) => selectedMode.value = v ?? '',
                      ),
                      if (selectedMode.value == 'nis') ...[
                        TextField(
                          controller: nisC,
                          decoration: const InputDecoration(
                            labelText: 'Masukkan NIS siswa',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      // Date range
                      ListTile(
                        title: const Text('Rentang tanggal'),
                        subtitle: Obx(() {
                          final r = rxRange.value;
                          return Text(r == null
                              ? 'Tidak dipilih'
                              : '${DateFormat('dd/MM/yyyy').format(r.start)} - ${DateFormat('dd/MM/yyyy').format(r.end)}');
                        }),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: pickRange,
                      ),
                      const SizedBox(height: 6),
                      // Quick presets
                      _buildDatePresets(rxRange),
                      const SizedBox(height: 12),
                      // Status checkboxes
                      _buildStatusCheckboxes(statuses, selectedStatuses),
                    ],
                  )),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(
                            color: Colors.grey.shade300, width: 1.5),
                      ),
                      child: Text('Batal',
                          style: TextStyle(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        _exportPdf(
                          context,
                          controller,
                          nis: selectedMode.value == 'nis'
                              ? nisC.text.trim()
                              : null,
                          range: rxRange.value,
                          statuses: selectedStatuses.isNotEmpty
                              ? selectedStatuses.toList()
                              : null,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.indigo,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('Cetak PDF',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildDatePresets(Rxn<DateTimeRange> rxRange) {
    final now = DateTime.now();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          TextButton(
            onPressed: () {
              final today = DateTime(now.year, now.month, now.day);
              rxRange.value = DateTimeRange(start: today, end: today);
            },
            child: const Text('Hari ini'),
          ),
          TextButton(
            onPressed: () {
              final start =
                  now.subtract(Duration(days: now.weekday - 1));
              rxRange.value = DateTimeRange(start: start, end: now);
            },
            child: const Text('Minggu ini'),
          ),
          TextButton(
            onPressed: () {
              final start = DateTime(now.year, now.month, 1);
              rxRange.value = DateTimeRange(start: start, end: now);
            },
            child: const Text('Bulan ini'),
          ),
          TextButton(
            onPressed: () {
              final start = DateTime(now.year, 1, 1);
              rxRange.value = DateTimeRange(start: start, end: now);
            },
            child: const Text('Tahun ini'),
          ),
          TextButton(
            onPressed: () => rxRange.value = null,
            child: const Text('Semua'),
          ),
        ],
      ),
    );
  }

  static Widget _buildStatusCheckboxes(
      List<String> statuses, RxList<String> selectedStatuses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: statuses.map((s) {
        String translatedStatus = s;
        switch (s) {
          case 'pending':
            translatedStatus = 'Menunggu Approval';
            break;
          case 'approved':
            translatedStatus = 'Disetujui';
            break;
          case 'dipinjam':
            translatedStatus = 'Dipinjam';
            break;
          case 'dikembalikan':
            translatedStatus = 'Dikembalikan / Selesai';
            break;
          case 'rejected':
            translatedStatus = 'Ditolak';
            break;
        }
        return Obx(() => CheckboxListTile(
              title: Text(translatedStatus,
                  style: const TextStyle(fontSize: 14)),
              value: selectedStatuses.contains(s),
              activeColor: AppColors.indigo,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (v) {
                if (v == true) {
                  selectedStatuses.add(s);
                } else {
                  selectedStatuses.remove(s);
                }
              },
            ));
      }).toList(),
    );
  }

  static Future<void> _exportPdf(
    BuildContext context,
    AdminDashboardController controller, {
    String? nis,
    DateTimeRange? range,
    List<String>? statuses,
  }) async {
    List<dynamic> list = controller.filteredTransactions;
    if (nis != null && nis.isNotEmpty) {
      list = list.where((t) => t.user?.nis == nis).toList();
    }
    DateTime? tryParse(String str) {
      try {
        return DateFormat('dd MMMM yyyy', 'id_ID').parse(str);
      } catch (_) {
        return null;
      }
    }

    if (range != null) {
      list = list.where((t) {
        final d = tryParse(t.tanggalPinjam);
        if (d == null) return false;
        return !d.isBefore(range.start) && !d.isAfter(range.end);
      }).toList();
    }
    if (statuses != null && statuses.isNotEmpty) {
      list = list.where((t) {
        return statuses.contains(t.status) ||
            statuses.contains(t.statusApproval);
      }).toList();
    }

    final font = await PdfGoogleFonts.openSansRegular();
    final fontBold = await PdfGoogleFonts.openSansBold();

    final pdf = pw.Document();
    final now = DateTime.now();
    final dateStr = DateFormat('dd MMMM yyyy', 'id_ID').format(now);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(
          base: font,
          bold: fontBold,
        ),
        build: (pw.Context ctx) {
          return [
            _buildPdfHeader(dateStr),
            pw.SizedBox(height: 10),
            pw.Divider(thickness: 1, color: PdfColors.grey300),
            pw.SizedBox(height: 20),
            if (range != null ||
                (statuses != null && statuses.isNotEmpty) ||
                nis != null) ...[
              _buildPdfFilterInfo(nis, range, statuses),
              pw.SizedBox(height: 15),
            ],
            _buildPdfTable(list),
            pw.SizedBox(height: 30),
            _buildPdfFooter(list.length),
          ];
        },
      ),
    );

    final bytes = await pdf.save();
    await Printing.sharePdf(
      bytes: bytes,
      filename:
          'Laporan_Transaksi_${DateFormat('yyyyMMdd_HHmm').format(now)}.pdf',
    );
  }

  static pw.Widget _buildPdfHeader(String dateStr) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('PERPUSTAKAAN DIGITAL',
                style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.indigo)),
            pw.SizedBox(height: 4),
            pw.Text('Laporan Transaksi Peminjaman Buku',
                style: pw.TextStyle(
                    fontSize: 12, fontWeight: pw.FontWeight.bold)),
            pw.Text('Jl. Raya Pendidikan No. 44, Indonesia',
                style: pw.TextStyle(
                    fontSize: 10, color: PdfColors.grey700)),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('Tanggal Cetak:',
                style: pw.TextStyle(
                    fontSize: 10, color: PdfColors.grey700)),
            pw.Text(dateStr,
                style: pw.TextStyle(
                    fontSize: 10, fontWeight: pw.FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildPdfFilterInfo(
      String? nis, DateTimeRange? range, List<String>? statuses) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius:
            const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Kriteria Filter:',
              style: pw.TextStyle(
                  fontSize: 9, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 2),
          if (range != null)
            pw.Text(
                'Periode: ${DateFormat('dd/MM/yyyy').format(range.start)} - ${DateFormat('dd/MM/yyyy').format(range.end)}',
                style: const pw.TextStyle(fontSize: 8)),
          if (nis != null && nis.isNotEmpty)
            pw.Text('NIS: $nis',
                style: const pw.TextStyle(fontSize: 8)),
          if (statuses != null && statuses.isNotEmpty)
            pw.Text('Status: ${statuses.join(", ")}',
                style: const pw.TextStyle(fontSize: 8)),
        ],
      ),
    );
  }

  static pw.Widget _buildPdfTable(List<dynamic> list) {
    return pw.Table.fromTextArray(
      headers: [
        'ID', 'NIS', 'Nama Siswa', 'Buku & Jumlah', 'Tgl Pinjam', 'Status'
      ],
      data: list.map((trx) {
        final books = trx.items.map((i) {
          final title = i.book?.judul ?? '';
          return i.quantity > 1 ? '$title (x${i.quantity})' : title;
        }).join('\n');

        String statusLabel = trx.status;
        if (trx.statusApproval == 'rejected') {
          statusLabel = 'Ditolak';
        } else if (trx.status == 'dipinjam') {
          statusLabel = 'Dipinjam';
        } else if (trx.status == 'dikembalikan') {
          statusLabel = 'Selesai';
        } else if (trx.status == 'pending') {
          statusLabel = 'Menunggu';
        }

        return [
          trx.id.toString(),
          trx.user?.nis ?? '-',
          trx.user?.name ?? '-',
          books,
          trx.tanggalPinjam,
          statusLabel,
        ];
      }).toList(),
      headerStyle: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
          fontSize: 10),
      headerDecoration:
          const pw.BoxDecoration(color: PdfColors.indigo),
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellAlignment: pw.Alignment.centerLeft,
      cellPadding:
          const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      border: pw.TableBorder.all(
          color: PdfColors.grey200, width: 0.5),
      oddRowDecoration:
          const pw.BoxDecoration(color: PdfColors.grey50),
    );
  }

  static pw.Widget _buildPdfFooter(int totalCount) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Ringkasan:',
                style: pw.TextStyle(
                    fontSize: 10, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Text('Total Transaksi: $totalCount',
                style: const pw.TextStyle(fontSize: 10)),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text('Petugas Perpustakaan,',
                style: const pw.TextStyle(fontSize: 10)),
            pw.SizedBox(height: 50),
            pw.Container(width: 120, height: 1, color: PdfColors.black),
            pw.SizedBox(height: 4),
            pw.Text('(....................................)',
                style: const pw.TextStyle(fontSize: 10)),
          ],
        ),
      ],
    );
  }
}
