enum MeasurementUnits {
  metric('Metric', 'Metric'),
  imperial('Imperial', 'Imperial');

  const MeasurementUnits(this.label, this.apiValue);

  final String label;

  /// Value for the Routes API `InstructionsMeasurementSystem` field.
  final String apiValue;
}
