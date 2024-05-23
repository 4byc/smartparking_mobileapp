import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ParkingDataPage extends StatefulWidget {
  const ParkingDataPage({super.key});

  @override
  _ParkingDataPageState createState() => _ParkingDataPageState();
}

class _ParkingDataPageState extends State<ParkingDataPage> {
  late Future<List<Map<String, dynamic>>> _parkingData;

  @override
  void initState() {
    super.initState();
    _parkingData = _fetchParkingData();
  }

  Future<List<Map<String, dynamic>>> _fetchParkingData() async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('detections').get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error fetching parking data: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parking Data'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _parkingData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No parking data found.'));
          } else {
            final parkingData = snapshot.data!;
            return ListView.builder(
              itemCount: parkingData.length,
              itemBuilder: (context, index) {
                final data = parkingData[index];
                return ListTile(
                  title: Text('Vehicle ID: ${data['vehicleId']}'),
                  subtitle: Text(
                    'Class: ${data['class']}\nEntry Time: ${DateTime.fromMillisecondsSinceEpoch(data['entryTime'] * 1000)}',
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
