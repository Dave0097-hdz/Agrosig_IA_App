import '../forms/activity_form_data.dart';

class UnitHelper {
  static const Map<String, Map<String, dynamic>> unitConversions = {
    // Peso
    'mg': {'baseUnit': 'g', 'factor': 0.001},
    'g': {'baseUnit': 'g', 'factor': 1},
    'kg': {'baseUnit': 'g', 'factor': 1000},
    'ton': {'baseUnit': 'g', 'factor': 1000000},
    'libra': {'baseUnit': 'g', 'factor': 453.592},
    'onza': {'baseUnit': 'g', 'factor': 28.3495},

    // Volumen
    'ml': {'baseUnit': 'ml', 'factor': 1},
    'L': {'baseUnit': 'ml', 'factor': 1000},
    'gal': {'baseUnit': 'ml', 'factor': 3785.41},

    // Unidades comerciales
    'saco': {'baseUnit': 'kg', 'factor': 50},
    'bolsa': {'baseUnit': 'kg', 'factor': 25},
    'unidad': {'baseUnit': 'unidad', 'factor': 1},
    'paquete': {'baseUnit': 'unidad', 'factor': 1},
  };

  // Listas de unidades
  static const List<String> weightUnits = ['mg', 'g', 'kg', 'ton', 'libra', 'onza'];
  static const List<String> volumeUnits = ['ml', 'L', 'gal'];
  static const List<String> commercialUnits = ['saco', 'bolsa', 'unidad', 'paquete'];

  // Obtener todas las unidades
  static List<String> getAllUnits() {
    return [...weightUnits, ...volumeUnits, ...commercialUnits];
  }

  // Validar compatibilidad de unidades (misma categoría)
  static bool areUnitsCompatible(String unit1, String unit2) {
    final info1 = unitConversions[unit1.toLowerCase()];
    final info2 = unitConversions[unit2.toLowerCase()];

    if (info1 == null || info2 == null) return false;
    return info1['baseUnit'] == info2['baseUnit'];
  }

  // Obtener factor de conversión entre unidades
  static double getConversionFactor(String fromUnit, String toUnit) {
    if (fromUnit == toUnit) return 1.0;

    final fromInfo = unitConversions[fromUnit.toLowerCase()];
    final toInfo = unitConversions[toUnit.toLowerCase()];

    if (fromInfo == null || toInfo == null) {
      throw Exception('No se puede convertir de $fromUnit a $toUnit');
    }

    if (fromInfo['baseUnit'] != toInfo['baseUnit']) {
      throw Exception('Unidades incompatibles: $fromUnit y $toUnit');
    }

    final fromFactor = fromInfo['factor'] as double;
    final toFactor = toInfo['factor'] as double;

    return fromFactor / toFactor;
  }

  // Convertir cantidad entre unidades
  static double convertQuantity(double quantity, String fromUnit, String toUnit) {
    if (fromUnit == toUnit) return quantity;

    final factor = getConversionFactor(fromUnit, toUnit);
    return quantity * factor;
  }

  // Calcular costo total considerando conversiones
  static double calculateTotalCost({
    required double quantity,
    required double unitCost,
    required String quantityUnit,
    required String costUnit,
  }) {
    try {
      if (quantityUnit == costUnit) {
        return quantity * unitCost;
      }

      final conversionFactor = getConversionFactor(costUnit, quantityUnit);
      return quantity * unitCost * conversionFactor;
    } catch (e) {
      // Si hay error de conversión, calcular sin conversión
      return quantity * unitCost;
    }
  }

  // Formatear moneda
  static String formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  // Validar datos del insumo
  static String? validateInput(InputFormData input) {
    if (input.inputName.isEmpty) {
      return 'El nombre del insumo es requerido';
    }
    if (input.quantity <= 0) {
      return 'La cantidad debe ser mayor a 0';
    }
    if (input.unitCost < 0) {
      return 'El costo unitario no puede ser negativo';
    }
    if (input.unit.isEmpty) {
      return 'La unidad es requerida';
    }
    if (input.costUnit.isEmpty) {
      return 'La unidad de costo es requerida';
    }

    // Validar compatibilidad de unidades
    if (!areUnitsCompatible(input.unit, input.costUnit)) {
      return 'Las unidades no son compatibles para conversión';
    }

    return null;
  }
}