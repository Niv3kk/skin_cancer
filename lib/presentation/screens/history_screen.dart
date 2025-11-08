// lib/presentation/screens/history_screen.dart

import 'package:flutter/material.dart';
// --- IMPORTAMOS LOS ARCHIVOS NUEVOS ---
import 'package:skin_cancer_detector/core/models/scan_history_item.dart';
import 'package:skin_cancer_detector/services/database_helper.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final List<String> _filters = ['Todo', 'Espalda', 'Pecho', 'Rostro'];
  int _selectedFilterIndex = 0;

  // --- ESTO ES NUEVO ---
  // Usamos un Future para cargar los datos de la DB
  late Future<List<ScanHistoryItem>> _historyItemsFuture;
  final dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    // Al iniciar la pantalla, cargamos el historial de la DB
    _refreshHistoryList();
  }

  // --- ESTO ES NUEVO ---
  // Función para recargar la lista desde la DB
  void _refreshHistoryList() {
    setState(() {
      _historyItemsFuture = dbHelper.getScans();
    });
  }

  // --- ESTO ES NUEVO ---
  // Función para eliminar un item
  void _deleteItem(int id) async {
    await dbHelper.deleteScan(id);
    _refreshHistoryList(); // Recargamos la lista
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Historial eliminado')));
    }
  }

  // --- ESTO ES NUEVO (PARA PRUEBAS) ---
  // Un botón temporal para añadir un escaneo de prueba
  void _addTestScan() async {
    final newItem = ScanHistoryItem(
      imagePath: 'assets/images/scan_1.png',
      date: '25/03/2025',
      recognition: '91%',
      diagnosisType: 'Prueba de DB',
      diagnosisDescription: 'Este item fue añadido desde la base de datos.',
    );
    await dbHelper.addScan(newItem);
    _refreshHistoryList(); // Recargamos la lista
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // --- BOTÓN DE PRUEBA PARA AÑADIR DATOS ---
      floatingActionButton: FloatingActionButton(
        onPressed: _addTestScan,
        child: const Icon(Icons.add),
        backgroundColor: const Color(0xFF11E9C4),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildFilters(),
            // --- ESTO ESTÁ MODIFICADO ---
            // Usamos un FutureBuilder para esperar a que la DB responda
            Expanded(
              child: FutureBuilder<List<ScanHistoryItem>>(
                future: _historyItemsFuture,
                builder: (context, snapshot) {
                  // Caso 1: Cargando...
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  // Caso 2: Error
                  if (snapshot.hasError) {
                    return const Center(
                        child: Text('Error al cargar el historial'));
                  }
                  // Caso 3: Éxito (pero no hay datos)
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'No hay historial de escaneos.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  // Caso 4: Éxito (y hay datos)
                  final historyItems = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 10.0),
                    itemCount: historyItems.length,
                    itemBuilder: (context, index) {
                      final item = historyItems[index];
                      return _HistoryCard(
                        item: item,
                        onDelete: () {
                          // Llamamos a _deleteItem con el ID de la DB
                          if (item.id != null) {
                            _deleteItem(item.id!);
                          }
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

  // --- EL RESTO DE TUS WIDGETS (Header, Filters, Card) ---
  // --- NO HAN SIDO MODIFICADOS ---
  // ... (Pega aquí tus widgets _buildHeader, _buildFilters, y la clase _HistoryCard)
  // ...
  Widget _buildHeader(BuildContext context) {
    // ... (Tu código de _buildHeader)
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        children: [
          Center(
            child: Image.asset('assets/images/splash_logo.png', height: 150),
          ),
          const SizedBox(height: 10),
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
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    // ... (Tu código de _buildFilters)
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 10),
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
              onSelected: (selected) {
                setState(() {
                  _selectedFilterIndex = index;
                });
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
  // ... (Tu código de _HistoryCard)
  final ScanHistoryItem item;
  final VoidCallback onDelete;

  const _HistoryCard({required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Columna Izquierda: Imagen y Fecha
          Column(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundImage: AssetImage(item.imagePath),
              ),
              const SizedBox(height: 10),
              Text(
                item.date,
                style: const TextStyle(color: Colors.black, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(width: 15),
          // Columna Derecha: Información
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('RECONOCIMIENTO:', style: TextStyle(fontSize: 12, color: Colors.black54)),
                    Text(
                      item.recognition,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.grey[600]),
                      onPressed: onDelete,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('DIAGNOSTICO:', style: TextStyle(fontSize: 12, color: Colors.black54)),
                Text(
                  item.diagnosisType, // Muestra el tipo de diagnóstico aquí si quieres
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  item.diagnosisDescription,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}