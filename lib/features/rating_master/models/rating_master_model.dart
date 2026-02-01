class APIRatingMaster {
  List<RatingMaster>? rating;

  APIRatingMaster({required this.rating});

  APIRatingMaster.fromJson(Map<String, dynamic> json) {
    if (json['records'] != null) {
      rating = <RatingMaster>[];
      json['records'].forEach((v) {
        rating!.add(RatingMaster.fromJson(v));
      });
    }
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (rating != null) {
      data['records'] = rating!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class RatingMaster {
  RatingMaster(this.ratingId, this.ratingScale, this.ratingCategoryId,
      this.ratingCategory, this.deleted);

  String? ratingId;
  int? ratingScale;
  String? ratingCategoryId;
  String? ratingCategory;
  bool? deleted;

  RatingMaster.fromJson(Map<String, dynamic> json) {
    ratingId = json["ratingid"]??"";
    ratingScale = json["ratingscale"]??0;
    ratingCategoryId = json["ratingcategoryid"]??"";
    ratingCategory = json["ratingcategory"]??"";
    deleted = json["deleted"]?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ratingid'] = ratingId;
    data['ratingscale'] = ratingScale;
    data['ratingcategoryid'] = ratingCategoryId;
    data['ratingcategory'] = ratingCategory;
    data['deleted'] = deleted;

    return data;
  }
}

