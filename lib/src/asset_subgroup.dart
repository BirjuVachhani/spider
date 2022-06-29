import 'package:spider/src/utils.dart';

/// Holds prefix, types and path info for [Group]
class AssetSubgroup {
  late final String prefix;
  late final List<String> types;
  late final List<String> paths;

  AssetSubgroup({
    required this.paths,
    this.prefix = '',
    this.types = const <String>[],
  });

  AssetSubgroup.fromJson(Map<String, dynamic> json) {
    prefix = json['prefix']?.toString() ?? '';
    types = <String>[];
    json['types']?.forEach(
        (group) => types.add(formatExtension(group.toString()).toLowerCase()));
    paths = <String>[];
    if (json['paths'] != null) {
      paths.addAll(List<String>.from(json['paths']));
    } else if (json['path'] != null) {
      paths.add(json['path'].toString());
    }
  }
}
