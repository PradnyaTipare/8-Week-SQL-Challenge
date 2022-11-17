------------------------
--    DATA CLEANING   --
------------------------

-- TABLE: customer_orders

/* Removed null values from columns extras and exclusions and changed the data type*/

UPDATE customer_orders
set extras = null
where extras = 'null';

UPDATE customer_orders
set exclusions = null
where exclusions = 'null';

-- TABLE: runner_orders

/* trimmed characters from column duration and distance, removed null values and changed the data type*/

UPDATE runner_orders
set duration = trim(case when position('minutes' in duration) >0 then trim('minutes' from duration)
							when position('mins' in duration)>0 then trim('mins' from duration)
                            when position('minute' in duration)>0 then trim('minute' from duration) 
                            when duration = 'null' then null
                            else duration end);
                            
UPDATE runner_orders
SET distance = trim(case when position('km' in distance) >0 then trim('km' from distance)
							when distance = 'null' then null 
                            else distance end);

UPDATE runner_orders
SET pickup_time = null
where pickup_time = 'null';

UPDATE runner_orders
SET cancellation = null
where cancellation in ('null','');
                            
ALTER TABLE runner_orders
MODIFY COLUMN pickup_time timestamp,
MODIFY COLUMN distance decimal(10,2),
modify column duration integer;