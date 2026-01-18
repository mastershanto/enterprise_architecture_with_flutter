import '../models/address_model.dart';

abstract class AddressLocalDataSource {
  Future<void> cacheAddress(AddressModel address);
  Future<void> deleteAddressCache(int id);
  Future<AddressModel?> getAddressByIdFromCache(int id);
}

class AddressLocalDataSourceInMemory implements AddressLocalDataSource {
  final Map<int, AddressModel> _cache = {};

  @override
  Future<void> cacheAddress(AddressModel address) async {
    _cache[address.id] = address;
  }

  @override
  Future<void> deleteAddressCache(int id) async {
    _cache.remove(id);
  }

  @override
  Future<AddressModel?> getAddressByIdFromCache(int id) async {
    return _cache[id];
  }
}
