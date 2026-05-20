import 'dart:io';
import 'dart:convert';

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

  Future<void> _restoreDatabase() async {
    setState(() => _isLoading = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['labourbackup'],
      );

      if (result != null && result.files.single.path != null) {
        final backupFile = File(result.files.single.path!);
        final jsonString = await backupFile.readAsString();

        Map<String, dynamic> backupData;
        try {
          backupData = jsonDecode(jsonString);
        } catch (_) {
          throw Exception("Invalid backup file format.");
        }

        if (backupData['app'] != "Labour Party" ||
            backupData['version'] == null ||
            backupData['data'] == null) {
          throw Exception("Corrupted or incompatible backup file.");
        }

        final data = backupData['data'] as Map<String, dynamic>;
        final worksList = data['works'] as List;
        final tripsList = data['trips'] as List;
        final laboursList = data['labours'] as List;

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

            await workBox.clear();
            await tripBox.clear();
            await labourBox.clear();
            await tripLabourBox.clear();

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
            for (var tl in data['tripLabours']) {
              await tripLabourBox.put(
                tl['id'],
                TripLabourModel(
                  id: tl['id'],
                  tripId: tl['tripId'],
                  labourId: tl['labourId'],
                  isPresent: tl['isPresent'],
                ),
              );
            }

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Restore successful!')),
              );
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Restore failed: $e')));
      }
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
