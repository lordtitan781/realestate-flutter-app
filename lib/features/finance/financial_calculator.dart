import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class FinancialCalculator extends StatefulWidget {
  const FinancialCalculator({Key? key}) : super(key: key);

  @override
  _FinancialCalculatorState createState() => _FinancialCalculatorState();
}

class _FinancialCalculatorState extends State<FinancialCalculator> {
  final _investmentCtrl = TextEditingController();
  final _finalValueCtrl = TextEditingController();
  String _roi = '';
  Map<String, double>? _scenarios;
  String _irr = '';
  bool _loading = false;

  @override
  void dispose() {
    _investmentCtrl.dispose();
    _finalValueCtrl.dispose();
    super.dispose();
  }

  Future<void> _calculate() async {
    setState(() => _loading = true);
    try {
      final investment = double.tryParse(_investmentCtrl.text) ?? 0.0;
      final finalValue = double.tryParse(_finalValueCtrl.text) ?? 0.0;
      final roi = await ApiService.calculateROI(investment, finalValue);
      final scenarios = await ApiService.getScenarioROI(investment);

      // Example IRR calculation using sample annual cashflows derived from investment/final
      // This is just a demo: convert simple yearly returns into cashflows
      final yearly = ((finalValue - investment) / 5.0);
      final flows = <double>[-investment];
      for (int i = 0; i < 5; i++) flows.add(yearly);
      final irr = await ApiService.calculateIRR(flows);

      setState(() {
        _roi = '${roi.toStringAsFixed(2)} %';
        _scenarios = scenarios;
        _irr = irr.isNaN ? 'N/A' : '${irr.toStringAsFixed(2)} %';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Money Calculator')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _investmentCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Investment Amount'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _finalValueCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Final Value (after periods)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _calculate,
              child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Calculate'),
            ),
            const SizedBox(height: 16),
            if (_roi.isNotEmpty) ...[
              Text('ROI: $_roi', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 12),
            ],
            if (_scenarios != null) ...[
              const Text('Scenarios:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              for (final entry in _scenarios!.entries)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text('${entry.key}: ${entry.value.toStringAsFixed(2)} %'),
                ),
              const SizedBox(height: 12),
            ],
            if (_irr.isNotEmpty) Text('Estimated IRR: $_irr', style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
