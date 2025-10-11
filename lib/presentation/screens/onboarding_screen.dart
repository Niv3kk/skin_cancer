import 'package:flutter/material.dart';
// 1. IMPORTAMOS LA PANTALLA DE LOGIN
import 'package:skin_cancer_detector/presentation/screens/login_screen.dart';

// Modelo de datos para cada página de bienvenida
class OnboardingInfo {
  final String image;
  final String title;
  final String description;

  OnboardingInfo({
    required this.image,
    required this.title,
    required this.description,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // Controlador para el PageView, nos permite controlar la página actual
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Lista con la información de cada pantalla
  final List<OnboardingInfo> _onboardingData = [
    OnboardingInfo(
      image: 'assets/images/onboarding_1.png',
      title: 'TIPOS DE CANCER DE PIEL',
      description: 'Los tres tipos más comunes de cáncer de piel son el carcinoma basocelular, el espinocelular y el melanoma; '
          'varían en apariencia y gravedad, pero todos requieren una detección temprana. '
          ' Esta aplicación te ayuda a identificar señales visuales que podrían estar relacionadas con estos.',
    ),
    OnboardingInfo(
      image: 'assets/images/onboarding_2.png',
      title: 'QUE ES EL CARCINOMA BASOCELULAR',
      description: 'El carcinoma basocelular (CBC) es el tipo más común de cáncer de piel, que se origina en las células basales de la epidermis'
          ' (la capa más externa de la piel). Es poco frecuente que se extienda a otras partes del cuerpo (metástasis).'
          ' Por lo general, se presenta como un bulto pequeño, brillante o una llaga que no sana en áreas de la piel expuestas al sol, como la cara.',
    ),
    OnboardingInfo(
      image: 'assets/images/onboarding_3.png',
      title: 'QUE ES EL CARCINOMA ESPINOCELULAR',
      description: 'El carcinoma espinocelular, también conocido como carcinoma de células escamosas,'
          ' es un tipo de cáncer que comienza en las células escamosas de la piel, las cuales son células delgadas y planas que cubren la superficie de la piel,'
          'las membranas mucosas y otras superficies del cuerpo. Es el segundo tipo de cáncer de piel más común, después del carcinoma basocelular. ',
    ),
    OnboardingInfo(
      image: 'assets/images/onboarding_4.png',
      title: 'QUE ES EL MELANOMA',
      description: 'El melanoma es un tipo de cáncer de piel que se desarrolla a partir de los melanocitos, las células que dan color a la piel.'
          ' Es el tipo más grave de cáncer de piel y puede propagarse a otras partes del cuerpo si no se detecta y trata a tiempo.',
    ),
    OnboardingInfo(
      image: 'assets/images/onboarding_5.png',
      title: 'EL CANCER DE PIEL A NIVEL BOLIVIA',
      description: 'En Bolivia, el cáncer de piel va en aumento debido a la alta exposición solar y la altitud. '
          ' Se reportan más de 20 casos por cada 100.000 personas, siendo Cochabamba una de las ciudades más afectadas.La deteccion temprana es clave para '
          'La detección temprana es clave para un tratamiento eficaz.',
    ),
    OnboardingInfo(
      image: 'assets/images/onboarding_6.png',
      title: '¡Recuerda!',
      description: 'Esta aplicación no sustituye el diagnóstico médico profesional. Su función se limita a detectar un tipo específico de melanomas.'
          'Ante cualquier resultado preocupante, se recomienda consultar directamente con un médico.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingData.length,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  return OnboardingPageWidget(info: _onboardingData[index]);
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _onboardingData.length,
                    (index) => buildDot(index, context),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: ElevatedButton(
                onPressed: () {
                  if (_currentPage < _onboardingData.length - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  }
                },
                child: Text(
                  _currentPage == _onboardingData.length - 1 ? 'Entendido' : 'Siguiente',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AnimatedContainer buildDot(int index, BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 5),
      height: 6,
      width: _currentPage == index ? 20 : 6,
      decoration: BoxDecoration(
        color: _currentPage == index ? Theme.of(context).primaryColor : const Color(0xFFD8D8D8),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}


// --- WIDGET ACTUALIZADO ---
// Widget reutilizable para mostrar el contenido de cada página
class OnboardingPageWidget extends StatelessWidget {
  final OnboardingInfo info;

  const OnboardingPageWidget({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    // --- CAMBIO PRINCIPAL: Envolvemos la columna en un SingleChildScrollView ---
    // Esto permite que el contenido se desplace si es más largo que la pantalla.
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              info.image,
              height: 300,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            Text(
              info.title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: const Color(0xFF11E9C4),
              ),

            ),
            const SizedBox(height: 10),
            Text(
              info.description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
