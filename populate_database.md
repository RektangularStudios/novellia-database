Create database
```
CREATE DATABASE novellia_bravo OWNER rektangular;
```

Drop schema
```
psql -U rektangular -d novellia

DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO postgres;
ALTER SCHEMA public OWNER to rektangular;

DROP SCHEMA novellia CASCADE;
CREATE SCHEMA novellia;
GRANT ALL ON SCHEMA novellia TO postgres;
ALTER SCHEMA novellia OWNER to rektangular;

DROP SCHEMA order_fulfillment CASCADE;
CREATE SCHEMA order_fulfillment;
GRANT ALL ON SCHEMA order_fulfillment TO postgres;
ALTER SCHEMA order_fulfillment OWNER to rektangular;
```

Rebuild schema
```
psql -U rektangular -d novellia_alpha -f ./novellia_schema.sql
psql -U rektangular -d novellia_alpha -f ./order_fulfillment_schema.sql
```

Execute copy to populate data
```
psql -U rektangular -d novellia

# on server

\cd /novellia-database/data/
\! pwd

\copy novellia.organization(organization_id, organization_name, organization_description) FROM './organization.csv' DELIMITER ',' CSV HEADER

\copy novellia.market(market_id, market_name, market_description) FROM './market.csv' DELIMITER ',' CSV HEADER

\copy novellia.native_token(native_token_id, policy_id, asset_id) FROM './native_token.csv' DELIMITER ',' CSV HEADER

\copy novellia.product(product_id,product_name,organization_id,market_id,price_currency_id,price_unit_amount,max_order_size,date_listed,date_available,native_token_id) FROM './product.csv' DELIMITER ',' CSV HEADER

\copy novellia.commission(product_id,recipient_name,recipient_address,commission_percent) FROM './commission.csv' DELIMITER ',' CSV HEADER

\copy novellia.remote_resource(product_id,resource_id,resource_description,priority,multihash,hash_source_type,resource_urls,content_type) FROM './remote_resource.csv' DELIMITER ',' CSV HEADER

\copy novellia.product_detail(product_id,copyright,publisher,product_version,id,tags,description_short,description_long,stock_available,total_supply) FROM './product_detail.csv' DELIMITER ',' CSV HEADER

\copy novellia.product_attribution(product_id,author_name,author_urls,work_attributed) FROM './product_attribution.csv' DELIMITER ',' CSV HEADER
```
