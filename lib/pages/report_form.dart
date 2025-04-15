import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:manage_organization/models/report_model.dart';
import 'package:manage_organization/services/api_service.dart';

class PersonFormPage extends StatefulWidget {
  final Person? person;

  const PersonFormPage({Key? key, this.person}) : super(key: key);

  @override
  _PersonFormPageState createState() => _PersonFormPageState();
}

class _PersonFormPageState extends State<PersonFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _personService = PersonService();
  bool _isLoading = false;
  File? _imageFile;
  bool _isImageChanged = false;

  // Form controllers
  final _nimController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Dropdown values
  int? _selectedRating;
  String? _selectedDivision;
  String? _selectedPriority;

  final List<String> _divisions = ['Billing', 'Tech', 'OPS', 'Sales'];
  final List<String> _priorities = ['Critical', 'High', 'Medium', 'Low'];

  @override
  void initState() {
    super.initState();
    if (widget.person != null) {
      _nimController.text = widget.person!.nim;
      _titleController.text = widget.person!.titleIssues;
      _descriptionController.text = widget.person!.descriptionIssues;
      _selectedRating = widget.person!.rating;
      _selectedDivision = _divisionFromId(widget.person!.idDivisionTarget);
      _selectedPriority = _priorityFromId(widget.person!.idPriority);
    }
  }

  @override
  void dispose() {
    _nimController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Mapping from ID to name and vice versa
  String _divisionFromId(int id) => _divisions[id - 1];
  int _divisionToId(String? name) => _divisions.indexOf(name!) + 1;

  String _priorityFromId(int id) => _priorities[id - 1];
  int _priorityToId(String? name) => _priorities.indexOf(name!) + 1;

  // Image Picker
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _isImageChanged = true;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() ||
        _selectedRating == null ||
        _selectedDivision == null ||
        _selectedPriority == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Semua field wajib diisi')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final idDivisionTarget = _divisionToId(_selectedDivision);
      final idPriority = _priorityToId(_selectedPriority);

      if (widget.person == null) {
        await _personService.createPersonWithImage(
          nim: _nimController.text,
          titleIssues: _titleController.text,
          descriptionIssues: _descriptionController.text,
          rating: _selectedRating!,
          imageFile: _imageFile,
          idDivisionTarget: idDivisionTarget,
          idPriority: idPriority,
        );
      } else {
        await _personService.updatePersonWithImage(
          idCustomerService: widget.person!.idCustomerService,
          nim: _nimController.text,
          titleIssues: _titleController.text,
          descriptionIssues: _descriptionController.text,
          rating: _selectedRating!,
          imageFile: _isImageChanged ? _imageFile : null,
          idDivisionTarget: idDivisionTarget,
          idPriority: idPriority,
          currentImageUrl: widget.person?.imageUrl,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.person == null
                ? 'Data berhasil ditambahkan'
                : 'Data berhasil diperbarui',
          ),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String emptyError,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      validator:
          (value) => (value == null || value.isEmpty) ? emptyError : null,
    );
  }

  Widget _buildImageSection() {
    final hasNetworkImage = widget.person?.imageUrl.isNotEmpty == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload Gambar:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.image),
              label: const Text('Galeri'),
              onPressed: () => _pickImage(ImageSource.gallery),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.camera),
              label: const Text('Kamera'),
              onPressed: () => _pickImage(ImageSource.camera),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_imageFile != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              _imageFile!,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          )
        else if (hasNetworkImage)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              widget.person!.imageUrl,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) => const Icon(Icons.broken_image, size: 150),
            ),
          ),
      ],
    );
  }

  Widget _buildStarRating() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Rating:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: List.generate(5, (index) {
            final ratingValue = index + 1;
            return IconButton(
              onPressed: () {
                setState(() {
                  _selectedRating = ratingValue;
                });
              },
              icon: Icon(
                Icons.star,
                color:
                    ratingValue <= (_selectedRating ?? 0)
                        ? Colors.amber
                        : Colors.grey,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildDropdownField(
    String label,
    List<String> items,
    String? value,
    void Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      items:
          items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (val) => val == null ? 'Wajib dipilih' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.person == null ? 'Tambah Data' : 'Edit Data'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                controller: _nimController,
                label: 'NIM',
                emptyError: 'NIM tidak boleh kosong',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _titleController,
                label: 'Judul Issue',
                emptyError: 'Judul tidak boleh kosong',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator:
                    (value) =>
                        (value == null || value.isEmpty)
                            ? 'Deskripsi tidak boleh kosong'
                            : null,
              ),
              const SizedBox(height: 16),
              _buildStarRating(),
              const SizedBox(height: 16),
              _buildImageSection(),
              const SizedBox(height: 16),
              _buildDropdownField(
                'Divisi Tujuan',
                _divisions,
                _selectedDivision,
                (val) {
                  setState(() => _selectedDivision = val);
                },
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                'Prioritas Isu',
                _priorities,
                _selectedPriority,
                (val) {
                  setState(() => _selectedPriority = val);
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                            widget.person == null ? 'Simpan' : 'Perbarui',
                            style: const TextStyle(fontSize: 16),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
