import 'package:cconnect/common/widgets/appbar/custom_appbar.dart';
import 'package:cconnect/data/models/survey.dart';
import 'package:cconnect/features/community/controllers/survey_provider.dart';
import 'package:cconnect/features/community/screens/communitySurveys/add_survey_dialog.dart';
import 'package:cconnect/utils/helpers/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class CommunitySurveysScreen extends StatelessWidget {
  const CommunitySurveysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Surveys",
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _showAddSurveyDialog(context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Consumer<SurveyProvider>(
        builder: (context, provider, child) {
          return StreamBuilder<List<Survey>>(
            stream: provider.getSurveys(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final surveys = snapshot.data ?? [];

              if (surveys.isEmpty) {
                return const Center(child: Text('No surveys available'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: surveys.length,
                itemBuilder: (context, index) {
                  return _SurveyCard(survey: surveys[index]);
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showAddSurveyDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const AddSurveyDialog());
  }
}

class _SurveyCard extends StatelessWidget {
  final Survey survey;

  const _SurveyCard({required this.survey});

  @override
  Widget build(BuildContext context) {
    final isActive = survey.status == SurveyStatus.active && !survey.isExpired;
    final isClosed = survey.status == SurveyStatus.closed || survey.isExpired;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and menu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    survey.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'report',
                      child: Row(
                        children: [
                          Icon(Icons.report, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text('Report Survey'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'report') {
                      _reportSurvey(context);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              survey.description,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 16),

            // Status and action buttons
            Row(
              children: [
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.green[50] : Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isActive ? Colors.green : Colors.red,
                    ),
                  ),
                  child: Text(
                    isActive ? 'Open' : 'Closed',
                    style: TextStyle(
                      color: isActive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Action button
                if (isActive)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _openSurveyLink(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Fill Survey'),
                    ),
                  ),
                if (isClosed)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _openSurveyLink(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2196F3),
                        side: const BorderSide(color: Color(0xFF2196F3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('View Results'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openSurveyLink(BuildContext context) async {
    final uri = Uri.parse(survey.surveyLink);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        SnackbarService.error('Could not open survey link');
      }
    }
  }

  void _reportSurvey(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Report Survey'),
        content: const Text(
          'Are you sure you want to report this survey as inappropriate?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await Provider.of<SurveyProvider>(
                  context,
                  listen: false,
                ).reportSurvey(survey.id);
                if (context.mounted) {
                  SnackbarService.success('Survey reported successfully');
                }
              } catch (e) {
                if (context.mounted) {
                  SnackbarService.error('Failed to report survey');
                }
              }
            },
            child: const Text('Report', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
