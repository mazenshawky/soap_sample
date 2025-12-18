import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:soap_sample/widgets/temprature_card.dart';
import '../services/soap_service.dart';

class TemperaturePage extends StatefulWidget {
  const TemperaturePage({super.key});

  @override
  State<TemperaturePage> createState() => _TemperaturePageState();
}

class _TemperaturePageState extends State<TemperaturePage> {
  final SoapService _soapService = SoapService();
  final TextEditingController _celsiusController = TextEditingController();
  final TextEditingController _fahrenheitController = TextEditingController();

  String _fahrenheitResult = '--';
  String _celsiusResult = '--';
  bool _isConvertingCtoF = false;
  bool _isConvertingFtoC = false;

  @override
  void initState() {
    super.initState();
    // Set default values for testing
    _celsiusController.text = '25';
    _fahrenheitController.text = '77';
  }

  @override
  void dispose() {
    _celsiusController.dispose();
    _fahrenheitController.dispose();
    super.dispose();
  }

  Future<void> _convertCelsiusToFahrenheit() async {
    final celsius = _celsiusController.text.trim();

    if (celsius.isEmpty) {
      _showToast('Please enter Celsius value');
      return;
    }

    if (!_isValidNumber(celsius)) {
      _showToast('Please enter a valid number');
      return;
    }

    setState(() {
      _isConvertingCtoF = true;
    });

    try {
      final result = await _soapService.celsiusToFahrenheit(celsius);
      setState(() {
        _fahrenheitResult = result;
      });
      _showToast('Conversion successful!');
    } catch (e) {
      _showToast('Error: ${e.toString()}');
      setState(() {
        _fahrenheitResult = 'Error';
      });
    } finally {
      setState(() {
        _isConvertingCtoF = false;
      });
    }
  }

  Future<void> _convertFahrenheitToCelsius() async {
    final fahrenheit = _fahrenheitController.text.trim();

    if (fahrenheit.isEmpty) {
      _showToast('Please enter Fahrenheit value');
      return;
    }

    if (!_isValidNumber(fahrenheit)) {
      _showToast('Please enter a valid number');
      return;
    }

    setState(() {
      _isConvertingFtoC = true;
    });

    try {
      final result = await _soapService.fahrenheitToCelsius(fahrenheit);
      setState(() {
        _celsiusResult = result;
      });
      _showToast('Conversion successful!');
    } catch (e) {
      _showToast('Error: ${e.toString()}');
      setState(() {
        _celsiusResult = 'Error';
      });
    } finally {
      setState(() {
        _isConvertingFtoC = false;
      });
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  bool _isValidNumber(String value) {
    final number = num.tryParse(value);
    return number != null;
  }

  void _clearAll() {
    setState(() {
      _celsiusController.clear();
      _fahrenheitController.clear();
      _fahrenheitResult = '--';
      _celsiusResult = '--';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SOAP API Demo - Temperature Converter'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _clearAll,
            tooltip: 'Clear all',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            const Text(
              'Temperature Converter',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Using SOAP Web Service API',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Input Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Celsius Input
                  InputField(
                    label: 'Celsius (°C)',
                    controller: _celsiusController,
                    hintText: 'Enter temperature in Celsius',
                  ),
                  const SizedBox(height: 20),

                  // Convert Celsius to Fahrenheit Button
                  ActionButton(
                    text: 'Convert to Fahrenheit',
                    onPressed: _convertCelsiusToFahrenheit,
                    color: Colors.orange,
                    isLoading: _isConvertingCtoF,
                  ),
                  const SizedBox(height: 32),

                  // Fahrenheit Input
                  InputField(
                    label: 'Fahrenheit (°F)',
                    controller: _fahrenheitController,
                    hintText: 'Enter temperature in Fahrenheit',
                  ),
                  const SizedBox(height: 20),

                  // Convert Fahrenheit to Celsius Button
                  ActionButton(
                    text: 'Convert to Celsius',
                    onPressed: _convertFahrenheitToCelsius,
                    color: Colors.green,
                    isLoading: _isConvertingFtoC,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Results Section
            const Text(
              'Results',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                // Celsius to Fahrenheit Result
                Expanded(
                  child: TemperatureCard(
                    title: 'Fahrenheit Result',
                    value: '$_fahrenheitResult °F',
                    color: Colors.orange,
                    icon: Icons.thermostat,
                  ),
                ),
                const SizedBox(width: 16),

                // Fahrenheit to Celsius Result
                Expanded(
                  child: TemperatureCard(
                    title: 'Celsius Result',
                    value: '$_celsiusResult °C',
                    color: Colors.green,
                    icon: Icons.thermostat_auto,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'About this SOAP Service',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This app uses a public SOAP web service from W3Schools to convert temperatures.'
                    ' The service accepts XML SOAP requests and returns XML responses.',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
