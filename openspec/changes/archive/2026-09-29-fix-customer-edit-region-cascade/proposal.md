## Why

When editing an existing customer in the "Edit Data Pelanggan" form (Step 2: Lokasi & Alamat), previous administrative region data (Kabupaten / Kota, Kecamatan, and Kelurahan / Desa) fails to load into the cascading dropdown selectors, leaving them unselected or stuck on placeholders such as "Pilih Kabupaten / Kota", "Pilih kabupaten/kota terlebih dahulu", and "Pilih kecamatan terlebih dahulu", even though the province (e.g., "BALI") and address details are loaded.

This occurs due to several compounding issues:
1. Robustness issues in DTO parsing (`CustomerLocationDto.fromJson`) where `_parseRegionRef` strictly checks for `Map<String, dynamic>` rather than generic `Map`, failing on nested map structures from HTTP decoders and returning raw stringified objects instead of IDs and names, and rigid casting of integer IDs where strings or alternate field names (`city`, `subdistrict`, `kabupaten`, `kecamatan`, `kelurahan`) are ignored.
2. Incomplete pre-population and cascading resolution in `CustomerFormController.loadInitialData` when region IDs or names are partially provided or format discrepancies exist between the stored names and the region master API list.
3. Brittle cascading initialization in `RegionPicker` where subsequent levels (regency, district, village) do not reliably trigger or synchronize with asynchronously loaded parent options, nor update correctly when initial IDs and names become available.
4. Rigid region matching in `isRegionMatch` that fails to match variations like "Kota Denpasar" vs "Denpasar", "Kab. Badung" vs "Badung", or terms with punctuation and prefixes/suffixes.

## What Changes

- **Enhance Region DTO Parsing (`CustomerLocationDto`)**: Support flexible region reference parsing handling both `Map` (with string or numeric `id` and `name`) and `String`, fallback aliases (`city` / `city_id` / `kabupaten` for regency, `district` / `kecamatan` for district, `village` / `subdistrict` / `kelurahan` for village), and safe string-to-int parsing.
- **Robust Region Name Matching (`isRegionMatch`)**: Expand region normalization to account for Indonesian administrative prefixes/suffixes (`kab.`, `kabupaten`, `kota`, `kotamadya`, `adm.`, `kec.`, `kecamatan`, `kel.`, `kelurahan`, `desa`) as well as case-insensitive substring/trimmed matching.
- **Cascading Pre-load in Controller (`CustomerFormController.loadInitialData`)**: Ensure that when loading an existing customer, both region IDs and region names are resolved and synchronized across all four tiers (Province -> Regency -> District -> Village) before or during form population.
- **Resilient Cascading State in UI (`RegionPicker`)**: Ensure `RegionPicker` properly initiates cascading loads when populated with existing IDs/names, keeps dropdown items and selected values in sync even when async fetches complete out of order, and eliminates false disabling of dependent dropdowns when parent data is valid.

## Capabilities

### New Capabilities
- `customer-location-regions`: Reliable cascading administrative region selection and pre-population (Province, Regency/City, District, Village) for customer locations in create and edit flows.

### Modified Capabilities
<!-- None -->

## Impact

- **Affected Files**:
  - `lib/modules/sales/repositories/dtos/customer_dto.dart`
  - `lib/modules/sales/controllers/customer_form_controller.dart`
  - `lib/modules/sales/views/widgets/customer_form/region_picker.dart`
  - Relevant tests under `test/modules/sales/`
- **APIs**:
  - `GET /v1/sales/customers/:id` response parsing
  - `GET /v1/provinces`, `GET /v1/regencies`, `GET /v1/districts`, `GET /v1/villages` query coordination
