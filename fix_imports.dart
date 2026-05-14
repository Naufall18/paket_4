import 'dart:io';

void main() {
  final dir1 = Directory('lib/presentation/admin/dashboard/views/widgets/components');
  final dir2 = Directory('lib/presentation/siswa/dashboard/views/widgets/components');
  
  void processDir(Directory dir) {
    if (!dir.existsSync()) return;
    for (var file in dir.listSync(recursive: true)) {
      if (file is File && file.path.endsWith('.dart')) {
        var content = file.readAsStringSync();
        var original = content;
        
        // fix the incorrect package name
        content = content.replaceAll("package:mobile_paket44/", "package:paket44/");
        
        if (content != original) {
          file.writeAsStringSync(content);
          print("Fixed package name in ${file.path}");
        }
      }
    }
  }
  
  processDir(dir1);
  processDir(dir2);
  
  // also fix siswa/dashboard_widget.dart
  final f1 = File('lib/presentation/siswa/dashboard/views/widgets/dashboard_widget.dart');
  if (f1.existsSync()) {
      var content = f1.readAsStringSync();
      content = content.replaceAll("package:mobile_paket44/", "package:paket44/");
      f1.writeAsStringSync(content);
      print("Fixed ${f1.path}");
  }
  
  // also fix admin/dashboard_widget.dart
  final f2 = File('lib/presentation/admin/dashboard/views/widgets/dashboard_widget.dart');
  if (f2.existsSync()) {
      var content = f2.readAsStringSync();
      content = content.replaceAll("package:mobile_paket44/", "package:paket44/");
      f2.writeAsStringSync(content);
      print("Fixed ${f2.path}");
  }
}
