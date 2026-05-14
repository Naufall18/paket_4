import 'dart:io';

void main() {
  Directory dir = Directory('c:/laragon/www/paket44/mobile_paket44/lib');
  List<File> files = dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();
  for (var file in files) {
    if (file.path.contains('app_colors.dart')) continue;
    String content = file.readAsStringSync();

    List<String> keywords = [
      'TextStyle',
      'BoxDecoration',
      'BorderSide',
      'Text',
      'Icon',
      'Padding',
      'Container',
      'SizedBox',
      'Center',
      'Column',
      'Row',
      'ListView',
      'Expanded',
      'ListTile',
      'CircleAvatar',
      'ClipRRect',
      'InputDecoration',
      'OutlineInputBorder',
      'RoundedRectangleBorder',
      'IconThemeData',
      'TextTheme',
      'AppBarTheme',
      'BottomNavigationBarThemeData',
      'Card',
      'Align',
      'Divider',
      'ThemeData',
      'ColorScheme',
      'EdgeInsets',
    ];

    for (var word in keywords) {
      content = content.replaceAll('const ' + word, word);
    }
    file.writeAsStringSync(content);
  }
}
