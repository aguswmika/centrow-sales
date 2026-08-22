import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:centrow_sales/app/di.dart';
import 'package:centrow_sales/modules/sales/controllers/proposal_form_controller.dart';

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
    if (widget.customerId != null) {
      _controller.customerId = widget.customerId;
    }
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              initialValue: _controller.customerId,
              decoration: const InputDecoration(labelText: 'Pelanggan'),
              onChanged: (val) => _controller.customerId = val,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Layanan'),
              onChanged: (val) => _controller.serviceId = val,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Tanggal Proposal (YYYY-MM-DD)',
              ),
              onChanged: (val) => _controller.proposalDate = val,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Berlaku Hingga (YYYY-MM-DD)',
              ),
              onChanged: (val) => _controller.validUntil = val,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Lokasi'),
              onChanged: (val) => _controller.addressId = val,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                final result = await _controller.submit();
                if (result.isOk && context.mounted) {
                  context.pop(true);
                } else if (result.isErr && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result.failureOrNull!.message)),
                  );
                }
              },
              child: const Text('Buat Proposal'),
            ),
          ],
        ),
      ),
    );
  }
}
