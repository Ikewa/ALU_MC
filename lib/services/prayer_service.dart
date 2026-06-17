import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';

class PrayerService {

  // Now we ask: "Give me the coordinates" instead of hardcoding them
  List<Map<String, String>> getPrayerTimes(double lat, double long) {

    final myCoordinates = Coordinates(lat, long);

    // Auto-detect the best calculation method for the location
    // (e.g., uses different math if you are in Europe vs Africa)
    final params = CalculationMethod.muslim_world_league.getParameters();
    params.madhab = Madhab.shafi;

    final prayerTimes = PrayerTimes.today(myCoordinates, params);

    return [
      {'name': 'Fajr', 'time': DateFormat.jm().format(prayerTimes.fajr)},
      {'name': 'Dhuhr', 'time': DateFormat.jm().format(prayerTimes.dhuhr)},
      {'name': 'Asr', 'time': DateFormat.jm().format(prayerTimes.asr)},
      {'name': 'Maghrib', 'time': DateFormat.jm().format(prayerTimes.maghrib)},
      {'name': 'Isha', 'time': DateFormat.jm().format(prayerTimes.isha)},
    ];
  }
}