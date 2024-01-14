import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class StoryProvider extends ChangeNotifier {
  String? imagePath;
  XFile? imageFile;

  CameraController? _controller;
  bool _isCameraInitialized = false;
  bool _isBackCameraSelected = true;

  bool get isCameraInitialized => _isCameraInitialized;
  bool get isBackCameraSelected => _isBackCameraSelected;
  CameraController? get controller => _controller;

  void setImagePath(String? value) {
    imagePath = value;
    notifyListeners();
  }

  void setImageFile(XFile? value) {
    imageFile = value;
    notifyListeners();
  }

  void clearImage() {
    imagePath = null;
    notifyListeners();
  }

  Future<void> onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = _controller;
    final cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
    );
    await previousCameraController?.dispose();
    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      print('Error initializing camera $e');
    }

    _controller = cameraController;
    _isCameraInitialized = _controller!.value.isInitialized;
    notifyListeners();
  }

  void toggleCameraSelection() {
    _isBackCameraSelected = !_isBackCameraSelected;
    notifyListeners();
  }
}
