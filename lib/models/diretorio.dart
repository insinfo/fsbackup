class Diretorio {
  Diretorio({
    this.path,
    this.id,
  });

  String path;
  String id;

  factory Diretorio.fromMap(Map<String, dynamic> json) => Diretorio(
        path: json['path'],
        id: json['id'],
      );

  Map<String, dynamic> toMap() => {
        'path': path,
        'id': id,
      };
}
