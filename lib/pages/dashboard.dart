// import 'package:flutter/material.dart';
// import 'package:charts_flutter/flutter.dart' as charts;
// import 'report_list.dart';

// class DashboardScreen extends StatefulWidget {
//   final ApiService apiService;
  
//   const DashboardScreen({Key? key, required this.apiService}) : super(key: key);

//   @override
//   _DashboardScreenState createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   late Future<Welcome> futureReports;
  
//   @override
//   void initState() {
//     super.initState();
//     futureReports = widget.apiService.getReports();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Customer Service Dashboard'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: () {
//               setState(() {
//                 futureReports = widget.apiService.getReports();
//               });
//             },
//           ),
//         ],
//       ),
//       body: FutureBuilder<Welcome>(
//         future: futureReports,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (!snapshot.hasData || snapshot.data!.datas.isEmpty) {
//             return const Center(child: Text('No reports available'));
//           }

//           final reports = snapshot.data!.datas;
          
//           // Calculate statistics
//           final totalReports = reports.length;
//           final Map<String, int> reportsByDivision = {};
//           final Map<String, int> reportsByPriority = {};
          
//           for (var report in reports) {
//             reportsByDivision[report.divisionDepartmentName] = 
//                 (reportsByDivision[report.divisionDepartmentName] ?? 0) + 1;
                
//             reportsByPriority[report.priorityName] = 
//                 (reportsByPriority[report.priorityName] ?? 0) + 1;
//           }

//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Card(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Overview',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         Text('Total Reports: $totalReports'),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
                
//                 // Division Chart
//                 Card(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Reports by Division',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         SizedBox(
//                           height: 200,
//                           child: _buildDivisionChart(reportsByDivision),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
                
//                 // Priority Chart
//                 Card(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Reports by Priority',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         SizedBox(
//                           height: 200,
//                           child: _buildPriorityChart(reportsByPriority),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
                
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     minimumSize: const Size.fromHeight(50),
//                   ),
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => ReportListScreen(
//                           apiService: widget.apiService,
//                         ),
//                       ),
//                     );
//                   },
//                   child: const Text('View All Reports'),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => ReportFormScreen(
//                 apiService: widget.apiService,
//               ),
//             ),
//           ).then((_) {
//             // Refresh data when returning from form
//             setState(() {
//               futureReports = widget.apiService.getReports();
//             });
//           });
//         },
//         child: const Icon(Icons.add),
//       ),
//     );
//   }

//   Widget _buildDivisionChart(Map<String, int> data) {
//     final seriesList = [
//       charts.Series<MapEntry<String, int>, String>(
//         id: 'Divisions',
//         domainFn: (MapEntry<String, int> entry, _) => entry.key,
//         measureFn: (MapEntry<String, int> entry, _) => entry.value,
//         colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
//         data: data.entries.toList(),
//       )
//     ];

//     return charts.BarChart(
//       seriesList,
//       animate: true,
//       vertical: false,
//     );
//   }

//   Widget _buildPriorityChart(Map<String, int> data) {
//     final seriesList = [
//       charts.Series<MapEntry<String, int>, String>(
//         id: 'Priorities',
//         domainFn: (MapEntry<String, int> entry, _) => entry.key,
//         measureFn: (MapEntry<String, int> entry, _) => entry.value,
//         colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
//         data: data.entries.toList(),
//       )
//     ];

//     return charts.BarChart(
//       seriesList,
//       animate: true,
//       vertical: false,
//     );
//   }
// }