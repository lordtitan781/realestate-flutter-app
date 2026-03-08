import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realestate/shared/widgets/summary_card.dart';
import '../../shared/app_state.dart';
import 'explore_screen.dart';
import 'portfolio_screen.dart';
import '../finance/financial_calculator.dart';

class InvestorDashboard extends StatelessWidget {
  const InvestorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final portfolio = appState.investorPortfolio;
        final totalInvested = portfolio.fold<double>(
            0, (prev, p) => prev + p.capitalRequired * p.capitalRaised);
        final activeCount = portfolio.length;
        final avgIrr = activeCount == 0
            ? 0
            : portfolio.fold<double>(0, (p, t) => p + t.irr) / activeCount;
        final nextMilestone = activeCount > 0 ? portfolio.first.stage : 'N/A';

        if (appState.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome back,",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    "Investor Dashboard",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 32),
                  // Quick action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExploreScreen())),
                          icon: const Icon(Icons.explore),
                          label: const Text('Explore Projects'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PortfolioScreen())),
                          icon: const Icon(Icons.pie_chart),
                          label: const Text('My Portfolio'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FinancialCalculator())),
                      icon: const Icon(Icons.calculate),
                      label: const Text('Smart Money Calculator'),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      SummaryCard(
                        title: "Total Invested",
                        value: "₹${totalInvested.toStringAsFixed(1)}L",
                        icon: Icons.account_balance_wallet_outlined,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 16),
                      SummaryCard(
                        title: "Active Projects",
                        value: "$activeCount",
                        icon: Icons.assignment_outlined,
                        color: Colors.orange.shade700,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      SummaryCard(
                        title: "Avg IRR",
                        value: "${avgIrr.toStringAsFixed(1)}%",
                        icon: Icons.trending_up,
                        color: Colors.green.shade700,
                      ),
                      const SizedBox(width: 16),
                      SummaryCard(
                        title: "Next Stage",
                        value: nextMilestone,
                        icon: Icons.flag_outlined,
                        color: Colors.purple.shade700,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Theme.of(context).colorScheme.primary, Color(0xFF3949AB)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Investment Insights",
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "The tourism sector is seeing a 12% growth this quarter. Check out new opportunities in the Explore tab.",
                          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
