import 'dart:io';

void main() {
  final adminTabs = Directory(
    'c:/mobile/paket44/lib/presentation/admin/dashboard/views/tabs',
  );
  if (adminTabs.existsSync()) {
    adminTabs.renameSync(
      'c:/mobile/paket44/lib/presentation/admin/dashboard/views/widgets',
    );
  }

  final siswaTabs = Directory(
    'c:/mobile/paket44/lib/presentation/siswa/dashboard/views/tabs',
  );
  if (siswaTabs.existsSync()) {
    siswaTabs.renameSync(
      'c:/mobile/paket44/lib/presentation/siswa/dashboard/views/widgets',
    );
  }

  // Rename the files from _tab.dart to _widget.dart
  final adminWidgets = Directory(
    'c:/mobile/paket44/lib/presentation/admin/dashboard/views/widgets',
  );
  if (adminWidgets.existsSync()) {
    for (var file in adminWidgets.listSync()) {
      if (file is File && file.path.endsWith('_tab.dart')) {
        file.renameSync(file.path.replaceAll('_tab.dart', '_widget.dart'));
      }
    }
  }

  final siswaWidgets = Directory(
    'c:/mobile/paket44/lib/presentation/siswa/dashboard/views/widgets',
  );
  if (siswaWidgets.existsSync()) {
    for (var file in siswaWidgets.listSync()) {
      if (file is File && file.path.endsWith('_tab.dart')) {
        file.renameSync(file.path.replaceAll('_tab.dart', '_widget.dart'));
      }
    }
  }
}
