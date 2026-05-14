import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:paket44/core/theme/app_colors.dart';
import 'package:paket44/core/utils/snackbar_helper.dart';
import 'package:paket44/core/utils/url_utils.dart';
import 'package:paket44/presentation/admin/dashboard/controllers/admin_dashboard_controller.dart';
import 'package:paket44/presentation/shared/widgets/app_text_field.dart';

/// Add & Edit book dialogs extracted from BookWidget.
class BookFormDialog {
  // ── Add Book ──
  static void showAddDialog(
      BuildContext context, AdminDashboardController controller) {
    final judulC = TextEditingController();
    final pengarangC = TextEditingController();
    final penerbitC = TextEditingController();
    final kategoriC = TextEditingController();
    final deskripsiC = TextEditingController();
    final tahunC = TextEditingController();
    final stokC = TextEditingController();
    final lokasiRakC = TextEditingController();
    XFile? selectedImage;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          Future<void> pickImage() async {
            final picker = ImagePicker();
            final image = await picker.pickImage(source: ImageSource.gallery);
            if (image != null) setState(() => selectedImage = image);
          }

          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildDialogHeader(
                    Icons.add_circle_outline,
                    AppColors.indigo,
                    'Tambah Buku Baru',
                  ),
                  const SizedBox(height: 20),
                  _buildImagePicker(
                      context, selectedImage, null, pickImage),
                  const SizedBox(height: 20),
                  _buildFormFields(judulC, pengarangC, penerbitC,
                      kategoriC, deskripsiC, tahunC, stokC, lokasiRakC),
                  const SizedBox(height: 24),
                  _buildActionButtons(
                    confirmLabel: 'Simpan',
                    confirmColor: AppColors.indigo,
                    onConfirm: () {
                      if (judulC.text.isEmpty ||
                          pengarangC.text.isEmpty ||
                          kategoriC.text.isEmpty) {
                        SnackbarHelper.showError(
                          'Validasi',
                          'Judul, Pengarang, dan Kategori wajib diisi',
                        );
                        return;
                      }
                      controller.addBook({
                        'judul': judulC.text,
                        'pengarang': pengarangC.text,
                        'penerbit': penerbitC.text,
                        'kategori': kategoriC.text,
                        'deskripsi': deskripsiC.text,
                        'tahun': tahunC.text,
                        'stok': stokC.text.isNotEmpty ? stokC.text : '1',
                        'lokasi_rak': lokasiRakC.text,
                      }, image: selectedImage);
                      Get.back();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Edit Book ──
  static void showEditDialog(BuildContext context, dynamic book,
      AdminDashboardController controller) {
    final judulC = TextEditingController(text: book.judul);
    final pengarangC = TextEditingController(text: book.pengarang);
    final penerbitC = TextEditingController(text: book.penerbit);
    final kategoriC = TextEditingController(text: book.kategori);
    final deskripsiC = TextEditingController(text: book.deskripsi ?? '');
    final tahunC = TextEditingController(text: book.tahun);
    final stokC = TextEditingController(text: book.stok.toString());
    final lokasiRakC = TextEditingController(text: book.lokasiRak ?? '');
    XFile? selectedImage;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          Future<void> pickImage() async {
            final picker = ImagePicker();
            final image = await picker.pickImage(source: ImageSource.gallery);
            if (image != null) setState(() => selectedImage = image);
          }

          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildDialogHeader(
                    Icons.edit_outlined,
                    Colors.orange,
                    'Edit Detail Buku',
                  ),
                  const SizedBox(height: 20),
                  _buildImagePicker(
                      context, selectedImage, book, pickImage),
                  if (book.coverUrl != null &&
                      book.coverUrl!.isNotEmpty &&
                      selectedImage == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Ketuk untuk mengganti cover',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 11),
                      ),
                    ),
                  const SizedBox(height: 20),
                  _buildFormFields(judulC, pengarangC, penerbitC,
                      kategoriC, deskripsiC, tahunC, stokC, lokasiRakC),
                  const SizedBox(height: 24),
                  _buildActionButtons(
                    confirmLabel: 'Simpan',
                    confirmColor: Colors.orange,
                    onConfirm: () {
                      if (judulC.text.isEmpty ||
                          pengarangC.text.isEmpty ||
                          kategoriC.text.isEmpty) {
                        SnackbarHelper.showError(
                          'Validasi',
                          'Judul, Pengarang, dan Kategori wajib diisi',
                        );
                        return;
                      }
                      controller.editBook(book.id, {
                        'judul': judulC.text,
                        'pengarang': pengarangC.text,
                        'penerbit': penerbitC.text,
                        'kategori': kategoriC.text,
                        'deskripsi': deskripsiC.text,
                        'tahun': tahunC.text,
                        'stok': stokC.text.isNotEmpty ? stokC.text : '1',
                        'lokasi_rak': lokasiRakC.text,
                      }, image: selectedImage);
                      Get.back();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Shared builders ──

  static Widget _buildDialogHeader(
      IconData icon, Color color, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark),
        ),
      ],
    );
  }

  static Widget _buildImagePicker(BuildContext context, XFile? selectedImage,
      dynamic book, VoidCallback onTap) {
    final hasExistingCover = book != null &&
        book.coverUrl != null &&
        book.coverUrl!.isNotEmpty;
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 100,
          height: 140,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1E293B)
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.indigo.withOpacity(0.3),
              width: 1,
              style: BorderStyle.solid,
            ),
            image: (() {
              if (selectedImage == null && hasExistingCover) {
                final ImageProvider? provider = isLocalAsset(book.coverUrl)
                    ? AssetImage(book.coverUrl!) as ImageProvider
                    : isHttpImageUrl(book.coverUrl)
                        ? NetworkImage(book.coverUrl!) as ImageProvider
                        : null;
                return provider != null
                    ? DecorationImage(image: provider, fit: BoxFit.cover)
                    : null;
              }
              return null;
            })(),
          ),
          child: selectedImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: kIsWeb
                      ? Image.network(selectedImage.path,
                          fit: BoxFit.cover)
                      : Image.file(File(selectedImage.path),
                          fit: BoxFit.cover),
                )
              : (!hasExistingCover
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined,
                            color: AppColors.textMuted, size: 32),
                        const SizedBox(height: 8),
                        Text(
                          book == null ? 'Cover\n(Opsional)' : 'Ganti Cover',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: AppColors.textMuted, fontSize: 11),
                        ),
                      ],
                    )
                  : null),
        ),
      ),
    );
  }

  static Widget _buildFormFields(
    TextEditingController judulC,
    TextEditingController pengarangC,
    TextEditingController penerbitC,
    TextEditingController kategoriC,
    TextEditingController deskripsiC,
    TextEditingController tahunC,
    TextEditingController stokC,
    TextEditingController lokasiRakC,
  ) {
    return Column(
      children: [
        AppTextField(label: 'Judul Buku', controller: judulC, icon: Icons.book),
        const SizedBox(height: 12),
        AppTextField(
            label: 'Pengarang', controller: pengarangC, icon: Icons.person),
        const SizedBox(height: 12),
        AppTextField(
            label: 'Penerbit', controller: penerbitC, icon: Icons.business),
        const SizedBox(height: 12),
        AppTextField(
            label: 'Kategori', controller: kategoriC, icon: Icons.category),
        const SizedBox(height: 12),
        AppTextField(
            label: 'Deskripsi Singkat',
            controller: deskripsiC,
            icon: Icons.description),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                  label: 'Tahun',
                  controller: tahunC,
                  icon: Icons.calendar_today,
                  isNumber: true),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppTextField(
                  label: 'Stok',
                  controller: stokC,
                  icon: Icons.inventory,
                  isNumber: true),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AppTextField(
            label: 'Lokasi Rak',
            controller: lokasiRakC,
            icon: Icons.location_on_outlined),
      ],
    );
  }

  static Widget _buildActionButtons({
    required String confirmLabel,
    required Color confirmColor,
    required VoidCallback onConfirm,
  }) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Get.back(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              side: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            child: Text('Batal',
                style: TextStyle(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(confirmLabel,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}
