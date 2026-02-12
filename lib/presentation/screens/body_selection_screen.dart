import 'package:flutter/material.dart';
import 'package:skin_cancer_detector/presentation/screens/account_screen.dart';
import 'package:skin_cancer_detector/presentation/screens/skin_scan_screen.dart';
import 'package:skin_cancer_detector/services/permissions_service.dart';

// Color primario de la app
const Color kPrimaryColor = Color(0xFF11E9C4);

enum LesionOption {
  ninguno,
  cambioMorfologico,
  picazon,
  sangrado,
  inflamacion,
}

class BodySelectionScreen extends StatefulWidget {
  final String userEmail;
  final String userName;

  const BodySelectionScreen({
    super.key,
    required this.userEmail,
    required this.userName,
  });

  @override
  State<BodySelectionScreen> createState() => _BodySelectionScreenState();
}

class _BodySelectionScreenState extends State<BodySelectionScreen> {
  LesionOption? _selectedLesionOption;
  String? _selectedBodyPart;

  final List<String> _bodyParts = const [
    'Brazo izquierdo',
    'Brazo derecho',
    'Pierna derecha',
    'Pierna izquierda',
    'Cabeza',
    'Pecho',
    'Espalda',
  ];

  // 🔹 Convertimos enum a texto estable (importante para ResultScreen)
  String _lesionOptionToText(LesionOption option) {
    switch (option) {
      case LesionOption.ninguno:
        return 'No hay cambios notables';
      case LesionOption.cambioMorfologico:
        return 'Cambio morfológico';
      case LesionOption.picazon:
        return 'Picazón';
      case LesionOption.sangrado:
        return 'Sangrado';
      case LesionOption.inflamacion:
        return 'Inflamación';
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

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 6),

                    _buildRadioCard(
                      value: LesionOption.ninguno,
                      title: 'Ninguno',
                      subtitle: 'No hay cambios notables.',
                      iconAssetPath: 'assets/images/picazon.png',
                    ),
                    _buildRadioCard(
                      value: LesionOption.cambioMorfologico,
                      title: 'Cambio morfológico',
                      subtitle: 'Ha cambiado el tamaño, la forma o el color.',
                      iconAssetPath: 'assets/images/color.png',
                    ),
                    _buildRadioCard(
                      value: LesionOption.picazon,
                      title: 'Picazón',
                      subtitle: 'Se siente con picor o irritado.',
                      iconAssetPath: 'assets/images/normal.png',
                    ),
                    _buildRadioCard(
                      value: LesionOption.sangrado,
                      title: 'Sangrado',
                      subtitle: 'Presencia de sangre o secreción de líquidos.',
                      iconAssetPath: 'assets/images/sangrado.png',
                    ),
                    _buildRadioCard(
                      value: LesionOption.inflamacion,
                      title: 'Inflamación',
                      subtitle: 'Enrojecimiento, hinchazón o una llaga que no cicatriza.',
                      iconAssetPath: 'assets/images/llagaNoCicatriza.png',
                    ),

                    const SizedBox(height: 18),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Cuerpo',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    DropdownButtonFormField<String>(
                      value: _selectedBodyPart,
                      items: _bodyParts
                          .map(
                            (part) => DropdownMenuItem<String>(
                          value: part,
                          child: Text(part),
                        ),
                      )
                          .toList(),
                      onChanged: (value) {
                        setState(() => _selectedBodyPart = value);
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: kPrimaryColor.withOpacity(0.12),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: kPrimaryColor.withOpacity(0.35)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: kPrimaryColor, width: 2),
                        ),
                      ),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      hint: const Text('Selecciona una parte del cuerpo'),
                    ),
                  ],
                ),
              ),
            ),

            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================
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
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AccountScreen(
                      userEmail: widget.userEmail,
                      userName: widget.userName,
                    ),
                  ),
                );
              },
              icon: Image.asset(
                'assets/images/cuenta_icon.png',
                height: 24,
                width: 24,
              ),
              label: Text(
                widget.userName,
                style: const TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Cuéntanos qué cambio observas y dónde se encuentra',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= RADIO =================
  Widget _buildRadioCard({
    required LesionOption value,
    required String title,
    required String subtitle,
    required String iconAssetPath,
  }) {
    final isSelected = _selectedLesionOption == value;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? kPrimaryColor : Colors.grey.withOpacity(0.25),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() => _selectedLesionOption = value),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Radio<LesionOption>(
                value: value,
                groupValue: _selectedLesionOption,
                activeColor: kPrimaryColor,
                onChanged: (val) => setState(() => _selectedLesionOption = val),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: Image.asset(iconAssetPath, width: 44, height: 44, fit: BoxFit.cover),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= FOOTER =================
  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () async {
            if (_selectedLesionOption == null || _selectedBodyPart == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Selecciona una opción y una parte del cuerpo para continuar.'),
                ),
              );
              return;
            }

            final symptomText = _lesionOptionToText(_selectedLesionOption!);

            final granted = await PermissionsService.requestCameraAndGallery();

            if (!granted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Necesitamos acceso a la cámara y galería para continuar.'),
                ),
              );
              return;
            }

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SkinScanScreen(
                  bodyPart: _selectedBodyPart!,
                  symptom: symptomText, // ✅ ahora se envía
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Siguiente',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
