import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/database_helper.dart';
import '../../data/models/settings_model.dart';
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsModel?>((ref) => SettingsNotifier(DatabaseHelper.instance));
class SettingsNotifier extends StateNotifier<SettingsModel?> {
  final DatabaseHelper _db;
  SettingsNotifier(this._db) : super(null) { load(); }
  Future<void> load() async {
    final maps = await (await _db.database).query('settings', limit: 1);
    if (maps.isNotEmpty) state = SettingsModel.fromMap(maps.first);
  }
  Future<void> update(SettingsModel s) async {
    final db = await _db.database;
    if (s.id != null) await db.update('settings', s.toMap(), where: 'id=?', whereArgs: [s.id]);
    else await db.insert('settings', s.toMap());
    await load();
  }
}
