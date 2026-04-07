import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/extensions.dart';
import '../../../session/domain/entities/session_entity.dart';
import '../cubit/admin_cubit.dart';
import 'admin_orders_tab.dart';
import 'admin_aggregation_tab.dart';
import 'admin_menu_tab.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<AdminCubit>().loadAdminData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.admin),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primaryColor,
          tabs: [
            Tab(text: context.l10n.orders),
            Tab(text: context.l10n.aggregatedItems),
            Tab(text: context.l10n.menu),
          ],
        ),
      ),
      body: Column(
        children: [
          // Session controls
          _buildSessionControls(),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                AdminOrdersTab(),
                AdminAggregationTab(),
                AdminMenuTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionControls() {
    return BlocBuilder<AdminCubit, AdminState>(
      builder: (context, state) {
        if (state is AdminLoading) {
          return const SizedBox.shrink();
        }

        if (state is AdminLoaded) {
          return _buildSessionCard(state);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSessionCard(AdminLoaded state) {
    final session = state.session;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session == null
                            ? 'No Session'
                            : _getStatusText(session.status),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: session == null
                              ? AppTheme.textSecondary
                              : _getStatusColor(session.status),
                        ),
                      ),
                      if (session != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${state.totalOrders} ${context.l10n.orders} • ${state.totalOrdersAmount.toStringAsFixed(2)} ${context.l10n.egp}',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                _buildSessionButton(session),
              ],
            ),
            if (session != null && session.status != SessionStatus.delivered) ...[
              const Divider(height: 24),
              _buildFeeInputs(session),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSessionButton(SessionEntity? session) {
    if (session == null) {
      return ElevatedButton(
        onPressed: () => context.read<AdminCubit>().createSession(),
        child: Text(context.l10n.openSession),
      );
    }

    switch (session.status) {
      case SessionStatus.open:
        return ElevatedButton(
          onPressed: () => context.read<AdminCubit>().closeSession(session.id),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.warningColor,
          ),
          child: Text(context.l10n.closeSession),
        );
      case SessionStatus.closed:
        return Row(
          children: [
            OutlinedButton(
              onPressed: () => context.read<AdminCubit>().openSession(session.id),
              child: Text(context.l10n.openSession),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => context.read<AdminCubit>().markDelivered(session.id),
              child: Text(context.l10n.markDelivered),
            ),
          ],
        );
      case SessionStatus.delivered:
        return ElevatedButton(
          onPressed: () => context.read<AdminCubit>().createSession(),
          child: const Text('New Session'),
        );
    }
  }

  Widget _buildFeeInputs(SessionEntity session) {
    return Row(
      children: [
        Expanded(
          child: _FeeInput(
            label: context.l10n.deliveryFee,
            value: session.deliveryFee,
            onSubmit: (value) {
              context.read<AdminCubit>().setDeliveryFee(session.id, value);
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _FeeInput(
            label: context.l10n.totalBill,
            value: session.totalBill,
            onSubmit: (value) {
              context.read<AdminCubit>().setTotalBill(session.id, value);
            },
          ),
        ),
      ],
    );
  }

  String _getStatusText(SessionStatus status) {
    switch (status) {
      case SessionStatus.open:
        return context.l10n.sessionOpen;
      case SessionStatus.closed:
        return context.l10n.sessionClosed;
      case SessionStatus.delivered:
        return context.l10n.sessionDelivered;
    }
  }

  Color _getStatusColor(SessionStatus status) {
    switch (status) {
      case SessionStatus.open:
        return AppTheme.successColor;
      case SessionStatus.closed:
        return AppTheme.warningColor;
      case SessionStatus.delivered:
        return AppTheme.primaryColor;
    }
  }
}

class _FeeInput extends StatefulWidget {
  final String label;
  final double value;
  final Function(double) onSubmit;

  const _FeeInput({
    required this.label,
    required this.value,
    required this.onSubmit,
  });

  @override
  State<_FeeInput> createState() => _FeeInputState();
}

class _FeeInputState extends State<_FeeInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.value > 0 ? widget.value.toString() : '',
    );
  }

  @override
  void didUpdateWidget(_FeeInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = widget.value > 0 ? widget.value.toString() : '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: widget.label,
        suffixText: context.l10n.egp,
        isDense: true,
      ),
      onSubmitted: (value) {
        final parsed = double.tryParse(value) ?? 0;
        widget.onSubmit(parsed);
      },
    );
  }
}
