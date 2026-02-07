// lib/presentation/screens/history_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:skin_cancer_detector/core/models/scan_history_item.dart';
import 'package:skin_cancer_detector/services/database_helper.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final List<String> _filters = ['Todo']; // por ahora solo "Todo"
  int _selectedFilterIndex = 0;

  late Future<List<ScanHistoryItem>> _historyItemsFuture;
  final dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _refreshHistoryList();
  }

  void _refreshHistoryList() {
    setState(() {
      _historyItemsFuture = dbHelper.getScans();
    });
  }

  Future<void> _deleteItem(int id) async {
    await dbHelper.deleteScan(id);
    _refreshHistoryList();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Historial eliminado')),
    );
  }

  String _formatDate(String iso) {
    // iso: 2026-02-06T01:23:45.000Z
    try {
      final dt = DateTime.parse(iso).toLocal();
      String two(int n) => n.toString().padLeft(2, '0');
      return '${two(dt.day)}/${two(dt.month)}/${dt.year}  ${two(dt.hour)}:${two(dt.minute)}';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildFilters(),

            Expanded(
              child: FutureBuilder<List<ScanHistoryItem>>(
                future: _historyItemsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text('Error al cargar el historial'));
                  }

                  final historyItems = snapshot.data ?? const <ScanHistoryItem>[];
                  if (historyItems.isEmpty) {
                    return const Center(
                      child: Text(
                        'No hay historial de escaneos.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    itemCount: historyItems.length,
                    itemBuilder: (context, index) {
                      final item = historyItems[index];
                      return _HistoryCard(
                        item: item,
                        formattedDate: _formatDate(item.date),
                        onDelete: () {
                          if (item.id != null) _deleteItem(item.id!);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        children: [
          Center(
            child: Image.asset('assets/images/splash_logo.png', height: 120),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_ios_new, size: 16),
              label: const Text('Atrás'),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF11E9C4),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedFilterIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: ChoiceChip(
              label: Text(_filters[index]),
              selected: isSelected,
              onSelected: (_) {
                setState(() => _selectedFilterIndex = index);
              },
              backgroundColor: Colors.grey[200],
              selectedColor: const Color(0xFF11E9C4).withOpacity(0.8),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black54,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              side: BorderSide.none,
            ),
          );
        },
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final ScanHistoryItem item;
  final String formattedDate;
  final VoidCallback onDelete;

  const _HistoryCard({
    required this.item,
    required this.formattedDate,
    required this.onDelete,
  });

  List<Map<String, dynamic>> _readDetails(String jsonStr) {
    try {
      final obj = jsonDecode(jsonStr) as Map<String, dynamic>;
      final labels = (obj['labels'] as List).map((e) => e.toString()).toList();
      final probs = (obj['probs'] as List).map((e) => (e as num).toDouble()).toList();

      final out = <Map<String, dynamic>>[];
      for (int i = 0; i < labels.length && i < probs.length; i++) {
        out.add({'label': labels[i], 'prob': probs[i]});
      }
      // Ordenar desc por probabilidad
      out.sort((a, b) => (b['prob'] as double).compareTo(a['prob'] as double));
      return out;
    } catch (_) {
      return const [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final details = _readDetails(item.detailsJson);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Izquierda: Imagen + fecha
          Column(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundImage: MemoryImage(item.imageBytes), // ✅ BLOB -> MemoryImage
              ),
              const SizedBox(height: 8),
              Text(
                formattedDate,
                style: const TextStyle(color: Colors.black87, fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ],
          ),

          const SizedBox(width: 14),

          // Derecha: Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // fila top: reconocimiento + delete
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'RECONOCIMIENTO',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ),
                    Text(
                      item.recognition,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.grey[700]),
                      onPressed: onDelete,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                const Text(
                  'DIAGNÓSTICO',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
                Text(
                  item.diagnosisType,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),

                const SizedBox(height: 6),
                Text(
                  item.diagnosisDescription,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),

                const SizedBox(height: 10),
                const Text(
                  'ACCIÓN RECOMENDADA',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 4),
                Text(
                  item.recommendation,
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),

                if (details.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Text(
                    'DETALLE',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 6),
                  ...details.map((d) {
                    final lbl = d['label'] as String;
                    final prob = d['prob'] as double;
                    final pct = (prob * 100).toStringAsFixed(2);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Expanded(child: Text(lbl, style: const TextStyle(fontSize: 12))),
                          Text('$pct%', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
