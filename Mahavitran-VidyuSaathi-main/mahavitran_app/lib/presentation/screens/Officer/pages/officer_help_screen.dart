import 'package:flutter/material.dart';
import 'package:civic_core/presentation/constants/app_colors.dart';

class OfficerHelpScreen extends StatelessWidget {
  const OfficerHelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.grey[50],
      appBar: AppBar(
        title: const Text('Help & Support'),
        elevation: 0,
        backgroundColor: isDark ? AppColors.darkSidebar : const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              'Frequently Asked Questions',
              [
                _buildFAQItem(context, 'How do I reassign a ticket?', 'Go to "All Tickets", open the ticket details, and click the "Reassign" button.'),
                _buildFAQItem(context, 'How do I download reports?', 'Navigate to the "Reports" section and click the "Export PDF" button at the top right.'),
                 _buildFAQItem(context, 'Can I change my profile details?', 'Currently profile details are read-only. Please contact HR for updates.'),
              ],
              isDark,
            ),
            const SizedBox(height: AppSpacing.xl),
            _buildSection(
              context,
              'Contact Support',
              [
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: const Text('Email Support'),
                  subtitle: const Text('it.support@mahavitran.in'),
                  tileColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                  onTap: () {},
                ),
                const SizedBox(height: AppSpacing.sm),
                ListTile(
                  leading: const Icon(Icons.phone_outlined),
                  title: const Text('Helpline'),
                  subtitle: const Text('1800-123-4567'),
                   tileColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                  onTap: () {},
                ),
              ],
              isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: AppFontWeights.semiBold,
            color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        ...children,
      ],
    );
  }

  Widget _buildFAQItem(BuildContext context, String question, String answer) {
    return ExpansionTile(
      title: Text(
        question, 
        style: const TextStyle(fontSize: AppFontSizes.sm, fontWeight: AppFontWeights.medium),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: TextStyle(
              fontSize: AppFontSizes.sm,
              color: Theme.of(context).dividerColor.withOpacity(0.7), // Using divider color as proxy for muted
            ),
          ),
        ),
      ],
    );
  }
}
