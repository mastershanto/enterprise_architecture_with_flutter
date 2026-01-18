import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../bloc/address_state.dart';

class AddressPage extends StatefulWidget {
  const AddressPage({super.key});

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  late TextEditingController _addressLine1Controller;
  late TextEditingController _addressLine2Controller;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _postalCodeController;
  late TextEditingController _countryController;
  late TextEditingController _labelController;

  @override
  void initState() {
    super.initState();
    _addressLine1Controller = TextEditingController();
    _addressLine2Controller = TextEditingController();
    _cityController = TextEditingController();
    _stateController = TextEditingController();
    _postalCodeController = TextEditingController();
    _countryController = TextEditingController();
    _labelController = TextEditingController(text: 'home');
  }

  @override
  void dispose() {
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  void _saveAddress(BuildContext context) {
    final addressProvider = context.read<AddressProvider>();

    addressProvider.saveAddress(
      addressLine1: _addressLine1Controller.text,
      addressLine2: _addressLine2Controller.text.isEmpty
          ? null
          : _addressLine2Controller.text,
      city: _cityController.text,
      state: _stateController.text,
      postalCode: _postalCodeController.text,
      country: _countryController.text,
      label: _labelController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Save Address'),
      ),
      body: Consumer<AddressProvider>(
        builder: (context, addressProvider, child) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (addressProvider.state.error != null)
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        margin: const EdgeInsets.only(bottom: 16.0),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          border: Border.all(color: Colors.red),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Error',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(color: Colors.red),
                            ),
                            const SizedBox(height: 8),
                            Text(addressProvider.state.error!.message),
                          ],
                        ),
                      ),
                    if (addressProvider.state.isSuccess &&
                        addressProvider.state.savedAddress != null)
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        margin: const EdgeInsets.only(bottom: 16.0),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          border: Border.all(color: Colors.green),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Address Saved Successfully',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(color: Colors.green),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'ID: ${addressProvider.state.savedAddress!.id}',
                            ),
                            Text(
                              addressProvider.state.savedAddress!.addressLine1,
                            ),
                            Text(
                              '${addressProvider.state.savedAddress!.city}, ${addressProvider.state.savedAddress!.state}',
                            ),
                          ],
                        ),
                      ),
                    TextField(
                      controller: _addressLine1Controller,
                      decoration: InputDecoration(
                        labelText: 'Address Line 1 *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _addressLine2Controller,
                      decoration: InputDecoration(
                        labelText: 'Address Line 2',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _cityController,
                      decoration: InputDecoration(
                        labelText: 'City *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _stateController,
                      decoration: InputDecoration(
                        labelText: 'State *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _postalCodeController,
                      decoration: InputDecoration(
                        labelText: 'Postal Code *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _countryController,
                      decoration: InputDecoration(
                        labelText: 'Country *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _labelController,
                      decoration: InputDecoration(
                        labelText: 'Label (home, work, etc.) *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: addressProvider.state.isLoading
                          ? null
                          : () => _saveAddress(context),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: addressProvider.state.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Save Address'),
                      ),
                    ),
                    if (addressProvider.state.savedAddress != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: ElevatedButton.icon(
                          onPressed: addressProvider.state.isLoading
                              ? null
                              : () {
                                  addressProvider.deleteAddress(
                                    id: addressProvider
                                        .state.savedAddress!.id,
                                  );
                                },
                          icon: const Icon(Icons.delete),
                          label: const Text('Delete Address'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
