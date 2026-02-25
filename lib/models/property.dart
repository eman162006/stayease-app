class Property {
  final String id;
  final String title;
  final String location;
  final double pricePerNight;
  final String imageUrl;

  const Property({
    required this.id,
    required this.title,
    required this.location,
    required this.pricePerNight,
    required this.imageUrl,
  });
   Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'location': location,
        'pricePerNight': pricePerNight,
        'imageUrl': imageUrl,
      };

  factory Property.fromJson(Map<String, dynamic> json) => Property(
        id: json['id'] as String,
        title: json['title'] as String,
        location: json['location'] as String,
        pricePerNight: (json['pricePerNight'] as num).toDouble(),
        imageUrl: json['imageUrl'] as String,
      );
}