import 'dart:convert';
import 'dart:html' as html;

import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:perf_evaluation/common/utilities/notification_type.dart';
import 'package:perf_evaluation/common/widgets/notification_bar.dart';
import 'package:perf_evaluation/features/assessment/presentation/assessment_navigation.dart';
import 'package:perf_evaluation/features/category_master/presentation/category_navigation.dart';
import 'package:perf_evaluation/features/employee_master/application/employee_provider.dart';
import 'package:perf_evaluation/features/employee_master/models/employee_master_model.dart';
import 'package:perf_evaluation/features/employee_master/presentation/employee_navigation.dart';
import 'package:perf_evaluation/features/financial_year/presentation/financialyear_navigation.dart';
import 'package:perf_evaluation/features/hr/presentation/hr_navigation.dart';
import 'package:perf_evaluation/features/my_goals/application/goal_provider.dart';
import 'package:perf_evaluation/features/my_goals/presentation/goal_navigation.dart';
import 'package:perf_evaluation/features/people/presentation/people_navigation.dart';
import 'package:perf_evaluation/features/perspective_master/presentation/perspective_navigation.dart';
import 'package:perf_evaluation/features/rating_master/presentation/rating_navigation.dart';
import 'package:perf_evaluation/features/reportees/presentation/reportees_navigation.dart';

import 'package:syn_multitenancy/common/helper.dart';
import 'package:syn_multitenancy/login/presentation/widgets/loading_widget.dart';
import 'package:syn_multitenancy/login/presentation/screens/login.dart';
import 'package:syn_multitenancy/common/auth_service.dart';
import 'package:syn_multitenancy/user_session/user_session_activity.dart';
import 'package:syn_useraccess/models/user.dart';
import 'package:syn_useraccess/models/useraccess.dart';
import 'package:syn_useraccess/provider/useraccess_provider.dart';
import 'package:syn_useraccess/syn_useraccess.dart';
import 'package:syn_useraccess/user/application/user_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, required this.navigatorKey});

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  ConsumerState<HomeScreen> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<HomeScreen> {
  PageController pageController =
      html.window.sessionStorage.containsKey('activePageIndex')
          ? PageController(
              initialPage:
                  int.parse(html.window.sessionStorage['activePageIndex']!))
          : PageController();
  SideMenuController sideMenu =
      html.window.sessionStorage.containsKey('activePageIndex')
          ? SideMenuController(
              initialPage:
                  int.parse(html.window.sessionStorage['activePageIndex']!))
          : SideMenuController();
  List<UserAccess> lstUserAccess = [];
  String? selectedPage = "";
  User userDetails = User(userFirstName: '', userLastName: '', userEmailId: '');

  late Future<void> _loadFuture;
  late Future<void> _loadEmployeeId;
  late Future<void> _loadAll;

  @override
  void dispose() {
    super.dispose();
    sideMenu.dispose();
    pageController.dispose();
  }

  @override
  void initState() {
    super.initState();
    sideMenu.addListener((index) {
      if (html.window.sessionStorage['activePageIndex'] == index.toString()) {
        //jump to dummy page
        pageController.jumpToPage(9999);
        setState(() {
          selectedPage = ''; // Temporarily change the selected page
        });
        Future.delayed(const Duration(milliseconds: 100), () {
          setState(() {
            selectedPage =
                index.toString(); // Temporarily change the selected page
          });
          pageController.jumpToPage(index);
        });
      } else {
        html.window.sessionStorage['activePageIndex'] = index.toString();
        pageController.jumpToPage(index);
      }
    });

    _loadFuture = _loadUserAccess();
    _loadEmployeeId = getEmployeeId(); // API call for fetching employee id
    List<Future> futures = [];
    futures.add(_loadFuture);
    futures.add(_loadEmployeeId);
    _loadAll = Future.wait(futures);
  }

  Future<void> _loadUserAccess() async {
    String? userJson = Helper.decrypt(html.window.sessionStorage['user']!);

    userDetails = User.fromJson(jsonDecode(userJson));
    //ref.read(userIdProvider.notifier).setUserId(userDetails.userID!);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      lstUserAccess = (json.decode(
                  Helper.decrypt(html.window.sessionStorage['userAccess']!))
              as List)
          .map((item) => UserAccess.fromJson(item as Map<String, dynamic>))
          .toList();
      ref.read(useraccessListNotifier.notifier).addUserAccess(lstUserAccess);
    });
  }

  Future<void> logout() async {
    // Clear user session (if necessary)
    await clearSession();
    html.window.sessionStorage.remove('activePageIndex');
    await AuthService.logout(
        context,
        ref,
        LoginScreen(
          navigatorKey: widget.navigatorKey,
          redirectWidget: HomeScreen(navigatorKey: widget.navigatorKey),
          loginScreenImagePath: 'assets/icons/login.svg',
        ));
  }

  Future<void> getEmployeeId() async {
    var resp = await ref.read(employeeMaster.future);
    var user = await ref.read(userMaster.future);
    String username = ref
        .read(userMasterListNotifier)
        .firstWhere((user) => user.userid == userDetails.userID)
        .username!;

    String employeeid = ref
        .read(employeeMasterListNotifier)
        .firstWhere((element) => element.employeeLoginId == username)
        .employeeId!;

    ref.watch(employeeId.notifier).state = employeeid;

    Map<String, dynamic> userLogin = {
      'userid': '${userDetails.userID}',
      'name': '${userDetails.userFirstName} ${userDetails.userLastName}',
    };

    ref.watch(loggedInUser.notifier).state = userLogin;
  }

  bool isSupervisor() {
    ref.read(employeeMaster.future);
    String username = ref
        .read(userMasterListNotifier)
        .firstWhere((user) => user.userid == userDetails.userID)
        .username!;

    List<EmployeeMaster> employee = ref
        .read(employeeMasterListNotifier)
        .where((element) => element.employeeLoginId == username)
        .toList();

    if (employee[0].reportees!.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadAll,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while _loadUserAccess is still running
          return const LoadingDialogWidget();
        } else if (snapshot.hasError) {
          // Show a loading indicator while _loadUserAccess is still running
          showNotificationBar(
                  NotificationTypes.error, 'Error getting user access')
              .show(context);
          return const SizedBox.shrink();
        } else {
          return PopScope(
              canPop: false,
              child: UserActivityTracker(
                  onInactivity: logout,
                  child: Scaffold(
                    appBar: AppBar(
                      title: const Text('Employee Performance Evaluation'),
                      centerTitle: false,
                      actions: [
                        const Icon(Icons.account_circle_rounded, size: 30),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(right: 50),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Row(
                                // Aligns items to the ends
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${userDetails.userFirstName!} ${userDetails.userLastName!}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        userDetails.userEmailId!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(width: 10),
                                  IconButton(
                                      alignment: Alignment.center,
                                      icon: const Icon(
                                        Icons.exit_to_app,
                                        size: 30,
                                      ), // Using the exit_to_app icon
                                      tooltip: 'Logout',
                                      onPressed: () async {
                                        clearProvider();
                                        await logout();
                                      }),
                                ]),
                          ),
                        ),
                      ],
                    ),
                    body: Container(
                      color: const Color.fromARGB(255, 236, 239, 251),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SideMenu(
                            controller: sideMenu,
                            style: SideMenuStyle(
                              itemHeight: 40.0,
                              openSideMenuWidth: 270,
                              showTooltip: true,
                              displayMode: SideMenuDisplayMode.auto,
                              showHamburger: true,
                              hoverColor: Colors.blue[100],
                              selectedHoverColor: Colors.blue[100],
                              selectedColor: Colors.lightBlue,
                              selectedTitleTextStyle: const TextStyle(
                                color: Colors.white,
                              ),
                              selectedIconColor: Colors.white,
                              backgroundColor:
                                  const Color.fromARGB(255, 236, 239, 251),
                            ),
                            items: [
                              if (hasAccess('O_Permissions'))
                                SideMenuItem(
                                  title: 'Roles',
                                  onTap: (index, _) {
                                    clearProvider();
                                    resetPage('Roles');
                                    sideMenu.changePage(index);
                                  },
                                  icon: const Icon(Icons.person_2_rounded),
                                ),
                              if (hasAccess('O_USRREG'))
                                SideMenuItem(
                                  title: 'Users',
                                  onTap: (index, _) {
                                    clearProvider();
                                    resetPage('Users');
                                    sideMenu.changePage(index);
                                  },
                                  icon:
                                      const Icon(Icons.supervised_user_circle),
                                ),
                              if (hasAccess('O_PermGroups'))
                                SideMenuItem(
                                  title: 'User Groups',
                                  onTap: (index, _) {
                                    clearProvider();
                                    resetPage('User Groups');
                                    sideMenu.changePage(index);
                                  },
                                  icon: const Icon(Icons.group),
                                ),
                              if (hasAccess('O_Category'))
                                SideMenuItem(
                                    title: "Categories",
                                    onTap: (index, _) {
                                      clearProvider();
                                      resetPage('Categories');
                                      sideMenu.changePage(index);
                                    },
                                    icon: const Icon(Icons.category_rounded)),
                              if (hasAccess('O_Employee'))
                                SideMenuItem(
                                    title: "Employee",
                                    onTap: (index, _) {
                                      clearProvider();
                                      resetPage('Employee');
                                      sideMenu.changePage(index);
                                    },
                                    icon: const Icon(Icons.person_rounded)),
                              if (hasAccess('O_FinancialYear'))
                                SideMenuItem(
                                    title: "Financial Year",
                                    onTap: (index, _) {
                                      clearProvider();
                                      resetPage('Financial Year');
                                      sideMenu.changePage(index);
                                    },
                                    icon: const Icon(
                                        Icons.calendar_month_outlined)),
                              if (hasAccess('O_HR'))
                                SideMenuItem(
                                    title: "HR View",
                                    onTap: (index, _) {
                                      clearProvider();
                                      resetPage('HR View');
                                      sideMenu.changePage(index);
                                    },
                                    icon: const Icon(Icons.person_2_rounded)),
                              if (hasAccess('O_Perspective'))
                                SideMenuItem(
                                    title: "Perspectives",
                                    onTap: (index, _) {
                                      clearProvider();
                                      resetPage('Perspectives');
                                      sideMenu.changePage(index);
                                    },
                                    icon: const Icon(Icons.category_rounded)),
                              if (hasAccess('O_Rating'))
                                SideMenuItem(
                                    title: "Ratings",
                                    onTap: (index, _) {
                                      clearProvider();
                                      resetPage('Ratings');
                                      sideMenu.changePage(index);
                                    },
                                    icon: const Icon(Icons.rate_review)),
                              if (hasAccess('O_MyGoals'))
                                SideMenuItem(
                                    title: "My Goals",
                                    onTap: (index, _) {
                                      clearProvider();
                                      resetPage('My Goals');
                                      sideMenu.changePage(index);
                                    },
                                    icon: const Icon(Icons.stairs)),
                              if (isSupervisor())
                                if (hasAccess('O_MyPeople'))
                                  SideMenuItem(
                                      title: "My People",
                                      onTap: (index, _) {
                                        clearProvider();
                                        resetPage('My People');
                                        sideMenu.changePage(index);
                                      },
                                      icon: const Icon(Icons.group)),
                              if (hasAccess('O_Assessment'))
                                SideMenuItem(
                                    title: "My Appraisals",
                                    onTap: (index, _) {
                                      clearProvider();
                                      resetPage('My Appraisals');
                                      sideMenu.changePage(index);
                                    },
                                    icon: const Icon(Icons.assessment)),
                              // if (isSupervisor())
                              //   if (hasAccess('O_Reportees'))
                              //     SideMenuItem(
                              //         title: "My Reportees",
                              //         onTap: (index, _) {
                              //           clearProvider();
                              //           resetPage('My Reportees');
                              //           sideMenu.changePage(index);
                              //         },
                              //         icon: const Icon(Icons.group)),
                            ],
                          ),
                          const VerticalDivider(
                            color: Color.fromARGB(255, 236, 239, 251),
                            width: 1,
                          ),
                          Expanded(
                            child: PageView(
                              controller: pageController,
                              children: [
                                if (hasAccess('O_Permissions'))
                                  buildPage(const RoleNavigation()),
                                if (hasAccess('O_USRREG'))
                                  buildPage(const UserNavigation()),
                                if (hasAccess('O_PermGroups'))
                                  buildPage(const GroupNavigation()),
                                if (hasAccess('O_Category'))
                                  buildPage(const CategoryNavigation()),
                                if (hasAccess('O_Employee'))
                                  buildPage(const EmployeeNavigation()),
                                if (hasAccess('O_FinancialYear'))
                                  buildPage(const FinancialYearNavigation()),
                                if (hasAccess('O_HR'))
                                  buildPage(const HRNavigation()),
                                if (hasAccess('O_Perspective'))
                                  buildPage(const PerspectiveNavigation()),
                                if (hasAccess('O_Rating'))
                                  buildPage(const RatingNavigation()),
                                if (hasAccess('O_MyGoals'))
                                  buildPage(const GoalNavigation()),
                                if (isSupervisor())
                                  if (hasAccess('O_MyPeople'))
                                    buildPage(const PeopleNavigation()),
                                if (hasAccess('O_Assessment'))
                                  buildPage(const AssessmentNavigation()),
                                // if (isSupervisor())
                                //   if (hasAccess('O_Reportees'))
                                //     buildPage(const ReporteesNavigation())
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )));
        }
      },
    );
  }

  void resetPage(String pageTitle) {
    setState(() {
      selectedPage = pageTitle;
    });
  }

  void clearProvider() {
    try {
      ref.watch(goalstartdate.notifier).state = "";
      ref.watch(financialyear.notifier).state = "";
      ref.watch(dateofjoining.notifier).state = "";
    } catch (e) {}
  }

  Future<void> clearSession() async {
    ref.invalidate(useraccessListNotifier);
    // ref.invalidate(userIdProvider);
  }

  bool hasAccess(String uiTag) {
    return lstUserAccess.any((access) => access.uiTag == uiTag);
  }

  String getPermission(String uiTag) {
    final permissionsSet = <String>{};
    lstUserAccess.where((access) => access.uiTag == uiTag).forEach((access) {
      permissionsSet.addAll(access.permission!.split('/'));
    });
    return permissionsSet.join('/');
  }

  Widget buildPage(Widget child) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Material(
        elevation: 2,
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            color: Color.fromARGB(255, 255, 255, 255),
          ),
          child: child,
        ),
      ),
    );
  }
}
