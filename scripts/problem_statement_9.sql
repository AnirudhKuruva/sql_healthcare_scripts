use healthcare;
-- Problem Statement 1: 
-- Brian, the healthcare department, has requested for a report that shows for each state how many people underwent 
-- treatment for the disease “Autism”.  He expects the report to show the data for each state as well as each gender
-- and for each state and gender combination. Prepare a report for Brian for his requirement.

select 
	coalesce(a.state,"Final") as State,
	sum(if(gender="male",1,0)) as male_count,
    sum(if(gender="female",1,0)) as female_count,
	count(patientID) as AffectCount
from disease join (select distinct diseaseid,patientid from treatment )t using (diseaseID) join patient p using (patientID) 
join person p2 on p2.personID  = p.patientID  join address a using (addressID)
where diseaseName = 'Autism'
group by state with rollup  ;
-- another approach
select coalesce (state,"Grand") as State, coalesce (gender,"Total") as gender, 
count(distinct patientID) "number of peopple"
from address 
natural join person pe 
join patient p on p.patientid = pe.personID 
natural join treatment 
natural join disease 
where diseasename = 'Autism'
group by state, gender with rollup;

-- Problem Statement 2:  
-- Insurance companies want to evaluate the performance of different insurance plans they offer. 
-- Generate a report that shows each insurance plan, the company that issues the plan, and the number of treatments 
-- the plan was claimed for. The report would be more relevant if the data compares the performance for different years(2020, 2021 and 2022) 
-- and if the report also includes the total number of claims in the different years, as well as the total number of claims for each plan 
-- in all 3 years combined.

select coalesce(companyname,"Final")as companyname,coalesce(planname,"Total") as planname,
	sum(if(year(t.date) = 2020, 1, 0)) as claims_2020,
	sum(if(year(t.date) = 2021, 1, 0)) as claims_2021,
	sum(if(year(t.date) = 2022, 1, 0)) as claims_20222,
    sum(1) as total
from treatment t join claim c using(claimid)
join insuranceplan using(uin) 
join insurancecompany using(companyid)
group by companyname,planname with rollup;

-- Problem Statement 3:  
-- Sarah, from the healthcare department, is trying to understand if some diseases are spreading in a particular region. 
-- Assist Sarah by creating a report which shows each state the number of the most and least treated diseases by the 
-- patients of that state in the year 2022. It would be helpful for Sarah if the aggregation for the different combinations
--  is found as well. Assist Sarah to create this report.

with cte as (
	select state,diseaseName,count(d.diseaseName) as treatments,
		row_number() over(partition by a.state order by count(*) desc) count_asc,
		row_number() over(partition by a.state order by count(*)) count_desc from disease d 
	join treatment t using (diseaseID)
	join patient p using (patientID)
	join person p2 on p2.personID = p.patientID 
	join address a using (addressID) where year(date) = 2022
	group by a.state, d.diseaseName  
)
select state,t1.diseaseName as Most_effected_disease,t1.treatments as treatments, 
t2.diseaseName as Least_effected_disease,t2.treatments as treatments
from (select * from cte where  count_asc= 1) t1 join
 (select * from cte where count_desc = 1) t2 using(state)  ;

-- Problem Statement 4: 
-- Jackson has requested a detailed pharmacy report that shows each pharmacy name, and how many prescriptions they 
-- have prescribed for each disease in the year 2022, along with this Jackson also needs to view how many prescriptions
-- were prescribed by each pharmacy, and the total number prescriptions were prescribed for each disease.
-- Assist Jackson to create this report. 

select coalesce(p.pharmacyName,"Final") as pharmace_name,coalesce(d.diseaseName, 'Total') as Disease_Name,
	count(prescriptionID) as prescriptions
from pharmacy p 
join prescription p2 using (pharmacyID)
join treatment t using (treatmentID)
join disease d using (diseaseID) where year(date) = 2022
group by p.pharmacyName, d.diseaseName with rollup ;

-- Problem Statement 5:  
-- Praveen has requested for a report that finds for every disease how many males and females
--  underwent treatment for each in the year 2022. It would be helpful for Praveen if the aggregation for
--  the different combinations is found as well. Assist Praveen to create this report. 

select coalesce(diseaseName, 'Final totals') as Disease_Name,
		sum(if(gender="male",1,0)) as male_count,sum(if(gender="female",1,0)) as female_count,count(*) as total_patients
from disease  join (select distinct diseaseid,patientid from treatment where year(date) = 2022)t using (diseaseID) 
join patient p using (patientID)
join person p2 on p2.personID = p.patientID
group by diseaseName with rollup ;

select diseaseid,patientid from treatment order by 1,2 ;
select distinct diseaseid,patientid from treatment order by 1,2;

select coalesce(diseaseName, 'Final totals') as Disease_Name,
		sum(if(gender="male",1,0)) as male_count,sum(if(gender="female",1,0)) as female_count,count(*) as total_patients
from disease  join treatment using (diseaseID) 
join patient p using (patientID)
join person p2 on p2.personID = p.patientID
group by diseaseName with rollup ;
