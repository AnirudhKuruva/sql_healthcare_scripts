use healthcare;
-- Problem Statement 1:
-- Patients are complaining that it is often difficult to find some medicines. They move from pharmacy to 
-- pharmacy to get the required medicine. A system is required that finds the pharmacies and their contact 
-- number that have the required medicine in their inventory. So that the patients can contact the pharmacy 
-- and order the required medicine.Create a stored procedure that can fix the issue.
drop procedure medicine_search;
delimiter //
create procedure medicine_search(in med_name varchar(50))
begin 
	select p.pharmacyName,p.phone,m.maxPrice  ,k.discount  from 
	medicine m join keep k using(medicineID)
	join pharmacy p using(pharmacyID) 
	where m.productName like concat('%', med_name, '%');
	end //
delimiter ;
call medicine_search('TEICOPLANINA');

-- Problem Statement 2:
-- The pharmacies are trying to estimate the average cost of all the prescribed medicines per prescription,
-- for all the prescriptions they have prescribed in a particular year. Create a stored function that will
-- return the required value when the pharmacyID and year are passed to it. Test the function with multiple
-- values.

delimiter //
create function avg_cost_per_prescription( phm_id int , year_ varchar(4))
returns decimal(10,3)
deterministic 
begin
	declare result decimal(10,3) ;
	with cte as (
	select p.prescriptionID as pid , sum(c.quantity*m.maxPrice) as price from treatment t 
	join prescription p using(treatmentID)
	join contain c using(prescriptionID) 
	join medicine m using(medicineID)
	where year(t.date) = year_ and p.pharmacyID = phm_id
	group by p.prescriptionID)
	select sum(price)/count(pid) into result from cte;
	return result;
end //
delimiter ;
select avg_cost_per_prescription(1008,2022);

-- Problem Statement 3:
-- The healthcare department has requested an application that finds out the disease that was spread the 
-- most in a state for a given year. So that they can use the information to compare the historical data 
-- and gain some insight.
-- Create a stored function that returns the name of the disease for which the patients from a particular 
-- state had the most number of treatments for a particular year. Provided the name of the state and year 
-- is passed to the stored function.
drop function most_effected_disease;
delimiter //
create function most_effected_disease(state_ varchar(50), year_ int)
returns varchar(60)
deterministic
begin 
	declare result varchar(50);
	select d.diseaseName into result
	from disease d join treatment t using(diseaseID)
	join person p on p.personID = t.patientID join address a using(addressID)
	where a.state = state_ and year(t.date) = year_
	group by diseaseID order by count(distinct patientid) desc limit 1;
    return result;
end //
delimiter ;
select most_effected_disease('OK',2022);

-- select state from address;


drop function most_effected_disease2;
delimiter //
create function most_effected_disease2(state_ varchar(50), year_ int)
returns varchar(500)
deterministic
begin 
	declare result varchar(500);
    with cte as(
	select d.diseaseName, count(distinct patientid) as cts
	from disease d join treatment t using(diseaseID)
	join person p on p.personID = t.patientID 
	join address a using(addressID)
	where a.state = state_ and year(date) = year_
	group by diseaseID)
    select group_concat(diseasename separator "||") into result from cte c1 where
    cts=(select max(cts) from cte );
    return result;
end //
delimiter ;
select most_effected_disease2('AL',2022) as Result;

select most_effected_disease('AL',2022) as Result;

select distinct state from address;
select group_concat(city separator " ") from address;

-- Problem Statement 4:
-- The representative of the pharma union, Aubrey, has requested a system that she can use to find how many
-- people in a specific city have been treated for a specific disease in a specific year.
-- Create a stored function for this purpose.

delimiter //
create function people_Effected_From_Disease(city_ varchar(30), d_id int, year_ int )
returns int
deterministic 
begin 
	declare result int;
	select count(t.patientID) into result from treatment t join disease d using(diseaseID)
	join person p on p.personID  = t.patientID 
	join address a using(addressID) where a.city = city_  and d.diseaseID = d_id and year(date) = year_;
	return result;
end //
delimiter ;
select people_Effected_From_Disease("Arvada",31,2022);
-- select * from address;

-- Problem Statement 5:
-- The representative of the pharma union, Aubrey, is trying to audit different aspects of the pharmacies.
-- She has requested a system that can be used to find the average balance for claims submitted by a specific
-- insurance company in the year 2022. 
-- Create a stored function that can be used in the requested application. 

delimiter //
create function avg_balance_per_claim(cmp_id int)
returns decimal(14,3)
deterministic
begin
	declare result decimal(14,3);
	select avg(balance) into result from claim c join insuranceplan i using(UIN) 
    join treatment t using(claimid)
	where companyID = cmp_id and year(t.date)=2022;
	return result;
end //
delimiter ;
 -- drop function avg_balance_per_claim;
-- select * from insurancecompany;
select avg_balance_per_claim(1118);


