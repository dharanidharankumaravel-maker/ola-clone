import 'dart:convert';
import 'dart:io';

void main() {
  final content = File('assets/auto.svg').readAsStringSync();
  final base64Regex = RegExp(r'base64,(.*?)"');
  final match = base64Regex.firstMatch(content);
  if (match != null) {
    final base64String = match.group(1)!;
    final bytes = base64Decode(base64String);
    File('assets/auto.png').writeAsBytesSync(bytes);
    print('Extracted to assets/auto.png');
  } else {
    print('No base64 found');
  }
}
