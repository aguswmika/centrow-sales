# API Contract: Proposal Pricing Worker Duration

Based on `/Users/agus/Project/centrow/docs/api/pricings.md` (Changelog 2026-09-08).

## Endpoints

### 1. `POST /api/v1/sales/proposals/:id/pricing` (Save Pricing)
### 2. `POST /api/v1/sales/proposals/:id/pricing/preview` (Preview Pricing)

#### Request Payload (`workers[]` array element):

```json
{
  "product_id": "aa0e8400-e29b-41d4-a716-446655440010",
  "visit_frequency": 4,
  "first_visit_minutes": 240,
  "routine_minutes": 120
}
```

| Field | Type | Required | Description | Constraints |
|---|---|---|---|---|
| `product_id` | string (UUID) | Yes | Reference to Teknisi category product (kind 4) | Must resolve to valid technician product |
| `visit_frequency` | integer | Yes | Number of visits for this worker line | Must be > 0 |
| `first_visit_minutes` | number | Yes | Work duration on the first visit in minutes | Must be >= 0 |
| `routine_minutes` | number | Yes | Work duration on each subsequent routine visit in minutes | Must be >= 0 |

#### Rejection Responses:

- HTTP 400 when `first_visit_minutes < 0` or `routine_minutes < 0`:
  ```json
  {
    "data": null,
    "is_error": true,
    "http_status": 400,
    "message": "Menit kerja tidak boleh negatif"
  }
  ```

---

### 3. `GET /api/v1/sales/proposals/:id/pricing` (Get Saved Pricing)

#### Response Payload (`data.workers[]` array element):

```json
{
  "id": "ww0e8400-e29b-41d4-a716-446655440040",
  "product_id": "aa0e8400-e29b-41d4-a716-446655440010",
  "position_name": "Teknisi Senior",
  "visit_frequency": 4,
  "first_visit_minutes": 240,
  "routine_minutes": 120,
  "hourly_rate": 100000,
  "line_total": 1200000
}
```

| Field | Type | Description |
|---|---|---|
| `id` | string (UUID) | Worker pricing line ID |
| `product_id` | string (UUID) | Product ID |
| `position_name` | string | Role / technician title |
| `visit_frequency` | integer | Number of visits |
| `first_visit_minutes` | number | First visit duration in minutes |
| `routine_minutes` | number | Routine visit duration in minutes |
| `hourly_rate` | number | Hourly billing rate |
| `line_total` | number | Line cost = `(first_visit_minutes + visit_frequency × routine_minutes) / 60 × hourly_rate` |
