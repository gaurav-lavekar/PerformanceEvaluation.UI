class ApiFYMaster {
  List<FinancialYearMaster>? financialyears;

  ApiFYMaster({required this.financialyears});

  ApiFYMaster.fromJson(Map<String, dynamic> json) {
    if (json['records'] != null) {
      financialyears = <FinancialYearMaster>[];
      json['records'].forEach((v) {
        financialyears!.add(FinancialYearMaster.fromJson(v));
      });
    }
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (financialyears != null) {
      data['records'] = financialyears!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class FinancialYearMaster {
  FinancialYearMaster(
    this.financialYear,
    this.financialyearid,
    this.deleted,
  );

  String? financialyearid;
  String? financialYear;
  bool? deleted;

  FinancialYearMaster.fromJson(Map<String, dynamic> json) {
    financialyearid = json["financialyearid"];
    financialYear = json["financialyear"] ?? "";
    deleted = json["deleted"] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['financialyearid'] = financialyearid;
    data['financialyear'] = financialYear;
    data['deleted'] = deleted;

    return data;
  }
}
