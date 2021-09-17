enum DirectoryItemType { directory, file }

class DirectoryItem {
  String name;
  int size;
  DirectoryItemType type;

  DirectoryItem({
    required this.name,
    required this.size,
    required this.type,
  });

  @override
  String toString() {
    return '$name';
  }
}
