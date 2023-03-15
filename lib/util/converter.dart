
import 'dart:typed_data';

Uint8List stringToUint8List(String data) {
  final list = data.codeUnits;
  return Uint8List.fromList(list);
}

String uInt8ListToString(Uint8List data) {
  return String.fromCharCodes(data);
}