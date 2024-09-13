import 'package:flutter/material.dart';

class InformationRenevTab extends StatelessWidget {
  const InformationRenevTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard('Status', 'Active', Icons.info, Colors.green),
            const SizedBox(height: 16),
            _buildInfoCard('Created', '12 Jan 2023', Icons.calendar_today, Colors.blue),
            _buildInfoCard('Last Update', '15 Feb 2023', Icons.update, Colors.orange),
            _buildInfoCard('Last Print', '16 Feb 2023', Icons.print, Colors.purple),
            const SizedBox(height: 16),
            _buildInfoCard('QS Survey', '20 Feb 2023', Icons.assignment, Colors.red),
            _buildInfoCard('CN Submit', '22 Feb 2023', Icons.send, Colors.teal),
            _buildInfoCard('Last CN Print', '23 Feb 2023', Icons.print, Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
