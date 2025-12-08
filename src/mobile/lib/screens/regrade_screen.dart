import 'package:flutter/material.dart';
import '../utils/app_localizations.dart';

class RegradeScreen extends StatelessWidget {
  const RegradeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    final rows = [
      ['IT005', 'IT005.Q11', '6', ''],
      ['IT004', 'IT004.Q12', '8', ''],
      ['IT007', 'IT007.Q15', '3', ''],
      ['SS006', 'SS006.Q111', '4.5', ''],
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.t('regrade_title')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              loc.t('regrade_time_over'),
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            // Make table horizontally scrollable to avoid overflow on small screens
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
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
            const SizedBox(height: 20),
            // Disabled button (user should see it's not clickable)
            ElevatedButton(
              onPressed: null, // intentionally disabled
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(loc.t('regrade_button')),
            ),
          ],
        ),
      ),
    );
  }
}

