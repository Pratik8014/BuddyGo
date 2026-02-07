import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:buddygoapp/core/widgets/custom_button.dart';
import 'package:buddygoapp/core/widgets/custom_textfield.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _destinationController = TextEditingController();
  final _budgetController = TextEditingController();
  final _maxMembersController = TextEditingController(text: '4');

  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedImagePath;
  String _groupType = 'public';
  final List<String> _selectedTags = [];

  final List<String> _availableTags = [
    'Adventure',
    'Beach',
    'Mountains',
    'City',
    'Cultural',
    'Budget',
    'Luxury',
    'Solo',
    'Party',
    'Family',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Trip'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _saveAsDraft,
            child: const Text(
              'Save Draft',
              style: TextStyle(color: Color(0xFF7B61FF)),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Trip Image
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                    image: _selectedImagePath != null
                        ? DecorationImage(
                      image: FileImage(_selectedImagePath as dynamic),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: _selectedImagePath == null
                      ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add Trip Cover Photo',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                      : null,
                ),
              ),
              const SizedBox(height: 24),
              // Trip Title
              CustomTextField(
                controller: _titleController,
                label: 'Trip Title',
                hintText: 'e.g., Goa Beach Adventure',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter trip title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Destination
              CustomTextField(
                controller: _destinationController,
                label: 'Destination',
                hintText: 'e.g., Goa, India',
                prefixIcon: const Icon(Icons.location_on_outlined),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter destination';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Dates
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Start Date',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6E7A8A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _selectStartDate(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 18,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey[300]!,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 20,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _startDate != null
                                      ? DateFormat('MMM dd, yyyy')
                                      .format(_startDate!)
                                      : 'Select date',
                                  style: TextStyle(
                                    color: _startDate != null
                                        ? const Color(0xFF1A1D2B)
                                        : const Color(0xFFA0A8B8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'End Date',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6E7A8A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _selectEndDate(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 18,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey[300]!,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 20,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _endDate != null
                                      ? DateFormat('MMM dd, yyyy')
                                      .format(_endDate!)
                                      : 'Select date',
                                  style: TextStyle(
                                    color: _endDate != null
                                        ? const Color(0xFF1A1D2B)
                                        : const Color(0xFFA0A8B8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Budget & Members
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _budgetController,
                      label: 'Budget (₹)',
                      hintText: '15000',
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.attach_money_outlined),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _maxMembersController,
                      label: 'Max Members',
                      hintText: '4',
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.people_outline),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Description
              CustomTextField(
                controller: _descriptionController,
                label: 'Description',
                hintText: 'Describe your trip...',
                maxLines: 4,
              ),
              const SizedBox(height: 24),
              // Tags
              const Text(
                'Add Tags',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1D2B),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableTags.map((tag) {
                  final isSelected = _selectedTags.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedTags.add(tag);
                        } else {
                          _selectedTags.remove(tag);
                        }
                      });
                    },
                    selectedColor: const Color(0xFF7B61FF),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF6E7A8A),
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              // Group Type
              const Text(
                'Visibility',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1D2B),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile(
                      title: const Text('Public'),
                      subtitle: const Text('Anyone can join'),
                      value: 'public',
                      groupValue: _groupType,
                      onChanged: (value) {
                        setState(() => _groupType = value!);
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile(
                      title: const Text('Private'),
                      subtitle: const Text('Invite only'),
                      value: 'private',
                      groupValue: _groupType,
                      onChanged: (value) {
                        setState(() => _groupType = value!);
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Create Button
              CustomButton(
                text: 'Create Trip',
                onPressed: _createTrip,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImagePath = image.path;
      });
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final firstDate = _startDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: firstDate.add(const Duration(days: 1)),
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 400)),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  void _saveAsDraft() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Trip saved as draft'),
      ),
    );
  }

  void _createTrip() {
    if (_formKey.currentState!.validate() &&
        _startDate != null &&
        _endDate != null) {
      // Create trip logic here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Trip created successfully!'),
          backgroundColor: Color(0xFF00D4AA),
        ),
      );
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Color(0xFFFF647C),
        ),
      );
    }
  }
}