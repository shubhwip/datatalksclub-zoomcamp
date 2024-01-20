COPY zones(LocationID, Borough, Zone, service_zone)
FROM '/Users/shubhamjain/Yapily/ext/sj/datatalksclub-zoomcamp/01-docker-terraform/import.sql'
DELIMITER ','
CSV HEADER;