class APIAssessmentMaster {
  List<AssessmentMaster>? assessments;

  APIAssessmentMaster({required this.assessments});

  APIAssessmentMaster.fromJson(Map<String, dynamic> json) {
    if (json["records"] != null) {
      assessments = <AssessmentMaster>[];
      json["records"].forEach((v) {
        assessments!.add(AssessmentMaster.fromJson(v));
      });
    }
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (assessments != null) {
      data["records"] = assessments!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AssessmentMaster {
  AssessmentMaster(
    this.assessmentId,
    this.assessmentPeriod,
    this.assessmentYear,
    this.assessmentQuarter,
    this.employeeId,
    this.assessmentStatus,
    this.overallRating,
    this.assessmentdetails,
    this.assessmentqualitatives,
    this.deleted,
  );

  String? assessmentId;
  String? employeeId;
  String? assessmentPeriod;
  String? assessmentQuarter;
  String? assessmentYear;
  String? assessmentStatus;
  int? overallRating;
  List<AssessmentDetails>? assessmentdetails;
  List<AssessmentQualitatives>? assessmentqualitatives;
  bool? deleted;

  AssessmentMaster.fromJson(Map<String, dynamic> json) {
    assessmentId = json["assessmentid"];
    assessmentPeriod = json["assessmentperiod"];
    assessmentYear = json["assessmentyear"];
    assessmentQuarter = json["assessmentquarter"];
    employeeId = json["employeeid"];
    assessmentStatus = json["assessmentstatus"];
    assessmentdetails = (json["assessmentdetails"] as List<dynamic>? ?? [])
        .map((detailsJson) =>
            AssessmentDetails.fromJson(detailsJson as Map<String, dynamic>))
        .toList();
    assessmentqualitatives =
        (json["assessmentqualitatives"] as List<dynamic>? ?? [])
            .map((qualitativeJson) => AssessmentQualitatives.fromJson(
                qualitativeJson as Map<String, dynamic>))
            .toList();
    overallRating = json["overallrating"];
    deleted = json["deleted"] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data["assessmentid"] = assessmentId;
    data["assessmentperiod"] = assessmentPeriod;
    data["assessmentyear"] = assessmentYear;
    data["assessmentquarter"] = assessmentQuarter;
    data["employeeid"] = employeeId;
    data["assessmentstatus"] = assessmentStatus;
    data["assessmentdetails"] = assessmentdetails;
    data["assessmentqualitatives"] = assessmentqualitatives;
    data["overallrating"] = overallRating;
    data["deleted"] = deleted;

    return data;
  }
}

class AssessmentDetails {
  AssessmentDetails(
      this.assessmentDetailsId,
      this.assessmentId,
      this.goalsettingId,
      this.actual,
      this.selfRating,
      this.appraiseeComments,
      this.appraiserComments,
      this.appraiserRating,
      this.deleted);

  String? assessmentDetailsId;
  String? assessmentId;
  String? goalsettingId;
  int? selfRating;
  String? actual;
  String? appraiseeComments;
  int? appraiserRating;
  String? appraiserComments;
  bool? deleted;

  AssessmentDetails.fromJson(Map<String, dynamic> json) {
    assessmentDetailsId = json["assessmentdetailsid"];
    assessmentId = json["assessmentid"];
    goalsettingId = json["goalsettingid"];
    actual = json["actual"];
    selfRating = json["selfrating"];
    appraiseeComments = json["appraiseecomments"] ?? "";
    appraiserRating = json["appraiserrating"];
    appraiserComments = json["appraisercomments"] ?? "";
    deleted = json["deleted"] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data["assessmentid"] = assessmentId;
    data["assessmentdetailsid"] = assessmentDetailsId;
    data["goalsettingid"] = goalsettingId;
    data["actual"] = actual;
    data["selfrating"] = selfRating;
    data["appraiseecomments"] = appraiseeComments;
    data["appraiserrating"] = appraiserRating;
    data["appraiseecomments"] = appraiserComments;
    data["deleted"] = deleted;

    return data;
  }
}

class AssessmentQualitatives {
  AssessmentQualitatives(
      this.assessmentQualitativeId,
      this.assessmentId,
      this.qualtitativeItemId,
      this.qualitativeItemName,
      this.qualtitativeItemScale,
      this.qualitativeItemComment,
      this.deleted);

  String? assessmentQualitativeId;
  String? assessmentId;
  String? qualtitativeItemId;
  String? qualitativeItemName;
  int? qualtitativeItemScale;
  String? qualitativeItemComment;
  bool? deleted;

  AssessmentQualitatives.fromJson(Map<String, dynamic> json) {
    assessmentQualitativeId = json["assessmentqualitativeid"];
    assessmentId = json["assessmentid"];
    qualtitativeItemId = json["qualitativeitemid"];
    qualitativeItemName = json["qualitativeitemname"];
    qualtitativeItemScale = json["qualitativeitemscale"];
    qualitativeItemComment = json["qualitativeitemcomment"];
    deleted = json["deleted"] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data["assessmentqualitativeid"] = assessmentQualitativeId;
    data["assessmentid"] = assessmentId;
    data["qualitativeitemid"] = qualtitativeItemId;
    data["qualitativeitemname"] = qualitativeItemName;
    data["qualitativeitemscale"] = qualtitativeItemScale;
    data["qualitativeitemcomment"] = qualitativeItemComment;
    data["deleted"] = deleted ?? false;

    return data;
  }
}
