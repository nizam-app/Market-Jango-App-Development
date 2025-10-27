import 'package:flutter/material.dart';

class GlobalPagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  const GlobalPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    int startPage = ((currentPage - 1) ~/ 6) * 6 + 1;
    int endPage = (startPage + 4).clamp(1, totalPages);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _pageButton(
          icon: Icons.chevron_left,
          enabled: startPage > 1,
          onPressed: () => onPageChanged(startPage - 1),
        ),
        ...List.generate(endPage - startPage + 1, (index) {
          int page = startPage + index;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () => onPageChanged(page),
              child: Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: page == currentPage ? Colors.orange : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  '$page',
                  style: TextStyle(
                    color: page == currentPage ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }),
        _pageButton(
          icon: Icons.chevron_right,
          enabled: endPage < totalPages,
          onPressed: () => onPageChanged(endPage + 1),
        ),
      ],
    );
  }

  Widget _pageButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Icon(
            icon,
            color: enabled ? Colors.black : Colors.grey.shade400,
            size: 20,
          ),
        ),
      ),
    );
  }
}