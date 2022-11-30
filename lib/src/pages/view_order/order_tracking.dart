import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../config/firebase/auth.dart';
import '../../core/utils/app_secrets.skeleton.dart';
import '../../widgets/atoms/loader.dart';
import '../../widgets/molecules/header.dart';
import 'location_picker_function.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class OrderTrackingMap extends StatefulWidget {
  final Map<String, dynamic> loc;
  final String consumerdocid;
  const OrderTrackingMap(
      {Key? key, required this.loc, required this.consumerdocid})
      : super(key: key);

  @override
  State<OrderTrackingMap> createState() => _OrderTrackingMapState();
}

class _OrderTrackingMapState extends State<OrderTrackingMap> {
  UserLocationPicker userLocationPicker = UserLocationPicker();
  Set<Marker> markers = {};

  Set<Polyline> _polyline = {};
  List<LatLng> polylineCoordinates = [];

  late LatLng endLocation;
  List<LatLng> latLen = [];

  late GoogleMapController mapController;

  StreamSubscription<Position>? poistionSubsrc;

  Map<PolylineId, Polyline> polylines = {};

  PolylinePoints polylinePoints = PolylinePoints();

  @override
  void initState() {
    endLocation = LatLng(
      double.parse(widget.loc["lat"].toString()),
      double.parse(widget.loc["long"].toString()),
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(
        title: "Start Delivery Order",
        showMenu: false,
        showAction: false,
        onPressedLeading: () {},
        onPressedAction: () {},
      ),
      body: StreamBuilder<Position>(
        stream: userLocationPicker.poistionStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            //print(LatLng(snapshot.data!.latitude, snapshot.data!.longitude));
            //return Text(snapshot.data.toString());
            // _getPolyline(
            //     startLatLong:
            //         LatLng(snapshot.data!.latitude, snapshot.data!.longitude),
            //     endLatLong: endLocation);
            setMaker(
                startLocation:
                    LatLng(snapshot.data!.latitude, snapshot.data!.longitude),
                endLocation: endLocation);
            firebaseFirestore
                .collection(AppSecrets.consumerorder)
                .doc(widget.consumerdocid)
                .set({
              "delivery_boy": {
                "lat": snapshot.data!.latitude,
                "logn": snapshot.data!.latitude
              }
            });
            return GoogleMap(
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                buildingsEnabled: false,
                compassEnabled: false,
                polylines: _polyline,
                onMapCreated: (GoogleMapController controller) {
                  mapController = controller;
                },
                markers: markers,
                initialCameraPosition: CameraPosition(
                  target:
                      LatLng(snapshot.data!.latitude, snapshot.data!.longitude),
                  zoom: 16,
                ),
                onTap: (LatLng) {});
          }
          return const Center(
            child: Loader(),
          );
        },
      ),
    );
  }

  setMaker({required LatLng startLocation, required LatLng endLocation}) async {
    latLen = [startLocation, endLocation];
    markers.addAll(
      {
        Marker(
          markerId: MarkerId(startLocation.toString()),
          position: startLocation,
          infoWindow: const InfoWindow(
            title: 'Delivery Boy',
            snippet: 'Order On the way',
          ),
          icon: BitmapDescriptor.defaultMarker,
        ),
        Marker(
          markerId: MarkerId(endLocation.toString()),
          position: endLocation,
          infoWindow: const InfoWindow(
            title: 'Destination',
            snippet: 'User location',
          ),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      },
    );

    for (int i = 0; i < latLen.length; i++) {
      _polyline.add(
        Polyline(
          polylineId: const PolylineId('1'),
          points: latLen,
          width: 5,
          color: Colors.green,
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  _getPolyline(
      {required LatLng startLatLong, required LatLng endLatLong}) async {
    print("value");
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        AppSecrets.mapkey,
        PointLatLng(startLatLong.latitude, startLatLong.longitude),
        PointLatLng(endLatLong.latitude, endLatLong.longitude),
        travelMode: TravelMode.driving,
        wayPoints: [PolylineWayPoint(location: "Sabo, Yaba Lagos Nigeria")]);
    // print(result.errorMessage);
    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }
    _addPolyLine();
  }

  _addPolyLine() {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id, color: Colors.red, points: polylineCoordinates);
    polylines[id] = polyline;
  }
}
