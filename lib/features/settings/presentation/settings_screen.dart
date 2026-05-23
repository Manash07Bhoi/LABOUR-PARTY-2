import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hive/hive.dart';
import 'package:labour_party/core/database/hive_setup.dart';
import 'package:labour_party/features/work/data/models/labour_model.dart';
import 'package:labour_party/features/work/data/models/trip_labour_model.dart';
import 'package:labour_party/features/work/data/models/trip_model.dart';
import 'package:labour_party/features/work/data/models/work_model.dart';
import 'package:labour_party/shared/widgets/glass_card.dart';
import 'package:labour_party/theme/app_theme.dart';
import 'package:intl/intl.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

Future<Map<String, dynamic>> _parseAndValidateBackup(String filePath) async {
  final file = File(filePath);

  if (!file.existsSync()) {
    throw Exception("File does not exist.");
  }

  if (!filePath.toLowerCase().endsWith('.labourbackup')) {
    throw Exception("Invalid file extension.");
  }

  final fileSize = await file.length();
  const maxBytes = 25 * 1024 * 1024; // 25 MB
  if (fileSize > maxBytes) {
    throw Exception("BackupTooLarge");
  }

  Map<String, dynamic> backupData;
  try {
    final dynamic decoded = await file
        .openRead()
        .transform(utf8.decoder)
        .transform(json.decoder)
        .first;
    if (decoded is Map<String, dynamic>) {
      backupData = decoded;
    } else {
      throw Exception("Invalid JSON structure.");
    }
  } catch (e) {
    if (e.toString().contains("BackupTooLarge") ||
        e.toString().contains("BackupInvalid") ||
        e.toString().contains("UnsupportedBackupVersion")) {
      rethrow;
    }
    throw Exception("BackupInvalid");
  }

  if (backupData['app'] != "Labour Party") {
    throw Exception("BackupInvalid");
  }

  if (backupData['version'] == null || backupData['data'] == null) {
    throw Exception("UnsupportedBackupVersion");
  }

  final data = backupData['data'];
  if (data is! Map<String, dynamic>) {
    throw Exception("BackupInvalid");
  }

  final worksList = data['works'] as List?;
  final tripsList = data['trips'] as List?;
  final laboursList = data['labours'] as List?;
  final tripLaboursList = data['tripLabours'] as List?;

  if (worksList == null ||
      tripsList == null ||
      laboursList == null ||
      tripLaboursList == null) {
    throw Exception("BackupInvalid");
  }

  if (worksList.length > 10000 ||
      tripsList.length > 100000 ||
      laboursList.length > 5000) {
    throw Exception("BackupInvalid");
  }

  return backupData;
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = false;

  Future<void> _backupDatabase() async {
    setState(() => _isLoading = true);
    try {
      final selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory != null) {
        final workBox = Hive.box<WorkModel>(HiveSetup.workBox);
        final tripBox = Hive.box<TripModel>(HiveSetup.tripBox);
        final labourBox = Hive.box<LabourModel>(HiveSetup.labourBox);
        final tripLabourBox = Hive.box<TripLabourModel>(
          HiveSetup.tripLabourBox,
        );

        final backupData = {
          "version": 1,
          "createdAt": DateTime.now().toIso8601String(),
          "app": "Labour Party",
          "data": {
            "works": workBox.values
                .map(
                  (w) => {
                    "id": w.id,
                    "date": w.date,
                    "session": w.session,
                    "workType": w.workType,
                    "place": w.place,
                    "createdAt": w.createdAt.toIso8601String(),
                    "updatedAt": w.updatedAt.toIso8601String(),
                  },
                )
                .toList(),
            "trips": tripBox.values
                .map(
                  (t) => {
                    "id": t.id,
                    "workId": t.workId,
                    "tripNumber": t.tripNumber,
                    "tractor": t.tractor,
                    "driverName": t.driverName,
                    "createdAt": t.createdAt.toIso8601String(),
                  },
                )
                .toList(),
            "labours": labourBox.values
                .map(
                  (l) => {
                    "id": l.id,
                    "name": l.name,
                    "phoneOptional": l.phoneOptional,
                    "createdAt": l.createdAt.toIso8601String(),
                  },
                )
                .toList(),
            "tripLabours": tripLabourBox.values
                .map(
                  (tl) => {
                    "id": tl.id,
                    "tripId": tl.tripId,
                    "labourId": tl.labourId,
                    "isPresent": tl.isPresent,
                  },
                )
                .toList(),
          },
        };

        final jsonString = jsonEncode(backupData);
        final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
        final destFile = File(
          '$selectedDirectory/labour_backup_$timestamp.labourbackup',
        );
        await destFile.writeAsString(jsonString);

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Backup successful!')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Backup failed: $e')));
      }
    }
    setState(() => _isLoading = false);
  }

  void _showErrorDialog(String title, String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkSurfaceColor,
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'OK',
              style: TextStyle(color: AppTheme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _restoreDatabase() async {
    setState(() => _isLoading = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['labourbackup'],
      );

      if (result != null && result.files.single.path != null) {
        final backupPath = result.files.single.path!;

        Map<String, dynamic> backupData;
        try {
          backupData = await compute(_parseAndValidateBackup, backupPath);
        } catch (e) {
          setState(() => _isLoading = false);
          final errorStr = e.toString();
          if (errorStr.contains("BackupTooLarge")) {
            _showErrorDialog(
              "Backup Too Large",
              "Selected backup exceeds the supported size limit.\n\nMaximum: 25 MB\n\nChoose another backup file.",
            );
          } else if (errorStr.contains("UnsupportedBackupVersion")) {
            _showErrorDialog(
              "Unsupported Backup Version",
              "The selected backup file version is not supported.",
            );
          } else {
            _showErrorDialog(
              "Backup Invalid",
              "The selected backup file is corrupted or invalid.",
            );
          }
          return;
        }

        final data = backupData['data'] as Map<String, dynamic>;
        final worksList = data['works'] as List;
        final tripsList = data['trips'] as List;
        final laboursList = data['labours'] as List;
        final tripLaboursList = data['tripLabours'] as List;

        if (mounted) {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: AppTheme.darkSurfaceColor,
              title: const Text(
                'Restore Backup',
                style: TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Backup Date: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(backupData['createdAt']))}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Works: ${worksList.length}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    'Trips: ${tripsList.length}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    'Labours: ${laboursList.length}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'This will OVERWRITE all current data. Are you sure?',
                    style: TextStyle(
                      color: AppTheme.errorColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text(
                    'Restore',
                    style: TextStyle(color: AppTheme.errorColor),
                  ),
                ),
              ],
            ),
          );

          if (confirm == true) {
            final workBox = Hive.box<WorkModel>(HiveSetup.workBox);
            final tripBox = Hive.box<TripModel>(HiveSetup.tripBox);
            final labourBox = Hive.box<LabourModel>(HiveSetup.labourBox);
            final tripLabourBox = Hive.box<TripLabourModel>(
              HiveSetup.tripLabourBox,
            );

            // 1. Create Recovery Snapshot
            final worksSnapshot = workBox.values.toList();
            final tripsSnapshot = tripBox.values.toList();
            final laboursSnapshot = labourBox.values.toList();
            final tripLaboursSnapshot = tripLabourBox.values.toList();

            try {
              // 2. Clear Boxes
              await workBox.clear();
              await tripBox.clear();
              await labourBox.clear();
              await tripLabourBox.clear();

              // 3. Apply Restore
              for (var w in worksList) {
                await workBox.put(
                  w['id'],
                  WorkModel(
                    id: w['id'],
                    date: w['date'],
                    session: w['session'],
                    workType: w['workType'],
                    place: w['place'] ?? '',
                    createdAt: DateTime.parse(w['createdAt']),
                    updatedAt: DateTime.parse(w['updatedAt']),
                  ),
                );
              }
              for (var t in tripsList) {
                await tripBox.put(
                  t['id'],
                  TripModel(
                    id: t['id'],
                    workId: t['workId'],
                    tripNumber: t['tripNumber'],
                    tractor: t['tractor'],
                    driverName: t['driverName'],
                    createdAt: DateTime.parse(t['createdAt']),
                  ),
                );
              }
              for (var l in laboursList) {
                await labourBox.put(
                  l['id'],
                  LabourModel(
                    id: l['id'],
                    name: l['name'],
                    phoneOptional: l['phoneOptional'],
                    createdAt: DateTime.parse(l['createdAt']),
                  ),
                );
              }
              for (var tl in tripLaboursList) {
                final compositeKey = '${tl['tripId']}_${tl['id']}';
                await tripLabourBox.put(
                  compositeKey,
                  TripLabourModel(
                    id: tl['id'],
                    tripId: tl['tripId'],
                    labourId: tl['labourId'],
                    isPresent: tl['isPresent'],
                  ),
                );
              }

              // 4. Verify Counts
              if (workBox.length != worksList.length ||
                  tripBox.length != tripsList.length ||
                  labourBox.length != laboursList.length ||
                  tripLabourBox.length != tripLaboursList.length) {
                throw Exception(
                  "Restore validation failed. Row count mismatch.",
                );
              }

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Restore successful!')),
                );
              }
            } catch (e) {
              // 5. Rollback on Failure
              await workBox.clear();
              await tripBox.clear();
              await labourBox.clear();
              await tripLabourBox.clear();

              for (var w in worksSnapshot) {
                await workBox.put(w.id, w);
              }
              for (var t in tripsSnapshot) {
                await tripBox.put(t.id, t);
              }
              for (var l in laboursSnapshot) {
                await labourBox.put(l.id, l);
              }
              for (var tl in tripLaboursSnapshot) {
                final compositeKey = '${tl.tripId}_${tl.id}';
                await tripLabourBox.put(compositeKey, tl);
              }

              _showErrorDialog(
                "Restore Failed",
                "An error occurred during restore. All original data has been safely rolled back.\n\nError: $e",
              );
            }
          }
        }
      }
    } catch (e) {
      _showErrorDialog("Restore Failed", "An unexpected error occurred: $e");
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                GlassCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.backup,
                          color: AppTheme.primaryColor,
                        ),
                        title: const Text('Backup Database'),
                        subtitle: const Text(
                          'Save your data to a .labourbackup file',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                        onTap: _backupDatabase,
                      ),
                      const Divider(color: Colors.white24, height: 1),
                      ListTile(
                        leading: const Icon(
                          Icons.restore,
                          color: AppTheme.accentColor,
                        ),
                        title: const Text('Restore Database'),
                        subtitle: const Text(
                          'Restore from a .labourbackup file',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                        onTap: _restoreDatabase,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                GlassCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.color_lens,
                          color: Colors.white70,
                        ),
                        title: const Text('Theme Mode'),
                        trailing: const Text(
                          'Dark',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {},
                      ),
                      const Divider(color: Colors.white24, height: 1),
                      ListTile(
                        leading: const Icon(
                          Icons.info_outline,
                          color: Colors.white70,
                        ),
                        title: const Text('About App'),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                const Center(
                  child: Text(
                    'Labour Party v1.0.0\nFully Offline',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ),
              ],
            ),
    );
  }
}
