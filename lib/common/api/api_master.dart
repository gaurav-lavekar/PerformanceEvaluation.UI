import 'package:global_configuration/global_configuration.dart';

class PerfAppraisalAPI {
  PerfAppraisalAPI();

  static final String schema = GlobalConfiguration().getValue("SCHEMA");
  static final String apiBaseUrl = GlobalConfiguration().getValue("APIBASEURL");
  static final String apiPrefix =
      GlobalConfiguration().getValue("AppraisalServicePrefix");

  Uri category() =>
      buildUrl(endpoint: GlobalConfiguration().getValue("GETCATEGORY"));

  Uri rating() =>
      buildUrl(endpoint: GlobalConfiguration().getValue("GETRATINGS"));

  Uri assessment() =>
      buildUrl(endpoint: GlobalConfiguration().getValue("GETASSESSMENTS"));

  Uri perspective() =>
      buildUrl(endpoint: GlobalConfiguration().getValue("GETPERSPECTIVE"));

  Uri employee() =>
      buildUrl(endpoint: GlobalConfiguration().getValue("GETEMPLOYEES"));

  Uri goals() => buildUrl(endpoint: GlobalConfiguration().getValue("GETGOALS"));

  Uri financialyears() =>
      buildUrl(endpoint: GlobalConfiguration().getValue("GETFINANCIALYEARS"));

  Uri getRating() => buildUriWithParam(
      endpoint: GlobalConfiguration().getValue("GETRATINGS"),
      parametersBuilder: pageSize);

  Uri getGoals() => buildUriWithParam(
      endpoint: GlobalConfiguration().getValue("GETGOALS"),
      parametersBuilder: pageSize);

  Uri getAssessments() => buildUriWithParam(
      endpoint: GlobalConfiguration().getValue("GETASSESSMENTS"),
      parametersBuilder: pageSize);

  Uri getPerspective() => buildUriWithParam(
      endpoint: GlobalConfiguration().getValue("GETPERSPECTIVE"),
      parametersBuilder: pageSize);

  Uri getEmployee() => buildUriWithParam(
      endpoint: GlobalConfiguration().getValue("GETEMPLOYEES"),
      parametersBuilder: pageSize);

  Uri getFinancialYears() => buildUriWithParam(
      endpoint: GlobalConfiguration().getValue("GETFINANCIALYEARS"),
      parametersBuilder: pageSize);

  Uri getCategory() => buildUriWithParam(
      endpoint: GlobalConfiguration().getValue("GETCATEGORY"),
      parametersBuilder: pageSize);

  Uri buildUrl({required String endpoint}) {
    return Uri(
      scheme: schema,
      host: apiBaseUrl,
      //port: 7153,
      path: apiPrefix + endpoint,
    );
  }

  Uri buildUriWithParam({
    required String endpoint,
    required Map<String, dynamic> Function() parametersBuilder,
  }) {
    return Uri(
      scheme: schema,
      host: apiBaseUrl,
      path: apiPrefix + endpoint,
      //port: 7153,
      queryParameters: pageSize(),
    );
  }

  Map<String, String> apiRequestHeader = {
    'Content-type': 'application/json',
    //'applicationname':'PerfEvalApp'
  };

  Map<String, String> getAPIRequestHeader() {
    apiRequestHeader['application_name'] =
        GlobalConfiguration().getValue("APPLICATIONNAME"); //PerfEvalApp
    return apiRequestHeader;
  }

  Map<String, dynamic> pageSize() => {
        "page[number]": "1",
        "page[size]": "25",
      };
}
