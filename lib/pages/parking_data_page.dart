import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ParkingDataPage extends StatefulWidget {
  const ParkingDataPage({super.key});

  @override
  _ParkingDataPageState createState() => _ParkingDataPageState();
}

class _ParkingDataPageState extends State<ParkingDataPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? latestData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLatestParkingData();
  }

  Future<void> _fetchLatestParkingData() async {
    try {
      final snapshot = await _firestore
          .collection('detections')
          .orderBy('time', descending: true)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          latestData = snapshot.docs.first.data();
          isLoading = false;
        });
      } else {
        setState(() {
          latestData = null;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching parking data: $e');
      setState(() {
        latestData = null;
        isLoading = false;
      });
    }
  }

  Future<void> _markVehicleAsParked(String vehicleId) async {
    // Add your logic here to mark the vehicle as parked, e.g., update the Firestore document
    await _firestore.collection('detections').doc(vehicleId).update({
      'status': 'parked',
    });
    // Fetch the next latest parking data
    _fetchLatestParkingData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parking Data'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : latestData == null
              ? const Center(child: Text('No parking data found.'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text('Vehicle ID: ${latestData!['VehicleID']}'),
                        subtitle: Text(
                          'Class: ${latestData!['class']} \nEntry Time: ${DateTime.fromMillisecondsSinceEpoch((latestData!['time'] * 1000).toInt())}',
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            _markVehicleAsParked(latestData!['VehicleID']),
                        child: const Text('Mark as Parked'),
                      ),
                    ],
                  ),
                ),
    );
  }
}
