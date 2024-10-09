class Cue {
  final int id;
  final String name;
  final String description;
  final String img;
  final double price;
  final int cueTypeId;

  Cue({
    required this.id,
    required this.name,
    required this.description,
    required this.img,
    required this.price,
    required this.cueTypeId,
  });

  factory Cue.fromMap(Map<String, dynamic> map) {
    return Cue(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      img: map['img'],
      price: map['price'],
      cueTypeId: map['cue_type_id'],
    );
  }
}
