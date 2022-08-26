import 'dart:convert';

void main(List<String> args) {
  // var base64Str = 'QzovVXNlcnMvaXNhcXVlL0RvY3VtZW50cy9iYWNrdXBfdGVzdGUvdG1wX3Rlc3RlXzIwMjIuMDguMjUuMTcuNDUuNTkvcHJvamV0bzFfYW50aWdvX2NvbV90dWRvL2NhZENsaSAtIEPzcGlhMi5waHA=';
  var base64fileNameLatin1 = 'Y2FkQ2xpIC0gQ/NwaWExLnBocA=='; //cadCli - Cópia1.php
  print(base64.decode(base64fileNameLatin1));
  var strLatin1 = latin1.decode(base64.decode(base64fileNameLatin1));

  print(strLatin1.codeUnits);

  print(Utf8Encoder().convert(strLatin1)); //utf8.decode([67, 67, 112]));
}
