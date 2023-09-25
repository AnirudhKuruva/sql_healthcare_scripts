--  Problem Statement 1:
-- The healthcare department has requested a system to analyze the performance of insurance companies and their plan.
-- For this purpose, create a stored procedure that returns the performance of different insurance plans
--  of an insurance company. When passed the insurance company ID the procedure should generate and return all 
-- the insurance plan names the provided company issues, the number of treatments the plan was claimed for, 
-- and the name of the disease the plan was claimed for the most. The plans which are claimed more are expected to 
-- appear above the plans that are claimed less.
delimiter //
create procedure insurance_company_report(in cmp_id int)
begin
with cte as(
	select planname,uin,diseaseid,count(claimid) as claims_diseasewise,
    row_number() over(partition by planname order by count(claimid) desc) as row_no
    from 
	insuranceplan join claim using(uin) join treatment using(claimid)
    where companyid=cmp_id 
    group by 1,2,3)
    select planname,total_claims,diseaseid as most_claimed_disease from 
    (select planname,sum(claims_diseasewise) as total_claims from cte
    group by 1 )t1
    join 
    (select * from cte where row_no=1)t2 using(planname)
    ;
end //
delimiter ;
call insurance_company_report(149);
use healthcare;
-- Problem Statement 2:
-- It was reported by some unverified sources that some pharmacies are more popular for certain diseases. 
-- The healthcare department wants to check the validity of this report.
-- Create a stored procedure that takes a disease name as a parameter and would return the top 3 pharmacies 
-- the patients are preferring for the treatment of that disease in 2021 as well as for 2022.
-- Check if there are common pharmacies in the top 3 list for a disease, in the years 2021 and the year 2022.
-- Call the stored procedure by passing the values “Asthma” and “Psoriasis” as disease names and draw a 
-- conclusion from the result.

drop procedure popularity;
delimiter //
create procedure popularity(in dname varchar(20))
begin
with cte as (select pharmacyname, dense_rank() over(order by count(*) desc) as res_2021
from disease join treatment using(diseaseid) join 
prescription using(treatmentid) 
join pharmacy using(pharmacyid) where diseasename = dname and year(date) = 2021 
group by pharmacyName) ,
cte2 as (select pharmacyname, dense_rank() over(order by count(*) desc) as res_2022
from disease join treatment using(diseaseid) join 
prescription using(treatmentid) 
join pharmacy using(pharmacyid) where diseasename = dname and year(date) = '2022' 
group by pharmacyName)
select * from cte join cte2 using(pharmacyname) order by res_2021, res_2022 asc ;
end //
delimiter ;
call popularity('Asthma');




-- Problem Statement 3:
-- Jacob, as a business strategist, wants to figure out if a state is appropriate for setting up an 
-- insurance company or not.
-- Write a stored procedure that finds the num_patients, num_insurance_companies, and insurance_patient_ratio,
-- the stored procedure should also find the avg_insurance_patient_ratio and if the insurance_patient_ratio of
-- the given state is less than the avg_insurance_patient_ratio then it Recommendation section can have the
-- value “Recommended” otherwise the value can be “Not Recommended”.
delimiter //
create procedure report_on_recomendation(in in_state varchar(20))
begin 
	declare total_avg decimal(16,2);
	declare state_avg decimal(16,2);
	declare state_patients int;
	declare state_companies int;
	select count(distinct p.patientID) / count(distinct i.companyID) into total_avg from insurancecompany i , patient p ;
	select count(distinct patientID) into state_patients from 
	patient p join person p2 on p.patientID = p2.personID 
	join address a using(addressID) where a.state = in_state;
	select count(distinct i.companyID) into state_companies from address a join insurancecompany i 
	using(addressID) where a.state = in_state;
    set state_avg = state_patients/state_companies;
	select  state_patients, state_companies, state_avg as patient_to_companies_ratio,
		case 
		when state_avg > total_avg then 'Not recommended'
		else 'Recommended'
		end as 'Recommendation'	;
end //
delimiter ;
call report_on_recomendation('OK');

-- Problem Statement 4:
-- Currently, the data from every state is not in the database, The management has decided to add the data
-- from other states and cities as well. It is felt by the management that it would be helpful if the date
-- and time were to be stored whenever new city or state data is inserted.
-- The management has sent a requirement to create a PlacesAdded table if it doesn’t already exist, that 
-- has four attributes. placeID, placeName, placeType, and timeAdded

create table if not exists PlacesAdded(
 placeID int auto_increment primary key ,
 placeName varchar(50) unique,
 placeType varchar(10) not null,
 timeAdded datetime not null);
 
 delimiter //
 create trigger for_PlacesAdded
 after insert on address for each row
 begin
	insert into PlacesAdded(placeName,placeType,timeAdded) values(new.city,'city',now());
    insert into PlacesAdded(placeName,placeType,timeAdded) values(new.state,'state',now());
 end//
 delimiter ;
 insert into address values(123,"yyyyyy-yy","demo city","demo state",12345);
select * from PlacesAdded;
set sql_safe_updates=0;
delete from address where city="demo city";
-- 5.Some pharmacies suspect there is some discrepancy in their inventory management. The quantity in the
--  ‘Keep’ is updated regularly and there is no record of it. They have requested to create a system that
--  keeps track of all the transactions whenever the quantity of the inventory is updated.

create table if not exists Keep_Log(
id int auto_increment primary key,
medicineID int not null,
quantity int not null);

delimiter //
create trigger update_log
after update on keep for each row
begin
if old.quantity <> new.quantity then
	insert into Keep_Log(medicineID,quantity) values(new.medicineID,new.quantity-old.quantity);
end if;
end //
delimiter ;


 






