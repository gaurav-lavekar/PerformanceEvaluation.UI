class APIEmployeeMaster {
  List<EmployeeMaster>? employees;

  APIEmployeeMaster({required this.employees});

  APIEmployeeMaster.fromJson(Map<String, dynamic> json) {
    if (json['records'] != null) {
      employees = <EmployeeMaster>[];
      json['records'].forEach((v) {
        employees!.add(EmployeeMaster.fromJson(v));
      });
    }
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (employees != null) {
      data['records'] = employees!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class EmployeeMaster {
  EmployeeMaster(
      this.employeeId,
      this.empid,
      this.firstName,
      this.middleName,
      this.lastName,
      this.gender,
      this.educationQualification,
      this.department,
      this.emailId,
      this.phone,
      this.joiningDate,
      this.confirmationDate,
      this.designation,
      this.supervisorId,
      this.employeeLoginId,
      this.deleted,
      this.activefromdate,
      this.inactivefromdate,
      this.createdOn,
      this.createdBy,
      this.modifiedOn,
      this.modifiedBy,
      this.supervisor,
      this.reportees);

  String? employeeId;
  String? empid;
  String? firstName;
  String? middleName;
  String? lastName;
  String? gender;
  String? educationQualification;
  String? department;
  String? emailId;
  String? phone;
  DateTime? joiningDate;
  DateTime? confirmationDate;
  String? designation;
  String? supervisorId;
  String? employeeLoginId;
  bool? deleted;
  DateTime? activefromdate;
  DateTime? inactivefromdate;
  DateTime? createdOn;
  String? createdBy;
  DateTime? modifiedOn;
  String? modifiedBy;
  List<EmployeeMaster>? supervisor;
  List<EmployeeMaster>? reportees;

  EmployeeMaster.fromJson(Map<String, dynamic> json) {
    employeeId = json["employeeid"];
    empid = json["empid"];
    firstName = json["firstname"] ?? "";
    middleName = json["middlename"] ?? "";
    lastName = json["lastname"] ?? "";
    gender = json["gender"] ?? "";
    educationQualification = json["highesteducationqualification"] ?? "";
    department = json["department"] ?? "";
    emailId = json["emailid"] ?? "";
    phone = json["phone"] ?? "";
    joiningDate = json["dateofjoining"] != null
        ? DateTime.tryParse(json["dateofjoining"])
        : null;
    confirmationDate = json["dateofconfirmation"] != null
        ? DateTime.tryParse(json["dateofconfirmation"])
        : null;
    designation = json["designation"] ?? "";
    supervisorId = json["supervisorid"] ?? "";
    employeeLoginId = json["employeeloginid"];
    deleted = json["deleted"] ?? false;
    createdOn =
        json["createdon"] != null ? DateTime.tryParse(json["createdon"]) : null;
    createdBy = json["createdby"] ?? "";
    modifiedOn = json["modifiedon"] != null
        ? DateTime.tryParse(json["modifiedon"])
        : null;
    modifiedBy = json["modifiedby"] ?? "";
    activefromdate = json["activefromdate"] != null
        ? DateTime.tryParse(json["activefromdate"])
        : null;
    inactivefromdate = json["inactivefromdate"] != null
        ? DateTime.tryParse(json["inactivefromdate"])
        : null;
    supervisor = (json['supervisor'] as List<dynamic>? ?? [])
        .map((supervisorJson) =>
            EmployeeMaster.fromJson(supervisorJson as Map<String, dynamic>))
        .toList();
    reportees = (json['reportees'] as List<dynamic>? ?? [])
        .map((reporteeJson) =>
            EmployeeMaster.fromJson(reporteeJson as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['employeeid'] = employeeId;
    data['empid'] = empid;
    data['firstname'] = firstName;
    data['middlename'] = middleName;
    data['lastname'] = lastName;
    data['gender'] = gender;
    data['highesteducationqualification'] = educationQualification;
    data['department'] = department;
    data['emailid'] = emailId;
    data['phone'] = phone;
    data['dateofjoining'] = joiningDate;
    data['dateofconfirmation'] = confirmationDate;
    data['designation'] = designation;
    data['supervisorid'] = supervisorId;
    data['employeeloginid'] = employeeLoginId;
    data['deleted'] = deleted;
    data['createdby'] = createdBy;
    data['createdon'] = createdOn;
    data['modifiedby'] = modifiedBy;
    data['modifiedon'] = modifiedOn;
    data['supervisor'] = supervisor!.map((s) => s.toJson()).toList();
    data['reportees'] =
        reportees!.map((reportee) => reportee.toJson()).toList();

    return data;
  }
}
