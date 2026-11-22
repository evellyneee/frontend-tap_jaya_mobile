
import '../../menu/models/official_menu_catalog.dart';

class MenuRecommendation {
  final OfficialProduct product;
  final double score;
  final String reason;

  const MenuRecommendation({
    required this.product,
    required this.score,
    required this.reason,
  });
}