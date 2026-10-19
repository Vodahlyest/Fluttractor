enum Density {
  low(label: "5000 points", step: 0.01),
  mid(label: "50000 points", step: 0.001),
  high(label: "500000 points", step: 0.0001);

  final String label;
  final double step;

  const Density({required this.label, required this.step});
}
