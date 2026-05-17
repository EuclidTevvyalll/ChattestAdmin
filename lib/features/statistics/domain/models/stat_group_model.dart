class StatGroupModel {
  final String label;
  final double count;

  const StatGroupModel({required this.label, required this.count});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatGroupModel &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          count == other.count;

  @override
  int get hashCode => label.hashCode ^ count.hashCode;
}
