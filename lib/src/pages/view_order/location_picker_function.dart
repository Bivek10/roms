import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_skeleton/src/injector.dart';
import 'package:geolocator/geolocator.dart';

class UserLocationPicker extends LocationPickerImpl {
  LocationSettings locationSettings = AndroidSettings(
    accuracy: LocationAccuracy.high,
    // distanceFilter: 100,
    // forceLocationManager: true,
    intervalDuration: const Duration(seconds: 10),
    //(Optional) Set foreground notification config to keep the app alive
    //when going to the background
    // foregroundNotificationConfig: const ForegroundNotificationConfig(
    //   notificationText:
    //       "Example app will continue to receive your location even when you aren't using it",
    //   notificationTitle: "Running in Background",
    //   enableWakeLock: true,
  );
  @override
  Future<bool> checkLocationPermission({required BuildContext context}) async {
    bool isLocationEnable =
        await permissionHandler.handleLocationPermission(context);
    return isLocationEnable;
  }

  @override
  Future<bool> getCurrentLocation() async {
    LocationPermission permission;
    bool isEnable = false;
    //late Future<Position> currentpoistion;
    permission = await Geolocator.checkPermission();
    //print(permission.name);
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      isEnable = true;
      // currentpoistion = Geolocator.getCurrentPosition(
      //   desiredAccuracy: LocationAccuracy.high,
      // );
    } else {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        isEnable = true;
        // currentpoistion = Geolocator.getCurrentPosition(
        //   desiredAccuracy: LocationAccuracy.high,
        // );
      }
    }

    return isEnable;
  }

  Stream<Position> poistionStream() {
    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }
}

abstract class LocationPickerImpl {
  void checkLocationPermission({required BuildContext context});
  Future<bool> getCurrentLocation();
}
