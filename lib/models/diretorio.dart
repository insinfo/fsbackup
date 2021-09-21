class Diretorio {
  Diretorio({this.path});

  String path;

  factory Diretorio.fromMap(Map<String, dynamic> json) => Diretorio(
        path: json['path'],
      );

  Map<String, dynamic> toMap() => {
        'path': path,
      };
}
