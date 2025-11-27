import 'dart:math';
import 'package:flutter/material.dart';
import 'package:bengkel_online_flutter/core/models/employment.dart';
import 'package:bengkel_online_flutter/core/theme/app_colors.dart';
import 'package:bengkel_online_flutter/core/theme/app_text_styles.dart';
import 'staff_helpers.dart';

class StaffTable extends StatefulWidget {
  const StaffTable({
    super.key,
    required this.rows,
    required this.headerController,
    required this.bodyHController,
    required this.bodyVController,
    required this.onToggleActive,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Employment> rows;
  final ScrollController headerController;
  final ScrollController bodyHController;
  final ScrollController bodyVController;
  final Future<void> Function(Employment, bool) onToggleActive;
  final Future<void> Function(Employment) onEdit;
  final Future<void> Function(Employment) onDelete;

  @override
  State<StaffTable> createState() => _StaffTableState();
}

class _StaffTableState extends State<StaffTable> with SingleTickerProviderStateMixin {
  int _currentPage = 1;
  static const int _itemsPerPage = 8;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  List<Employment> get _paginatedRows {
    final start = (_currentPage - 1) * _itemsPerPage;
    final end = min(start + _itemsPerPage, widget.rows.length);
    return widget.rows.sublist(start, end);
  }

  int get _totalPages => (widget.rows.length / _itemsPerPage).ceil();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isSmall = width < 600;

    return Material(
      elevation: 2,
      shadowColor: AppColors.shadow,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withAlpha(100)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  if (!isSmall) ...[
                    const SizedBox(width: 48), // Avatar space
                    Expanded(
                      flex: 3,
                      child: _HeaderText('Name'),
                    ),
                    Expanded(
                      flex: 2,
                      child: _HeaderText('Position'),
                    ),
                  ] else
                    Expanded(
                      child: _HeaderText('Staff'),
                    ),
                  SizedBox(
                    width: 100,
                    child: _HeaderText('Status'),
                  ),
                  const SizedBox(width: 48), // Actions
                ],
              ),
            ),
            const Divider(height: 1),

            // Body
            AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _paginatedRows.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    return _buildAnimatedRow(index, _paginatedRows[index], isSmall);
                  },
                );
              },
            ),

            // Pagination
            if (_totalPages > 1) ...[
              const Divider(height: 1),
              _buildPagination(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedRow(int index, Employment data, bool isSmall) {
    final delay = index * 0.05;
    final animation = CurvedAnimation(
      parent: _animController,
      curve: Interval(
        (delay).clamp(0.0, 1.0),
        (delay + 0.3).clamp(0.0, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(animation),
        child: StaffRow(
          data: data,
          isSmall: isSmall,
          onToggleActive: (v) => widget.onToggleActive(data, v),
          onEdit: () => widget.onEdit(data),
          onDelete: () => widget.onDelete(data),
        ),
      ),
    );
  }

  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _PaginationButton(
            icon: Icons.chevron_left,
            enabled: _currentPage > 1,
            onTap: () => setState(() => _currentPage--),
          ),
          const SizedBox(width: 8),
          ..._buildPageNumbers(),
          const SizedBox(width: 8),
          _PaginationButton(
            icon: Icons.chevron_right,
            enabled: _currentPage < _totalPages,
            onTap: () => setState(() {
              _currentPage++;
              _animController.forward(from: 0);
            }),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers() {
    final List<Widget> pages = [];
    
    if (_totalPages <= 5) {
      for (int i = 1; i <= _totalPages; i++) {
        pages.add(_PageNumber(
          number: i,
          isActive: i == _currentPage,
          onTap: () => setState(() {
            _currentPage = i;
            _animController.forward(from: 0);
          }),
        ));
      }
    } else {
      // Show first, current-1, current, current+1, last
      pages.add(_PageNumber(number: 1, isActive: _currentPage == 1, onTap: () => _goToPage(1)));
      
      if (_currentPage > 3) {
        pages.add(const _PageEllipsis());
      }
      
      for (int i = max(2, _currentPage - 1); i <= min(_totalPages - 1, _currentPage + 1); i++) {
        pages.add(_PageNumber(number: i, isActive: i == _currentPage, onTap: () => _goToPage(i)));
      }
      
      if (_currentPage < _totalPages - 2) {
        pages.add(const _PageEllipsis());
      }
      
      pages.add(_PageNumber(number: _totalPages, isActive: _currentPage == _totalPages, onTap: () => _goToPage(_totalPages)));
    }
    
    return pages;
  }

  void _goToPage(int page) {
    setState(() {
      _currentPage = page;
      _animController.forward(from: 0);
    });
  }
}

class _HeaderText extends StatelessWidget {
  final String text;
  const _HeaderText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    );
  }
}

class StaffRow extends StatelessWidget {
  const StaffRow({
    super.key,
    required this.data,
    required this.isSmall,
    required this.onToggleActive,
    required this.onEdit,
    required this.onDelete,
  });

  final Employment data;
  final bool isSmall;
  final ValueChanged<bool> onToggleActive;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: staffAvatarBg(data.name),
            child: Text(
              staffInitials(data.name),
              style: AppTextStyles.label(color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),

          // Name & Details
          if (!isSmall) ...[
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.name.isEmpty ? '-' : data.name,
                    style: AppTextStyles.heading5(color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data.email.isEmpty ? '-' : data.email,
                    style: AppTextStyles.caption(color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                data.role.isEmpty ? '-' : data.role,
                style: AppTextStyles.bodyMedium(color: AppColors.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ] else
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.name.isEmpty ? '-' : data.name,
                    style: AppTextStyles.heading5(color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data.role.isEmpty ? '-' : data.role,
                    style: AppTextStyles.caption(color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
            ),

          // Status
          SizedBox(
            width: 100,
            child: _StatusBadge(active: data.isActive),
          ),

          // Actions Menu
          SizedBox(
            width: 48,
            child: PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, size: 20, color: AppColors.textSecondary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              offset: const Offset(0, 40),
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    onEdit();
                    break;
                  case 'delete':
                    onDelete();
                    break;
                  case 'toggle':
                    onToggleActive(!data.isActive);
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'toggle',
                  child: Row(
                    children: [
                      Icon(
                        data.isActive ? Icons.toggle_on : Icons.toggle_off,
                        size: 20,
                        color: data.isActive ? AppColors.success : AppColors.textHint,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        data.isActive ? 'Set Inactive' : 'Set Active',
                        style: AppTextStyles.bodyMedium(),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 20, color: AppColors.textSecondary),
                      const SizedBox(width: 12),
                      Text('Edit', style: AppTextStyles.bodyMedium()),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                      const SizedBox(width: 12),
                      Text('Delete', style: AppTextStyles.bodyMedium(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool active;
  const _StatusBadge({required this.active});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? AppColors.success : AppColors.textHint,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          active ? 'Active' : 'Inactive',
          style: AppTextStyles.bodySmall(
            color: active ? AppColors.success : AppColors.textSecondary,
          ).copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _PaginationButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _PaginationButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? Colors.white : AppColors.backgroundLight,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: enabled ? AppColors.textPrimary : AppColors.textHint,
          ),
        ),
      ),
    );
  }
}

class _PageNumber extends StatelessWidget {
  final int number;
  final bool isActive;
  final VoidCallback onTap;

  const _PageNumber({
    required this.number,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: isActive ? AppColors.primaryRed : Colors.white,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              border: Border.all(
                color: isActive ? AppColors.primaryRed : AppColors.border,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$number',
                style: AppTextStyles.label(
                  color: isActive ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PageEllipsis extends StatelessWidget {
  const _PageEllipsis();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SizedBox(
        width: 36,
        height: 36,
        child: Center(
          child: Text(
            '...',
            style: AppTextStyles.label(color: AppColors.textHint),
          ),
        ),
      ),
    );
  }
}
