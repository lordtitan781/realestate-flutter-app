import 'package:flutter/material.dart';
import '../../models/destination.dart';
import '../../services/api_service.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  List<Destination> _destinations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ApiService.getDestinations();
      setState(() => _destinations = res);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load destinations: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explore Destinations')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _destinations.length,
              itemBuilder: (context, i) {
                final d = _destinations[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: ListTile(
                    title: Text(d.name),
                    subtitle: Text('Tourists: ${d.touristsPerYear}, Occupancy: ${d.hotelOccupancy}%, Growth: ${d.growthRate}%'),
                    trailing: Icon(Icons.trending_up, color: d.growthRate >= 6 ? Colors.green : Colors.orange),
                  ),
                );
              },
            ),
    );
  }
}
