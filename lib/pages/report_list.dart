import 'package:flutter/material.dart';
import 'package:manage_organization/models/report_model.dart';
import 'package:manage_organization/services/api_service.dart';
import 'package:manage_organization/pages/report_form.dart';

class ListPerson extends StatefulWidget {
  const ListPerson({Key? key}) : super(key: key);

  @override
  State<ListPerson> createState() => _ListPersonState();
}

class _ListPersonState extends State<ListPerson> {
  final PersonService _personService = PersonService();
  late Future<List<Person>> _futurePersons;
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _futurePersons = _personService.fetchPersons();
    });
  }

  Future<void> _confirmDelete(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Konfirmasi Hapus'),
            content: const Text('Apakah Anda yakin ingin menghapus data ini?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Hapus'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        final success = await _personService.deletePerson(id);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data berhasil dihapus'),
              backgroundColor: Colors.green,
            ),
          );
          _refreshData();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToForm(BuildContext context, {Person? person}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PersonFormPage(person: person)),
    );

    if (result == true) {
      _refreshData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Aduan'),
        backgroundColor: isDark ? Colors.black : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshData),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(context),
        backgroundColor: isDark ? Colors.white : Colors.black,
        child: Icon(Icons.add, color: isDark ? Colors.black : Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Cari...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : FutureBuilder<List<Person>>(
                      future: _futurePersons,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Gagal memuat data: ${snapshot.error}'),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(child: Text('Tidak ada data'));
                        }

                        final persons =
                            snapshot.data!
                                .where(
                                  (p) =>
                                      p.titleIssues.toLowerCase().contains(
                                        _searchQuery,
                                      ) ||
                                      p.descriptionIssues
                                          .toLowerCase()
                                          .contains(_searchQuery) ||
                                      p.nim.toLowerCase().contains(
                                        _searchQuery,
                                      ),
                                )
                                .toList();

                        return ListView.builder(
                          itemCount: persons.length,
                          itemBuilder: (context, index) {
                            final person = persons[index];
                            return InkWell(
                              onTap:
                                  () =>
                                      _navigateToForm(context, person: person),
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color:
                                      isDark
                                          ? Colors.grey[900]
                                          : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          isDark
                                              ? Colors.black26
                                              : Colors.grey.shade300,
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 28,
                                      backgroundImage:
                                          person.imageUrl.isNotEmpty
                                              ? NetworkImage(person.imageUrl)
                                              : null,
                                      backgroundColor: Colors.grey.shade300,
                                      child:
                                          person.imageUrl.isEmpty
                                              ? const Icon(
                                                Icons.person,
                                                size: 30,
                                              )
                                              : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            person.titleIssues,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color:
                                                  isDark
                                                      ? Colors.white
                                                      : Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            person.descriptionIssues,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color:
                                                  isDark
                                                      ? Colors.grey[300]
                                                      : Colors.grey[700],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Text(
                                                "⭐",
                                                style: TextStyle(fontSize: 14),
                                              ),
                                              const SizedBox(width: 4),
                                              Text('${person.rating}'),
                                              const SizedBox(width: 10),
                                              Text(
                                                person.divisionDepartmentName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.blue,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            'NIM: ${person.nim}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color:
                                                  isDark
                                                      ? Colors.grey[400]
                                                      : Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                      ),
                                      onPressed:
                                          () => _confirmDelete(
                                            person.idCustomerService,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
