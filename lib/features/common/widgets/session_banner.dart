import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../session/domain/entities/session_entity.dart';
import '../../../core/utils/extensions.dart';

class SessionBanner extends StatelessWidget {
  final SessionEntity? session;
  final bool isAdmin;
  final VoidCallback? onOpenSession;
  final VoidCallback? onCloseSession;

  const SessionBanner({
    super.key,
    required this.session,
    this.isAdmin = false,
    this.onOpenSession,
    this.onCloseSession,
  });

  @override
  Widget build(BuildContext context) {
    if (session == null) {
      return _buildNoSessionBanner(context);
    }

    final isOpen = session!.status == SessionStatus.open;
    final isClosed = session!.status == SessionStatus.closed;
    final isDelivered = session!.status == SessionStatus.delivered;

    Color backgroundColor;
    Color textColor;
    IconData icon;
    String statusText;

    if (isOpen) {
      backgroundColor = AppTheme.successColor.withValues(alpha: 0.1);
      textColor = AppTheme.successColor;
      icon = Icons.check_circle;
      statusText = context.l10n.sessionOpen;
    } else if (isClosed) {
      backgroundColor = AppTheme.warningColor.withValues(alpha: 0.1);
      textColor = AppTheme.warningColor;
      icon = Icons.pause_circle;
      statusText = context.l10n.sessionClosed;
    } else {
      backgroundColor = AppTheme.primaryColor.withValues(alpha: 0.1);
      textColor = AppTheme.primaryColor;
      icon = Icons.delivery_dining;
      statusText = context.l10n.sessionDelivered;
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: textColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusText,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (session!.deliveryFee > 0)
                      Text(
                        '${context.l10n.deliveryFee}: ${session!.deliveryFee.toStringAsFixed(2)} ${context.l10n.egp}',
                        style: TextStyle(
                          color: textColor.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              if (isAdmin && !isDelivered)
                _buildAdminButton(context, isOpen),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoSessionBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.textSecondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: AppTheme.textSecondary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.l10n.sessionClosed,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (isAdmin)
            ElevatedButton(
              onPressed: onOpenSession,
              child: Text(context.l10n.openSession),
            ),
        ],
      ),
    );
  }

  Widget _buildAdminButton(BuildContext context, bool isOpen) {
    return ElevatedButton(
      onPressed: isOpen ? onCloseSession : onOpenSession,
      style: ElevatedButton.styleFrom(
        backgroundColor: isOpen ? AppTheme.warningColor : AppTheme.successColor,
      ),
      child: Text(isOpen ? context.l10n.closeSession : context.l10n.openSession),
    );
  }
}
