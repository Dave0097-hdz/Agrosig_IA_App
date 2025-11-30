import '../../domain/models/activitys/activitys_model.dart';
import '../../domain/models/inputs/inputs_model.dart';

class ActivityFormData {
  String activityType;
  DateTime date;
  String? description;
  List<InputFormData> inputs;

  ActivityFormData({
    required this.activityType,
    required this.date,
    this.description,
    required this.inputs,
  });

  // Constructor para nueva actividad
  ActivityFormData.newActivity()
      : activityType = '',
        date = DateTime.now(),
        description = '',
        inputs = [InputFormData.newInput()];

  // Getter público para el costo total
  double get totalCost {
    return inputs.fold(0.0, (total, input) => total + input.calculateTotalCost());
  }

  // Convertir a modelo Activity
  Activity toActivity({int cropId = 0, int userId = 0}) {
    return Activity(
      activityId: 0, // Se asignará en el backend
      cropId: cropId,
      userId: userId,
      activityType: activityType,
      date: date,
      description: description,
      costTotal: totalCost,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      inputs: inputs.map((input) => input.toInputUsed()).toList(),
    );
  }

  // Calcular costo total de todos los insumos
  double _calculateTotalCost() {
    return inputs.fold(0.0, (total, input) => total + input.calculateTotalCost());
  }

  // Validar formulario
  bool isValid() {
    return activityType.isNotEmpty &&
        inputs.isNotEmpty &&
        inputs.every((input) => input.isValid());
  }

  // Agregar nuevo insumo
  void addInput() {
    inputs.add(InputFormData.newInput());
  }

  // Remover insumo
  void removeInput(int index) {
    if (inputs.length > 1) {
      inputs.removeAt(index);
    }
  }

  // Clonar el formulario
  ActivityFormData copy() {
    return ActivityFormData(
      activityType: activityType,
      date: date,
      description: description,
      inputs: inputs.map((input) => input.copy()).toList(),
    );
  }
}

class InputFormData {
  String inputName;
  String unit;
  double quantity;
  double unitCost;
  String costUnit;

  InputFormData({
    required this.inputName,
    required this.unit,
    required this.quantity,
    required this.unitCost,
    required this.costUnit,
  });

  // Constructor para nuevo insumo
  InputFormData.newInput()
      : inputName = '',
        unit = 'unidad',
        quantity = 0.0,
        unitCost = 0.0,
        costUnit = 'unidad';

  // Convertir a modelo InputUsed
  InputUsed toInputUsed({int activityId = 0}) {
    return InputUsed(
      inputId: 0,
      activityId: activityId,
      inputName: inputName,
      unit: unit,
      quantity: quantity,
      unitCost: unitCost,
      costUnit: costUnit,
      baseUnit: unit,
      conversionFactor: 1.0,
      costTotal: calculateTotalCost(),
      createdAt: DateTime.now(),
    );
  }

  // Calcular costo total
  double calculateTotalCost() {
    return quantity * unitCost;
  }

  // Validar insumo
  bool isValid() {
    return inputName.isNotEmpty &&
        unit.isNotEmpty &&
        quantity > 0 &&
        unitCost >= 0 &&
        costUnit.isNotEmpty;
  }

  // Clonar el insumo
  InputFormData copy() {
    return InputFormData(
      inputName: inputName,
      unit: unit,
      quantity: quantity,
      unitCost: unitCost,
      costUnit: costUnit,
    );
  }
}