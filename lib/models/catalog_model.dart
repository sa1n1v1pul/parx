class CatalogModel {
  final int id;
  final String title;
  final String? pdf;
  final String? video;
  final String? image;
  final List<String> gallery;
  final String? createdAt;

  CatalogModel({
    required this.id,
    required this.title,
    this.pdf,
    this.video,
    this.image,
    this.gallery = const [],
    this.createdAt,
  });

  factory CatalogModel.fromJson(Map<String, dynamic> json) {
    final galleryList = json['gallery'];
    List<String> galleryUrls = [];
    if (galleryList is List) {
      galleryUrls = galleryList.map((e) => e.toString()).toList();
    }
    return CatalogModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      pdf: json['pdf']?.toString(),
      video: json['video']?.toString(),
      image: json['image']?.toString(),
      gallery: galleryUrls,
      createdAt: json['created_at']?.toString(),
    );
  }

  /// All viewable media: main image + gallery images (for full-screen gallery)
  List<String> get allImages {
    final list = <String>[];
    if (image != null && image!.isNotEmpty) list.add(image!);
    list.addAll(gallery);
    return list;
  }
}
