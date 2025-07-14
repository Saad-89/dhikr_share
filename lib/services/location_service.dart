import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;

class LocationService {
  static Future<bool> requestLocationPermission() async {
    try {
      // For iOS, we need to be more specific about the permission type
      Permission permission = Platform.isIOS 
          ? Permission.locationWhenInUse 
          : Permission.location;
      
      final status = await permission.request();
      
      // Handle iOS specific permission statuses
      if (Platform.isIOS && status.isGranted) {
        // Check if location services are enabled
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          return false;
        }
      }
      
      return status.isGranted;
    } catch (e) {
      print('Error requesting location permission: $e');
      return false;
    }
  }

  static Future<bool> hasLocationPermission() async {
    try {
      Permission permission = Platform.isIOS 
          ? Permission.locationWhenInUse 
          : Permission.location;
      
      final status = await permission.status;
      return status.isGranted;
    } catch (e) {
      print('Error checking location permission: $e');
      return false;
    }
  }

  static Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) return null;

      // For iOS, use higher accuracy and longer timeout
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: Platform.isIOS 
            ? LocationAccuracy.best 
            : LocationAccuracy.high,
        timeLimit: Duration(seconds: Platform.isIOS ? 15 : 10),
      );
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  static Future<String?> getCityFromPosition(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        // Try different fields for city name
        return place.locality ?? 
               place.subAdministrativeArea ?? 
               place.administrativeArea ?? 
               place.subLocality;
      }
    } catch (e) {
      print('Error getting city name: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> getLocationInfo() async {
    try {
      final position = await getCurrentPosition();
      if (position == null) return null;

      final city = await getCityFromPosition(position);

      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'city': city ?? 'Unknown',
        'accuracy': position.accuracy,
        'timestamp': position.timestamp,
      };
    } catch (e) {
      print('Error getting location info: $e');
      return null;
    }
  }
}
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:permission_handler/permission_handler.dart';

// class LocationService {
//   static Future<bool> requestLocationPermission() async {
//     final status = await Permission.location.request();
//     return status.isGranted;
//   }

//   static Future<Position?> getCurrentPosition() async {
//     try {
//       final hasPermission = await requestLocationPermission();
//       if (!hasPermission) return null;

//       return await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//         timeLimit: Duration(seconds: 10),
//       );
//     } catch (e) {
//       print('Error getting location: $e');
//       return null;
//     }
//   }

//   static Future<String?> getCityFromPosition(Position position) async {
//     try {
//       List<Placemark> placemarks = await placemarkFromCoordinates(
//         position.latitude,
//         position.longitude,
//       );

//       if (placemarks.isNotEmpty) {
//         return placemarks.first.locality ?? placemarks.first.administrativeArea;
//       }
//     } catch (e) {
//       print('Error getting city name: $e');
//     }
//     return null;
//   }

//   static Future<Map<String, dynamic>?> getLocationInfo() async {
//     final position = await getCurrentPosition();
//     if (position == null) return null;

//     final city = await getCityFromPosition(position);

//     return {
//       'latitude': position.latitude,
//       'longitude': position.longitude,
//       'city': city ?? 'Unknown',
//     };
//   }
// }
