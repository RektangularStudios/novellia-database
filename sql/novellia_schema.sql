-- extensions
CREATE extension IF NOT EXISTS "uuid-ossp";

-- schema
CREATE SCHEMA novellia;

-- organization
CREATE TABLE IF NOT EXISTS novellia.organization (
  organization_id          TEXT PRIMARY KEY,
  organization_name        TEXT NOT NULL,
  organization_description TEXT NOT NULL,
  created                  TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
  modified                 TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
  deleted                  TIMESTAMPTZ
);

-- market
CREATE TABLE IF NOT EXISTS novellia.market (
  market_id          TEXT PRIMARY KEY,
  market_name        TEXT NOT NULL,
  market_description TEXT NOT NULL,
  created            TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
  modified           TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
  deleted            TIMESTAMPTZ
);

-- product
CREATE TABLE IF NOT EXISTS novellia.native_token (
  native_token_id  TEXT PRIMARY KEY,
  policy_id        TEXT NOT NULL,
  asset_id         TEXT NOT NULL,
  created          TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
  modified         TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
  deleted          TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS novellia.product (
  product_id             TEXT PRIMARY KEY,
  product_name           TEXT NOT NULL,
  organization_id        TEXT REFERENCES novellia.organization NOT NULL,
  market_id              TEXT REFERENCES novellia.market NOT NULL,
  -- pricing
  price_currency_id      TEXT,
  price_unit_amount      DECIMAL CHECK(price_unit_amount >= 0),
  max_order_size         INTEGER CHECK(max_order_size >= 0),
  -- metadata
  date_listed            TIMESTAMPTZ,
  date_available         TIMESTAMPTZ,
  -- product details
  native_token_id        TEXT REFERENCES novellia.native_token,
  created                TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
  modified               TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
  deleted                TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS novellia.commission (
  commission_id        uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  product_id           TEXT REFERENCES novellia.product NOT NULL,
  recipient_name       TEXT NOT NULL,
  recipient_address    TEXT NOT NULL,
  commission_percent   DECIMAL CHECK(commission_percent >= 0),
  created              TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
  modified             TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
  deleted              TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS novellia.remote_resource (
  remote_resource_id   uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  product_id           TEXT REFERENCES novellia.product NOT NULL,
  resource_id          TEXT NOT NULL,
  resource_description TEXT NOT NULL,
  priority             INTEGER NOT NULL CHECK(priority >= 0),
  multihash            TEXT NOT NULL,
  hash_source_type     TEXT NOT NULL,
  resource_urls        TEXT[] NOT NULL,
  content_type         TEXT NOT NULL,
  created              TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
  modified             TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
  deleted              TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS novellia.product_detail (
  product_id              TEXT PRIMARY KEY REFERENCES novellia.product,
  copyright               TEXT NOT NULL,
  publisher               TEXT[] NOT NULL,
  product_version         INTEGER NOT NULL CHECK(product_version >= 0),
  id                      INTEGER CHECK(id >= 0),
  tags                    TEXT[],
  description_short       TEXT,
  description_long        TEXT,
  -- stock
  stock_available         DECIMAL CHECK(stock_available >= 0),
  total_supply            DECIMAL CHECK(total_supply >= 0),
  created                 TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
  modified                TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
  deleted                 TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS novellia.product_attribution(
  attribution_id    uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  product_id        TEXT REFERENCES novellia.product NOT NULL,
  author_name       TEXT NOT NULL,
  author_urls       TEXT[],
  work_attributed   TEXT NOT NULL,
  created           TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
  modified          TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
  deleted           TIMESTAMPTZ
);

-- triggers
CREATE OR REPLACE FUNCTION novellia.set_modified_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.modified = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DO $$
DECLARE
    t record;
BEGIN
    FOR t IN 
        SELECT * FROM information_schema.columns
        WHERE
          column_name = 'modified' AND
          table_schema = 'novellia'
    LOOP
        EXECUTE format('CREATE TRIGGER trigger_set_modified_timestamp
                        BEFORE UPDATE ON %I.%I
                        FOR EACH ROW EXECUTE PROCEDURE novellia.set_modified_timestamp()',
                        t.table_schema, t.table_name);
    END LOOP;
END;
$$ LANGUAGE plpgsql;