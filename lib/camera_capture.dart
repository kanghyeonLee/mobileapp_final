import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraCapturePage extends StatefulWidget {
  const CameraCapturePage({super.key});

  @override
  State<CameraCapturePage> createState() => _CameraCapturePageState();
}

class _CameraCapturePageState extends State<CameraCapturePage> {
  late CameraController _controller;
  late Future<void> _initController;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    _setupCameras();
  }

  Future<void> _setupCameras() async {
    _cameras = await availableCameras();

    // 전면 카메라 우선 선택
    _selectedCameraIndex = _cameras.indexWhere(
      (cam) => cam.lensDirection == CameraLensDirection.front,
    );
    if (_selectedCameraIndex == -1) _selectedCameraIndex = 0; // fallback

    await _initializeCamera(_selectedCameraIndex);
  }

  Future<void> _initializeCamera(int cameraIndex) async {
    _controller = CameraController(
      _cameras[cameraIndex],
      ResolutionPreset.medium,
    );
    _initController = _controller.initialize();
    setState(() {});
  }

  void _toggleCamera() async {
    if (_cameras.isEmpty) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    await _initializeCamera(_selectedCameraIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("촬영"),
        actions: [
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: _toggleCamera,
          ),
        ],
      ),
      body: FutureBuilder(
        future: _initController,
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.done) {
            return Column(
              children: [
                Expanded(child: CameraPreview(_controller)),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.camera),
                    label: const Text("촬영"),
                    onPressed: () async {
                      final photo = await _controller.takePicture();
                      Navigator.pop(context, photo);
                    },
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}