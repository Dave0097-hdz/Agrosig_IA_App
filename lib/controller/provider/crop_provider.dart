import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/crop/crop_model.dart';
import '../../domain/services/crop_services/crop_services.dart';

final cropProvider = StateNotifierProvider<CropNotifier, CropState>((ref) {
  return CropNotifier();
});

class CropNotifier extends StateNotifier<CropState> {
  final CropService _cropService = CropService();

  CropNotifier() : super(CropState());

  Future<void> loadAllCrops() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: '');
      final response = await _cropService.getCrops(page: 1, limit: 100);

      if (response.success) {
        state = state.copyWith(
          crops: response.data.crops,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.message,
        );
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error al cargar cultivos: $error',
      );
    }
  }

  Crop? getCropById(int cropId) {
    try {
      return state.crops.firstWhere((crop) => crop.cropId == cropId);
    } catch (e) {
      return null;
    }
  }

  String getCropName(int cropId) {
    final crop = getCropById(cropId);
    return crop != null ? _formatCropName(crop) : 'Cultivo $cropId';
  }

  String _formatCropName(Crop crop) {
    if (crop.cropVariety != null && crop.cropVariety!.isNotEmpty) {
      return '${crop.cropType} - ${crop.cropVariety}';
    }
    return crop.cropType;
  }
}

class CropState {
  final List<Crop> crops;
  final bool isLoading;
  final String errorMessage;

  CropState({
    this.crops = const [],
    this.isLoading = false,
    this.errorMessage = '',
  });

  CropState copyWith({
    List<Crop>? crops,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CropState(
      crops: crops ?? this.crops,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}