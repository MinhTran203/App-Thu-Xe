class Product {
  int id;
  String name;
  String img;
  String description;

  Product({
    required this.id,
    required this.name,
    required this.img,
    required this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'],
        name: json['name'],
        img: json['img'], // Thay đổi từ 'imgtyle' thành 'img'
        description: json['description'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'img': img, // Thay đổi từ 'imgtyle' thành 'img'
        'description': description,
      };
}

class CueType {
  int id;
  String name;
  String img;
  String description;
  int productId;

  CueType({
    required this.id,
    required this.name,
    required this.img,
    required this.description,
    required this.productId,
  });

  factory CueType.fromJson(Map<String, dynamic> json) => CueType(
        id: json['id'],
        name: json['name'],
        img: json['img'], // Thay đổi từ 'imgtyle' thành 'img'
        description: json['description'],
        productId: json['product_id'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'img': img, // Thay đổi từ 'imgtyle' thành 'img'
        'description': description,
        'product_id': productId,
      };
}

class Cue {
  int id;
  String name;
  String description;
  String img;
  double price;
  int cueTypeId;

  Cue({
    required this.id,
    required this.name,
    required this.description,
    required this.img,
    required this.price,
    required this.cueTypeId,
  });

  factory Cue.fromJson(Map<String, dynamic> json) => Cue(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        img: json['img'],
        price: json['price'],
        cueTypeId: json['cue_type_id'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'img': img,
        'price': price,
        'cue_type_id': cueTypeId,
      };
}

class Account {
  int id;
  String username;
  String password;
  String email;

  Account({
    required this.id,
    required this.username,
    required this.password,
    required this.email,
  });

  factory Account.fromJson(Map<String, dynamic> json) => Account(
        id: json['id'],
        username: json['username'],
        password: json['password'],
        email: json['email'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'password': password,
        'email': email,
      };
}
