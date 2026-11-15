import '../models/official_menu_catalog.dart';

class MenuRepository {
  const MenuRepository();

  /// Sumber data sementara dari katalog lokal.
  /// Nantinya diganti dengan API backend utama TAPJAYA.
  Future<List<Map<String, String>>> getProducts() async {
    return OfficialMenuCatalog.referenceProducts
        .map((product) => Map<String, String>.from(product))
        .toList();
  }
}
