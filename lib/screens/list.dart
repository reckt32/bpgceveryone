import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:newproject2/custom_theme.dart';

import 'dart:convert';
import 'package:newproject2/models/student.dart';
import 'package:newproject2/services/getdata.dart';
import 'package:newproject2/services/putdata.dart';

import 'package:newproject2/services/search.dart';
import 'package:newproject2/widgets/tag.dart';
import 'dart:html' as html;

class CardList extends StatefulWidget {
  const CardList({super.key});

  @override
  _CardListState createState() => _CardListState();
}

class _CardListState extends State<CardList> {
  late List<Student> students;
  late List<Student> filteredStudents;
  late TextEditingController searchController;
  Set<int> selectedYearFilters = {};
  Set<String> selectedDegreeFilters = {};
  Set<String> selectedDegreeFilters2 = {};
  Set<String> selectedHostelFilters = {};

  Map codetobranch = {
    "A1": "Chemical",
    "A3": "E.E.E.",
    "A4": "Mechanical",
    "A7": "C.S.E.",
    "A8": "E.N.I.",
    "AA": "E.C.E.",
    "B1": "M.Sc. Bio.",
    "B2": "M.Sc. Chem.",
    "B3": "M.Sc. Eco.",
    "B4": "M.Sc. Math",
    "B5": "M.Sc. Physics",
  };

  @override
  void initState() {
    super.initState();
    students = [];
    fetchData();
    filteredStudents = students;
    searchController = TextEditingController();
  }

  Future<List> fetchData() async {
    var response = await Fetch().fetchStudents();

    var response2 = await Fetch().fetchHostels();

    setState(() {
      final Map<String, dynamic> data = json.decode(response)['data'];
      final Map<String, dynamic> data2 = json.decode(response2);

      data.forEach((campusId, studentData) {
        students.add(Student.fromJson(campusId, studentData));
      });
      for (var student in students) {
        if (data2.containsKey(student.campusId)) {
          student.updateHostelRoom(data2[student.campusId]['hostel'],
              data2[student.campusId]['room'] ?? 'NA');
        } else {
          student.updateHostelRoom('', '');
        }
      }
      filteredStudents = students;
    });

    return filteredStudents;
  }

  void search(String query) {
    setState(() {
      filteredStudents = students
          .where((student) =>
              (selectedYearFilters.isEmpty || selectedYearFilters.contains(int.parse(student.campusId.toString().substring(0, 4)))) &&
              (selectedDegreeFilters.isEmpty && selectedDegreeFilters2.isEmpty ||
                  selectedDegreeFilters2.isEmpty &&
                      selectedDegreeFilters.any((code) => student.campusId
                          .toString()
                          .substring(4, 8)
                          .contains(code)) ||
                  selectedDegreeFilters.isEmpty &&
                      selectedDegreeFilters2.any((code) => student.campusId
                          .toString()
                          .substring(4, 8)
                          .contains(code)) ||
                  selectedDegreeFilters2.any((code) => student.campusId.toString().substring(4, 8).contains(code)) &&
                      selectedDegreeFilters.any((code) => student.campusId
                          .toString()
                          .substring(4, 8)
                          .contains(code))) &&
              (Search().namesearch(query, student) ||
                  student.campusId.toLowerCase().contains(query.toLowerCase())))
          .toList();
    });
  }

  void sortname() {
    setState(() {
      filteredStudents.sort((a, b) => a.name.compareTo(b.name));
    });
  }

  void sorthostel() {
    setState(() {
      filteredStudents.sort((a, b) => a.room!.compareTo(b.room!));
    });
  }

  void clear() {
    setState(() {
      searchController.clear();
      selectedYearFilters.clear();
      selectedDegreeFilters.clear();
      selectedDegreeFilters2.clear();
      selectedHostelFilters.clear();
      filteredStudents = students;
    });
  }

  void clearsearch() {
    setState(() {
      searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double screenWidth = mediaQueryData.size.width;
    double screenHeight = mediaQueryData.size.height;
    var uri = Uri.parse(html.window.location.href);
    var paramValue = uri.queryParameters['id'];
    Student user = students.firstWhere(
        (element) => element.campusId == paramValue,
        orElse: () => Student(campusId: '', name: '', cgpa: 0, show: 'true'));
    print(user.show);
    int totalFilteredStudents = filteredStudents.length;

    return Scaffold(
      backgroundColor: CustomTheme.darkScaffoldColor,
      appBar: AppBar(
        backgroundColor: CustomTheme.darkScaffoldColor,
        title: const Text(
          'BPGC EVERYONE',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
            child: TextField(
              controller: searchController,
              onChanged: search,
              cursorColor: Colors.white,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: const BorderSide(
                    color: Colors.white,
                    width: 3,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: const BorderSide(
                    color: CustomTheme.darkSecondaryColor,
                    width: 3,
                  ),
                ),
                labelText: 'Search',
                labelStyle: const TextStyle(
                  color: Colors.white,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: clearsearch,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.filter_list),
                      color: Colors.white,
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext ctx) => StatefulBuilder(
                                  builder: (context, setState) => AlertDialog(
                                    actionsAlignment: MainAxisAlignment.start,
                                    actionsPadding: const EdgeInsets.all(8.0),
                                    alignment: Alignment.centerLeft,
                                    scrollable: true,
                                    backgroundColor:
                                        CustomTheme.darkPrimaryColorVariant,
                                    title: const Text(
                                      'Filters',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    actions: <Widget>[
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Row(
                                            children: [
                                              SizedBox(
                                                width: 2.0,
                                              ),
                                              Text(
                                                'Year',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20.0,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 2.0,
                                              ),
                                              Expanded(
                                                child: Divider(
                                                  color: Colors.white,
                                                  thickness: 2,
                                                ),
                                                
                                              ),
                                            
                                            ],
                                          ),
                                          Wrap(
                                            spacing: 10.0,
                                            children: List.generate(6, (index) {
                                              final year = [
                                                2023,
                                                2022,
                                                2021,
                                                2020,
                                                2019,
                                                2018,
                                              ][index];
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.all(3.0),
                                                child: FilterChip(
                                                  showCheckmark: false,
                                                  selectedColor: CustomTheme
                                                      .darkSecondaryColor,
                                                  backgroundColor: CustomTheme
                                                      .darkScaffoldColor,
                                                  label: Text(
                                                    '$year',
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  selected: selectedYearFilters
                                                      .contains(year),
                                                  onSelected: (isSelected) {
                                                    setState(() {
                                                      if (isSelected) {
                                                        selectedYearFilters
                                                            .add(year);
                                                      } else {
                                                        selectedYearFilters
                                                            .remove(year);
                                                      }
                                                      applyFilters();
                                                      clearsearch();
                                                    });
                                                  },
                                                ),
                                              );
                                            }),
                                          ),
                                          const SizedBox(height: 10),

                                          const SizedBox(
                                            height: 10,
                                          ),
                                            const Row(
                                            children: [
                                              SizedBox(
                                                width: 2.0,
                                              ),
                                              Text(
                                                'B.E.',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20.0,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 2.0,
                                              ),
                                              Expanded(
                                                child: Divider(
                                                  color: Colors.white,
                                                  thickness: 2,
                                                ),
                                                
                                              ),
                                            
                                            ],
                                          ),
                                          Wrap(
                                            spacing: 10.0,
                                            children: List.generate(6, (index) {
                                              final degreeCodes = [
                                                'A1',
                                                'A3',
                                                'A4',
                                                'A7',
                                                'A8',
                                                'AA'
                                              ];
                                              final degreeCode =
                                                  degreeCodes[index];
                                              return FilterChip(
                                                showCheckmark: false,
                                                selectedColor: CustomTheme
                                                    .darkSecondaryColor,
                                                backgroundColor: CustomTheme
                                                    .darkScaffoldColor,
                                                label: Text(
                                                  codetobranch[degreeCode],
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                                selected: selectedDegreeFilters
                                                    .contains(degreeCode),
                                                onSelected: (isSelected) {
                                                  setState(() {
                                                    if (isSelected) {
                                                      selectedDegreeFilters
                                                          .add(degreeCode);
                                                    } else {
                                                      selectedDegreeFilters
                                                          .remove(degreeCode);
                                                    }
                                                    applyFilters();
                                                    clearsearch();
                                                  });
                                                },
                                              );
                                            }),
                                          ),
                                          const SizedBox(height: 10),
                                            const Row(
                                            children: [
                                              SizedBox(
                                                width: 2.0,
                                              ),
                                              Text(
                                                'M.Sc.',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20.0,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 2.0,
                                              ),
                                              Expanded(
                                                child: Divider(
                                                  color: Colors.white,
                                                  thickness: 2,
                                                ),
                                                
                                              ),
                                            
                                            ],
                                          ),

                                          Wrap(
                                            spacing: 10.0,
                                            children: List.generate(5, (index) {
                                              final degreeCodes = [
                                                'B1',
                                                'B2',
                                                'B3',
                                                'B4',
                                                'B5'
                                              ];
                                              final degreeCode =
                                                  degreeCodes[index];
                                              return FilterChip(
                                                showCheckmark: false,
                                                selectedColor: CustomTheme
                                                    .darkSecondaryColor,
                                                backgroundColor: CustomTheme
                                                    .darkScaffoldColor,
                                                label: Text(
                                                  codetobranch[degreeCode],
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                                selected: selectedDegreeFilters2
                                                    .contains(degreeCode),
                                                onSelected: (isSelected) {
                                                  setState(() {
                                                    if (isSelected) {
                                                      selectedDegreeFilters2
                                                          .add(degreeCode);
                                                    } else {
                                                      selectedDegreeFilters2
                                                          .remove(degreeCode);
                                                    }
                                                    applyFilters();
                                                    clearsearch();
                                                  });
                                                },
                                              );
                                            }),
                                          ),
                                          const SizedBox(height: 10),
                                            const Row(
                                            children: [
                                              SizedBox(
                                                width: 2.0,
                                              ),
                                              Text(
                                                'A-hostels',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20.0,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 2.0,
                                              ),
                                              Expanded(
                                                child: Divider(
                                                  color: Colors.white,
                                                  thickness: 2,
                                                ),
                                                
                                              ),
                                            
                                            ],
                                          ),

                                          // For Hostel Filters
                                          Wrap(
                                            spacing: 10.0,
                                            children: List.generate(9, (index) {
                                              final hostel = [
                                                'AH1',
                                                'AH2',
                                                'AH3',
                                                'AH4',
                                                'AH5',
                                                'AH6',
                                                'AH7',
                                                'AH8',
                                                'AH9'
                                              ][index];
                                              return FilterChip(
                                                showCheckmark: false,
                                                selectedColor: CustomTheme
                                                    .darkSecondaryColor,
                                                backgroundColor: CustomTheme
                                                    .darkScaffoldColor,
                                                label: Text(
                                                  '${hostel}',
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                                selected: selectedHostelFilters
                                                    .contains(hostel),
                                                onSelected: (isSelected) {
                                                  setState(() {
                                                    if (isSelected) {
                                                      selectedHostelFilters
                                                          .add(hostel);
                                                    } else {
                                                      selectedHostelFilters
                                                          .remove(hostel);
                                                    }
                                                    applyFilters();
                                                    clearsearch();
                                                  });
                                                },
                                              );
                                            }),
                                          ),
                                          const SizedBox(height: 10),
  const Row(
                                            children: [
                                              SizedBox(
                                                width: 2.0,
                                              ),
                                              Text(
                                                'C-Hostels',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20.0,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 2.0,
                                              ),
                                              Expanded(
                                                child: Divider(
                                                  color: Colors.white,
                                                  thickness: 2,
                                                ),
                                                
                                              ),
                                            
                                            ],
                                          ),
                                          // For Additional Hostel Filters
                                          Wrap(
                                            spacing: 10.0,
                                            children: List.generate(6, (index) {
                                              final hostel = [
                                                'CH1',
                                                'CH2',
                                                'CH3',
                                                'CH4',
                                                'CH5',
                                                'CH6'
                                              ][index];
                                              return FilterChip(
                                                showCheckmark: false,
                                                selectedColor: CustomTheme
                                                    .darkSecondaryColor,
                                                backgroundColor: CustomTheme
                                                    .darkScaffoldColor,
                                                label: Text(
                                                  '${hostel}',
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                                selected: selectedHostelFilters
                                                    .contains(hostel),
                                                onSelected: (isSelected) {
                                                  setState(() {
                                                    if (isSelected) {
                                                      selectedHostelFilters
                                                          .add(hostel);
                                                    } else {
                                                      selectedHostelFilters
                                                          .remove(hostel);
                                                    }
                                                    applyFilters();
                                                    clearsearch();
                                                  });
                                                },
                                              );
                                            }),
                                          ),
                                          const SizedBox(height: 10),
                                            const Row(
                                            children: [
                                              SizedBox(
                                                width: 2.0,
                                              ),
                                              Text(
                                                'D-Hostels',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20.0,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 2.0,
                                              ),
                                              Expanded(
                                                child: Divider(
                                                  color: Colors.white,
                                                  thickness: 2,
                                                ),
                                                
                                              ),
                                            
                                            ],
                                          ),

                                          // For Dormitory Filters
                                          Wrap(
                                            spacing: 10.0,
                                            children: List.generate(6, (index) {
                                              final hostel = [
                                                'DH1',
                                                'DH2',
                                                'DH3',
                                                'DH4',
                                                'DH5',
                                                'DH6'
                                              ][index];
                                              return FilterChip(
                                                showCheckmark: false,
                                                selectedColor: CustomTheme
                                                    .darkSecondaryColor,
                                                backgroundColor: CustomTheme
                                                    .darkScaffoldColor,
                                                label: Text(
                                                  '$hostel',
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                                selected: selectedHostelFilters
                                                    .contains(hostel),
                                                onSelected: (isSelected) {
                                                  setState(() {
                                                    if (isSelected) {
                                                      selectedHostelFilters
                                                          .add(hostel);
                                                    } else {
                                                      selectedHostelFilters
                                                          .remove(hostel);
                                                    }
                                                    applyFilters();
                                                    clearsearch();
                                                  });
                                                },
                                              );
                                            }),
                                          ),

                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            children: [
                                              ElevatedButton(
                                                onPressed: () => setState(() {
                                                  searchController.clear();
                                                  selectedYearFilters.clear();
                                                  selectedDegreeFilters.clear();
                                                  selectedDegreeFilters2
                                                      .clear();
                                                  selectedYearFilters.clear();
                                                  filteredStudents = students;
                                                }),
                                                child:
                                                    const Text('Clear Filters'),
                                              ),
                                              const SizedBox(
                                                width: 100,
                                              ),
                                              ElevatedButton(
                                                onPressed:
                                                    Navigator.of(context).pop,
                                                child:
                                                    const Text('Apply Filters'),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ));
                      },
                    ),
                  ],
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomTheme.darkPrimaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        Hide().putrequest(paramValue!);
                        Phoenix.rebirth(context);
                      });
                    },
                    child: Text(
                      (user.show == 'true')
                          ? 'Hide your CGPA'
                          : 'Unhide your CGPA',
                      style: const TextStyle(color: Colors.white),
                    )),
                Text(
                  'RESULTS: $totalFilteredStudents',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredStudents.length,
              itemBuilder: (context, index) {
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
                  shape: RoundedRectangleBorder(
                    side:
                        const BorderSide(color: Color(0xFFBDBDBD), width: 0.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: 10,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: CustomTheme.darkScaffoldColor,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: const [
                            BoxShadow(
                              color: CustomTheme.darkSecondaryColor,
                              offset: Offset(2.5, 2.5),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.fromLTRB(20, 0, 0, 0),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${filteredStudents[index].name}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(30, 0, 0, 0),
                                child: Column(
                                  children: [
                                    Container(
                                      height: 58,
                                      width: 58,
                                      decoration: BoxDecoration(
                                        color: CustomTheme.darkScaffoldColor,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(width: 3),
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          border: Border.all(
                                            color:
                                                CustomTheme.darkSecondaryColor,
                                            width: 3, // Border width
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 1,
                                                      vertical: 1),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 0),
                                                decoration: BoxDecoration(
                                                  color: CustomTheme
                                                      .darkSecondaryColor,
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                                child: const Text(
                                                  'CGPA',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            if (filteredStudents[index].show ==
                                                'true')
                                              Text(
                                                '${filteredStudents[index].cgpa}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
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
                          subtitle: Row(
                            children: [
                              Buildtag(text: filteredStudents[index].campusId),
                              Buildtag(
                                  text: codetobranch[filteredStudents[index]
                                      .campusId
                                      .substring(4, 6)]),
                              if (filteredStudents[index]
                                      .campusId
                                      .substring(6, 7) ==
                                  'A')
                                Buildtag(
                                    text: codetobranch[filteredStudents[index]
                                        .campusId
                                        .substring(6, 8)]),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: CustomTheme.darkSecondaryColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${filteredStudents[index].hostel} - ${filteredStudents[index].room}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void applyFilters() {
    setState(() {
      filteredStudents = students
          .where((student) =>
              (selectedYearFilters.isEmpty || selectedYearFilters.contains(int.parse(student.campusId.toString().substring(0, 4)))) &&
              (selectedHostelFilters.isEmpty ||
                  selectedHostelFilters.contains(student.hostel)) &&
              (selectedDegreeFilters.isEmpty && selectedDegreeFilters2.isEmpty ||
                  selectedDegreeFilters2.isEmpty &&
                      selectedDegreeFilters.any((code) => student.campusId
                          .toString()
                          .substring(4, 8)
                          .contains(code)) ||
                  selectedDegreeFilters.isEmpty &&
                      selectedDegreeFilters2.any((code) => student.campusId
                          .toString()
                          .substring(4, 8)
                          .contains(code)) ||
                  selectedDegreeFilters2.any((code) => student.campusId
                          .toString()
                          .substring(4, 8)
                          .contains(code)) &&
                      selectedDegreeFilters
                          .any((code) => student.campusId.toString().substring(4, 8).contains(code))))
          .toList();
    });
  }
}