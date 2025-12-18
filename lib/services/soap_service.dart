import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

class SoapService {
  // Using a public SOAP service for demonstration
  static const String baseUrl =
      'https://www.w3schools.com/xml/tempconvert.asmx';

  // Convert Celsius to Fahrenheit
  Future<String> celsiusToFahrenheit(String celsius) async {
    try {
      final soapEnvelope = _buildCelsiusToFahrenheitEnvelope(celsius);

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: _getHeaders('CelsiusToFahrenheit'),
        body: soapEnvelope,
      );

      if (response.statusCode == 200) {
        return _parseCelsiusToFahrenheitResponse(response.body);
      } else {
        throw Exception(
          'Failed to call SOAP service. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('SOAP request error: $e');
    }
  }

  // Convert Fahrenheit to Celsius
  Future<String> fahrenheitToCelsius(String fahrenheit) async {
    try {
      final soapEnvelope = _buildFahrenheitToCelsiusEnvelope(fahrenheit);

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: _getHeaders('FahrenheitToCelsius'),
        body: soapEnvelope,
      );

      if (response.statusCode == 200) {
        return _parseFahrenheitToCelsiusResponse(response.body);
      } else {
        throw Exception(
          'Failed to call SOAP service. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('SOAP request error: $e');
    }
  }

  // Build SOAP envelope for Celsius to Fahrenheit
  String _buildCelsiusToFahrenheitEnvelope(String celsius) {
    return '''
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
               xmlns:xsd="http://www.w3.org/2001/XMLSchema" 
               xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <CelsiusToFahrenheit xmlns="https://www.w3schools.com/xml/">
      <Celsius>$celsius</Celsius>
    </CelsiusToFahrenheit>
  </soap:Body>
</soap:Envelope>
''';
  }

  // Build SOAP envelope for Fahrenheit to Celsius
  String _buildFahrenheitToCelsiusEnvelope(String fahrenheit) {
    return '''
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
               xmlns:xsd="http://www.w3.org/2001/XMLSchema" 
               xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <FahrenheitToCelsius xmlns="https://www.w3schools.com/xml/">
      <Fahrenheit>$fahrenheit</Fahrenheit>
    </FahrenheitToCelsius>
  </soap:Body>
</soap:Envelope>
''';
  }

  // Get SOAP headers
  Map<String, String> _getHeaders(String action) {
    return {
      'Content-Type': 'text/xml; charset=utf-8',
      'SOAPAction': 'https://www.w3schools.com/xml/$action',
    };
  }

  // Parse Celsius to Fahrenheit response
  String _parseCelsiusToFahrenheitResponse(String xmlResponse) {
    try {
      final document = xml.XmlDocument.parse(xmlResponse);

      // Navigate through the XML structure
      final body = document.findAllElements('soap:Body').first;
      final celsiusToFahrenheitResponse = body
          .findAllElements('CelsiusToFahrenheitResponse')
          .first;
      final result = celsiusToFahrenheitResponse
          .findAllElements('CelsiusToFahrenheitResult')
          .first;

      return result.innerText;
    } catch (e) {
      throw Exception(
        'Failed to parse SOAP response: $e\nResponse: $xmlResponse',
      );
    }
  }

  // Parse Fahrenheit to Celsius response
  String _parseFahrenheitToCelsiusResponse(String xmlResponse) {
    try {
      final document = xml.XmlDocument.parse(xmlResponse);

      // Navigate through the XML structure
      final body = document.findAllElements('soap:Body').first;
      final fahrenheitToCelsiusResponse = body
          .findAllElements('FahrenheitToCelsiusResponse')
          .first;
      final result = fahrenheitToCelsiusResponse
          .findAllElements('FahrenheitToCelsiusResult')
          .first;

      return result.innerText;
    } catch (e) {
      throw Exception(
        'Failed to parse SOAP response: $e\nResponse: $xmlResponse',
      );
    }
  }

  // Generic SOAP call method (for other services)
  Future<Map<String, dynamic>> callGenericSoap({
    required String endpoint,
    required String action,
    required String namespace,
    required Map<String, dynamic> parameters,
  }) async {
    try {
      final soapEnvelope = _buildGenericEnvelope(action, namespace, parameters);

      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'text/xml; charset=utf-8',
          'SOAPAction': '$namespace/$action',
        },
        body: soapEnvelope,
      );

      if (response.statusCode == 200) {
        return _parseGenericResponse(response.body, action);
      } else {
        throw Exception('SOAP call failed. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Generic SOAP error: $e');
    }
  }

  String _buildGenericEnvelope(
    String action,
    String namespace,
    Map<String, dynamic> parameters,
  ) {
    final builder = xml.XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="utf-8"');
    builder.element(
      'soap:Envelope',
      nest: () {
        builder.attribute(
          'xmlns:soap',
          'http://schemas.xmlsoap.org/soap/envelope/',
        );
        builder.attribute(
          'xmlns:xsi',
          'http://www.w3.org/2001/XMLSchema-instance',
        );
        builder.attribute('xmlns:xsd', 'http://www.w3.org/2001/XMLSchema');

        builder.element(
          'soap:Body',
          nest: () {
            builder.element(
              action,
              nest: () {
                builder.attribute('xmlns', namespace);
                parameters.forEach((key, value) {
                  builder.element(key, nest: value.toString());
                });
              },
            );
          },
        );
      },
    );

    return builder.buildDocument().toXmlString(pretty: true);
  }

  Map<String, dynamic> _parseGenericResponse(
    String xmlResponse,
    String action,
  ) {
    try {
      final document = xml.XmlDocument.parse(xmlResponse);
      final resultMap = <String, dynamic>{};

      final body = document.findAllElements('soap:Body').first;
      final responseElement = body.findAllElements('${action}Response').first;

      // Parse all elements in the response
      for (final element in responseElement.childElements) {
        resultMap[element.name.local] = element.innerText;
      }

      return resultMap;
    } catch (e) {
      throw Exception('Failed to parse generic response: $e');
    }
  }
}
