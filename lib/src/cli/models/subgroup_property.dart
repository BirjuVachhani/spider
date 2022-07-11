/// Represents a sub_group property.
class SubgroupProperty {
  /// Subgroup prefix.
  final String prefix;

  /// Subgroup file map (fileName: path).
  final Map<String, String> files;

  /// Creates an instance of [SubgroupProperty].
  SubgroupProperty(this.prefix, this.files);
}
