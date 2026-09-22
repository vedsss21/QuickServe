import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quickserve/models/service_item.dart';
import 'package:quickserve/models/service_request.dart';
import 'package:quickserve/providers/app_state.dart';

class CreateRequestScreen extends StatefulWidget {
  final ServiceItem? preselectedService;

  const CreateRequestScreen({super.key, this.preselectedService});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  ServiceItem? _selectedService;
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _addressController = TextEditingController(text: '742 Evergreen Terrace, Sector 4, Nagpur');
  RequestPriority _priority = RequestPriority.medium;
  DateTime _preferredDateTime = DateTime.now().add(const Duration(days: 1, hours: 2));

  @override
  void initState() {
    super.initState();
    _selectedService = widget.preselectedService;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _preferredDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_preferredDateTime),
    );
    if (pickedTime == null || !mounted) return;

    setState(() {
      _preferredDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final services = appState.services;

    if (_selectedService == null && services.isNotEmpty) {
      _selectedService = services.first;
    }

    final dateFormat = DateFormat('EEE, MMM dd, yyyy • hh:mm a');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Book a Service Request'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notice banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFC7D2FE)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFF4F46E5), size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'A unique tracking ID (e.g. REQ-2026-00XXXX) will be assigned automatically upon submission.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF3730A3), height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Service type dropdown
              const Text('Service Category', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<ServiceItem>(
                    isExpanded: true,
                    value: _selectedService,
                    items: services.map((s) {
                      return DropdownMenuItem<ServiceItem>(
                        value: s,
                        child: Text('${s.name} (\$${s.basePrice.toStringAsFixed(0)})'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedService = val;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Title
              const Text('Issue Summary / Title', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Living room AC not cooling properly',
                ),
              ),
              const SizedBox(height: 18),

              // Description
              const Text('Detailed Description of the Problem', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Describe symptoms, unusual sounds, leaks, or breaker trips in detail...',
                ),
              ),
              const SizedBox(height: 18),

              // Priority Selection
              const Text('Priority Level', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildPriorityOption(RequestPriority.low, 'Low', Colors.blue.shade600),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildPriorityOption(RequestPriority.medium, 'Medium', Colors.amber.shade700),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildPriorityOption(RequestPriority.high, 'High', Colors.red.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Preferred Date & Time
              const Text('Preferred Appointment Window', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 6),
              InkWell(
                onTap: _pickDateTime,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 18, color: Color(0xFF4F46E5)),
                          const SizedBox(width: 10),
                          Text(
                            dateFormat.format(_preferredDateTime),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const Icon(Icons.edit, size: 16, color: Color(0xFF64748B)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Service Address
              const Text('Service Address', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: _addressController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Apartment, Street, Landmark, City & Pincode',
                  prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                ),
              ),
              const SizedBox(height: 28),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: appState.isLoading
                      ? null
                      : () async {
                          if (_selectedService == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please choose a service category')),
                            );
                            return;
                          }
                          final title = _titleController.text.trim();
                          final desc = _descController.text.trim();
                          final addr = _addressController.text.trim();

                          if (title.length < 4 || desc.length < 10 || addr.length < 5) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please fill all fields (title min 4 chars, description min 10 chars)'),
                              ),
                            );
                            return;
                          }

                          final created = await appState.createRequest(
                            serviceId: _selectedService!.id,
                            serviceName: _selectedService!.name,
                            title: title,
                            description: desc,
                            priority: _priority,
                            preferredDateTime: _preferredDateTime,
                            serviceAddress: addr,
                          );

                          if (created != null && mounted) {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Row(
                                  children: [
                                    Icon(Icons.check_circle, color: Color(0xFF10B981)),
                                    SizedBox(width: 8),
                                    Text('Request Created!'),
                                  ],
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Your service request has been registered in the system.'),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Tracking Number:', style: TextStyle(fontSize: 12)),
                                          Text(
                                            created.requestNumber,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF4F46E5),
                                              fontFamily: 'monospace',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      Navigator.pop(context);
                                    },
                                    child: const Text('View My Requests'),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                  child: appState.isLoading
                      ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      : const Text('Submit Service Request'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityOption(RequestPriority p, String label, Color color) {
    final isSelected = _priority == p;
    return InkWell(
      onTap: () => setState(() => _priority = p),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.12) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFCBD5E1),
            width: isSelected ? 2 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? color : const Color(0xFF64748B),
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
