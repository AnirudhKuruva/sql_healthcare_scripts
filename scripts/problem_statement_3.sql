use healthcare;
-- Problem Statement 1:  Some complaints have been lodged by patients that they have been prescribed
--  hospital-exclusive medicine that they can’t find elsewhere and facing problems due to that. 
--  Joshua, from the pharmacy management, wants to get a report of which pharmacies have prescribed 
--  hospital-exclusive medicines the most in the years 2021 and 2022.Assist Joshua to generate the report 
--  so that the pharmacies who prescribe hospital-exclusive medicine more often are advised to avoid such
--  practice if possible.  

select PharmacyName,count(prescriptionId) as Count_of_HospitalExclusive_prescriptions
from Pharmacy 
join Prescription using(pharmacyId)
join contain using(prescriptionId)
join Medicine  using(MedicineId)
join Treatment using(treatmentId)
where hospitalExclusive = 'S' and year(date) between 2012 and 2022
group by pharmacyId
order by count_of_HospitalExclusive_prescriptions desc;

-- Problem Statement 2: Insurance companies want to assess the performance of their insurance plans.
--  Generate a report that shows each insurance plan, the company that issues the plan, 
--  and the number of treatments the plan was claimed for.

select planname,companyName,count(*) as treatments_claimed from treatment t join claim c using(claimid) 
join insuranceplan ip using(uin)
join insurancecompany using(companyid) 
group by 1,2 order by  3 desc;



-- Problem Statement 3: Insurance companies want to assess the performance of their insurance plans.
--  Generate a report that shows each insurance company's name with their most and least claimed insurance 
--  plans.
with company_plan_claims as
(
select companyName,planName,count(claimId) as No_of_Claims
from InsuranceCompany ic 
join InsurancePlan i using(companyId)
left join claim c using(uin)
group by companyName,planName
),Assign_Ranks as
(
	select companyName,planName,No_of_claims,row_number() over(partition by companyName order by No_of_Claims desc) as Max_To_Min,
	row_number() over(partition by companyName order by No_of_Claims) as Min_To_Max
    from company_plan_claims
)
select companyName,t1.planName as Maximum_Claimed_Plan,t1.No_of_claims as Total_Maximum_Claims,
t2.planName as Minimum_Claimed_Plan,t2.no_of_claims as Total_Minimum_claims
from 
(select companyName,planName,No_of_Claims
from Assign_Ranks
where Max_To_Min = 1) t1
join 
(select companyName,planName,No_of_Claims
from Assign_Ranks
where Min_To_Max = 1) t2
using(companyName);

-- Problem Statement 4:  The healthcare department wants a state-wise health report to assess which state
--  requires more attention in the healthcare sector. Generate a report for them that shows the state name,
--  number of registered people in the state, number of registered patients in the state, and the
--  people-to-patient ratio. sort the data by people-to-patient ratio. 
select state,count(personid) as people,count(patientid)as patient ,count(personid)/count(patientid) as people_to_patient_ratio
from address join person using(addressid) 
left join patient on patient.patientid=person.personid
group by state order by people_to_patient_ratio desc;

-- Problem Statement 5:  Jhonny, from the finance department of Arizona(AZ), has requested a report
--  that lists the total quantity of medicine each pharmacy in his state has prescribed that falls 
--  under Tax criteria I for treatments that took place in 2021. Assist Jhonny in generating the report. 
with cte as(
select pharmacyid from address a join pharmacy 
using(addressid) where state="AZ" )
,
cte2 as (select treatmentid from treatment where year(date)="2021")
select pharmacyid,sum(quantity) as total_quantity from cte join prescription using(pharmacyid)
join cte2 using(treatmentid)
join contain using(prescriptionid) 
join medicine using(medicineid)
where taxcriteria="I"
group by pharmacyid order by total_quantity desc;

