import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class FilterBar extends StatefulWidget {
  final String type;
  final ValueChanged<String> onTypeChanged;
  final DateTimeRange? range;
  final ValueChanged<DateTimeRange?> onPickRange;
  final VoidCallback onClearRange;
  final ValueChanged<String> onSearch;
  final bool isCompact;

  const FilterBar({
    super.key,
    required this.type,
    required this.onTypeChanged,
    required this.range,
    required this.onPickRange,
    required this.onClearRange,
    required this.onSearch,
    this.isCompact = false,
  });

  @override
  State<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (widget.isCompact) {
      return Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search transactions...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: widget.onSearch,
          ),
          const SizedBox(height: 12),
          // Type filter chips
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  children: [
                    _buildFilterChip('all', 'All'),
                    _buildFilterChip('income', 'Income'),
                    _buildFilterChip('expense', 'Expense'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Date range
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickDateRange,
                  icon: const Icon(Icons.date_range, size: 18),
                  label: Text(
                    widget.range == null
                        ? 'Select Date Range'
                        : '${DateFormat('MMM d').format(widget.range!.start)} - ${DateFormat('MMM d').format(widget.range!.end)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
              if (widget.range != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: widget.onClearRange,
                  icon: const Icon(Icons.clear, size: 18),
                  tooltip: 'Clear date range',
                ),
              ],
            ],
          ),
        ],
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Search
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search transactions...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: widget.onSearch,
                  ),
                ),
                const SizedBox(width: 16),
                // Date range
                OutlinedButton.icon(
                  onPressed: _pickDateRange,
                  icon: const Icon(Icons.date_range, size: 18),
                  label: Text(
                    widget.range == null
                        ? 'Date Range'
                        : '${DateFormat('MMM d').format(widget.range!.start)} - ${DateFormat('MMM d').format(widget.range!.end)}',
                  ),
                ),
                if (widget.range != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: widget.onClearRange,
                    icon: const Icon(Icons.clear),
                    tooltip: 'Clear date range',
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Filter by type:',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildFilterChip('all', 'All'),
                    _buildFilterChip('income', 'Income'),
                    _buildFilterChip('expense', 'Expense'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = widget.type == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => widget.onTypeChanged(value),
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }

  Future<void> _pickDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: widget.range,
    );
    if (range != null) {
      widget.onPickRange(range);
    }
  }
}
