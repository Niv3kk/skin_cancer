import 'package:flutter/material.dart';
// --- CAMBIO 1: Importamos login_screen para tener acceso al enum 'UserRole' ---
import 'package:skin_cancer_detector/presentation/screens/login_screen.dart';
import 'package:skin_cancer_detector/presentation/screens/home_screen.dart';

// Modelo de datos para cada sección de ayuda (sin cambios)
class InfoTopic {
  final String title;
  final String content;

  const InfoTopic({required this.title, required this.content});
}

// Lista con las preguntas y respuestas de ayuda (sin cambios)
const List<InfoTopic> _infoTopics = [
  InfoTopic(
    title: 'Acerca de',
    content:
    'Nuestra aplicación utiliza tecnología de inteligencia artificial para ayudar en la identificación temprana de posibles lesiones cutáneas malignas. Esta herramienta no reemplaza el diagnóstico de un profesional médico. Versión 1.0.0.',
  ),
  InfoTopic(
    title: 'Historial de transacciones',
    content:
    'Actualmente, todos los servicios proporcionados por la aplicación son gratuitos. No se realizan transacciones monetarias. Cualquier cambio futuro en este modelo será notificado con antelación.',
  ),
  InfoTopic(
    title: 'Política de privacidad',
    content:
    'Respetamos tu privacidad. Las imágenes y datos de los escaneos se procesan y almacenan de forma local en tu dispositivo. No recopilamos ni compartimos tu información personal con terceros sin tu consentimiento explícito.',
  ),
  InfoTopic(
    title: 'Términos y condiciones',
    content:
    'Al usar esta aplicación, aceptas que los resultados son una guía preliminar y no constituyen un diagnóstico médico. El desarrollador no se hace responsable del uso indebido de la información proporcionada. Es tu responsabilidad consultar a un especialista.',
  ),
  InfoTopic(
    title: 'Política de eliminación',
    content:
    'Puedes eliminar cualquier registro de tu historial de escaneos directamente desde la pantalla de "Historial" usando el ícono de la papelera. Para eliminar todos tus datos, desinstala la aplicación de tu dispositivo.',
  ),
];

class HelpScreen extends StatelessWidget {
  // --- CAMBIO 2: Añadimos la variable para recibir el rol ---
  final UserRole userRole;

  // --- CAMBIO 3: Actualizamos el constructor para requerir el rol ---
  const HelpScreen({super.key, required this.userRole});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Pasamos el rol al encabezado para que decida si muestra el botón
            _buildHeader(context, userRole),

            // El resto del cuerpo de la pantalla no necesita cambios
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Obtener más información',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ..._infoTopics.map((topic) => _InfoExpansionTile(topic: topic)).toList(),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 20),
                    _buildExamplesSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- CAMBIO 4: El encabezado ahora recibe el rol y tiene una nueva estructura ---
  Widget _buildHeader(BuildContext context, UserRole userRole) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        children: [
          Image.asset('assets/images/splash_logo.png', height: 150),
          const SizedBox(height: 10),
          // Usamos un Row para alinear los botones en la misma línea
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Alinea los elementos a los extremos
            children: [
              // Botón "Atrás" a la izquierda
              TextButton.icon(
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

              // Botón "Editar" condicional a la derecha
              if (userRole == UserRole.admin)
                TextButton.icon(
                  onPressed: () {
                    // TODO: Lógica para navegar a la pantalla de edición
                    print('El administrador quiere editar el contenido.');
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Editar'),
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xFF11E9C4), // Un color diferente para distinguirlo
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExamplesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Para una detección precisa, asegúrese de que la imagen sea clara y bien enfocada.',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Image.asset('assets/images/correct_example.png', height: 100, width: 100, fit: BoxFit.cover),
                const SizedBox(height: 8),
                const Text('Correcto', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ],
            ),
            Column(
              children: [
                Image.asset('assets/images/incorrect_example.png', height: 100, width: 100, fit: BoxFit.cover),
                const SizedBox(height: 8),
                const Text('Incorrecto', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoExpansionTile extends StatelessWidget {
  final InfoTopic topic;
  const _InfoExpansionTile({required this.topic});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.grey[100],
      margin: const EdgeInsets.only(bottom: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(
          topic.title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0).copyWith(top: 0),
            child: Text(
              topic.content,
              style: const TextStyle(color: Colors.black54, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}