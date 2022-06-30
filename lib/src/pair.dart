/// Represents a pair of values.
class Pair<Ty1, Ty2> {
  /// First value.
  final Ty1 first;

  /// Second value.
  final Ty2 second;

  /// Creates an instance of [Pair].
  const Pair(this.first, this.second);

  /// Creates an instance of [Pair] with the specified list [values].
  factory Pair.fromList(List values) {
    if (values.length != 2) {
      throw ArgumentError('values must have length 2');
    }

    return Pair<Ty1, Ty2>(values[0] as Ty1, values[1] as Ty2);
  }

  /// Creates a [List] containing the values of this [Pair].
  ///
  /// The elements are in item order. The list is variable-length
  /// if [growable] is true.
  List toList({bool growable = false}) =>
      List.from([first, second], growable: growable);

  @override
  String toString() => '[$first, $second]';

  @override
  bool operator ==(Object other) =>
      other is Pair && other.first == first && other.second == second;

  @override
  int get hashCode => Object.hash(first.hashCode, second.hashCode);
}
