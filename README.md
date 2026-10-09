# Calculator App – Flutter

## Project Overview
This is a calculator application developed using Flutter and Dart for CSC 6370 – Assignment 01.

The application supports basic arithmetic operations, decimal calculations, and additional graduate-level features.

## Features
- Addition, subtraction, multiplication, and division
- Decimal number support
- Calculation history with result reuse
- Clear calculation history
- Backspace to delete individual digits
- Long-press backspace to reset the calculator
- Error handling for division by zero and incomplete calculations
- Modern dark-themed interface

## Technologies Used
- Flutter
- Dart
- Material Design
- Android Emulator

## How to Run the Application

1. Install Flutter and configure the Android SDK.
2. Clone the repository:

   `git clone https://github.com/harikachinnam30/Calculator-.git`

3. Open the project folder:

   `cd Calculator-`

4. Install dependencies:

   `flutter pub get`

5. Start an Android emulator or connect an Android device.

6. Run the application:

   `flutter run`

## Build the APK

Run:

`flutter build apk --release`

The generated APK will be available at:

`build/app/outputs/flutter-apk/app-release.apk`

## Testing

The calculator was tested on an Android emulator using 15 functional test cases covering arithmetic operations, decimal calculations, backspace, calculation history, and error handling.

All 15 tests passed.

## Graduate Features

The graduate pathway includes decimal support and three selected advanced features:

1. Calculation History
2. Backspace/Delete
3. Advanced Error Handling

## Developer

Harika Chinnam  
Georgia State University  
CSC 6370 – Graduate

## GitHub Repository

https://github.com/harikachinnam30/Calculator-