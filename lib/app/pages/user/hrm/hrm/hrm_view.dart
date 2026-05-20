import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/core.dart';
import '../../../../widgets/widgets.dart';
import '../../../../../i18n/strings.g.dart';
import '../../../../routes/app_routes.gr.dart';

@RoutePage()
class HrmView extends ConsumerWidget {
  const HrmView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(context.t.common.hrm),
      ),
      body: PermissionGate.canAny(
        moduleKeys: [
          PMKeys.department,
          PMKeys.designation,
          PMKeys.shift,
          PMKeys.employee,
          PMKeys.leaveType,
          PMKeys.leave,
          PMKeys.holiday,
          PMKeys.attendance,
          PMKeys.payroll,
          PMKeys.attendanceReport,
          PMKeys.payrollReport,
          PMKeys.leaveReport,
        ],
        fallback: PermissionGate.imageFallback(),
        child: PageNavigationListView(
          navTiles: [
            // Department
            if (ref.can(PMKeys.department)) ...[
              PageNavigationNavTile(
                svgIconPath: DAppSvgIcons.hrmIcons.department,
                title: context.t.hrm.department,
                route: const DepartmentListRoute(),
              ),
            ],

            // Designation
            if (ref.can(PMKeys.designation)) ...[
              PageNavigationNavTile(
                svgIconPath: DAppSvgIcons.hrmIcons.designation,
                title: context.t.hrm.designation,
                route: const DesignationListRoute(),
              ),
            ],

            // Shift
            if (ref.can(PMKeys.shift)) ...[
              PageNavigationNavTile(
                svgIconPath: DAppSvgIcons.hrmIcons.shift,
                title: context.t.hrm.shift,
                route: const ShiftListRoute(),
              ),
            ],

            // Employee
            if (ref.can(PMKeys.employee)) ...[
              PageNavigationNavTile(
                svgIconPath: DAppSvgIcons.hrmIcons.employee,
                title: context.t.hrm.employee,
                route: const EmployeeListRoute(),
              ),
            ],

            // Leave Request
            if (ref.canAny([PMKeys.leaveType, PMKeys.leave])) ...[
              PageNavigationNavTile(
                svgIconPath: DAppSvgIcons.hrmIcons.leaveRequest,
                title: context.t.hrm.leaveRequest,
                submenus: [
                  // Leave Type
                  if (ref.can(PMKeys.leaveType)) ...[
                    PageNavigationNavTile(
                      title: context.t.hrm.leaveType,
                      route: const LeaveTypeListRoute(),
                    ),
                  ],
                  // Leave
                  if (ref.can(PMKeys.leave)) ...[
                    PageNavigationNavTile(
                      title: context.t.hrm.leave,
                      route: const LeaveListRoute(),
                    ),
                  ],
                ],
              ),
            ],

            // Holiday
            if (ref.can(PMKeys.holiday)) ...[
              PageNavigationNavTile(
                svgIconPath: DAppSvgIcons.hrmIcons.holiday,
                title: context.t.hrm.holiday,
                route: const HolidayListRoute(),
              ),
            ],

            // Attendance
            if (ref.can(PMKeys.attendance)) ...[
              PageNavigationNavTile(
                svgIconPath: DAppSvgIcons.hrmIcons.attendance,
                title: context.t.hrm.attendance,
                route: const AttendanceListRoute(),
              ),
            ],

            // Payroll
            if (ref.can(PMKeys.payroll)) ...[
              PageNavigationNavTile(
                svgIconPath: DAppSvgIcons.hrmIcons.payroll,
                title: context.t.hrm.payroll,
                route: const PayrollListRoute(),
              ),
            ],

            // Reports
            if (ref.canAny([PMKeys.attendanceReport, PMKeys.payrollReport, PMKeys.leaveReport])) ...[
              PageNavigationNavTile(
                svgIconPath: DAppSvgIcons.hrmIcons.reports,
                title: context.t.common.reports,
                submenus: [
                  // Attendance Report
                  if (ref.can(PMKeys.attendanceReport)) ...[
                    PageNavigationNavTile(
                      title: context.t.hrm.attendance,
                      route: const AttendanceReportListRoute(),
                    ),
                  ],

                  // Payroll Report
                  if (ref.can(PMKeys.payrollReport)) ...[
                    PageNavigationNavTile(
                      title: context.t.hrm.payroll,
                      route: const PayrollReportListRoute(),
                    ),
                  ],

                  // Leave Report
                  if (ref.can(PMKeys.leaveReport)) ...[
                    PageNavigationNavTile(
                      title: context.t.hrm.leave,
                      route: const LeaveReportListRoute(),
                    ),
                  ],
                ],
              ),
            ],
          ],
          onTap: (value) async {
            if (value.type == PageNavigationListTileType.navigation && value.route != null) {
              return await context.router.push<void>(value.route!);
            }
          },
        ),
      ),
    );
  }
}
