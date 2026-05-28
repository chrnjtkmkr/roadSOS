import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import 'package:lucide_icons/lucide_icons.dart';

class Contact {
  final String id;
  final String name;
  final String relation;
  final String initials;
  final Color color;

  Contact({
    required this.id,
    required this.name,
    required this.relation,
    required this.initials,
    required this.color,
  });
}

class EmergencyNumber {
  final String num;
  final String label;

  EmergencyNumber(this.num, this.label);
}

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final List<EmergencyNumber> _emergencyNumbers = [
    EmergencyNumber("108", "Ambulance"),
    EmergencyNumber("100", "Police"),
    EmergencyNumber("112", "Emergency"),
    EmergencyNumber("101", "Fire"),
  ];

  List<Contact> _contacts = [
    Contact(id: "1", name: "Rahul Sharma", relation: "Husband", initials: "RS", color: AppColors.blue700),
    Contact(id: "2", name: "Anjali Gupta", relation: "Mother", initials: "AG", color: AppColors.indigo500),
    Contact(id: "3", name: "Dr. Mehta", relation: "Family Doctor", initials: "DM", color: AppColors.cyan500),
  ];

  void _handleDelete(String id) {
    setState(() {
      _contacts.removeWhere((c) => c.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top + 32),
                const Text(
                  'Emergency Contacts',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),

                // National Emergency Numbers
                const Text(
                  'NATIONAL EMERGENCY',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.slate400,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.2,
                  ),
                  itemCount: _emergencyNumbers.length,
                  itemBuilder: (context, index) {
                    final em = _emergencyNumbers[index];
                    return _buildEmergencyCard(em);
                  },
                ),
                const SizedBox(height: 32),

                // Personal Contacts
                const Text(
                  'PERSONAL CONTACTS',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.slate400,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.only(bottom: 120), // Padding for FAB + Nav bar
                    itemCount: _contacts.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final contact = _contacts[index];
                      return _buildContactCard(contact);
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // FAB Add Contact
          Positioned(
            bottom: 100, // Above bottom nav
            right: 24,
            child: FloatingActionButton(
              onPressed: () {},
              backgroundColor: AppColors.rose500,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(LucideIcons.plus, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyCard(EmergencyNumber em) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.rose500.withOpacity(0.1),
        border: Border.all(color: AppColors.rose500.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          highlightColor: AppColors.rose500.withOpacity(0.2),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      em.num,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      em.label.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.rose500,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.rose500,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.phone,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard(Contact contact) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: contact.color,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              contact.initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  contact.relation,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Actions
          Row(
            children: [
              IconButton(
                onPressed: () => _handleDelete(contact.id),
                icon: const Icon(LucideIcons.trash2, size: 18),
                color: Colors.white.withOpacity(0.4),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.05),
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(10),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {},
                icon: const Icon(LucideIcons.phone, size: 18),
                color: Colors.white,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.emerald500,
                  shadowColor: AppColors.emerald500.withOpacity(0.4),
                  elevation: 8,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
