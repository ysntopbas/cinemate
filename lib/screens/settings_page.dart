import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/tmdb_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TMDBService _tmdbService = TMDBService();
  bool _includeAdult = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _includeAdult = prefs.getBool('include_adult') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Yetişkin İçerikleri Göster'),
            subtitle: const Text(
              'Bu ayar açıkken yetişkinlere yönelik içerikler gösterilir',
            ),
            value: _includeAdult,
            onChanged: (bool value) async {
              await _tmdbService.setIncludeAdult(value);
              setState(() {
                _includeAdult = value;
              });
            },
          ),
        ],
      ),
    );
  }
} 