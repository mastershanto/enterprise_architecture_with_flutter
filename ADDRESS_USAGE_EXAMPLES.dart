// Example: How to Use Address Feature in Your App

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import the provider and page
import 'features/address/presentation/bloc/address_state.dart';
import 'features/address/presentation/pages/address_page.dart';

/// Example 1: Basic button to navigate to Address Page
class NavigateToAddressPageExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddressPage()),
        );
      },
      child: const Text('Add Address'),
    );
  }
}

/// Example 2: Use AddressProvider directly in a widget
class SaveAddressFormExample extends StatefulWidget {
  @override
  State<SaveAddressFormExample> createState() => _SaveAddressFormExampleState();
}

class _SaveAddressFormExampleState extends State<SaveAddressFormExample> {
  final _formKey = GlobalKey<FormState>();
  final _addressLine1Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _countryController = TextEditingController();

  @override
  void dispose() {
    _addressLine1Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AddressProvider>(
      builder: (context, addressProvider, _) {
        return Form(
          key: _formKey,
          child: Column(
            children: [
              // Show loading
              if (addressProvider.state.isLoading)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),

              // Show error
              if (addressProvider.state.error != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Error: ${addressProvider.state.error!.message}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              // Show success
              if (addressProvider.state.isSuccess &&
                  addressProvider.state.savedAddress != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Address saved successfully!',
                        style: TextStyle(color: Colors.green),
                      ),
                      Text(
                        'ID: ${addressProvider.state.savedAddress!.id}',
                      ),
                      Text(
                        addressProvider.state.savedAddress!.addressLine1,
                      ),
                    ],
                  ),
                ),

              // Form fields
              TextFormField(
                controller: _addressLine1Controller,
                decoration: const InputDecoration(labelText: 'Address Line 1'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'City'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: _stateController,
                decoration: const InputDecoration(labelText: 'State'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: _postalCodeController,
                decoration: const InputDecoration(labelText: 'Postal Code'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: _countryController,
                decoration: const InputDecoration(labelText: 'Country'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),

              // Save button
              ElevatedButton(
                onPressed: addressProvider.state.isLoading
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          addressProvider.saveAddress(
                            addressLine1: _addressLine1Controller.text,
                            city: _cityController.text,
                            state: _stateController.text,
                            postalCode: _postalCodeController.text,
                            country: _countryController.text,
                            label: 'home',
                          );
                        }
                      },
                child: const Text('Save Address'),
              ),

              // Delete button (if address exists)
              if (addressProvider.state.savedAddress != null)
                ElevatedButton.icon(
                  onPressed: addressProvider.state.isLoading
                      ? null
                      : () {
                          addressProvider.deleteAddress(
                            id: addressProvider.state.savedAddress!.id,
                          );
                        },
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Example 3: Using context.read for one-off operations
class SaveAddressButtonExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Save address without rebuilding the entire widget
        context.read<AddressProvider>().saveAddress(
              addressLine1: 'Dhaka',
              city: 'Dhaka',
              state: 'Dhaka',
              postalCode: '12345',
              country: 'Bangladesh',
              label: 'home',
            );
      },
      child: const Text('Save My Address'),
    );
  }
}

/// Example 4: Accessing provider state with Consumer
class AddressDisplayExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AddressProvider>(
      builder: (context, addressProvider, child) {
        final savedAddress = addressProvider.state.savedAddress;

        if (savedAddress == null) {
          return const Text('No address saved');
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saved Address',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(savedAddress.addressLine1),
                if (savedAddress.addressLine2 != null)
                  Text(savedAddress.addressLine2!),
                Text('${savedAddress.city}, ${savedAddress.state}'),
                Text(
                  '${savedAddress.postalCode}, ${savedAddress.country}',
                ),
                const SizedBox(height: 8),
                Text(
                  'Label: ${savedAddress.label}',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Example 5: Custom error handling
class AddressFormWithErrorHandling extends StatefulWidget {
  @override
  State<AddressFormWithErrorHandling> createState() =>
      _AddressFormWithErrorHandlingState();
}

class _AddressFormWithErrorHandlingState
    extends State<AddressFormWithErrorHandling> {
  final _addressLine1Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _countryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<AddressProvider>(
      builder: (context, addressProvider, _) {
        return SingleChildScrollView(
          child: Column(
            children: [
              // Custom error dialog
              if (addressProvider.state.error != null)
                AlertDialog(
                  title: const Text('Error'),
                  content: Text(addressProvider.state.error!.message),
                  actions: [
                    TextButton(
                      onPressed: addressProvider.clearError,
                      child: const Text('OK'),
                    ),
                  ],
                ),

              // Custom success snackbar
              if (addressProvider.state.isSuccess &&
                  addressProvider.state.savedAddress != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    color: Colors.green.shade100,
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Address saved! ID: ${addressProvider.state.savedAddress!.id}',
                    ),
                  ),
                ),

              // Form fields
              TextField(
                controller: _addressLine1Controller,
                decoration: const InputDecoration(
                  labelText: 'Address Line 1',
                ),
              ),
              TextField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'City'),
              ),
              TextField(
                controller: _stateController,
                decoration: const InputDecoration(labelText: 'State'),
              ),
              TextField(
                controller: _postalCodeController,
                decoration: const InputDecoration(labelText: 'Postal Code'),
              ),
              TextField(
                controller: _countryController,
                decoration: const InputDecoration(labelText: 'Country'),
              ),

              // Save button with custom logic
              ElevatedButton(
                onPressed: addressProvider.state.isLoading
                    ? null
                    : () async {
                        if (_addressLine1Controller.text.isEmpty ||
                            _cityController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please fill all required fields'),
                            ),
                          );
                          return;
                        }

                        await addressProvider.saveAddress(
                          addressLine1: _addressLine1Controller.text,
                          city: _cityController.text,
                          state: _stateController.text,
                          postalCode: _postalCodeController.text,
                          country: _countryController.text,
                          label: 'work',
                        );

                        if (addressProvider.state.isSuccess) {
                          _addressLine1Controller.clear();
                          _cityController.clear();
                          _stateController.clear();
                          _postalCodeController.clear();
                          _countryController.clear();
                        }
                      },
                child: addressProvider.state.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(),
                      )
                    : const Text('Save Address'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _addressLine1Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }
}

/// Main app showing all examples
void main() {
  runApp(const ExamplesApp());
}

class ExamplesApp extends StatelessWidget {
  const ExamplesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ExamplesHomePage(),
    );
  }
}

class ExamplesHomePage extends StatelessWidget {
  const ExamplesHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Address Feature Examples'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Example 1: Navigate to Address Page',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          NavigateToAddressPageExample(),
          const Divider(height: 32),
          const Text(
            'Example 2: Save Address Button',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SaveAddressButtonExample(),
          const Divider(height: 32),
          const Text(
            'Example 3: Address Display',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          AddressDisplayExample(),
        ],
      ),
    );
  }
}
