use healthcare;
-- Problem Statement 1: 
-- Johansson is trying to prepare a report on patients who have gone through treatments more than once.
--  Help Johansson prepare a report that shows the patient's name, the number of treatments they have 
--  undergone, and their age, Sort the data in a way that the patients who have undergone more treatments 
--  appear on top.
select personname,year(now())-year(dob) as age ,count(treatmentid)  as treatments_undergone from patient 
join person on patient.patientID=person.personID
join treatment using(patientid)
group by patientID  having treatments_undergone>1 order by treatments_undergone desc;

-- Problem Statement 2:  
-- Bharat is researching the impact of gender on different diseases, He wants to analyze if a
--  certain disease is more likely to infect a certain gender or not.Help Bharat analyze this by creating 
--  a report showing for every disease how many males
--  and females underwent treatment for each in the year 2021. It would also be helpful for Bharat 
--  if the male-to-female ratio is also shown.
select diseaseid,diseasename,
sum(case when gender="male" then 1 else 0 end) as male_count,
sum(case when gender="female" then 1 else 0 end) as female_count,
sum(case when gender="male" then 1 else 0 end)/sum(case when gender="female" then 1 else 0 end) 
as male_to_female_ratio
 from treatment t join person p on t.patientID=p.personID 
 join disease using(diseaseid)
 where year(date)="2021"
 group by diseaseID order by male_to_female_ratio  desc; 
--  Problem Statement 3:  
-- Kelly, from the Fortis Hospital management, has requested a report that
--  shows for each disease, the top 3 cities that had the most number treatment for that disease.
-- Generate a report for Kelly’s requirement.
with cte as (
select diseaseid,city,treatments, row_number() 
over(partition by diseaseid order by treatments desc) as ranks from 
(select diseaseid,city,count(*) as treatments
 from treatment t join prescription pre using(treatmentid)
join pharmacy using(pharmacyid) join address a using(addressid)
group by diseaseid,city order by diseaseid,treatments desc)t) 
select diseaseid,city,treatments from cte
where ranks<=3;

-- Problem Statement 4: 
-- Brooke is trying to figure out if patients with a particular disease are preferring some pharmacies
--  over others or not, For this purpose, she has requested a detailed pharmacy report that shows each 
--  pharmacy name, and how many prescriptions they have prescribed for each disease in 2021 and 2022,
--  She expects the number of prescriptions prescribed in 2021 and 2022 be displayed in two 
--  separate columns.Write a query for Brooke’s requirement.
select pharmacyname , diseasename,sum( if(year(date) = 2021, 1,0 ))  as treatements_in_2021,
sum( if(year(date) = 2022, 1,0 )) as treatments_in_2022
from prescription p join treatment t using(treatmentID)
join pharmacy using(pharmacyid)
join disease using(diseaseid)
where year(date) in (2021,2022)
group by  pharmacyname,diseasename order by 1,2;

-- Problem Statement 5:  
-- Walde, from Rock tower insurance, has sent a requirement for a report that presents which insurance 
-- company is targeting the patients of which state the most. 
-- Write a query for Walde that fulfills the requirement of Walde.
-- Note: We can assume that the insurance company is targeting a region more if the patients of that region 
-- are claiming more insurance of that company.
with cte as (
select ic.companyName, a.state ,count(c.claimID) as claims
, rank() over(partition by ip.companyID order by count(c.claimID) desc ) as ranks from 
treatment t join person p on p.personID = t.patientID
join address a using(addressID) join claim c using(claimID)
join insuranceplan ip using(uin) join insurancecompany ic using(companyID)
group by a.state,ic.companyID) 
select companyname,state,claims from cte 
where ranks = 1 order by 3 desc;



