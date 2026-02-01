class APIPerspectiveMaster {
  List<PerspectiveMaster>? perspective;

  APIPerspectiveMaster({required this.perspective});

  APIPerspectiveMaster.fromJson(Map<String, dynamic> json) {
    if (json['records'] != null) {
      perspective = <PerspectiveMaster>[];
      json['records'].forEach((v) {
        perspective!.add(PerspectiveMaster.fromJson(v));
      });
    }
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (perspective != null) {
      data['records'] = perspective!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PerspectiveMaster {
  PerspectiveMaster(this.goalPerspectiveId, this.goalPerspectiveName, this.deleted);

  String? goalPerspectiveId;
  String? goalPerspectiveName;
  bool? deleted;

  PerspectiveMaster.fromJson(Map<String, dynamic> json) {
   
    goalPerspectiveId = json["goalperspectiveid"]??"";
    goalPerspectiveName = json["goalperspectivename"]??"";
    deleted = json["deleted"]?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
   
    data['goalperspectiveid'] = goalPerspectiveId;
    data['goalperspectivename'] = goalPerspectiveName;
    data['deleted'] = deleted;

    return data;
  }
}

