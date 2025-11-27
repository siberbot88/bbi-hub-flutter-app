import 'dart:math';
import 'package:flutter/material.dart';
import 'package:bengkel_online_flutter/core/models/employment.dart';
import 'staff_helpers.dart';

class StaffTable extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isSmall = width < 900;

    return Material(
      elevation: 6,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
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
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    const SizedBox(
                      width: 40,
                      child: Icon(Icons.person, size: 18, color: Color(0xFF475467)),
                    ),
                    Expanded(flex: 3, child: _headerText('NAME')),
                    if (!isSmall) ...[
                      Expanded(flex: 2, child: _headerText('Position')),
                      Expanded(flex: 3, child: _headerText('E-Mail')),
                    ],
                    Expanded(flex: 2, child: _headerText('Status')),
                    const SizedBox(width: 100, child: Text('')), // Actions
                    const SizedBox(width: 16),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),

            // Body
            SizedBox(
              height: min(680.0, MediaQuery.of(context).size.height * 0.72),
              child: ListView.separated(
                controller: bodyVController,
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                itemBuilder: (context, i) {
                  final e = rows[i];
                  return StaffRow(
                    data: e,
                    isSmall: isSmall,
                    onToggleActive: (v) => onToggleActive(e, v),
                    onEdit: () => onEdit(e),
                    onDelete: () => onDelete(e),
                  );
                },
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemCount: rows.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerText(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF475467),
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
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
    final ts = Theme.of(context).textTheme;

    return SizedBox(
      height: 72, // Slightly taller for better touch targets
      child: Row(
        children: [
          const SizedBox(width: 16),
          // AVATAR
          SizedBox(
            width: 40,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: staffAvatarBg(data.name),
              child: Text(
                staffInitials(data.name),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          
          // NAME
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.name.isEmpty ? '-' : data.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ts.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (isSmall) // Show role below name on small screens
                    Text(
                      data.role,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ts.bodySmall?.copyWith(color: Colors.grey),
                    ),
                ],
              ),
            ),
          ),

          if (!isSmall) ...[
            // POSITION
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
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
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  data.email.isEmpty ? '-' : data.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ts.bodyMedium?.copyWith(color: const Color(0xFF344054)),
                ),
              ),
            ),
          ],

          // STATUS
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: isSmall 
                ? StaffStatusPill(active: data.isActive) // Just pill on small
                : Row(
                    children: [
                      StaffStatusPill(active: data.isActive),
                      const SizedBox(width: 8),
                      Transform.scale(
                        scale: 0.8,
                        child: Switch.adaptive(
                          value: data.isActive,
                          onChanged: onToggleActive,
                          activeTrackColor: const Color(0xFF16A34A),
                        ),
                      ),
                    ],
                  ),
            ),
          ),

          // ACTIONS
          SizedBox(
            width: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  tooltip: 'Edit',
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: onEdit,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 16),
                IconButton(
                  tooltip: 'Delete',
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
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

class StaffStatusPill extends StatelessWidget {
  const StaffStatusPill({super.key, required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9);
    final textColor = active ? const Color(0xFF166534) : const Color(0xFF475467);
    final label = active ? 'Active' : 'Inactive';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE6EAF0)),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.w600)),
    );
  }
}
