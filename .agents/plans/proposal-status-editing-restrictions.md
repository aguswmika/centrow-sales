# Proposal Status Editing Restrictions Plan

## Goal

Enforce proposal editing restrictions according to the backend business rules matrix:

- Direct **Pricing edit (`UpsertForProposal`)** is allowed **ONLY for Draft**.
- Direct **Proposal fields edit (`UpdateProposal`)** is allowed **ONLY for Draft**.
- **Document edit (`UpdateContent`)** is allowed for **Draft, Sent, Accepted, Rejected**, but **BLOCKED for Expired and Cancelled**.
- **Revise (`ReviseProposal`)** is allowed for **Sent, Rejected, Expired**, but **BLOCKED for Draft, Accepted, Cancelled**.

---

## Permission Matrix

| Proposal Status   | Proposal fields (`UpdateProposal`) | Pricing (`UpsertForProposal`)       | Document (`UpdateContent`)  | Revise (`ReviseProposal`) | Document View  |   Pricing View   |
| ----------------- | ---------------------------------- | ----------------------------------- | --------------------------- | ------------------------- | :------------: | :--------------: |
| **Draft** (1)     | ✅ edit directly (`canEdit`)       | ✅ edit directly (`canEditPricing`) | ✅ edit (`canEditDocument`) | ❌ blocked                |       ✅       |        ✅        |
| **Sent** (2)      | ❌ "gunakan revisi"                | ❌ "gunakan revisi"                 | ✅ edit (`canEditDocument`) | ✅ allowed (`canRevise`)  |       ✅       |        ✅        |
| **Accepted** (3)  | ❌ "gunakan revisi"                | ❌ "gunakan revisi"                 | ✅ edit (`canEditDocument`) | ❌ blocked                |       ✅       |        ✅        |
| **Rejected** (4)  | ❌ "gunakan revisi"                | ❌ "gunakan revisi"                 | ✅ edit (`canEditDocument`) | ✅ allowed (`canRevise`)  |       ✅       |        ✅        |
| **Expired** (5)   | ❌ "gunakan revisi"                | ❌ "gunakan revisi"                 | ❌ **blocked**              | ✅ allowed (`canRevise`)  | ✅ (read-only) | ✅ (detail pane) |
| **Cancelled** (6) | ❌ "gunakan revisi"                | ❌ "gunakan revisi"                 | ❌ **blocked**              | ❌ blocked                | ✅ (read-only) | ✅ (detail pane) |

---

## Approach

1. **Entity Layer (`lib/modules/sales/entities/proposal.dart`)**:
   - `canEdit => isDraft;` (existing)
   - `canRevise => isSent || isRejected || isExpired;` (existing)
   - Add `bool get canEditPricing => isDraft;`
   - Add `bool get canEditDocument => !isExpired && !isCancelled;`
2. **Proposal Detail Pane (`lib/modules/sales/views/widgets/proposal_detail_pane.dart`)**:
   - **Pricing button**:
     - `onPressed: proposal.status.canEditPricing ? onOpenCalculator : null`.
     - When disabled, button renders with disabled styling (`onPressed: null`).
   - **Dokumen button**:
     - Always clickable (user can always open document to view or edit).
     - When `canEditDocument` is `true`: icon `Icons.edit_document`, tooltip "Ubah Dokumen".
     - When `canEditDocument` is `false`: icon `Icons.description_outlined`, tooltip "Lihat Dokumen".
   - **Empty Pricing Placeholder**:
     - If `!proposal.hasPricing`:
       - If `proposal.status.canEditPricing` (Draft): show `AppButton(text: 'Buat Kalkulasi Harga', onPressed: onOpenCalculator)`.
       - If `!proposal.status.canEditPricing`: show text message: _"Kalkulasi harga tidak dapat dibuat karena proposal telah [status]."_
3. **Pricing Page (`lib/modules/sales/views/pages/pricing_page.dart` & `pricing_calculator_view.dart`)**:
   - If navigated to directly for a proposal where `!data.status.canEditPricing`:
     - Render warning lock banner: _"Proposal berstatus ${data.status.displayName}. Kalkulasi harga terkunci dan tidak dapat diubah."_
     - Disable duration and frequency input fields (`enabled: false`).
     - Pass `isReadOnly: true` to `PricingCalculatorView` (disabling save/submit actions).
4. **Document Page & Tiptap Editor (`proposal_document_page.dart` & `webview_tiptap_editor.dart`)**:
   - `ProposalDocumentPage`:
     - Inspects proposal status (`initialProposal` from route extra, or loaded via `ProposalRepository`).
     - `final isEditable = _proposal == null || _proposal!.status.canEditDocument;`
     - When `!isEditable` (Expired or Cancelled):
       - Hide "Simpan" button.
       - Hide `CustomTiptapToolbar`.
       - Render warning banner: _"Proposal ini berstatus ${\_proposal?.status.displayName}. Dokumen terkunci dan tidak dapat diedit."_
       - Pass `isEditable: false` to `WebviewTiptapEditor`.
     - When `isEditable` (Draft, Sent, Accepted, Rejected):
       - Show "Simpan" button.
       - Show `CustomTiptapToolbar`.
       - Pass `isEditable: true` to `WebviewTiptapEditor`.
   - `WebviewTiptapEditor`:
     - Add `final bool isEditable;` (default `true`).
     - Pass `editable: $isEditable` to Tiptap initialization and `window.editor.setEditable($isEditable)` in `setupContent`.
5. **Testing**:
   - Unit tests covering `canEditPricing` and `canEditDocument` across all 6 statuses.
   - Detail pane widget tests verifying that `Pricing` button is disabled for non-drafts and document view is read-only for expired and cancelled proposals.

---

## Steps to Execute

1. **Update Entity Model**:
   - Edit `lib/modules/sales/entities/proposal.dart`: add `canEditPricing => isDraft;` and `canEditDocument => !isExpired && !isCancelled;`.
2. **Update Proposal Detail Pane**:
   - Edit `lib/modules/sales/views/widgets/proposal_detail_pane.dart`:
     - Set `onPressed: proposal.status.canEditPricing ? onOpenCalculator : null` on the "Pricing" button.
     - Adapt "Dokumen" icon based on `proposal.status.canEditDocument`.
     - Disable or replace "Buat Kalkulasi Harga" button when `!proposal.status.canEditPricing`.
3. **Update Webview Tiptap Editor**:
   - Edit `lib/modules/sales/views/widgets/webview_tiptap_editor.dart`: add `isEditable` property and pass to Tiptap editor instance and `setupContent`.
4. **Update Proposal Document Page & Router**:
   - Edit `lib/app/router.dart`: forward `proposal` in `state.extra` if present to `ProposalDocumentPage`.
   - Edit `lib/modules/sales/views/pages/proposal_document_page.dart`:
     - Receive `initialProposal`.
     - Fetch proposal if needed.
     - Compute `isEditable = _proposal == null || _proposal!.status.canEditDocument`.
     - Render lock banner and hide toolbar & save button when `!isEditable`.
     - Pass `isEditable: isEditable` to `WebviewTiptapEditor`.
5. **Update Pricing Page & Pricing Calculator View**:
   - Edit `lib/modules/sales/views/widgets/pricing_calculator_view.dart`: accept `isReadOnly`, disable preview action bar when `isReadOnly`.
   - Edit `lib/modules/sales/views/pages/pricing_page.dart`: show lock banner, disable parameter inputs, pass `isReadOnly: !data.status.canEditPricing`.
6. **Update Tests**:
   - In `test/modules/sales/entities/proposal_test.dart`: verify `canEditPricing` and `canEditDocument` for all 6 statuses.
   - In `test/modules/sales/views/widgets/proposal_detail_pane_test.dart`: update tests to verify disabled Pricing button on non-drafts and enabled on draft.
   - Run `flutter analyze` and `flutter test`.

---

## Proposed Changes (Not Yet Applied)

### 1. `lib/modules/sales/entities/proposal.dart`

```diff
--- a/lib/modules/sales/entities/proposal.dart
+++ b/lib/modules/sales/entities/proposal.dart
@@ -29,4 +29,6 @@ enum ProposalStatus {
   bool get canEdit => isDraft;
+  bool get canEditPricing => isDraft;
+  bool get canEditDocument => !isExpired && !isCancelled;
   bool get canRevise => isSent || isRejected || isExpired;
   bool get canSend => isDraft;
   bool get canAccept => isSent;
```

### 2. `lib/modules/sales/views/widgets/proposal_detail_pane.dart`

```diff
--- a/lib/modules/sales/views/widgets/proposal_detail_pane.dart
+++ b/lib/modules/sales/views/widgets/proposal_detail_pane.dart
@@ -176,14 +176,14 @@ class ProposalDetailPane extends StatelessWidget {
                 height: 40.0,
                 isFullWidth: false,
                 borderRadius: AppRadius.borderMd,
-                icon: const Icon(
+                icon: Icon(
                   Icons.calculate_outlined,
                   size: 16.0,
-                  color: AppColors.text,
+                  color: proposal.status.canEditPricing ? AppColors.text : AppColors.muted,
                 ),
-                onPressed: onOpenCalculator,
+                onPressed: proposal.status.canEditPricing ? onOpenCalculator : null,
               ),
               AppButton.secondary(
                 text: 'Dokumen',
                 height: 40.0,
                 isFullWidth: false,
                 borderRadius: AppRadius.borderMd,
-                icon: const Icon(
-                  Icons.edit_document,
+                icon: Icon(
+                  proposal.status.canEditDocument ? Icons.edit_document : Icons.description_outlined,
                   size: 16.0,
                   color: AppColors.text,
                 ),
                 onPressed: onOpenDocument,
               ),
@@ -624,9 +624,19 @@ class ProposalDetailPane extends StatelessWidget {
             ),
             const SizedBox(height: 24.0),
-            AppButton(
-              text: 'Buat Kalkulasi Harga',
-              onPressed: onOpenCalculator,
-              isFullWidth: false,
-            ),
+            if (proposal.status.canEditPricing)
+              AppButton(
+                text: 'Buat Kalkulasi Harga',
+                onPressed: onOpenCalculator,
+                isFullWidth: false,
+              )
+            else
+              Text(
+                'Kalkulasi harga tidak dapat dibuat karena proposal telah ${proposal.status.displayName.toLowerCase()}.',
+                style: GoogleFonts.inter(
+                  fontSize: 13.0,
+                  color: AppColors.muted,
+                ),
+                textAlign: TextAlign.center,
+              ),
           ],
```

### 3. `lib/modules/sales/views/widgets/webview_tiptap_editor.dart`

```diff
--- a/lib/modules/sales/views/widgets/webview_tiptap_editor.dart
+++ b/lib/modules/sales/views/widgets/webview_tiptap_editor.dart
@@ -20,7 +20,9 @@ class WebviewTiptapEditor extends StatefulWidget {
   final Map<String, dynamic> initialJson;
   final ValueChanged<TiptapState>? onStateChange;
   final void Function(WebViewController)? onControllerCreated;
+  final bool isEditable;

   const WebviewTiptapEditor({
     super.key,
     required this.initialJson,
     this.onStateChange,
     this.onControllerCreated,
+    this.isEditable = true,
   });
@@ -51,7 +53,8 @@ class _WebviewTiptapEditorState extends State<WebviewTiptapEditor> {
           onPageFinished: (String url) {
             final initialJsonStr = jsonEncode(widget.initialJson);
             _controller.runJavaScript(
-              "window.setupContent(String.raw`$initialJsonStr`);",
+              "window.setupContent(String.raw`$initialJsonStr`, ${widget.isEditable});",
             );
             setState(() {
               _isLoading = false;
@@ -148,6 +151,7 @@ class _WebviewTiptapEditorState extends State<WebviewTiptapEditor> {
     window.editor = new Editor({
       element: document.querySelector('#editor'),
+      editable: ${widget.isEditable},
       extensions: [
@@ -176,7 +180,7 @@ class _WebviewTiptapEditorState extends State<WebviewTiptapEditor> {
-    window.setupContent = function(jsonString) {
+    window.setupContent = function(jsonString, isEditable) {
       try {
         const json = JSON.parse(jsonString);
         if (Object.keys(json).length > 0) {
           window.editor.commands.setContent(json);
         }
       } catch (e) {
         console.error(e);
       }
+      if (typeof isEditable === 'boolean') {
+        window.editor.setEditable(isEditable);
+      }
       sendStateToFlutter(window.editor);
     };
```

### 4. `lib/modules/sales/views/pages/proposal_document_page.dart`

```diff
--- a/lib/modules/sales/views/pages/proposal_document_page.dart
+++ b/lib/modules/sales/views/pages/proposal_document_page.dart
@@ -1,6 +1,8 @@
 import 'package:flutter/material.dart';
 import 'package:go_router/go_router.dart';
 import 'package:signals/signals_flutter.dart';
 import 'package:centrow_sales/app/di.dart';
+import 'package:centrow_sales/modules/sales/entities/proposal.dart';
+import 'package:centrow_sales/modules/sales/repositories/proposal_repository.dart';
 import 'package:centrow_sales/modules/sales/controllers/proposal_document_controller.dart';
 import 'package:centrow_sales/modules/sales/entities/proposal_document.dart';
@@ -16,7 +18,12 @@ import 'package:webview_flutter/webview_flutter.dart';

 class ProposalDocumentPage extends StatefulWidget {
   final String proposalId;
+  final Proposal? initialProposal;

-  const ProposalDocumentPage({super.key, required this.proposalId});
+  const ProposalDocumentPage({
+    super.key,
+    required this.proposalId,
+    this.initialProposal,
+  });

   @override
@@ -25,12 +32,23 @@ class _ProposalDocumentPageState extends State<ProposalDocumentPage> {
   late final _controller = getIt<ProposalDocumentController>();
+  Proposal? _proposal;
   WebViewController? _webViewController;
   TiptapState? _tiptapState;

   @override
   void initState() {
     super.initState();
+    _proposal = widget.initialProposal;
     _controller.loadDocument(widget.proposalId);
+    if (_proposal == null) {
+      getIt<ProposalRepository>().getProposalById(widget.proposalId).then((result) {
+        if (result case Ok(:final value)) {
+          if (mounted) setState(() => _proposal = value);
+        }
+      });
+    }
   }
@@ -40,6 +58,7 @@ class _ProposalDocumentPageState extends State<ProposalDocumentPage> {
   @override
   Widget build(BuildContext context) {
+    final isEditable = _proposal == null || _proposal!.status.canEditDocument;
     return Scaffold(
       backgroundColor: AppColors.bg,
       body: SafeArea(
@@ -69,6 +88,7 @@ class _ProposalDocumentPageState extends State<ProposalDocumentPage> {
                   ),
                   const Spacer(),
+                  if (isEditable) ...[
                   AppButton(
                     text: 'Simpan',
                     isFullWidth: false,
@@ -88,6 +108,35 @@ class _ProposalDocumentPageState extends State<ProposalDocumentPage> {
                     },
                   ),
                   const SizedBox(width: 8),
+                  ],
                 ],
               ),
             ),
+            if (!isEditable)
+              Container(
+                width: double.infinity,
+                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
+                decoration: const BoxDecoration(
+                  color: Color(0xFFFEF3C7),
+                  border: Border(
+                    bottom: BorderSide(color: Color(0xFFFDE68A), width: 1),
+                  ),
+                ),
+                child: Row(
+                  children: [
+                    const Icon(Icons.lock_outline, size: 18, color: Color(0xFFB45309)),
+                    const SizedBox(width: 8),
+                    Expanded(
+                      child: Text(
+                        'Proposal ini berstatus ${_proposal?.status.displayName ?? "terkunci"}. Dokumen hanya dapat dibaca dan tidak dapat diubah.',
+                        style: const TextStyle(
+                          fontSize: 12.5,
+                          fontWeight: FontWeight.w600,
+                          color: Color(0xFF92400E),
+                        ),
+                      ),
+                    ),
+                  ],
+                ),
+              ),
@@ -107,7 +156,7 @@ class _ProposalDocumentPageState extends State<ProposalDocumentPage> {
-                    UiSuccess(:final data) => _buildEditorContent(data),
+                    UiSuccess(:final data) => _buildEditorContent(data, isEditable),
@@ -134,7 +183,7 @@ class _ProposalDocumentPageState extends State<ProposalDocumentPage> {
-            if (_webViewController != null && _tiptapState != null)
+            if (isEditable && _webViewController != null && _tiptapState != null)
               CustomTiptapToolbar(
                 controller: _webViewController!,
                 state: _tiptapState!,
                 placeholders: doc.placeholders,
               ),
@@ -148,6 +197,7 @@ class _ProposalDocumentPageState extends State<ProposalDocumentPage> {
                 child: WebviewTiptapEditor(
                   initialJson: doc.content,
+                  isEditable: isEditable,
                   onStateChange: (state) {
```

### 5. `lib/app/router.dart`

```diff
--- a/lib/app/router.dart
+++ b/lib/app/router.dart
@@ -113,8 +113,15 @@ final appRouter = GoRouter(
                   path: ':id/document',
                   name: 'proposal-document',
-                  builder: (context, state) => ProposalDocumentPage(
-                    proposalId: state.pathParameters['id']!,
-                  ),
+                  builder: (context, state) {
+                    Proposal? initialProposal;
+                    if (state.extra is Proposal) {
+                      initialProposal = state.extra as Proposal;
+                    }
+                    return ProposalDocumentPage(
+                      proposalId: state.pathParameters['id']!,
+                      initialProposal: initialProposal,
+                    );
+                  },
                 ),
```

### 6. `lib/modules/sales/views/pages/pricing_page.dart` & `pricing_calculator_view.dart`

```diff
--- a/lib/modules/sales/views/pages/pricing_page.dart
+++ b/lib/modules/sales/views/pages/pricing_page.dart
@@ -77,7 +77,29 @@ class _PricingPageState extends State<PricingPage> {
                 crossAxisAlignment: CrossAxisAlignment.stretch,
                 children: [
                   _buildPageHeader(context, data),
+                  if (!data.status.canEditPricing)
+                    Container(
+                      width: double.infinity,
+                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
+                      decoration: const BoxDecoration(
+                        color: Color(0xFFFEF3C7),
+                        border: Border(
+                          bottom: BorderSide(color: Color(0xFFFDE68A), width: 1),
+                        ),
+                      ),
+                      child: Row(
+                        children: [
+                          const Icon(Icons.lock_outline, size: 18, color: Color(0xFFB45309)),
+                          const SizedBox(width: 8),
+                          Expanded(
+                            child: Text(
+                              'Proposal ini berstatus ${data.status.displayName}. Kalkulasi harga terkunci dan tidak dapat diubah.',
+                              style: const TextStyle(
+                                fontSize: 12.5,
+                                fontWeight: FontWeight.w600,
+                                color: Color(0xFF92400E),
+                              ),
+                            ),
+                          ),
+                        ],
+                      ),
+                    ),
-                  _buildParamBar(context),
+                  _buildParamBar(context, isEditable: data.status.canEditPricing),
                   const Divider(
@@ -88,3 +110,4 @@ class _PricingPageState extends State<PricingPage> {
                     child: PricingCalculatorView(
                       proposal: data,
                       calculatorController: _calcController,
+                      isReadOnly: !data.status.canEditPricing,
                     ),
```

---

## Verification Plan

1. **Unit Tests (`test/modules/sales/entities/proposal_test.dart`)**:
   - `canEditPricing`: `draft` -> `true`; `sent`, `accepted`, `rejected`, `expired`, `cancelled` -> `false`.
   - `canEditDocument`: `draft`, `sent`, `accepted`, `rejected` -> `true`; `expired`, `cancelled` -> `false`.
   - `canRevise`: `sent`, `rejected`, `expired` -> `true`; `draft`, `accepted`, `cancelled` -> `false`.
2. **Widget Tests (`test/modules/sales/views/widgets/proposal_detail_pane_test.dart`)**:
   - Verify `Pricing` button is enabled for `draft`, and disabled (`onPressed: null`) for `sent`, `accepted`, `rejected`, `expired`, `cancelled`.
   - Verify `Dokumen` button remains clickable across all statuses, with appropriate icon (`edit_document` vs `description_outlined`).
   - Verify empty pricing view shows disabled guidance for non-draft statuses.
3. **Static Analysis & Test Suite**:
   - `flutter analyze`: 0 issues.
   - `flutter test`: all test suites pass.
