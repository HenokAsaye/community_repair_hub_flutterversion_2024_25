import 'package:flutter/material.dart';

enum IssueStatus { all, pending, completed, untracked }

class DashboardFilter extends StatefulWidget {
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<IssueStatus> onStatusChanged;
  final String searchQuery;
  final IssueStatus selectedStatus;
  
  const DashboardFilter({
    Key? key,
    required this.onSearchChanged,
    required this.onStatusChanged,
    required this.searchQuery,
    required this.selectedStatus,
  }) : super(key: key);

  @override
  _DashboardFilterState createState() => _DashboardFilterState();

  static String getStatusText(IssueStatus status) {
    switch (status) {
      case IssueStatus.all:
        return 'All Issues';
      case IssueStatus.pending:
        return 'Pending';
      case IssueStatus.completed:
        return 'Completed';
      case IssueStatus.untracked:
        return 'Untracked';
      // default:
      //   return 'Unknown';
    }
  }
}

class _DashboardFilterState extends State<DashboardFilter> {
  final TextEditingController _searchController = TextEditingController();
  late IssueStatus _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.selectedStatus;
    _searchController.text = widget.searchQuery;
  }

  @override
  void didUpdateWidget(DashboardFilter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedStatus != _selectedStatus) {
      setState(() {
        _selectedStatus = widget.selectedStatus;
      });
    }
    if (widget.searchQuery != _searchController.text) {
      _searchController.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showFilterDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _FilterDialog(
        initialStatus: _selectedStatus,
        initialQuery: _searchController.text,
      ),
    );

    if (result != null) {
      final newStatus = result['status'] as IssueStatus;
      final newQuery = result['query'] as String;
      
      if (newStatus != _selectedStatus) {
        setState(() => _selectedStatus = newStatus);
        widget.onStatusChanged(newStatus);
      }
      
      if (newQuery != _searchController.text) {
        _searchController.text = newQuery;
        widget.onSearchChanged(newQuery);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // Search Bar
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search issues...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                suffixIcon: _selectedStatus != IssueStatus.all
                    ? IconButton(
                        icon: Icon(Icons.filter_alt, color: Theme.of(context).primaryColor),
                        onPressed: _showFilterDialog,
                      )
                    : null,
              ),
              onChanged: widget.onSearchChanged,
            ),
          ),
          const SizedBox(width: 8.0),
          // Filter Button
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: IconButton(
              icon: Icon(
                Icons.filter_alt,
                color: _selectedStatus != IssueStatus.all 
                    ? Theme.of(context).primaryColor 
                    : null,
              ),
              onPressed: _showFilterDialog,
              tooltip: 'Filter',
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterDialog extends StatefulWidget {
  final IssueStatus initialStatus;
  final String initialQuery;

  const _FilterDialog({
    Key? key,
    required this.initialStatus,
    required this.initialQuery,
  }) : super(key: key);

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  late IssueStatus _selectedStatus;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.initialStatus;
    _searchController.text = widget.initialQuery;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter Issues'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
            ...IssueStatus.values.map((status) {
              return RadioListTile<IssueStatus>(
                title: Text(DashboardFilter.getStatusText(status)),
                value: status,
                groupValue: _selectedStatus,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedStatus = value);
                  }
                },
                contentPadding: EdgeInsets.zero,
                dense: true,
              );
            }).toList(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, {
              'status': _selectedStatus,
              'query': _searchController.text,
            });
          },
          child: const Text('APPLY'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}