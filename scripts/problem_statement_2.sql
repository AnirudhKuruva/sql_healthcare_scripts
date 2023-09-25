use healthcare;
-- Problem Statement 1: A company needs to set up 3 new pharmacies, they have come up with 
-- an idea that the pharmacy can be set up in cities where the pharmacy-to-prescription ratio is
--  the lowest and the number of prescriptions should exceed 100. Assist the company to identify those 
--  cities where the pharmacy can be set up.
select city,count(pharmacy_id)/sum(ct2) as pharmacy_to_prescription from (
select city, p.pharmacyid as pharmacy_id , count(pre.prescriptionid) as ct2 from prescription pre join pharmacy p using(pharmacyid) join address a using(addressid)
group by p.pharmacyid )t  group by city having sum(ct2)>100
order by pharmacy_to_prescription limit 3 ;


-- Problem Statement 2: The State of Alabama (AL) is trying to manage its healthcare resources more 
-- efficiently. For each city in their state, they need to identify the disease for which the maximum 
-- number of patients have gone for treatment. Assist the state for this purpose.
-- Note: The state of Alabama is represented as AL in Address Table.

with cte as(
select t.diseaseid,city,count(distinct patientID) as count from treatment t join person p on t.patientid=p.personid 
join address a using(addressid) where state="AL"
group by city,diseaseid)
select city,diseaseid,count as effected_persons from(
select *,row_number() over(partition by city order by count desc) as ranks from cte)t 
where ranks =1 ;

-- Problem Statement 3: The healthcare department needs a report about insurance plans. 
-- The report is required to include the insurance plan, which was claimed the most and least for each 
-- disease.  Assist to create such a report.

with cte as (select t.diseaseID , i.planName , count(i.planName) as claims from 
treatment t right join claim c using(claimId)
join insuranceplan i using(UIN)
group by i.planName,t.diseaseID),
cte2 as ( select diseaseID , min(claims) as min_, max(claims) as max_ from cte group by diseaseID)
select cte.* from cte2 join cte using(diseaseId) where claims in (cte2.min_, cte2.max_) order by diseaseID, claims desc ;


-- Problem Statement 4: The Healthcare department wants to know which disease 
-- is most likely to infect multiple people in the same household. 
-- For each disease find the number of households that has more than one patient with the same disease. 
-- Note: 2 people are considered to be in the same household if they have the same address. 
with cte as (
select t.diseaseid,d.diseasename,p.addressid,count(*) as no_of_patients from treatment t
join disease d using(diseaseid) join
person p
 on t.patientid=p.personid group by t.diseaseid,p.addressid )
 select diseaseid,diseasename,count(addressid) as effected_more_than_person_of_house from cte where 
 no_of_patients>1 group by diseaseid order by effected_more_than_person_of_house desc;
 
--  Problem Statement 5:  An Insurance company wants a state wise report of the treatments to 
--  claim ratio between 1st April 2021 and 31st March 2022 (days both included). 
--  Assist them to create such a report.
with cte as (
select *  from person p join address a using(addressid)
join treatment t on t.patientid=p.personid
where date between "2021-04-01" and "2022-03-31")
select state,count(treatmentid)/count(claimid) as
 treatment_to_claim_ratio
from cte group by state order by 2 desc;


-- approach 2
with cte as (
select *  from treatment t join prescription  using(treatmentid)
join pharmacy using(pharmacyid)
join address using(addressid)
where date between "2021-04-01" and "2022-03-31")
select state,count(treatmentid)/count(claimid) as
 treatment_to_claim_ratio
from cte group by state order by 2 desc;



