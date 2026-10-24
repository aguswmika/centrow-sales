## Context

The Flutter mobile sales application (`centrow-sales`) uses a layered architecture (`View → Controller → Repository → Entity/DTO`) with Signals for state management. Currently, the pricing calculator (`PricingCalculatorController` and `PricingSettingsCard`) models the quote configuration using "Markup" with options Persen (`1`) and Nominal (`2`), and allows arbitrary manual discounts.

Following the 2026-10-14 backend API contract update:
- Pricing is offer-based: `subtotal` is the offer before tax, `service_price = offer - addon_amount`, and `total_amount = offer × (1 + tax)`.
- `markup_type` accepts only `1` (Persentase) and `3` (Jumlah). `2` (Nominal) is rejected with 400.
- `discount_amount` is ignored (stored/returned as 0).
- Add-on products can be standard (`kind: 5`) or package (`kind: 6`).
- Custom items without product ID accept optional `unit_cost`.
- Header responses include `addon_cost` in COGS.

## Goals / Non-Goals

**Goals:**
- Replace "Markup" with "Penawaran" across all sales pricing screens and cards.
- Restrict offer selection to `1` (Persentase (%)) and `3` (Nilai Tetap (Rp)).
- Display the computed nominal offer in Rupiah below the percentage input when Persentase mode is active.
- Support Add-on Package products (`kind: 6`) in product selection and line total calculation (`(qty × unit_price) / frequency`).
- Allow entering manual unit cost (`unit_cost`) on custom items (`kind == 0`) and serialize it in `PricingItemDto`.
- Parse and display `addon_cost` as part of COGS in `PricingPreview` and `PricingDetail`.
- Gracefully handle migration of legacy draft proposals having `markup_type: 2`.

**Non-Goals:**
- Backend API or database changes (the mobile app is a client consumer).
- Web Inertia admin views.

## Decisions

### 1. "Penawaran" Terminology & API Field Preservation
- **Rationale**: The salesperson's mental model is now setting the offer (*penawaran*) directly or as a percentage over the internal cost floor. We use "Penawaran" in all user-facing labels, while preserving `markup_type` and `markup_value` in DTOs and API requests to adhere to the backend JSON contract.

### 2. Supported Offer Models (1 & 3) and Legacy 2 Migration
- **Rationale**: Backend rejects `markup_type: 2` with HTTP 400 `"Jenis markup tidak valid"`.
- **Implementation**:
  - `markupType` dropdown offers:
    - `1`: `Persentase (%)`
    - `3`: `Nilai Tetap (Rp)`
  - When loading existing proposals with legacy `markupType == 2`, the controller migrates the state to `markupType = 3` with `markupValue = existing.markupValue` (or converts to percentage) so resaving will not fail.

### 3. Displaying Nominal Offer under Persentase Mode
- **Rationale**: When entering a percentage (e.g. 20%), users need to see the resulting monetary figure without having to navigate back and forth.
- **Implementation**:
  - `PricingCalculatorController` holds reactive signals for the latest preview figures (`previewSubtotal`, `previewTotalAmount`).
  - In `PricingSettingsCard`, when `markupType == 1`, an informational container displays:
    - Nominal Penawaran (Sebelum PPN): `formatRp(subtotal)`
    - Total (+ PPN): `formatRp(totalAmount)`
  - If inputs have changed since the last preview, a subtle indicator or auto-preview refresh confirms that the numbers reflect the current draft.

### 4. Custom Item Unit Cost
- **Rationale**: Backend allows custom add-ons to define their own cost floor so margins are calculated accurately.
- **Implementation**:
  - Add `unitCost` signal on `PricingItemRow` for `kind == 0`.
  - In `PricingItemRowWidget`, add an optional input field for "Biaya Satuan (Rp)" when expanded or inline.
  - Serialize `unit_cost: unitCost > 0 ? unitCost : null` in `PricingItemDto`.

### 5. Add-on Package (`kind: 6`) Support
- **Rationale**: Backend distinguishes between per-frequency add-ons (`kind: 5`) and package add-ons (`kind: 6`), dividing package totals by visit frequency.
- **Implementation**:
  - In `PricingItemTab`, allow selecting between standard Add-on and Add-on Paket (or filter in `ProductPickerSheet`).
  - If product has `kind == 6`, line total calculation uses `(qty × unit_price) / frequency`.

### 6. Discount De-emphasis
- **Rationale**: Backend ignores `discount_amount` and stores it as 0.
- **Implementation**:
  - Remove or hide the "Diskon Khusus" input from `PricingSettingsCard`, or set `discount_amount: 0.0` automatically.

## Risks / Trade-offs

- **[Risk] User enters Add-on items exceeding the offer amount**
  → *Mitigation*: The backend will respond with 400 `"Jumlah Tambahan melebihi penawaran"`. The app already maps Dio 400 errors to user toasts, and client-side validation can optionally warn if `addonAmount > offerAmount`.

- **[Risk] Existing saved drafts with `markup_type: 2`**
  → *Mitigation*: `loadExistingPricing` checks if `markupType == 2`, and if so, defaults to `3` (Nilai Tetap) with the previous nominal value.
