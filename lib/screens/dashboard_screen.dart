import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int totalProduits = 0;
  double totalAchats = 0.0;
  double totalVentes = 0.0;
  double benefices = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      print('Token: $token');

      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/dashboard'), // Remplace par l'IP si appareil physique
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('Dashboard response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Parsed data: $data');
        setState(() {
          totalProduits = data['total_produits'] ?? 0;
          totalAchats = (data['total_achats'] ?? 0).toDouble();
          totalVentes = (data['total_ventes'] ?? 0).toDouble();
          benefices = (data['benefices'] ?? 0).toDouble();
          _isLoading = false;
        });
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('Dashboard error: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des données : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tableau de bord'),
        backgroundColor: Color(0xFFF28C38),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFFF28C38)))
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatCard('Total Produits', totalProduits.toString(), Icons.inventory),
                  _buildStatCard('Total Achats', '${totalAchats.toStringAsFixed(2)} MAD', Icons.shopping_cart),
                  _buildStatCard('Total Ventes', '${totalVentes.toStringAsFixed(2)} MAD', Icons.attach_money),
                  _buildStatCard('Bénéfices', '${benefices.toStringAsFixed(2)} MAD', Icons.trending_up),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon, color: Color(0xFFF28C38), size: 40),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value, style: TextStyle(fontSize: 18)),
      ),
    );
  }
}