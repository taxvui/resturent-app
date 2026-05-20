import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../../widgets/widgets.dart';

@RoutePage()
class NotificationDetailsView extends StatelessWidget {
  const NotificationDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: ListTile(
          contentPadding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
          title: Text(
            'Your rent is due (Reminder 1)',
            style: _theme.textTheme.titleMedium?.copyWith(
              color: _theme.colorScheme.onPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 18,
            ),
          ),
          subtitle: Text(
            DateTime.now().getFormatedString(pattern: 'dd MMM yyyy - hh:mm a'),
            style: _theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.grey[300],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          'Hi [Tenant\'s Name]\n\nHope this message finds you well. Just a friendly reminder that your monthly house rental payment is due on [Due Date]. Kindly ensure that the payment is made by this date to avoid any inconvenience.\n\nYou can make the payment through the app, and if you have any questions or need assistance, please feel free to reach out to me.\n\nThank you for your prompt attention to this matter.\n\nBest regards,\nRiead',
          style: _theme.textTheme.bodyLarge,
        ),
      ),
    );
  }
}
