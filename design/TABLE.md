```sql
/* =====================================================================
   sales_pricings + child tables — final consolidated version
   PostgreSQL. uuidv7, smallint codes, varchar without length,
   no constraints, indexes only, tenant_id on every table.

   sales_pricings
     -> sales_pricing_persiapan   chemicals and tools (has uom_id)
     -> sales_pricing_teknisi     worker, one row per technician
     -> sales_pricing_items       fuel + addon + other (merged, same shape)

   One pricing per proposal. proposal_id is the only link — customer,
   service and site are reached through it, not duplicated here. No
   version / is_current / status on this table: revisions and the freeze
   both live on sales_proposals.
   ===================================================================== */


/* =====================================================================
   1. sales_pricings
   ===================================================================== */

CREATE TABLE sales_pricings (
    id uuid PRIMARY KEY DEFAULT uuidv7(),
    tenant_id uuid NOT NULL,
    proposal_id uuid NOT NULL,      -- the only link
    contract_id uuid,               -- only for a mid-term reprice with no new proposal
    calculator_version varchar,

    -- INPUTS
    region_id uuid,
    area_size numeric(18, 2) NOT NULL DEFAULT 0,
    uom_id uuid,
    contract_months smallint,
    visit_frequency integer NOT NULL DEFAULT 1,   -- treatments for the contract
    technician_count smallint NOT NULL DEFAULT 0, -- derived: count of teknisi rows
    inputs jsonb NOT NULL DEFAULT '{}'::jsonb,

    -- COST SIDE
    material_cost numeric(18, 2) NOT NULL DEFAULT 0,   -- persiapan
    worker_cost numeric(18, 2) NOT NULL DEFAULT 0,      -- teknisi
    fuel_cost numeric(18, 2) NOT NULL DEFAULT 0,       -- items, line_role 1
    surcharge_amount numeric(18, 2) NOT NULL DEFAULT 0,
    total_cost numeric(18, 2) NOT NULL DEFAULT 0,

    -- PRICE SIDE
    markup_type smallint NOT NULL DEFAULT 1,   -- 1 percent | 2 fixed | 3 target price
    markup_value numeric(18, 4) NOT NULL DEFAULT 0,
    service_price numeric(18, 2) NOT NULL DEFAULT 0,
    addon_amount numeric(18, 2) NOT NULL DEFAULT 0,    -- items, component_type 2
    other_amount numeric(18, 2) NOT NULL DEFAULT 0,    -- items, component_type 3
    subtotal numeric(18, 2) NOT NULL DEFAULT 0,
    discount_amount numeric(18, 2) NOT NULL DEFAULT 0,
    tax_rate numeric(9, 4) NOT NULL DEFAULT 0,
    tax_amount numeric(18, 2) NOT NULL DEFAULT 0,
    total_amount numeric(18, 2) NOT NULL DEFAULT 0,

    -- DERIVED
    price_per_visit numeric(18, 2) NOT NULL DEFAULT 0,
    price_per_month numeric(18, 2) NOT NULL DEFAULT 0,
    margin_amount numeric(18, 2) NOT NULL DEFAULT 0,
    margin_percent numeric(9, 4) NOT NULL DEFAULT 0,

    notes varchar,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMPTZ,
    created_by UUID NOT NULL,
    updated_by UUID,
    deleted_by UUID
);

CREATE INDEX ix_sales_pricings_proposal
  ON sales_pricings (tenant_id, proposal_id) WHERE deleted_at IS NULL;
CREATE INDEX ix_sales_pricings_contract
  ON sales_pricings (tenant_id, contract_id) WHERE contract_id IS NOT NULL;
CREATE INDEX ix_sales_pricings_region
  ON sales_pricings (tenant_id, region_id);
CREATE INDEX ix_sales_pricings_inputs
  ON sales_pricings USING gin (inputs);


/* =====================================================================
   2. sales_pricing_persiapan — chemicals and tools
   Quantity is absolute for the whole contract, entered by the rep — not
   derived from visit_frequency.
   ===================================================================== */

CREATE TABLE sales_pricing_persiapan (
    id uuid PRIMARY KEY DEFAULT uuidv7(),
    tenant_id uuid NOT NULL,
    pricing_id uuid NOT NULL,
    product_id uuid NOT NULL,
    uom_id uuid NOT NULL,

    item_code varchar,
    description varchar NOT NULL,   -- snapshot

    quantity numeric(18, 4) NOT NULL DEFAULT 1,   -- was jumlah, absolute
    frequency integer NOT NULL DEFAULT 1,         -- was frekuensi — still open, see below
    unit_cost numeric(18, 4) NOT NULL DEFAULT 0,  -- was biaya
    line_cost numeric(18, 2) NOT NULL DEFAULT 0,  -- quantity * frequency * unit_cost

    notes varchar,
    sort_order integer NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMPTZ,
    created_by UUID NOT NULL,
    updated_by UUID,
    deleted_by UUID
);

CREATE INDEX ix_sales_pricing_persiapan_pricing
  ON sales_pricing_persiapan (tenant_id, pricing_id, sort_order) WHERE deleted_at IS NULL;
CREATE INDEX ix_sales_pricing_persiapan_product
  ON sales_pricing_persiapan (tenant_id, product_id);
CREATE INDEX ix_sales_pricing_persiapan_uom
  ON sales_pricing_persiapan (tenant_id, uom_id);


/* =====================================================================
   3. sales_pricing_teknisi — one row per technician
   ===================================================================== */

CREATE TABLE sales_pricing_teknisi (
    id uuid PRIMARY KEY DEFAULT uuidv7(),
    tenant_id uuid NOT NULL,
    pricing_id uuid NOT NULL,
    technician_no smallint NOT NULL DEFAULT 1,
    product_id uuid,                -- worker grade, if graded

    description varchar,
    volume numeric(18, 2) NOT NULL DEFAULT 0,     -- meaning still open, see below
    visit_frequency integer NOT NULL DEFAULT 1,   -- how many of the contract's visits this technician attends
    first_visit_hours numeric(9, 2) NOT NULL DEFAULT 0,
    routine_visit_hours numeric(9, 2) NOT NULL DEFAULT 0,
    hourly_rate numeric(18, 4) NOT NULL DEFAULT 0, -- source still open, see below

    first_visit_cost numeric(18, 2) NOT NULL DEFAULT 0,
    routine_visit_cost numeric(18, 2) NOT NULL DEFAULT 0,
    line_cost numeric(18, 2) NOT NULL DEFAULT 0,   -- first + routine

    notes varchar,
    sort_order integer NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMPTZ,
    created_by UUID NOT NULL,
    updated_by UUID,
    deleted_by UUID
);

CREATE INDEX ix_sales_pricing_teknisi_pricing
  ON sales_pricing_teknisi (tenant_id, pricing_id, technician_no) WHERE deleted_at IS NULL;
CREATE INDEX ix_sales_pricing_teknisi_product
  ON sales_pricing_teknisi (tenant_id, product_id);


/* =====================================================================
   4. sales_pricing_items — fuel, addon, other (merged)
   component_type says which of the three; line_role says what it does to
   the money. product_id NULL is the manual-entry flag; description is
   always filled either way.
   ===================================================================== */

CREATE TABLE sales_pricing_items (
    id uuid PRIMARY KEY DEFAULT uuidv7(),
    tenant_id uuid NOT NULL,
    pricing_id uuid NOT NULL,

    component_type smallint NOT NULL,   -- 1 fuel | 2 addon | 3 other
    line_role smallint NOT NULL,        -- 1 cost input | 2 direct sale

    product_id uuid,                    -- null = manual line

    item_code varchar,
    description varchar NOT NULL,

    quantity numeric(18, 4) NOT NULL DEFAULT 1,
    frequency integer NOT NULL DEFAULT 1,
    unit_cost numeric(18, 4) NOT NULL DEFAULT 0,
    unit_price numeric(18, 4) NOT NULL DEFAULT 0,   -- role 2 only
    discount_amount numeric(18, 2) NOT NULL DEFAULT 0,

    line_cost numeric(18, 2) NOT NULL DEFAULT 0,
    line_total numeric(18, 2) NOT NULL DEFAULT 0,

    notes varchar,
    sort_order integer NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMPTZ,
    created_by UUID NOT NULL,
    updated_by UUID,
    deleted_by UUID
);

CREATE INDEX ix_sales_pricing_items_pricing
  ON sales_pricing_items (tenant_id, pricing_id, sort_order) WHERE deleted_at IS NULL;
CREATE INDEX ix_sales_pricing_items_type
  ON sales_pricing_items (tenant_id, pricing_id, component_type, line_role)
  WHERE deleted_at IS NULL;
CREATE INDEX ix_sales_pricing_items_product
  ON sales_pricing_items (tenant_id, product_id);
CREATE INDEX ix_sales_pricing_items_manual
  ON sales_pricing_items (tenant_id, lower(description))
  WHERE product_id IS NULL AND deleted_at IS NULL;


/* =====================================================================
   STILL OPEN — carried forward, unresolved

   1. sales_pricing_persiapan.frequency — quantity is already the contract
      total, so if frequency also multiplies, the line cost doubles up.
      Confirm against a real old record before the calculator ships.

   2. sales_pricing_teknisi.volume — meaning unknown. Cannot be a headcount
      since one row is already one technician.

   3. sales_pricing_teknisi.hourly_rate — the old table had no cost column,
      so the rate came from somewhere outside it. Decide the source before
      building the form; a worker product referenced by product_id is the
      version that survives a rate change.
   ===================================================================== */

CREATE TABLE public.crm_customers (
	id uuid DEFAULT uuidv7() NOT NULL,
	tenant_id uuid NOT NULL,
	code varchar NOT NULL,
	segment_id uuid NOT NULL,
	regencies_id int8 NULL,
	"name" varchar NOT NULL,
	npwp_number varchar NULL,
	email varchar NULL,
	phone varchar NULL,
	phone_alt varchar NULL,
	risk_notes varchar NULL,
	status int2 DEFAULT 1 NOT NULL,
	notes varchar NULL,
	scan_code varchar NULL,
	created_at timestamptz DEFAULT CURRENT_TIMESTAMP NULL,
	updated_at timestamptz DEFAULT CURRENT_TIMESTAMP NULL,
	deleted_at timestamptz NULL,
	created_by uuid NOT NULL,
	updated_by uuid NULL,
	deleted_by uuid NULL,
	CONSTRAINT crm_customers_code_not_null NOT NULL code,
	CONSTRAINT crm_customers_created_by_not_null NOT NULL created_by,
	CONSTRAINT crm_customers_id_not_null NOT NULL id,
	CONSTRAINT crm_customers_name_not_null NOT NULL name,
	CONSTRAINT crm_customers_pkey PRIMARY KEY (id),
	CONSTRAINT crm_customers_segment_id_not_null NOT NULL segment_id,
	CONSTRAINT crm_customers_status_not_null NOT NULL status,
	CONSTRAINT crm_customers_tenant_id_not_null NOT NULL tenant_id
);
CREATE INDEX ix_crm_customers_segment ON public.crm_customers USING btree (tenant_id, segment_id);
CREATE INDEX ix_crm_customers_status ON public.crm_customers USING btree (tenant_id, status) WHERE (deleted_at IS NULL);
CREATE UNIQUE INDEX ux_crm_customers_code ON public.crm_customers USING btree (tenant_id, code) WHERE (deleted_at IS NULL);


-- public.pc_pest_categories definition

-- Drop table

-- DROP TABLE public.pc_pest_categories;

CREATE TABLE public.pc_pest_categories (
	id uuid DEFAULT uuidv7() NOT NULL,
	code varchar NOT NULL,
	"name" varchar NOT NULL,
	is_active bool DEFAULT true NOT NULL,
	created_at timestamptz DEFAULT CURRENT_TIMESTAMP NULL,
	updated_at timestamptz DEFAULT CURRENT_TIMESTAMP NULL,
	deleted_at timestamptz NULL,
	created_by uuid NOT NULL,
	updated_by uuid NULL,
	deleted_by uuid NULL,
	CONSTRAINT pest_categories_code_not_null NOT NULL code,
	CONSTRAINT pest_categories_created_by_not_null NOT NULL created_by,
	CONSTRAINT pest_categories_id_not_null NOT NULL id,
	CONSTRAINT pest_categories_is_active_not_null NOT NULL is_active,
	CONSTRAINT pest_categories_name_not_null NOT NULL name,
	CONSTRAINT pest_categories_pkey PRIMARY KEY (id)
);
CREATE UNIQUE INDEX ux_pc_pest_categories_code ON public.pc_pest_categories USING btree (lower((code)::text)) WHERE (deleted_at IS NULL);


-- public.pc_pests definition

-- Drop table

-- DROP TABLE public.pc_pests;

CREATE TABLE public.pc_pests (
	id uuid DEFAULT uuidv7() NOT NULL,
	category_id uuid NOT NULL,
	code varchar NOT NULL,
	"name" varchar NOT NULL,
	is_active bool DEFAULT true NOT NULL,
	created_at timestamptz DEFAULT CURRENT_TIMESTAMP NULL,
	updated_at timestamptz DEFAULT CURRENT_TIMESTAMP NULL,
	deleted_at timestamptz NULL,
	created_by uuid NOT NULL,
	updated_by uuid NULL,
	deleted_by uuid NULL,
	CONSTRAINT pests_category_id_not_null NOT NULL category_id,
	CONSTRAINT pests_code_not_null NOT NULL code,
	CONSTRAINT pests_created_by_not_null NOT NULL created_by,
	CONSTRAINT pests_id_not_null NOT NULL id,
	CONSTRAINT pests_is_active_not_null NOT NULL is_active,
	CONSTRAINT pests_name_not_null NOT NULL name,
	CONSTRAINT pests_pkey PRIMARY KEY (id)
);
CREATE INDEX ix_pc_pests_category_id ON public.pc_pests USING btree (category_id);
CREATE UNIQUE INDEX ux_pc_pests_code ON public.pc_pests USING btree (lower((code)::text)) WHERE (deleted_at IS NULL);


-- public.product_categories definition

-- Drop table

-- DROP TABLE public.product_categories;

CREATE TABLE public.product_categories (
	id uuid DEFAULT uuidv7() NOT NULL,
	tenant_id uuid NOT NULL,
	code varchar NOT NULL,
	"name" varchar NOT NULL,
	kind int2 DEFAULT 0 NOT NULL,
	is_active bool DEFAULT true NOT NULL,
	created_at timestamptz DEFAULT CURRENT_TIMESTAMP NULL,
	updated_at timestamptz DEFAULT CURRENT_TIMESTAMP NULL,
	deleted_at timestamptz NULL,
	created_by uuid NOT NULL,
	updated_by uuid NULL,
	deleted_by uuid NULL,
	CONSTRAINT product_categories_code_not_null NOT NULL code,
	CONSTRAINT product_categories_created_by_not_null NOT NULL created_by,
	CONSTRAINT product_categories_id_not_null NOT NULL id,
	CONSTRAINT product_categories_is_active_not_null NOT NULL is_active,
	CONSTRAINT product_categories_kind_not_null NOT NULL kind,
	CONSTRAINT product_categories_name_not_null NOT NULL name,
	CONSTRAINT product_categories_pkey PRIMARY KEY (id),
	CONSTRAINT product_categories_tenant_id_not_null NOT NULL tenant_id
);
CREATE INDEX ix_product_categories_code ON public.product_categories USING btree (tenant_id, code) WHERE (deleted_at IS NULL);
CREATE INDEX ix_product_categories_kind ON public.product_categories USING btree (tenant_id, kind) WHERE (deleted_at IS NULL);


-- public.products definition

-- Drop table

-- DROP TABLE public.products;

CREATE TABLE public.products (
	id uuid DEFAULT uuidv7() NOT NULL,
	tenant_id uuid NOT NULL,
	category_id uuid NOT NULL,
	uom_id uuid NOT NULL,
	code varchar NOT NULL,
	"name" varchar NOT NULL,
	description varchar NULL,
	cogs numeric(18, 2) DEFAULT 0 NOT NULL,
	is_active bool DEFAULT true NOT NULL,
	created_at timestamptz DEFAULT CURRENT_TIMESTAMP NULL,
	updated_at timestamptz DEFAULT CURRENT_TIMESTAMP NULL,
	deleted_at timestamptz NULL,
	created_by uuid NOT NULL,
	updated_by uuid NULL,
	deleted_by uuid NULL,
	CONSTRAINT products_category_id_not_null NOT NULL category_id,
	CONSTRAINT products_code_not_null NOT NULL code,
	CONSTRAINT products_cogs_not_null NOT NULL cogs,
	CONSTRAINT products_created_by_not_null NOT NULL created_by,
	CONSTRAINT products_id_not_null NOT NULL id,
	CONSTRAINT products_is_active_not_null NOT NULL is_active,
	CONSTRAINT products_name_not_null NOT NULL name,
	CONSTRAINT products_pkey PRIMARY KEY (id),
	CONSTRAINT products_tenant_id_not_null NOT NULL tenant_id,
	CONSTRAINT products_uom_id_not_null NOT NULL uom_id
);
CREATE INDEX ix_products_category ON public.products USING btree (tenant_id, category_id) WHERE (deleted_at IS NULL);
CREATE INDEX ix_products_code ON public.products USING btree (tenant_id, code) WHERE (deleted_at IS NULL);
CREATE INDEX ix_products_name ON public.products USING btree (tenant_id, lower((name)::text)) WHERE (deleted_at IS NULL);
CREATE INDEX ix_products_uom ON public.products USING btree (tenant_id, uom_id);


-- public.sales_contract_categories definition

-- Drop table

-- DROP TABLE public.sales_contract_categories;

CREATE TABLE public.sales_contract_categories (
	id uuid DEFAULT uuidv7() NOT NULL,
	tenant_id uuid NOT NULL,
	"name" varchar NOT NULL,
	created_at timestamptz DEFAULT CURRENT_TIMESTAMP NULL,
	updated_at timestamptz DEFAULT CURRENT_TIMESTAMP NULL,
	deleted_at timestamptz NULL,
	created_by uuid NOT NULL,
	updated_by uuid NULL,
	deleted_by uuid NULL,
	CONSTRAINT sales_contract_categories_created_by_not_null NOT NULL created_by,
	CONSTRAINT sales_contract_categories_id_not_null NOT NULL id,
	CONSTRAINT sales_contract_categories_name_not_null NOT NULL name,
	CONSTRAINT sales_contract_categories_pkey PRIMARY KEY (id),
	CONSTRAINT sales_contract_categories_tenant_id_not_null NOT NULL tenant_id
);
CREATE INDEX ix_sales_contract_categories_tenant ON public.sales_contract_categories USING btree (tenant_id) WHERE (deleted_at IS NULL);
CREATE UNIQUE INDEX ux_sales_contract_categories_name ON public.sales_contract_categories USING btree (tenant_id, lower((name)::text)) WHERE (deleted_at IS NULL);


-- public.sales_contracts definition

-- Drop table

-- DROP TABLE public.sales_contracts;

CREATE TABLE public.sales_contracts (
	id uuid DEFAULT uuidv7() NOT NULL,
	tenant_id uuid NOT NULL,
	service_id uuid NOT NULL,
	customer_id uuid NOT NULL,
	code varchar NOT NULL,
	category_id uuid NOT NULL,
	signed_date date NULL,
	start_date date NOT NULL,
	end_date date NULL,
	first_invoice_date date NULL,
	total_visits int4 NULL,
	contract_value numeric(18, 2) DEFAULT 0 NOT NULL,
	payment_type_id int2 DEFAULT 1 NOT NULL,
	signatory_name varchar NULL,
	signatory_position varchar NULL,
	status int2 DEFAULT 1 NOT NULL,
	terminated_at date NULL,
	termination_reason varchar NULL,
	notes varchar NULL,
	created_by uuid NULL,
	updated_by uuid NULL,
	deleted_by uuid NULL,
	created_at timestamptz DEFAULT now() NOT NULL,
	updated_at timestamptz DEFAULT now() NOT NULL,
	deleted_at timestamptz NULL,
	CONSTRAINT sales_contracts_category_id_not_null NOT NULL category_id,
	CONSTRAINT sales_contracts_code_not_null NOT NULL code,
	CONSTRAINT sales_contracts_contract_value_not_null NOT NULL contract_value,
	CONSTRAINT sales_contracts_created_at_not_null NOT NULL created_at,
	CONSTRAINT sales_contracts_customer_id_not_null NOT NULL customer_id,
	CONSTRAINT sales_contracts_id_not_null NOT NULL id,
	CONSTRAINT sales_contracts_payment_type_id_not_null NOT NULL payment_type_id,
	CONSTRAINT sales_contracts_pkey PRIMARY KEY (id),
	CONSTRAINT sales_contracts_service_id_not_null NOT NULL service_id,
	CONSTRAINT sales_contracts_start_date_not_null NOT NULL start_date,
	CONSTRAINT sales_contracts_status_not_null NOT NULL status,
	CONSTRAINT sales_contracts_tenant_id_not_null NOT NULL tenant_id,
	CONSTRAINT sales_contracts_updated_at_not_null NOT NULL updated_at
);
CREATE INDEX ix_sales_contracts_category ON public.sales_contracts USING btree (tenant_id, category_id);
CREATE INDEX ix_sales_contracts_code ON public.sales_contracts USING btree (tenant_id, code) WHERE (deleted_at IS NULL);
CREATE INDEX ix_sales_contracts_customer ON public.sales_contracts USING btree (tenant_id, customer_id, status) WHERE (deleted_at IS NULL);
CREATE INDEX ix_sales_contracts_expiring ON public.sales_contracts USING btree (tenant_id, end_date) WHERE ((status = 2) AND (deleted_at IS NULL));
CREATE INDEX ix_sales_contracts_invoice_due ON public.sales_contracts USING btree (tenant_id, first_invoice_date) WHERE ((first_invoice_date IS NOT NULL) AND (deleted_at IS NULL));
CREATE INDEX ix_sales_contracts_period ON public.sales_contracts USING btree (tenant_id, start_date, end_date) WHERE (deleted_at IS NULL);
CREATE INDEX ix_sales_contracts_service ON public.sales_contracts USING btree (tenant_id, service_id) WHERE (deleted_at IS NULL);


-- public.sales_proposals definition

-- Drop table

-- DROP TABLE public.sales_proposals;

CREATE TABLE public.sales_proposals (
	id uuid DEFAULT uuidv7() NOT NULL,
	tenant_id uuid NOT NULL,
	customer_id uuid NOT NULL,
	service_id uuid NOT NULL,
	code varchar NOT NULL,
	address_id uuid NULL,
	pricing_id uuid NULL,
	"version" int2 DEFAULT 1 NOT NULL,
	parent_id uuid NULL,
	proposal_date date NOT NULL,
	valid_until date NULL,
	total_amount numeric(18, 2) DEFAULT 0 NOT NULL,
	status int2 DEFAULT 1 NOT NULL,
	sent_at timestamptz NULL,
	decided_at timestamptz NULL,
	rejection_reason varchar NULL,
	notes varchar NULL,
	created_at timestamptz DEFAULT CURRENT_TIMESTAMP NULL,
	updated_at timestamptz DEFAULT CURRENT_TIMESTAMP NULL,
	deleted_at timestamptz NULL,
	created_by uuid NOT NULL,
	updated_by uuid NULL,
	deleted_by uuid NULL,
	CONSTRAINT sales_proposals_code_not_null NOT NULL code,
	CONSTRAINT sales_proposals_created_by_not_null NOT NULL created_by,
	CONSTRAINT sales_proposals_customer_id_not_null NOT NULL customer_id,
	CONSTRAINT sales_proposals_id_not_null NOT NULL id,
	CONSTRAINT sales_proposals_pkey PRIMARY KEY (id),
	CONSTRAINT sales_proposals_proposal_date_not_null NOT NULL proposal_date,
	CONSTRAINT sales_proposals_service_id_not_null NOT NULL service_id,
	CONSTRAINT sales_proposals_status_not_null NOT NULL status,
	CONSTRAINT sales_proposals_tenant_id_not_null NOT NULL tenant_id,
	CONSTRAINT sales_proposals_total_amount_not_null NOT NULL total_amount,
	CONSTRAINT sales_proposals_version_not_null NOT NULL version
);
CREATE INDEX ix_sales_proposals_address ON public.sales_proposals USING btree (tenant_id, address_id);
CREATE INDEX ix_sales_proposals_code ON public.sales_proposals USING btree (tenant_id, code, version) WHERE (deleted_at IS NULL);
CREATE INDEX ix_sales_proposals_customer ON public.sales_proposals USING btree (tenant_id, customer_id, status) WHERE (deleted_at IS NULL);
CREATE INDEX ix_sales_proposals_open ON public.sales_proposals USING btree (tenant_id, valid_until) WHERE ((status = 2) AND (deleted_at IS NULL));
CREATE INDEX ix_sales_proposals_parent ON public.sales_proposals USING btree (tenant_id, parent_id);
CREATE INDEX ix_sales_proposals_pricing ON public.sales_proposals USING btree (tenant_id, pricing_id);
CREATE INDEX ix_sales_proposals_service ON public.sales_proposals USING btree (tenant_id, service_id) WHERE (deleted_at IS NULL);


-- public.sales_segments definition

-- Drop table

-- DROP TABLE public.sales_segments;

CREATE TABLE public.sales_segments (
	id uuid DEFAULT uuidv7() NOT NULL,
	tenant_id uuid NOT NULL,
	"name" varchar NOT NULL,
	created_at timestamptz DEFAULT CURRENT_TIMESTAMP NULL,
	updated_at timestamptz DEFAULT CURRENT_TIMESTAMP NULL,
	deleted_at timestamptz NULL,
	created_by uuid NOT NULL,
	updated_by uuid NULL,
	deleted_by uuid NULL,
	CONSTRAINT sales_segments_created_by_not_null NOT NULL created_by,
	CONSTRAINT sales_segments_id_not_null NOT NULL id,
	CONSTRAINT sales_segments_name_not_null NOT NULL name,
	CONSTRAINT sales_segments_pkey PRIMARY KEY (id),
	CONSTRAINT sales_segments_tenant_id_not_null NOT NULL tenant_id
);
CREATE INDEX ix_sales_segments_tenant ON public.sales_segments USING btree (tenant_id) WHERE (deleted_at IS NULL);
CREATE UNIQUE INDEX ux_sales_segments_name ON public.sales_segments USING btree (tenant_id, lower((name)::text)) WHERE (deleted_at IS NULL);


-- public.services definition

-- Drop table

-- DROP TABLE public.services;

CREATE TABLE public.services (
	id uuid DEFAULT uuidv7() NOT NULL,
	tenant_id uuid NOT NULL,
	code varchar NOT NULL,
	"name" varchar NOT NULL,
	proposal_template_id uuid NULL,
	is_active bool DEFAULT true NOT NULL,
	created_at timestamptz DEFAULT CURRENT_TIMESTAMP NULL,
	updated_at timestamptz DEFAULT CURRENT_TIMESTAMP NULL,
	deleted_at timestamptz NULL,
	created_by uuid NOT NULL,
	updated_by uuid NULL,
	deleted_by uuid NULL,
	CONSTRAINT services_code_not_null NOT NULL code,
	CONSTRAINT services_created_by_not_null NOT NULL created_by,
	CONSTRAINT services_id_not_null NOT NULL id,
	CONSTRAINT services_is_active_not_null NOT NULL is_active,
	CONSTRAINT services_name_not_null NOT NULL name,
	CONSTRAINT services_pkey PRIMARY KEY (id),
	CONSTRAINT services_tenant_id_not_null NOT NULL tenant_id
);
CREATE INDEX ix_services_active ON public.services USING btree (tenant_id, is_active) WHERE (deleted_at IS NULL);
CREATE INDEX ix_services_code ON public.services USING btree (tenant_id, code) WHERE (deleted_at IS NULL);
CREATE INDEX ix_services_template ON public.services USING btree (tenant_id, proposal_template_id);


-- public.units_of_measure definition

-- Drop table

-- DROP TABLE public.units_of_measure;

CREATE TABLE public.units_of_measure (
	id uuid DEFAULT uuidv7() NOT NULL,
	tenant_id uuid NOT NULL,
	code varchar NOT NULL,
	"name" varchar NOT NULL,
	is_active bool DEFAULT true NOT NULL,
	created_at timestamptz DEFAULT CURRENT_TIMESTAMP NULL,
	updated_at timestamptz DEFAULT CURRENT_TIMESTAMP NULL,
	deleted_at timestamptz NULL,
	created_by uuid NOT NULL,
	updated_by uuid NULL,
	deleted_by uuid NULL,
	CONSTRAINT units_of_measure_code_not_null NOT NULL code,
	CONSTRAINT units_of_measure_created_by_not_null NOT NULL created_by,
	CONSTRAINT units_of_measure_id_not_null NOT NULL id,
	CONSTRAINT units_of_measure_is_active_not_null NOT NULL is_active,
	CONSTRAINT units_of_measure_name_not_null NOT NULL name,
	CONSTRAINT units_of_measure_pkey PRIMARY KEY (id),
	CONSTRAINT units_of_measure_tenant_id_not_null NOT NULL tenant_id
);
CREATE INDEX ix_units_of_measure_code ON public.units_of_measure USING btree (tenant_id, code) WHERE (deleted_at IS NULL);


-- public.crm_customer_addresses definition

-- Drop table

-- DROP TABLE public.crm_customer_addresses;

CREATE TABLE public.crm_customer_addresses (
	id uuid DEFAULT uuidv7() NOT NULL,
	tenant_id uuid NOT NULL,
	customer_id uuid NOT NULL,
	"label" varchar NOT NULL,
	address_line varchar NOT NULL,
	province_id int8 NULL,
	regency_id int8 NULL,
	district_id int8 NULL,
	village_id int8 NULL,
	area_size numeric(10, 2) NULL,
	uom_id uuid NULL,
	latitude numeric(10, 7) NULL,
	longitude numeric(10, 7) NULL,
	is_primary bool DEFAULT false NULL,
	created_at timestamptz DEFAULT CURRENT_TIMESTAMP NULL,
	updated_at timestamptz DEFAULT CURRENT_TIMESTAMP NULL,
	deleted_at timestamptz NULL,
	created_by uuid NOT NULL,
	updated_by uuid NULL,
	deleted_by uuid NULL,
	CONSTRAINT crm_customer_addresses_address_line_not_null NOT NULL address_line,
	CONSTRAINT crm_customer_addresses_created_by_not_null NOT NULL created_by,
	CONSTRAINT crm_customer_addresses_customer_id_not_null NOT NULL customer_id,
	CONSTRAINT crm_customer_addresses_id_not_null NOT NULL id,
	CONSTRAINT crm_customer_addresses_label_not_null NOT NULL label,
	CONSTRAINT crm_customer_addresses_pkey PRIMARY KEY (id),
	CONSTRAINT crm_customer_addresses_tenant_id_not_null NOT NULL tenant_id,
	CONSTRAINT crm_customer_addresses_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.crm_customers(id)
);
CREATE INDEX ix_crm_customer_addresses_customer ON public.crm_customer_addresses USING btree (tenant_id, customer_id) WHERE (deleted_at IS NULL);


-- public.crm_customer_contacts definition

-- Drop table

-- DROP TABLE public.crm_customer_contacts;

CREATE TABLE public.crm_customer_contacts (
	id uuid DEFAULT uuidv7() NOT NULL,
	tenant_id uuid NOT NULL,
	customer_id uuid NOT NULL,
	"name" varchar NOT NULL,
	"position" varchar NULL,
	email varchar NULL,
	phone varchar NULL,
	"role" int2 DEFAULT 1 NOT NULL,
	is_primary bool DEFAULT false NULL,
	created_at timestamptz DEFAULT CURRENT_TIMESTAMP NULL,
	updated_at timestamptz DEFAULT CURRENT_TIMESTAMP NULL,
	deleted_at timestamptz NULL,
	created_by uuid NOT NULL,
	updated_by uuid NULL,
	deleted_by uuid NULL,
	CONSTRAINT crm_customer_contacts_created_by_not_null NOT NULL created_by,
	CONSTRAINT crm_customer_contacts_customer_id_not_null NOT NULL customer_id,
	CONSTRAINT crm_customer_contacts_id_not_null NOT NULL id,
	CONSTRAINT crm_customer_contacts_name_not_null NOT NULL name,
	CONSTRAINT crm_customer_contacts_pkey PRIMARY KEY (id),
	CONSTRAINT crm_customer_contacts_role_not_null NOT NULL role,
	CONSTRAINT crm_customer_contacts_tenant_id_not_null NOT NULL tenant_id,
	CONSTRAINT crm_customer_contacts_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.crm_customers(id)
);
CREATE INDEX ix_crm_customer_contacts_customer ON public.crm_customer_contacts USING btree (tenant_id, customer_id) WHERE (deleted_at IS NULL);
```