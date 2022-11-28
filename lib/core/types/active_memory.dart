class ActiveMemory<ActiveType> {

  final DateTime createdAt;

  final DateTime? expiresAt;

  final ActiveType? activeType;

  const ActiveMemory({
    required this.createdAt,
    this.expiresAt,
    this.activeType,
  });

  factory ActiveMemory.create(ActiveType? activeType, {DateTime? dateTime}) =>
      ActiveMemory(
        createdAt: DateTime.now(),
        expiresAt: dateTime,
        activeType: activeType,
      );

  ActiveMemory<ActiveType> copyWith({
    DateTime? createdAt,
    DateTime? expiresAt,
    ActiveType? activeType,
  }) {
    return ActiveMemory<ActiveType>(
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      activeType: activeType ?? this.activeType,
    );
  }
}
