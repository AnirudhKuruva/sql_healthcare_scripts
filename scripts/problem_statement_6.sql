use healthcare;
-- Problem Statement 1: 
-- The healthcare department wants a pharmacy report on the percentage of hospital-exclusive medicine prescribed
-- in the year 2022.
-- Assist the healthcare department to view for each pharmacy, the pharmacy id, pharmacy name, total quantity
-- of medicine prescribed in 2022, total quantity of hospital-exclusive medicine prescribed by the pharmacy
-- in 2022, and the percentage of hospital-exclusive medicine to the total medicine prescribed in 2022.
-- Order the result in descending order of the percentage found. 

with cte as(
select pharmacyID ,pharmacyName  , sum( if(m.hospitalExclusive = 'S' , c.quantity , 0) ) as Hosp_Exclusive
, sum(c.quantity) as Total from prescription p join contain c using(prescriptionID) 
join medicine m using(medicineID) 
join treatment t using(treatmentID)
join pharmacy p2 using(pharmacyID)
where year (date) = 2022
group by p.pharmacyID)
select *,(Hosp_exclusive/total)*100 as percentage from cte order by percentage desc;

-- Problem Statement 2:  
-- Sarah, from the healthcare department, has noticed many people do not claim insurance for their treatment.
-- She has requested a state-wise report of the percentage of treatments that took place without claiming
-- insurance. Assist Sarah by creating a report as per her requirement.

select a.state , (sum( if(t.claimID is null, 1, 0) ) / count(t.treatmentID)) * 100 as treatments_not_claimed_percent
from treatment t join person p on p.personID = t.patientID 
join address a using(addressID) group by a.state 
order by treatments_not_claimed_percent desc;

-- Problem Statement 3:  
-- Sarah, from the healthcare department, is trying to understand if some diseases are spreading in a particular
-- region. Assist Sarah by creating a report which shows for each state, the number of the most and least
-- treated diseases by the patients of that state in the year 2022. 

with cte as (
select a.state ,t.diseaseID  , count(t.diseaseID) as counts
, row_number() over (partition by a.state order by count(t.diseaseID) desc) as r1,
 row_number() over (partition by a.state order by count(t.diseaseID) asc) as r2
from 
address a join person p using(addressID) 
join treatment t on t.patientID = p.personID 
where year(date) = 2022
group by a.state,t.diseaseID)
select state,diseaseid,diseasename,counts ,case when r1=1 then "highest_effected" else "least_effected" end as category  from cte
join disease using(diseaseid)
where r1=1 or r2=1 order by 1,2;

-- Problem Statement 4: 
-- Manish, from the healthcare department, wants to know how many registered people are registered as patients
-- as well, in each city. Generate a report that shows each city that has 10 or more registered people belonging
-- to it and the number of patients from that city as well as the percentage of the patient with respect to the
-- registered people.

with cte as (
select a.city , count(p2.personID) as persons, count(p.patientID) patients from 
patient p right join person p2 on p.patientID = p2.personID
right join address a using(addressID)
group by a.city having count(p2.personID) >= 10)
select *, (patients/persons) * 100 as percent_of_patients from cte order by 4 desc;

-- Problem Statement 5:  
-- It is suspected by healthcare research department that the substance “ranitidina” might be causing some 
-- side effects. Find the top 3 companies using the substance in their medicine so that they can be informed 
-- about it.
select companyName , count(medicineID) medicines_having_ranitidina from medicine 
where substanceName like '%ranitidina%' group by companyName order by 2 desc limit 3;


















