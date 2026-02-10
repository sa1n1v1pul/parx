class ProductModel {
  final int id;
  final String name;
  final String description;
  final String price;
  final int rewardPoints;
  final int warrantyPeriodMonths;
  final CategoryModel? category;
  final SubcategoryModel? subcategory;
  final List<String> images;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.rewardPoints,
    required this.warrantyPeriodMonths,
    this.category,
    this.subcategory,
    required this.images,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] ?? '0.00',
      rewardPoints: json['reward_points'] ?? 0,
      warrantyPeriodMonths: json['warranty_period_months'] ?? 0,
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'])
          : null,
      subcategory: json['subcategory'] != null
          ? SubcategoryModel.fromJson(json['subcategory'])
          : null,
      images: json['images'] != null
          ? List<String>.from(json['images'])
          : [],
    );
  }
}

class CategoryModel {
  final int id;
  final String name;

  CategoryModel({required this.id, required this.name});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class SubcategoryModel {
  final int id;
  final String name;

  SubcategoryModel({required this.id, required this.name});

  factory SubcategoryModel.fromJson(Map<String, dynamic> json) {
    return SubcategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

