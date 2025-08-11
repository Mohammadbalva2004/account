import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SummaryCards extends StatelessWidget {
  final double income;
  final double expense;
  final double balance;
  final String Function(double) currency;
  final bool isCompact;

  const SummaryCards({
    super.key,
    required this.income,
    required this.expense,
    required this.balance,
    required this.currency,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Responsive layout: stack on mobile, row on tablet/desktop
    if (isCompact) {
      return Column(
        children: [
          _buildCard(
            context,
            'Total Income',
            currency(income),
            Icons.trending_up,
            Colors.green,
            isCompact: true,
          ),
          const SizedBox(height: 8),
          _buildCard(
            context,
            'Total Expense',
            currency(expense),
            Icons.trending_down,
            Colors.red,
            isCompact: true,
          ),
          const SizedBox(height: 8),
          _buildCard(
            context,
            'Balance',
            currency(balance),
            balance >= 0 ? Icons.account_balance_wallet : Icons.warning,
            balance >= 0 ? Colors.blue : Colors.orange,
            isCompact: true,
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _buildCard(
            context,
            'Total Income',
            currency(income),
            Icons.trending_up,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildCard(
            context,
            'Total Expense',
            currency(expense),
            Icons.trending_down,
            Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildCard(
            context,
            'Balance',
            currency(balance),
            balance >= 0 ? Icons.account_balance_wallet : Icons.warning,
            balance >= 0 ? Colors.blue : Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildCard(
      BuildContext context,
      String title,
      String amount,
      IconData icon,
      Color color, {
        bool isCompact = false,
      }) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(isCompact ? 12.0 : 16.0),
        child: isCompact
            ? Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    amount,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              amount,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
