import '../core/widgets/hotel_card.dart';

class MapService {
  List<UiHotel> sortNearby() {
    final sorted = [...hotels]
      ..sort((a, b) => a.distance.compareTo(b.distance));
    return sorted;
  }
}
