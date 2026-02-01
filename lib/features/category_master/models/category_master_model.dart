class APICategoryMaster {
  List<CategoryMaster>? category;

  APICategoryMaster({required this.category});

  APICategoryMaster.fromJson(Map<String, dynamic> json) {
    if (json['records'] != null) {
      category = <CategoryMaster>[];
      json['records'].forEach((v) {
        category!.add(CategoryMaster.fromJson(v));
      });
    }
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (category != null) {
      data['records'] = category!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CategoryMaster {
  CategoryMaster(this.ratingCategoryId, this.ratingCategoryName, this.deleted);

  String? ratingCategoryId;
  String? ratingCategoryName;
  bool? deleted;

  CategoryMaster.fromJson(Map<String, dynamic> json) {
    ratingCategoryId = json["ratingcategoryid"];
    ratingCategoryName = json["ratingcategoryname"] ?? "";
    deleted = json["deleted"] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ratingcategoryid'] = ratingCategoryId;
    data['ratingcategoryname'] = ratingCategoryName;
    data['deleted'] = deleted;

    return data;
  }
}
