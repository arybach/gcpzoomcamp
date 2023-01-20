-- #3
-- count all trips starting and ending on the '2019.01.15'
with dates as (
	select index, date_trunc('day',lpep_pickup_datetime) as start_date, date_trunc('day', lpep_dropoff_datetime) as end_date
	from yellow_taxi_trips
),
filtered as (
	select dates.index, dates.start_date, dates.end_date 
	from dates
	where dates.start_date = '2019.01.15' and dates.end_date = '2019.01.15'
)
select count(*) 
from yellow_taxi_trips ytt 
where ytt.index in (select f.index from filtered f)
-- count 20,530

-- #4
-- longest trips starting on the '2019.01.18','2019.01.28','2019.01.15','2019.01.10'
with dates as (
	select index, date_trunc('day',lpep_pickup_datetime) as start_date, trip_distance
	from yellow_taxi_trips
),
filtered as (
	select dates.start_date, max(trip_distance) as max_trip_distance  
	from dates
	group by dates.start_date
	having dates.start_date in ('2019.01.18','2019.01.28','2019.01.15','2019.01.10')
)
select * 
from yellow_taxi_trips ytt, filtered f 
where ytt.trip_distance = f.max_trip_distance
-- 2019.01.18 80.96
-- 2019.01.28 64.27
-- 2019.01.15 117.99
-- 2019.01.10 64.2

-- #5
-- in 2019-01-01 how many trips had 2 and 3 passengers?
with dates as (
	select index, passenger_count, date_trunc('day',lpep_pickup_datetime) as start_date, date_trunc('day', lpep_dropoff_datetime) as end_date
	from yellow_taxi_trips
),
filtered as (
	select dates.index, dates.passenger_count, dates.start_date, dates.end_date 
	from dates
	where dates.start_date = '2019.01.01' --and dates.end_date = '2019.01.01'
	and passenger_count in (2,3)
),
grouped as (
	select ytt.index, passenger_count  
	from yellow_taxi_trips ytt 
	where ytt.index in (select f.index from filtered f)
)
select passenger_count, count(*) 
from grouped
group by passenger_count
-- 2 - 1282
-- 3 - 254 

-- #6
-- For the passengers picked up in the Astoria Zone which was the drop off zone that had the largest tip? 
-- We want the name of the zone, not the id.
-- PULocationID
-- DOLocationID
-- from taxi_zones LocationID, Borough, Zone (this one is the name), service_zone
with pickups as (
	select ytt."PULocationID", max(ytt.tip_amount) as max_tip 
	from yellow_taxi_trips ytt 
	group by ytt."PULocationID"
	having ytt."PULocationID" in 
	(select tz."LocationID" 
	from taxi_zones tz
	where tz."Zone"  = 'Astoria')
),
dropoffs as (
	select ytt."index", ytt.lpep_pickup_datetime, ytt.lpep_dropoff_datetime, ytt."PULocationID", ytt."DOLocationID",
	ytt.trip_distance, ytt.fare_amount, ytt.tip_amount
	from yellow_taxi_trips ytt, pickups
	where ytt.tip_amount = pickups.max_tip and ytt."PULocationID" in (select pickups."PULocationID" from pickups)
)
select df.index, df.lpep_pickup_datetime, df.lpep_dropoff_datetime, df."PULocationID", df."DOLocationID", 
tz."Zone", df.trip_distance, df.fare_amount, df.tip_amount
from dropoffs df, taxi_zones tz
where tz."LocationID" = df."DOLocationID"
-- Long Island City/Queens Plaza

--select ytt."PULocationID", max(ytt.tip_amount) as max_tip 
--from yellow_taxi_trips ytt 
--group by ytt."PULocationID"
