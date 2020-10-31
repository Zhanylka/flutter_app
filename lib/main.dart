import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

import 'package:location/location.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps Demo',
      home: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  Location location = Location();

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  Completer<GoogleMapController> _controller = Completer();
  LatLng lastLatLngCoordinate;
  int id = 0;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: GoogleMap(
        markers: _markers,
        polylines: _polylines,
        mapType: MapType.normal,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
          location.onLocationChanged.listen((LocationData currentLocation) {
            LatLng latLng =
                LatLng(currentLocation.latitude, currentLocation.longitude);
            getPosition(latLng);
          });
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToTheLake,
        label: Text('To the lake!'),
        icon: Icon(Icons.directions_boat),
      ),
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }

  getPosition(LatLng latLng) async {
    final GoogleMapController controller = await _controller.future;
    CameraPosition position = CameraPosition(
        bearing: 192.8334901395799,
        target: latLng,
        tilt: 59.440717697143555,
        zoom: 19.151926040649414);
    setState(() {
      _markers.add(
          Marker(markerId: MarkerId(id.toString()), position: latLng));
      id++;

      if (lastLatLngCoordinate != null) {
        _polylines.add(Polyline(
            polylineId: PolylineId(id.toString()),
            points: [lastLatLngCoordinate, latLng]));
      }
      lastLatLngCoordinate = latLng;
    });

    controller.animateCamera(CameraUpdate.newCameraPosition(position));
  }
}
