import 'package:flutter/material.dart';
import 'package:buddygoapp/core/widgets/custom_button.dart';

class ReportScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const ReportScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String? _selectedReason;
  final TextEditingController _detailsController = TextEditingController();
  bool _isSubmitting = false;

  final List<String> _reportReasons = [
    'Inappropriate behavior',
    'Harassment',
    'Fake profile',
    'Spam or scam',
    'Offensive content',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report User'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFF7B61FF),
                      child: Text(
                        widget.userName[0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.userName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1D2B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Report this user for inappropriate behavior',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6E7A8A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Reason Selection
            const Text(
              'Select a reason for reporting',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1D2B),
              ),
            ),
            const SizedBox(height: 16),
            ..._reportReasons.map((reason) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: RadioListTile(
                  title: Text(reason),
                  value: reason,
                  groupValue: _selectedReason,
                  onChanged: (value) {
                    setState(() => _selectedReason = value);
                  },
                  contentPadding: EdgeInsets.zero,
                  tileColor: Colors.grey[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 32),
            // Additional Details
            const Text(
              'Additional details (optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1D2B),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _detailsController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Please provide any additional information...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Warning
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFA940).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFFA940).withOpacity(0.3),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.warning_amber,
                    color: Color(0xFFFFA940),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your report will be reviewed by our safety team. False reports may result in account suspension.',
                      style: TextStyle(
                        color: Color(0xFFFFA940),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Submit Button - FIXED HERE
            CustomButton(
              text: 'Submit Report',
              isLoading: _isSubmitting,
              backgroundColor: const Color(0xFFFF647C),
              onPressed: _selectedReason == null
                  ? null
                  : () => _submitReport(), // Fixed: Wrap in anonymous function
            ),
            const SizedBox(height: 16),
            // Cancel Button
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF6E7A8A),
                side: const BorderSide(color: Color(0xFFE0E0E0)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              child: const SizedBox(
                width: double.infinity,
                child: Center(
                  child: Text('Cancel'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReport() async {
    if (_selectedReason == null) return;

    setState(() => _isSubmitting = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isSubmitting = false);

    if (context.mounted) {
      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Report Submitted'),
          content: const Text(
            'Thank you for your report. Our safety team will review it within 24 hours.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close report screen
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}