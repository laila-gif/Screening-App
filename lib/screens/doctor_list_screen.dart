import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/doctor_model.dart';
import '../services/doctor_service.dart';
import '../services/language_service.dart';
import '../widgets/doctor_card.dart';
import 'doctor_profile_screen.dart';

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({Key? key}) : super(key: key);

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  final DoctorService _doctorService = DoctorService();
  final TextEditingController _searchController = TextEditingController();

  List<Doctor> _allDoctors = [];
  List<Doctor> _filteredDoctors = [];
  String _selectedSpecialization = 'Semua';
  bool _isLoading = true;
  bool _showOnlyAvailable = false;

  final List<String> _specializations = [
    'Semua',
    'Psikiater',
    'Psikolog Klinis',
  ];

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDoctors() async {
    setState(() => _isLoading = true);

    try {
      final doctors = await _doctorService.loadDoctors();
      setState(() {
        _allDoctors = doctors;
        _filteredDoctors = doctors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _filterDoctors() {
    List<Doctor> filtered = _allDoctors;

    // Filter by specialization
    if (_selectedSpecialization != 'Semua') {
      filtered = filtered
          .where((d) => d.specialization == _selectedSpecialization)
          .toList();
    }

    // Filter by availability
    if (_showOnlyAvailable) {
      filtered = filtered.where((d) => d.isAvailable).toList();
    }

    // Filter by search query
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered.where((doctor) {
        return doctor.name.toLowerCase().contains(query) ||
            doctor.specialization.toLowerCase().contains(query) ||
            doctor.expertise.any((e) => e.toLowerCase().contains(query));
      }).toList();
    }

    setState(() {
      _filteredDoctors = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, ls, child) {
        final code = ls.currentLanguageCode == 'system'
            ? ls.currentLocale.languageCode
            : ls.currentLanguageCode;

        final title = code.startsWith('en')
            ? 'Doctor List'
            : code.startsWith('zh')
            ? '医生列表'
            : code.startsWith('ar')
            ? 'قائمة الأطباء'
            : 'Daftar Dokter';

        final hintSearch = code.startsWith('en')
            ? 'Search doctors or specialization...'
            : code.startsWith('zh')
            ? '搜索医生或专业...'
            : code.startsWith('ar')
            ? 'ابحث عن طبيب أو تخصص...'
            : 'Cari dokter atau spesialisasi...';

        final tooltipAvailable = code.startsWith('en')
            ? 'Show only available'
            : code.startsWith('zh')
            ? '只显示可用'
            : code.startsWith('ar')
            ? 'عرض المتاحين فقط'
            : 'Tampilkan yang tersedia';

        final noResults = code.startsWith('en')
            ? 'No doctors found'
            : code.startsWith('zh')
            ? '未找到医生'
            : code.startsWith('ar')
            ? 'لم يتم العثور على أطباء'
            : 'Tidak ada dokter ditemukan';

        final resetLabel = code.startsWith('en')
            ? 'Reset Filter'
            : code.startsWith('zh')
            ? '重置筛选'
            : code.startsWith('ar')
            ? 'إعادة ضبط الفلتر'
            : 'Reset Filter';

        String displaySpec(String spec) {
          if (spec == 'Semua') {
            return code.startsWith('en')
                ? 'All'
                : code.startsWith('zh')
                ? '全部'
                : code.startsWith('ar')
                ? 'الكل'
                : 'Semua';
          } else if (spec == 'Psikiater') {
            return code.startsWith('en')
                ? 'Psychiatrist'
                : code.startsWith('zh')
                ? '精神科医生'
                : code.startsWith('ar')
                ? 'طبيب نفسي'
                : 'Psikiater';
          } else if (spec == 'Psikolog Klinis') {
            return code.startsWith('en')
                ? 'Clinical Psychologist'
                : code.startsWith('zh')
                ? '临床心理学家'
                : code.startsWith('ar')
                ? 'أخصائي علم النفس الإكلينيكي'
                : 'Psikolog Klinis';
          }
          return spec;
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF5EFD0),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF5EFD0),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _showOnlyAvailable ? Icons.toggle_on : Icons.toggle_off,
                  color: _showOnlyAvailable
                      ? const Color(0xFF6B9080)
                      : Colors.black54,
                  size: 32,
                ),
                onPressed: () {
                  setState(() {
                    _showOnlyAvailable = !_showOnlyAvailable;
                  });
                  _filterDoctors();
                },
                tooltip: tooltipAvailable,
              ),
            ],
          ),
          body: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => _filterDoctors(),
                    decoration: InputDecoration(
                      hintText: hintSearch,
                      hintStyle: const TextStyle(color: Colors.black45),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.black54,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: Colors.black54,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _filterDoctors();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
              ),

              // Filter Chips
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _specializations.length,
                  itemBuilder: (context, index) {
                    final spec = _specializations[index];
                    final isSelected = _selectedSpecialization == spec;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(displaySpec(spec)),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedSpecialization = spec;
                          });
                          _filterDoctors();
                        },
                        backgroundColor: Colors.white,
                        selectedColor: const Color(0xFF6B9080),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                        checkmarkColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),

              // Doctors List
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF6B9080),
                        ),
                      )
                    : _filteredDoctors.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 80,
                              color: Colors.black.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              noResults,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _selectedSpecialization = 'Semua';
                                  _showOnlyAvailable = false;
                                  _searchController.clear();
                                });
                                _filterDoctors();
                              },
                              child: Text(resetLabel),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadDoctors,
                        color: const Color(0xFF6B9080),
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: _filteredDoctors.length,
                          itemBuilder: (context, index) {
                            final doctor = _filteredDoctors[index];
                            return DoctorCard(
                              doctor: doctor,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DoctorProfileScreen(doctor: doctor),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
