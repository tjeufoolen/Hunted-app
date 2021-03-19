class Prototype {
  final int id;
  final String text;
  final String price;

  Prototype({this.id, this.text, this.price});

  factory Prototype.fromJson(Map<String, dynamic> json) {
    return Prototype(
      id: json['id'],
      text: json['text'],
      price: json['price'],
    );
  }
}
