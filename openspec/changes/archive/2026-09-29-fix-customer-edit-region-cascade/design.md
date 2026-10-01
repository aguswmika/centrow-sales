## Context

See `proposal.md` for problem background.

In the Customer Form (Step 2: Lokasi & Alamat), location cards use `RegionPicker` backed by `RegionRepository` and `CustomerFormController`. When editing an existing customer:
1. `CustomerRepository.getCustomerById` retrieves raw customer JSON and deserializes it via `CustomerDetailDto.fromJson` and `CustomerLocationDto.fromJson`.
2. `CustomerFormController.loadInitialData` iterates through `customer.locations` and resolves any missing region IDs using `_regionRepository` before assigning `locations.value`.
3. `Step2LocationsForm` builds `RegionPicker` for each location item.
4. `RegionPicker` fetches region tiers (`_fetchProvinces`, `_fetchRegencies`, `_fetchDistricts`, `_fetchVillages`) and renders four `DropdownButtonFormField<int>` widgets.

Currently, if the backend returns nested maps typed as generic `Map` rather than `Map<String, dynamic>`, or uses aliases like `city` / `city_id`, or if region names have slight formatting differences (e.g. "Kota Denpasar" vs "Denpasar"), the cascading dropdowns fail to select or populate subsequent levels.

## Goals / Non-Goals

**Goals:**
- Guarantee robust deserialization of region references and IDs in `CustomerLocationDto.fromJson`.
- Make `normalizeRegionName` and `isRegionMatch` tolerant of Indonesian administrative naming differences without false positives.
- Ensure `CustomerFormController.loadInitialData` and `RegionPicker` reliably pre-fetch and select all 4 tiers of region data for existing customers.
- Maintain seamless UX during edit mode where Kabupaten, Kecamatan, and Kelurahan appear selected with proper labels.

**Non-Goals:**
- Altering the backend API schema or database models.
- Changing the public interface of `RegionRepository`.

## Decisions

### 1. Robust DTO Parsing for Region References
- **Approach**: In `CustomerLocationDto`, update `_parseRegionRef` to inspect `raw is Map` instead of strict `raw is Map<String, dynamic>`.
- Extract IDs safely using a helper that handles both `num` and `String` (via `int.tryParse`).
- Check fallback keys:
  - Regency: `json['regency'] ?? json['city'] ?? json['kabupaten']` and `json['regency_id'] ?? json['city_id']`
  - District: `json['district'] ?? json['kecamatan']` and `json['district_id']`
  - Village: `json['village'] ?? json['subdistrict'] ?? json['kelurahan'] ?? json['desa']` and `json['village_id'] ?? json['subdistrict_id']`
- **Alternatives Considered**: Require the backend to only return a single rigid format. Rejected as mobile client must remain resilient against API variations and legacy records.

### 2. Enhanced Region Name Matching
- **Approach**: Expand `normalizeRegionName` to strip additional prefixes (`kotamadya`, `kota adm.`, `adm.`, `kab`, `kab.`, `kec`, `kec.`, `kel`, `kel.`, `desa`) and ignore common suffixes or trailing words like "city", "kabupaten".
- Check normalized equality first. If not equal, compare tokens to avoid partial mismatches (e.g. "Kuta" vs "Kuta Selatan").
- **Alternatives Considered**: Fuzzy string distance (Levenshtein). Rejected because Indonesian administrative names can have short distinct words where token matching with prefix normalization is far more reliable and predictable.

### 3. Comprehensive Cascading Pre-population in `RegionPicker`
- **Approach**:
  - In `RegionPicker.initState()`, if `provinceId` is already present, trigger `_fetchRegencies(provinceId)`. If `regencyId` is also present, trigger `_fetchDistricts(provinceId, regencyId)`. If `districtId` is also present, trigger `_fetchVillages(provinceId, regencyId, districtId)`.
  - When `_fetchRegencies` resolves, if `regencyId` was not yet set but `regency` name is available, perform name matching against the fetched list, set `regencyId`, and trigger `_fetchDistricts`.
  - Follow the same pattern in `_fetchDistricts` and `_fetchVillages`.
  - Update `didUpdateWidget` so that when `widget.item` updates with newly resolved region IDs/names, matching child lists are fetched rather than cleared.

## Risks / Trade-offs

- **[Risk] Name matching collisions between similar district names (e.g. "Denpasar Barat" vs "Denpasar Timur")**
  → **Mitigation**: Token-based matching ensures multi-word names require all significant tokens to match; "Denpasar Barat" will not match "Denpasar Timur".
- **[Risk] Multiple cascading async calls racing when user quickly switches selections**
  → **Mitigation**: Track active request IDs or verify that the returned region data matches the currently selected parent before setting state.
