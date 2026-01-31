# Agrease

A Flutter mobile application for plant disease detection using machine learning. Capture or upload photos of plants to identify diseases and get treatment recommendations.

## Features

- **Disease Detection**: Uses TensorFlow Lite model to classify plant diseases from images
- **15 Disease Classes**: Supports detection across Pepper Bell, Potato, and Tomato plants
- **Treatment Recommendations**: Provides causes and solutions for identified diseases
- **Detection History**: Stores past detections locally using Hive database
- **Multi-language Support**: Automatic translation to device language via Google Translator
- **Onboarding**: Guided introduction for new users

## Supported Plants & Diseases

| Plant | Diseases |
|-------|----------|
| Pepper Bell | Bacterial Spot, Healthy |
| Potato | Early Blight, Late Blight, Healthy |
| Tomato | Bacterial Spot, Early Blight, Late Blight, Leaf Mold, Septoria Leaf Spot, Spotted Spider Mites, Target Spot, Mosaic Virus, Yellow Leaf Curl Virus, Healthy |

## Tech Stack

- **Framework**: Flutter (Dart 3.0+)
- **ML Inference**: TensorFlow Lite (tflite_flutter)
- **State Management**: Provider, GetX
- **Local Storage**: Hive
- **Image Handling**: image_picker
- **Translation**: Google Translator API

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / Xcode for mobile development

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd agrease
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Generate Hive adapters:
   ```bash
   flutter pub run build_runner build
   ```

4. Run the app:
   ```bash
   flutter run
   ```
