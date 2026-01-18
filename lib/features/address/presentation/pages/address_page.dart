import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/bloc/auth_state.dart';
import '../../data/datasources/address_remote_datasource.dart';
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
  int? _selectedTab = 0;

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

    // Load addresses on init with auth token
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final token = authProvider.user?.token;

      // Set auth token in datasource
      final addressProvider = context.read<AddressProvider>();
      // Note: This requires accessing the datasource through repository
      // For now, call getAddresses - it will use the auth token
      addressProvider.getAddresses();
    });
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

  void _clearForm() {
    _addressLine1Controller.clear();
    _addressLine2Controller.clear();
    _cityController.clear();
    _stateController.clear();
    _postalCodeController.clear();
    _countryController.clear();
    _labelController.text = 'home';
  }

  void _saveAddress(BuildContext context) {
    final addressProvider = context.read<AddressProvider>();

    if (_addressLine1Controller.text.isEmpty || _cityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

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

    _clearForm();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Addresses'), elevation: 0),
      body: Consumer<AddressProvider>(
        builder: (context, addressProvider, child) {
          return Column(
            children: [
              // Tab Navigation
              Container(
                color: Colors.grey.shade100,
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTabButton(
                        context,
                        'Addresses (${addressProvider.state.addresses.length})',
                        0,
                        addressProvider,
                      ),
                    ),
                    Expanded(
                      child: _buildTabButton(
                        context,
                        'Add New',
                        1,
                        addressProvider,
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: _selectedTab == 0
                    ? _buildAddressList(addressProvider)
                    : _buildAddressForm(context, addressProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabButton(
    BuildContext context,
    String label,
    int tabIndex,
    AddressProvider provider,
  ) {
    final isSelected = _selectedTab == tabIndex;
    return Material(
      color: isSelected ? Colors.white : Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() => _selectedTab = tabIndex);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Colors.deepPurple : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.deepPurple : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddressList(AddressProvider provider) {
    if (provider.state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Error: ${provider.state.error!.message}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => provider.getAddresses(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (provider.state.addresses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'No addresses saved',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => setState(() => _selectedTab = 1),
              icon: const Icon(Icons.add),
              label: const Text('Add Address'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.getAddresses(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: provider.state.addresses.length,
        itemBuilder: (context, index) {
          final address = provider.state.addresses[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12.0),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16.0),
              title: Text(
                address.label.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(address.addressLine1),
                  if (address.addressLine2 != null) Text(address.addressLine2!),
                  const SizedBox(height: 4),
                  Text(
                    '${address.city}, ${address.state} ${address.postalCode}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    address.country,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              trailing: SizedBox(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        _showEditDialog(context, address, provider);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _showDeleteDialog(context, address.id, provider);
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddressForm(BuildContext context, AddressProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (provider.state.error != null)
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
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.red),
                  ),
                  const SizedBox(height: 8),
                  Text(provider.state.error!.message),
                ],
              ),
            ),
          if (provider.state.isSuccess && provider.state.savedAddress != null)
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
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.green),
                  ),
                  const SizedBox(height: 8),
                  Text('ID: ${provider.state.savedAddress!.id}'),
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
              prefixIcon: const Icon(Icons.location_on),
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
          ElevatedButton.icon(
            onPressed: provider.state.isLoading
                ? null
                : () => _saveAddress(context),
            icon: provider.state.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: const Text('Save Address'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    int addressId,
    AddressProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Address'),
        content: const Text('Are you sure you want to delete this address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteAddress(id: addressId);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    dynamic address,
    AddressProvider provider,
  ) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Edit feature coming soon')));
  }
}
