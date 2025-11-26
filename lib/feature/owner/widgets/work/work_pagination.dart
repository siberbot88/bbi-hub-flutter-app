import 'package:flutter/material.dart';

class WorkPagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final bool loading;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const WorkPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.loading,
    this.onPrev,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: currentPage > 1 && !loading ? onPrev : null,
            child: const Text('Prev'),
          ),
          const SizedBox(width: 16),
          Text('Page $currentPage of $totalPages',
              style: const TextStyle(color: Colors.white)),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: currentPage < totalPages && !loading ? onNext : null,
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }
}
