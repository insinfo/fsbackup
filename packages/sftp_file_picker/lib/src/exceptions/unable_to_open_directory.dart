class UnableToOpenDirectory implements Exception {
  dynamic message;
  StackTrace? stackTrace;
  UnableToOpenDirectory(
      {this.message = 'Não foi possível abrir este diretório, verifique se este caminho está correto!',
      this.stackTrace});

  String toString() {
    Object? message = this.message;
    if (message == null) return "";
    return " $message";
  }
}
