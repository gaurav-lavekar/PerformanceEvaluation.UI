class APIGoalMaster {
  List<GoalMaster>? goals;

  APIGoalMaster({required this.goals});

  APIGoalMaster.fromJson(Map<String, dynamic> json) {
    if (json['records'] != null) {
      goals = <GoalMaster>[];
      json['records'].forEach((v) {
        goals!.add(GoalMaster.fromJson(v));
      });
    }
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (goals != null) {
      data['records'] = goals!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class GoalMaster {
  GoalMaster(
      this.employeeId,
      this.goalDetailsId,
      this.financialyearid,
      this.financialyear,
      this.goalSettingId,
      this.goalDescription,
      this.goalStartDate,
      this.goalEndDate,
      this.deleted,
      this.goalStatus,
      this.goalPerspectiveId,
      this.goalPerspectiveName,
      this.goalMeasurementUnit,
      this.goalTargetValue);

  String? employeeId;
  String? financialyearid;
  String? goalSettingId;
  String? goalDetailsId;
  String? goalPerspectiveId;
  String? goalPerspectiveName;
  String? goalDescription;
  DateTime? goalStartDate;
  String? financialyear;
  DateTime? goalEndDate;
  bool? deleted;
  String? goalMeasurementUnit;
  String? goalStatus;
  String? createdBy;
  String? goalTargetValue;

  GoalMaster.fromJson(Map<String, dynamic> json) {
    employeeId = json["employeeid"];
    goalSettingId = json["goalsettingid"];
    goalDetailsId = json["goaldetailsid"];
    goalPerspectiveId = json["goalperspectiveid"] ?? "";
    goalPerspectiveName = json["goalperspectivename"] ?? "";
    goalDescription = json["goaldescription"] ?? "";
    goalTargetValue = json["goaltargetvalue"] ?? "";
    goalStartDate = json["goalstartdate"] != null
        ? DateTime.tryParse(json["goalstartdate"])
        : null;
    goalEndDate = json["goalenddate"] != null
        ? DateTime.tryParse(json["goalenddate"])
        : null;
    goalMeasurementUnit = json["goalmeasurementunit"] ?? "";
    financialyearid = json["financialyearid"];
    financialyear = json["financialyear"] ?? "";
    goalStatus = json['goalstatus'] ?? "";
    createdBy = json['createdby'] ?? "";
    deleted = json["deleted"] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['employeeid'] = employeeId;
    data['goalsettingid'] = goalSettingId;
    data['goaldetailsid'] = goalDetailsId;
    data['goalperspectiveid'] = goalPerspectiveId;
    data['goalperspectivename'] = goalPerspectiveName;
    data['goaldescription'] = goalDescription;
    data['financialyearid'] = financialyearid;
    data['financialyear'] = financialyear;
    data['goalstartdate'] = goalStartDate;
    data['goalenddate'] = goalEndDate;
    data['goalmeasurementunit'] = goalMeasurementUnit;
    data['goaltargetvalue'] = goalTargetValue;
    data['goalstatus'] = goalStatus;
    data['deleted'] = deleted;
    data['createdby'] = createdBy;

    return data;
  }
}
