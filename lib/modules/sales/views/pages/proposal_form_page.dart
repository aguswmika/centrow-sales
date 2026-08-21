import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:centrow_sales/app/di.dart';
import 'package:centrow_sales/modules/sales/controllers/proposal_form_controller.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';

class ProposalFormPage extends StatefulWidget {
  final String? customerId;

  const ProposalFormPage({super.key, this.customerId});

  @override
  State<ProposalFormPage> createState() => _ProposalFormPageState();
}

class _ProposalFormPageState extends State<ProposalFormPage> {
  late final ProposalFormController _controller;

  @override
  void initState() {
    super.initState();
    _controller = getIt<ProposalFormController>();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Proposal Baru'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text('Formulir Proposal (UI Placeholder)'),
        ),
      ),
    );
  }
}
