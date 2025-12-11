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

  static const double wAvatar = 64; // kolom foto
  static const double wName = 220;
  static const double wPos = 180;
  static const double wEmail = 240;
  static const double wStatus = 140;
  static const double wActions = 120;

  static const double rowHeight = 64;

  static double get totalWidth => wAvatar + wName + wPos + wEmail + wStatus + wActions;

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
    return Material(
      elevation: 6,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(10), // radius kecil
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10), // radius kecil
          border: Border.all(color: const Color(0xFFE6EAF0)),
        ),
        child: Column(
          children: [
            // Header
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              child: Container(
                color: const Color(0xFFF9FAFB),
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: SingleChildScrollView(
                  controller: headerController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: SizedBox(
                    width: max(totalWidth, MediaQuery.of(context).size.width - 32),
                    child: Row(
                      children: [
                        // Icon saja agar tidak overflow (hilangin tulisan Photo)
                        _headerCell(
                          width: wAvatar,
                          child: const Icon(Icons.person, size: 18, color: Color(0xFF475467)),
                        ),
                        _headerCell(width: wName, label: 'NAME'),
                        _headerCell(width: wPos, label: 'Position'),
                        _headerCell(width: wEmail, label: 'E-Mail'),
                        _headerCell(width: wStatus, label: 'Status'),
                        _headerCell(width: wActions, label: ''),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const Divider(height: 1),

            // Body (dibikin lebih tinggi)
            SizedBox(
              height: min(680.0, MediaQuery.of(context).size.height * 0.72),
              child: Scrollbar(
                controller: bodyVController,
                radius: const Radius.circular(10),
                thickness: 6,
                child: SingleChildScrollView(
                  controller: bodyHController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: SizedBox(
                    width: max(totalWidth, MediaQuery.of(context).size.width - 32),
                    child: ListView.separated(
                      controller: bodyVController,
                      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                      itemBuilder: (context, i) {
                        final e = rows[i];
                        return StaffRow(
                          data: e,
                          onToggleActive: (v) => onToggleActive(e, v),
                          onEdit: () => onEdit(e),
                          onDelete: () => onDelete(e),
                        );
                      },
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemCount: rows.length,
                    ),
                  ),
                ),
              ),
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

  Widget _headerCell({required double width, String? label, Widget? child}) {
    const style = TextStyle(
      fontSize: 12,
      color: Color(0xFF475467),
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
    );
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Align(
          alignment: Alignment.centerLeft,
          child: child ?? Text(label ?? '', style: style),
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
    required this.onToggleActive,
    required this.onEdit,
    required this.onDelete,
  });

  final Employment data;
  final ValueChanged<bool> onToggleActive;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  static const double wAvatar = StaffTable.wAvatar;
  static const double wName = StaffTable.wName;
  static const double wPos = StaffTable.wPos;
  static const double wEmail = StaffTable.wEmail;
  static const double wStatus = StaffTable.wStatus;
  static const double wActions = StaffTable.wActions;

  @override
  Widget build(BuildContext context) {
    final ts = Theme.of(context).textTheme;

    return SizedBox(
      height: StaffTable.rowHeight,
      child: Row(
        children: [
          // AVATAR
          SizedBox(
            width: wAvatar,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: staffAvatarBg(data.name),
                child: Text(
                  staffInitials(data.name),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          // NAME (tanpa kotak ungu)
          SizedBox(
            width: wName,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE6EAF0)),
                  borderRadius: BorderRadius.circular(8), // lebih kotak
                ),
                child: Text(
                  data.name.isEmpty ? '-' : data.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ts.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          // POSITION
          SizedBox(
            width: wPos,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                data.role.isEmpty ? '-' : data.role,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ts.bodyMedium?.copyWith(
                  color: const Color(0xFF344054),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          // EMAIL
          SizedBox(
            width: wEmail,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                data.email.isEmpty ? '-' : data.email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ts.bodyMedium?.copyWith(color: const Color(0xFF344054)),
              ),
            ),
          ),
          // STATUS
          SizedBox(
            width: wStatus,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: StaffStatusPill(active: data.isActive),
                    ),
                  ),
                  Switch.adaptive(
                    value: data.isActive,
                    onChanged: onToggleActive,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    activeTrackColor: const Color(0xFF16A34A),
                  ),
                ],
              ),
            ),
          ),
          // ACTIONS
          SizedBox(
            width: wActions,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    tooltip: 'Edit',
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: onEdit,
                  ),
                  IconButton(
                    tooltip: 'Delete',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ),
          ),
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
