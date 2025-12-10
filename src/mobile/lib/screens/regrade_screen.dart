import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/app_localizations.dart';
import '../widgets/animated_background.dart';

class RegradeScreen extends StatelessWidget {
  const RegradeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final rows = [
      ['IT005', 'IT005.Q11', '6', ''],
      ['IT004', 'IT004.Q12', '8', ''],
      ['IT007', 'IT007.Q15', '3', ''],
      ['SS006', 'SS006.Q111', '4.5', ''],
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(loc.t('regrade_title')),
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(child: AnimatedBackground(isDark: isDark)),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Make table horizontally scrollable to avoid overflow on small screens
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color.fromRGBO(30, 41, 59, 0.62) : const Color.fromRGBO(255, 255, 255, 0.92),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? const Color.fromRGBO(255,255,255,0.08) : const Color.fromRGBO(0,0,0,0.08)),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: DataTable(
                        columns: [
                          DataColumn(label: Text(loc.t('regrade_table_col_subject_code'))),
                          DataColumn(label: Text(loc.t('regrade_table_col_class_code'))),
                          DataColumn(label: Text(loc.t('regrade_table_col_score'))),
                          DataColumn(label: Text(loc.t('regrade_table_col_note'))),
                        ],
                        rows: rows
                            .map(
                              (r) => DataRow(cells: [
                                DataCell(Text(r[0])),
                                DataCell(Text(r[1])),
                                DataCell(Text(r[2])),
                                DataCell(Text(r[3])),
                              ]),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Warning message placed between the table and the button
                  Text(
                    loc.t('regrade_time_over'),
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  // Disabled button (user should see it's not clickable)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: null, // intentionally disabled
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(loc.t('regrade_button')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
