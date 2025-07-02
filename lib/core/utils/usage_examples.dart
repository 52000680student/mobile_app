// This file contains usage examples for the core utilities
// Remove this file after understanding how to use the utilities

import 'package:flutter/material.dart';
import 'toast_service.dart';
import 'loading_service.dart';
import 'dialog_service.dart';
import 'debouncer.dart';
import 'validator.dart';

class UtilityUsageExamples {
  // Toast Service Examples
  static void showToastExamples(BuildContext context) {
    // Success toast
    ToastService.showSuccess(context, 'Operation completed successfully!');

    // Error toast
    ToastService.showError(context, 'Something went wrong. Please try again.');

    // Warning toast
    ToastService.showWarning(context, 'This action cannot be undone.');

    // Info toast
    ToastService.showInfo(context, 'New update available.');
  }

  // Loading Service Examples
  static void showLoadingExamples(BuildContext context) async {
    // Show full-screen loading
    LoadingService.show(context, message: 'Loading data...');

    // Simulate some async operation
    await Future.delayed(const Duration(seconds: 2));

    // Hide loading
    LoadingService.hide();

    // Show loading dialog
    LoadingService.showDialog(
      context,
      message: 'Processing your request...',
      barrierDismissible: false,
    );
  }

  // Dialog Service Examples
  static void showDialogExamples(BuildContext context) async {
    // Confirmation dialog
    final confirmed = await DialogService.showConfirmation(
      context,
      title: 'Delete Item',
      message: 'Are you sure you want to delete this item?',
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (confirmed) {
      // User confirmed deletion
    }

    // Alert dialog
    await DialogService.showAlert(
      context,
      title: 'Information',
      message: 'This is an informational message.',
      icon: Icons.info,
    );

    // Error dialog
    await DialogService.showError(
      context,
      message: 'Failed to save data. Please try again.',
    );

    // Input dialog
    final userInput = await DialogService.showInput(
      context,
      title: 'Enter Name',
      hint: 'Your name',
      validator: Validator.name,
    );

    if (userInput != null) {
      // User entered some text
    }
  }

  // Debouncer Examples
  static void debouncerExamples() {
    // General debouncer
    final debouncer = Debouncer(delay: const Duration(milliseconds: 500));

    // Use in a search field
    debouncer.call(() {
      // Perform search
      print('Performing search...');
    });

    // Text debouncer for search
    final searchDebouncer = TextDebouncer(
      delay: const Duration(milliseconds: 300),
      onChanged: (value) {
        // Perform search with the value
        print('Searching for: $value');
      },
    );

    // Use in TextField onChanged
    // searchDebouncer.process(newValue);
  }

  // Validator Examples
  static void validatorExamples() {
    // Email validation
    String? emailError = Validator.email('user@example.com');

    // Password validation
    String? passwordError = Validator.password('mypassword123');

    // Strong password validation
    String? strongPasswordError = Validator.strongPassword('MyPass123!');

    // Name validation
    String? nameError = Validator.name('John Doe');

    // Phone validation
    String? phoneError = Validator.phoneNumber('+1234567890');

    // Required field validation
    String? requiredError = Validator.required('', fieldName: 'Username');

    // Combine multiple validators
    String? combinedError = Validator.combine([
      (value) => Validator.required(value, fieldName: 'Email'),
      Validator.email,
    ], 'user@example.com');
  }

  // Widget examples with the new utilities
  static Widget buildExampleForm() {
    return Scaffold(
      appBar: AppBar(title: const Text('Utility Examples')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Text field with validation
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
              ),
              validator: Validator.email,
            ),

            const SizedBox(height: 16),

            // Loading button example
            const LoadingButton(
              onPressed: null, // Set to actual function
              isLoading: false,
              child: Text('Submit'),
            ),

            const SizedBox(height: 16),

            // Inline loading indicator
            const Row(
              children: [
                Text('Loading data... '),
                LoadingIndicator(size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
