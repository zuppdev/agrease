import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:ui' as ui;

class Classifier {
  late File imageFile;
  Interpreter? _interpreter;
  List<String>? _labels;

  Future<List<Map<String, dynamic>>?> getDisease(ImageSource imageSource) async {
    var image = await ImagePicker().pickImage(source: imageSource);
    if (image == null) return null;
    imageFile = File(image.path);
    await loadModel();
    var result = await classifyImage(imageFile);
    close();
    return result;
  }

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset('assets/model/model_unquant.tflite');
    _labels = await _loadLabels('assets/model/labels.txt');
  }

  Future<List<String>> _loadLabels(String path) async {
    final labelsData = await rootBundle.loadString(path);
    return labelsData.split('\n').where((label) => label.isNotEmpty).toList();
  }

  Future<List<Map<String, dynamic>>?> classifyImage(File image) async {
    if (_interpreter == null || _labels == null) return null;

    // Get input shape from the model
    final inputShape = _interpreter!.getInputTensor(0).shape;
    final inputHeight = inputShape[1];
    final inputWidth = inputShape[2];

    // Load and preprocess image
    final imageBytes = await image.readAsBytes();
    final codec = await ui.instantiateImageCodec(
      imageBytes,
      targetWidth: inputWidth,
      targetHeight: inputHeight,
    );
    final frame = await codec.getNextFrame();
    final uiImage = frame.image;

    // Convert to byte data
    final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) return null;

    // Prepare input tensor (normalize to 0-1 range, then apply imageMean=0, imageStd=255)
    final inputBuffer = Float32List(1 * inputHeight * inputWidth * 3);
    final pixels = byteData.buffer.asUint8List();

    int pixelIndex = 0;
    for (int i = 0; i < inputHeight * inputWidth; i++) {
      // RGBA format - skip alpha channel
      inputBuffer[pixelIndex++] = pixels[i * 4] / 255.0;     // R
      inputBuffer[pixelIndex++] = pixels[i * 4 + 1] / 255.0; // G
      inputBuffer[pixelIndex++] = pixels[i * 4 + 2] / 255.0; // B
    }

    final input = inputBuffer.reshape([1, inputHeight, inputWidth, 3]);

    // Prepare output tensor
    final outputShape = _interpreter!.getOutputTensor(0).shape;
    final outputSize = outputShape[1];
    final output = List.filled(1 * outputSize, 0.0).reshape([1, outputSize]);

    // Run inference
    _interpreter!.run(input, output);

    // Process results
    final results = <Map<String, dynamic>>[];
    final outputList = output[0] as List<double>;

    for (int i = 0; i < outputList.length && i < _labels!.length; i++) {
      if (outputList[i] > 0.2) { // threshold
        results.add({
          'index': i,
          'label': _labels![i],
          'confidence': outputList[i],
        });
      }
    }

    // Sort by confidence and return top 2
    results.sort((a, b) => (b['confidence'] as double).compareTo(a['confidence'] as double));
    return results.take(2).toList();
  }

  void close() {
    _interpreter?.close();
    _interpreter = null;
  }
}
