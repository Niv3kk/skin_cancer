import 'package:flutter/material.dart';

// --- MODELO DE DATOS ACTUALIZADO ---
// Se divide 'diagnosis' en 'diagnosisType' y 'diagnosisDescription'.
class ScanHistoryItem {
  final String imagePath;
  final String date;
  final String recognition;
  final String diagnosisType;
  final String diagnosisDescription;

  ScanHistoryItem({
    required this.imagePath,
    required this.date,
    required this.recognition,
    required this.diagnosisType,
    required this.diagnosisDescription,
  });
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final List<String> _filters = ['Todo', 'Espalda', 'Pecho', 'Rostro'];
  int _selectedFilterIndex = 0;

  // --- LISTA DE EJEMPLO ACTUALIZADA CON LA NUEVA ESTRUCTURA ---
  final List<ScanHistoryItem> _historyItems = [
    ScanHistoryItem(
      imagePath: 'assets/images/scan_1.png',
      date: '12/03/2025',
      recognition: '89%',
      diagnosisType: 'Melanoma',
      diagnosisDescription: 'La imagen presenta signos compatibles con una posible lesión tipo melanoma. Se recomienda consultar a un dermatólogo para una evaluación profesional y confirmar el diagnóstico.',
    ),
    ScanHistoryItem(
      imagePath: 'assets/images/scan_1.png',
      date: '15/03/2025',
      recognition: '85%',
      diagnosisType: 'Carcinoma Basocelular',
      diagnosisDescription: 'Se observa una lesión cutánea con características típicas de un carcinoma basocelular. Es fundamental la revisión por un especialista.',
    ),
    ScanHistoryItem(
      imagePath: 'assets/images/scan_1.png',
      date: '20/03/2025',
      recognition: '79%',
      diagnosisType: 'Queratosis Actínica',
      diagnosisDescription: 'Se detectan signos consistentes con queratosis actínica. Se aconseja seguimiento y posible tratamiento médico.',
    ),
    ScanHistoryItem(
      imagePath: 'assets/images/scan_1.png',
      date: '25/03/2025',
      recognition: '91%',
      diagnosisType: 'Nevus Atípico',
      diagnosisDescription: 'La imagen muestra un nevus con algunas características atípicas. Se sugiere un control dermatoscópico detallado.',
    ),
    ScanHistoryItem(
      imagePath: 'assets/images/scan_1.png',
      date: '30/03/2025',
      recognition: '70%',
      diagnosisType: 'Lesión Benigna',
      diagnosisDescription: 'Los indicadores sugieren una lesión de naturaleza benigna. Sin embargo, ante cualquier cambio, consulte a un especialista.',
    ),
  ];

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
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                itemCount: _historyItems.length,
                itemBuilder: (context, index) {
                  final item = _historyItems[index];
                  return _HistoryCard(
                    item: item,
                    onDelete: () {
                      print('Eliminar: ${item.diagnosisType}');
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

// --- TARJETA DE HISTORIAL CON EL NUEVO DISEÑO ---
class _HistoryCard extends StatelessWidget {
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
