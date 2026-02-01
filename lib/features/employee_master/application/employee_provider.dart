import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:perf_evaluation/features/employee_master/data/employee_repository.dart';
import 'package:perf_evaluation/features/employee_master/models/employee_master_model.dart';
import 'package:perf_evaluation/features/my_goals/application/goal_provider.dart';

final Map<String, String> requestHeaders = {'Content-type': 'application/json'};

final employeeMaster = FutureProvider.autoDispose<String>((ref) async {
  try {
    final employeeList =
        await ref.watch(employeeMasterRepositoryProvider).getEmployees();

    final employee = employeeList.employees;

    ref.watch(employeeMasterListNotifier.notifier).clearEmployee();

    for (var i = 0; i < employee!.length; i++) {
      ref.watch(employeeMasterListNotifier.notifier).addEmployee(employee[i]);
    }

    return 'Success';
  } catch (e) {
    //print(e.toString());
    throw e.toString();
  }
});

final employeeMasterbyId = FutureProvider.autoDispose<String>((ref) async {
  try {
    final requestbody = ref.read(employeeId);
    final employeeList = await ref
        .watch(employeeMasterRepositoryProvider)
        .getEmployeebyId(requestBody: requestbody);

    final employee = employeeList.employees;

    ref.watch(employeeMasterListNotifier.notifier).clearEmployee();

    for (var i = 0; i < employee!.length; i++) {
      ref.watch(employeeMasterListNotifier.notifier).addEmployee(employee[i]);
    }

    return 'Success';
  } catch (e) {
    //print(e.toString());
    throw e.toString();
  }
});

final saveEmployeeMaster = FutureProvider.autoDispose<String>((ref) async {
  try {
    final requestBody = ref.watch(employeeBody);

    final response = await ref
        .watch(employeeMasterRepositoryProvider)
        .postEmployee(requestBody: requestBody, requestHeaders: requestHeaders);

    final employeeList =
        await ref.read(employeeMasterRepositoryProvider).getEmployees();

    final employee = employeeList.employees;

    ref.read(employeeMasterListNotifier.notifier).clearEmployee();

    for (var i = 0; i < employee!.length; i++) {
      ref.read(employeeMasterListNotifier.notifier).addEmployee(employee[i]);
    }
    return response;
  } catch (e) {
    //print(e.toString());
    throw e.toString();
  }
});

final updateEmployeeMaster = FutureProvider.autoDispose<String>((ref) async {
  try {
    final requestBody = ref.watch(updateEmployeeBody);
    final response = await ref
        .watch(employeeMasterRepositoryProvider)
        .updateEmployee(
            requestHeaders: requestHeaders, requestBody: requestBody);

    final employeeList =
        await ref.read(employeeMasterRepositoryProvider).getEmployees();

    final employee = employeeList.employees;

    ref.read(employeeMasterListNotifier.notifier).clearEmployee();

    for (var i = 0; i < employee!.length; i++) {
      ref.read(employeeMasterListNotifier.notifier).addEmployee(employee[i]);
    }
    return response;
  } catch (e) {
    //print(e.toString());
    throw e.toString();
  }
});

final deleteEmployeeMaster = FutureProvider.autoDispose<String>((ref) async {
  try {
    final requestBody = ref.watch(deleteEmployeeBody);
    final response = await ref
        .watch(employeeMasterRepositoryProvider)
        .deleteEmployee(
            requestBody: requestBody, requestHeaders: requestHeaders);

    final employeeList =
        await ref.read(employeeMasterRepositoryProvider).getEmployees();

    final employee = employeeList.employees;

    ref.read(employeeMasterListNotifier.notifier).clearEmployee();

    for (var i = 0; i < employee!.length; i++) {
      ref.read(employeeMasterListNotifier.notifier).addEmployee(employee[i]);
    }
    return response;
  } catch (e) {
    //print(e.toString());
    throw e.toString();
  }
});

final employeeMasterListNotifier =
    StateNotifierProvider<EmployeeMasterNotifier, List<EmployeeMaster>>((ref) {
  return EmployeeMasterNotifier();
});

final employeeBody = StateProvider<Map>((ref) {
  return {};
});

final updateEmployeeBody = StateProvider<Map>((ref) {
  return {};
});

final deleteEmployeeBody = StateProvider<String>((ref) {
  return "";
});

final loggedInUser = StateProvider<Map>((ref) {
  return {};
});

final dateofjoining = StateProvider<String>((ref) {
  return "";
});
