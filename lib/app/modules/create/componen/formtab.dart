import 'package:flutter/material.dart';

class FormTab extends StatefulWidget {
  const FormTab({Key? key}) : super(key: key);

  @override
  _FormTabState createState() => _FormTabState();
}

class _FormTabState extends State<FormTab> {
  final TextEditingController _nomorReferensiController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ktpController = TextEditingController();
  final TextEditingController _nomorTeleponController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _kodePosController = TextEditingController();
  final TextEditingController _tanggalAwalController = TextEditingController();
  final TextEditingController _noPolisiController = TextEditingController();
  final TextEditingController _noMesinController = TextEditingController();
  final TextEditingController _noRangkaController = TextEditingController();
  String? _kategoriValue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20), // Kurangi padding vertikal dan tambahkan padding horizontal
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Submit', style: TextStyle(fontSize: 16, color: Colors.white)), // Kurangi ukuran font
        ),

      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Data Diri'),
            _buildTextField('Nomor Referensi', Icons.numbers, _nomorReferensiController),
            _buildTextField('Nama', Icons.person, _namaController),
            _buildTextField('Alamat', Icons.location_on, _alamatController),
            _buildDateField(context, 'Birthdate', Icons.calendar_today, _birthdateController),
            _buildTextField('Email', Icons.email, _emailController),
            _buildTextField('KTP', Icons.credit_card, _ktpController),
            _buildTextField('Nomor Telepon', Icons.phone, _nomorTeleponController),
            _buildTextField('Phone', Icons.phone_android, _phoneController),
            _buildTextField('Kode Pos', Icons.location_pin, _kodePosController),
            const SizedBox(height: 20),
            _buildSectionTitle('Data Kendaraan'),
            _buildDateField(context, 'Tanggal Awal', Icons.calendar_today, _tanggalAwalController),
            _buildTextField('No Polisi', Icons.car_rental, _noPolisiController),
            _buildTextField('No Mesin', Icons.engineering, _noMesinController),
            _buildTextField('No Rangka', Icons.confirmation_number, _noRangkaController),
            _buildDropdownField('Kategori', Icons.category),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, top: 24.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.orange),
            labelText: label,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(BuildContext context, String label, IconData icon, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.orange),
            labelText: label,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
          ),
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
            );

            if (pickedDate != null) {
              controller.text = pickedDate.toLocal().toString().split(' ')[0];
            }
          },
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.orange),
            labelText: label,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
          ),
          items: const [
            DropdownMenuItem(value: 'Kategori 1', child: Text('Kategori 1')),
            DropdownMenuItem(value: 'Kategori 2', child: Text('Kategori 2')),
            DropdownMenuItem(value: 'Kategori 3', child: Text('Kategori 3')),
          ],
          onChanged: (value) {
            setState(() {
              _kategoriValue = value;
            });
          },
        ),
      ),
    );
  }

  void _submitForm() {
    // Validasi semua field wajib
    if (_nomorReferensiController.text.isEmpty ||
        _namaController.text.isEmpty ||
        _alamatController.text.isEmpty ||
        _birthdateController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _ktpController.text.isEmpty ||
        _nomorTeleponController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _kodePosController.text.isEmpty ||
        _tanggalAwalController.text.isEmpty ||
        _noPolisiController.text.isEmpty ||
        _noMesinController.text.isEmpty ||
        _noRangkaController.text.isEmpty ||
        _kategoriValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all mandatory fields!'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form submitted successfully!')),
      );
    }
  }
}
