## Problem Statment

https://github.com/DataTalksClub/data-engineering-zoomcamp/blob/main/cohorts/2024/01-docker-terraform/homework.md

## Start a Postgres Database
```
docker run  -it --name dtc --restart=always -p 5433:5432 -e POSTGRES_PASSWORD=local -e POSTGRES_USER=local -e POSTGRES_DB=local -d postgres:15.2
```


## Login to db

```
psql -h localhost -p 5433 -U local -d local 
```

## Create tables

### Zones
```
CREATE TABLE zones (
  LocationID INT, 
  Borough VARCHAR(50), 
  Zone VARCHAR(50),
  service_zone VARCHAR(50)
);
```

### Trips

```
CREATE TABLE trips (
  VendorID INT,
  lpep_pickup_datetime TIMESTAMP,
  lpep_dropoff_datetime TIMESTAMP,
  store_and_fwd_flag VARCHAR(2),
  RatecodeID INT,
  PULocationID INT,
  DOLocationID INT,
  passenger_count INT,
  trip_distance DECIMAL,
  fare_amount DECIMAL,
  extra DECIMAL,
  mta_tax DECIMAL,
  tip_amount DECIMAL,
  tolls_amount DECIMAL,
  ehail_fee DECIMAL,
  improvement_surcharge DECIMAL,
  total_amount DECIMAL,
  payment_type INT,
  trip_type INT,
  congestion_surcharge DECIMAL
);
```

## Importing data

```
cd datatalksclub-zoomcamp/01-docker-terraform/
psql -h localhost -p 5433 -U local -d local  -c "\copy zones (LocationID, Borough, Zone, service_zone) FROM './taxi+_zone_lookup.csv' WITH DELIMITER ',' CSV HEADER;"

psql -h localhost -p 5433 -U local -d local  -c "\copy trips (VendorID,lpep_pickup_datetime,lpep_dropoff_datetime,store_and_fwd_flag,RatecodeID,PULocationID,DOLocationID,passenger_count,trip_distance,fare_amount,extra,mta_tax,tip_amount,tolls_amount,ehail_fee,improvement_surcharge,total_amount,payment_type,trip_type,congestion_surcharge
) FROM './green_tripdata_2019-09.csv' WITH DELIMITER ',' CSV HEADER;"
```


## Count records

How many taxi trips were totally made on September 18th 2019?

Tip: started and finished on 2019-09-18.

Remember that lpep_pickup_datetime and lpep_dropoff_datetime columns are in the format timestamp (date and hour+min+sec) and not in date.
```
 select count(*) from trips where TO_CHAR((lpep_pickup_datetime), 'YYYY-MM-DD') = '2019-09-18' and TO_CHAR((lpep_dropoff_datetime), 'YYYY-MM-DD') = '2019-09-18';
```


### Largest trip for each day

Which was the pick up day with the largest trip distance Use the pick up time for your calculations.

```
 select lpep_pickup_datetime from trips order by trip_distance desc limit 1;
```

### Three biggest pick up Boroughs

Consider lpep_pickup_datetime in '2019-09-18' and ignoring Borough has Unknown

Which were the 3 pick up Boroughs that had a sum of total_amount superior to 50000?
```
 select z.Borough, sum(total_amount)
 from zones z 
 inner join trips t
 on t.PULocationID = z.LocationID
 where z.Borough != 'Unknown'
 group by z.Borough 
 having sum(total_amount) > 50000.0
 order by sum(total_amount) desc;
```

### Largest tip

```
 select z.service_zone, sum(t.tip_amount)
 from trips t
 inner join zones z
 on z.LocationID = t.PULocationID
 where TO_CHAR((t.lpep_pickup_datetime), 'YYYY-MM') = '2019-09' and t.DOLocationID in (select LocationID from zones where zone = 'Astoria')
 group by z.service_zone
 order by sum(t.tip_amount) desc;
```

