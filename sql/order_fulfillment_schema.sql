-- extensions
CREATE extension IF NOT EXISTS "uuid-ossp";

-- schema
CREATE SCHEMA order_fulfillment;

-- order
CREATE TABLE IF NOT EXISTS order_fulfillment.customer_order (
  customer_order_id TEXT PRIMARY KEY,
  order_status      TEXT NOT NULL,
  order_description TEXT NOT NULL,
  checked_last      TIMESTAMPTZ,
  -- customer
  delivery_address  TEXT NOT NULL,
  -- reservation
  reserved          BOOLEAN DEFAULT FALSE NOT NULL,
  reserved_until    TIMESTAMPTZ,
  -- payment
  payment_address   TEXT NOT NULL,
  price_currency_id TEXT NOT NULL,
  price_amount      DECIMAL CHECK(price_amount >= 0) NOT NULL,
  created           TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
  modified          TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
  deleted           TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS order_fulfillment.customer_order_item(
  customer_order_item_id   uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  customer_order_id        TEXT REFERENCES order_fulfillment.customer_order NOT NULL,
  product_id               TEXT REFERENCES novellia.product NOT NULL,
  quantity                 INTEGER NOT NULL CHECK(quantity >= 0),
  created                  TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
  modified                 TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
  deleted                  TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS order_fulfillment.cardano_transaction(
  cardano_transaction_id   uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  customer_order_id        TEXT REFERENCES order_fulfillment.customer_order NOT NULL,
  txid                     TEXT NOT NULL,
  created                  TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
  modified                 TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
  deleted                  TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS order_fulfillment.now_payments_payment(
  payment_id               TEXT PRIMARY KEY,
  payment_status           TEXT NOT NULL,
  pay_address              TEXT NOT NULL,
  price_amount             DECIMAL NOT NULL,
  price_currency           TEXT NOT NULL,
  pay_amount               DECIMAL NOT NULL,
  actually_paid            DECIMAL,
  pay_currency             TEXT NOT NULL,
  customer_order_id        TEXT REFERENCES order_fulfillment.customer_order NOT NULL,
  order_description        TEXT NOT NULL,
  purchase_id              TEXT NOT NULL,
  now_payments_created_at  TIMESTAMPTZ NOT NULL,
  now_payments_updated_at  TIMESTAMPTZ NOT NULL,
  outcome_amount           DECIMAL,
  outcome_currency         TEXT,
  ipn_callback_url         TEXT NOT NULL,
  created                  TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
  modified                 TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
  deleted                  TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS order_fulfillment.customer_order_native_tokens(
  customer_order_native_tokens_id   uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  customer_order_id                 TEXT REFERENCES order_fulfillment.customer_order NOT NULL,
  native_token_id                   TEXT REFERENCES novellia.native_token NOT NULL,
  quantity                          INTEGER NOT NULL CHECK(quantity >= 0)
);

-- triggers
CREATE OR REPLACE FUNCTION order_fulfillment.set_modified_timestamp()
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
          table_schema = 'order_fulfillment'
    LOOP
        EXECUTE format('CREATE TRIGGER trigger_set_modified_timestamp
                        BEFORE UPDATE ON %I.%I
                        FOR EACH ROW EXECUTE PROCEDURE order_fulfillment.set_modified_timestamp()',
                        t.table_schema, t.table_name);
    END LOOP;
END;
$$ LANGUAGE plpgsql;