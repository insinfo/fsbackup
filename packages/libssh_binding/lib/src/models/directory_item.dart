enum DirectoryItemType { directory, file }

class DirectoryItem {
  late String name;
  late int size;
  late DirectoryItemType type;
  late String path;
  String? longname;

  List<int>? nativePath;

  DirectoryItem({
    required this.name,
    required this.size,
    required this.type,
    required this.path,
    this.longname,
    this.nativePath,
  });

  factory DirectoryItem.fromName(String name) => DirectoryItem(
      longname: name, name: name, path: name, nativePath: name.codeUnits, size: 0, type: DirectoryItemType.directory);

  @override
  String toString() {
    return '$name';
  }
}
