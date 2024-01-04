class Child {
  final String id;
  final String name;
  final String lname;
  final String dob;
  final String gender;
  final String state;
  final String? country;
  final String? weight;
  final String? height;
  final String weightUnit;
  final String heightUnit;
  final String? image;

  Child({
    required this.id,
    required this.name,
    required this.lname,
    required this.dob,
    required this.gender,
    required this.state,
    this.country,
    this.weight,
    this.height,
    required this.weightUnit,
    required this.heightUnit,
    this.image,
  });
}
