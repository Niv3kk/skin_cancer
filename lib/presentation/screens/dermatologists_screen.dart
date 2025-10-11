import 'package:flutter/material.dart';

// --- Modelo de Datos para cada Dermatólogo ---
class Dermatologist {
  final String imagePath;
  final String name;
  final String specialty;
  final String description;
  final String address;
  final String whatsappUrl;
  final String facebookUrl;

  const Dermatologist({
    required this.imagePath,
    required this.name,
    required this.specialty,
    required this.description,
    required this.address,
    required this.whatsappUrl,
    required this.facebookUrl,
  });
}

// --- Lista de Especialistas de Ejemplo ---
const List<Dermatologist> _dermatologists = [
  Dermatologist(
    imagePath: 'assets/images/doc_1.png', // Reemplaza con tu imagen
    name: 'Dra. Ana Gutiérrez',
    specialty: 'Dermatóloga Clínica',
    description:
    'Especialista en dermatoscopia y detección temprana de melanoma. Con más de 15 años de experiencia en el tratamiento de afecciones de la piel.',
    address: 'Av. América #123, Edificio Sol, Consultorio 301',
    whatsappUrl: 'https://wa.me/59170012345', // Número de ejemplo
    facebookUrl: 'https://www.facebook.com/DraAnaGutierrez',
  ),
  Dermatologist(
    imagePath: 'assets/images/doc_2.png', // Reemplaza con tu imagen
    name: 'Dr. Carlos Mendoza',
    specialty: 'Cirujano Dermatólogo',
    description:
    'Experto en cirugía de Mohs para el tratamiento del cáncer de piel y procedimientos estéticos. Miembro de la Sociedad Boliviana de Dermatología.',
    address: 'Calle Nataniel Aguirre #456, Clínica PielSana',
    whatsappUrl: 'https://wa.me/59170067890', // Número de ejemplo
    facebookUrl: 'https://www.facebook.com/DrCarlosMendoza',
  ),
];

class DermatologistsScreen extends StatelessWidget {
  const DermatologistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              // --- CAMBIO 1: Se ajusta el ListView ---
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                // Ahora solo cuenta el número de dermatólogos
                itemCount: _dermatologists.length,
                itemBuilder: (context, index) {
                  // Ya no se necesita la condición 'if/else', solo se construyen las tarjetas
                  return _DermatologistCard(
                      dermatologist: _dermatologists[index]);
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
          Image.asset('assets/images/splash_logo.png', height: 150),
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
                padding:
                const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

// --- CAMBIO 2: Se elimina por completo la función _buildFooter ---
}

class _DermatologistCard extends StatelessWidget {
  final Dermatologist dermatologist;
  const _DermatologistCard({required this.dermatologist});

  Future<void> _launchURL(String url) async {
    print('Intentando abrir: $url');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[200],
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundImage: AssetImage(dermatologist.imagePath),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dermatologist.name,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        dermatologist.specialty,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              dermatologist.description,
              style: const TextStyle(color: Colors.black54, height: 1.4),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    color: Colors.grey, size: 18),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(dermatologist.address,
                        style: const TextStyle(color: Colors.grey))),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => _launchURL(dermatologist.whatsappUrl),
                  icon: Image.asset('assets/images/whatsapp.png',
                      height: 28),
                ),
                IconButton(
                  onPressed: () => _launchURL(dermatologist.facebookUrl),
                  icon: Image.asset('assets/images/facebook.png',
                      height: 28),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
