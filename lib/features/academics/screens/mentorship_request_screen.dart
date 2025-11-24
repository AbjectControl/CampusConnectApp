import 'package:cconnect/common/widgets/appbar/custom_appbar.dart';
import 'package:cconnect/common/widgets/forms/custom_textformfield.dart';
import 'package:cconnect/data/models/mentorProfile.dart';
import 'package:cconnect/data/repositories/functions/FireBaseFunctions/mentorship_repository.dart';
import 'package:cconnect/features/personalization/controllers/userProvider.dart';
import 'package:cconnect/utils/constraints/sizing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MentorshipRequestScreen extends StatefulWidget {
  const MentorshipRequestScreen({super.key});

  @override
  State<MentorshipRequestScreen> createState() => _MentorshipRequestScreenState();
}

class _MentorshipRequestScreenState extends State<MentorshipRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectsController = TextEditingController();
  final _bioController = TextEditingController();
  final _availabilityController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _subjectsController.dispose();
    _bioController.dispose();
    _availabilityController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final currentUser = Provider.of<UserProvider>(context, listen: false).user!;
      final subjects = _subjectsController.text.split(',').map((s) => s.trim()).toList();
      
      final mentorProfile = MentorProfile(
        userId: currentUser.id,
        subjects: subjects,
        bio: _bioController.text,
        availability: {'description': _availabilityController.text}, // Store as map
        approved: false, // Pending admin approval
      );

      await MentorshipRepository.instance.submitMentorshipRequest(mentorProfile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mentorship request submitted! Awaiting admin approval.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Request Mentorship',
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: Sizing.paddingAll16,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Become a Mentor',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Share your knowledge and help fellow students. Your request will be reviewed by an admin.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              
              CustomTextFormField(
                controller: _subjectsController,
                labelText: 'Subjects',
                hintText: 'e.g., Math, Physics, Programming (comma-separated)',
                svgIcon: '',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter at least one subject';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: _bioController,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  hintText: 'Tell us about your expertise and teaching experience',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              
              CustomTextFormField(
                controller: _availabilityController,
                labelText: 'Availability',
                hintText: 'e.g., Weekdays 6-8 PM, Weekends',
                svgIcon: '',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your availability';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitRequest,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Submit Request'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
