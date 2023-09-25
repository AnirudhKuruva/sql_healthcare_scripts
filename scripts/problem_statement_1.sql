use healthcare;
-- Problem Statement 1:  Jimmy, from the healthcare department, has requested a report that shows 
-- how the number of treatments each age category of patients has gone through in the year 2022. 
-- The age category is as follows, Children (00-14 years), Youth (15-24 years), Adults (25-64 years), 
-- and Seniors (65 years and over).
-- Assist Jimmy in generating the report. 
select count(*) from patient;

select count( t.treatmentid) as patient, p.age_cat
from treatment t join (select distinct patientID , case 
	when timestampdiff(year,dob,now()) <= 14 then "Children"
	when timestampdiff(year,dob,now()) <= 24 then "Youth"
	when timestampdiff(year,dob,now()) <= 64 then "Adults"
	else "Seniors"
end as age_cat
from patient) p on t.patientID = p.patientID where year(t.date) = 2022 group by age_cat ;

-- Problem Statement 2:  Jimmy, from the healthcare department, wants to know which disease is infecting people 
-- of which gender more often.
-- Assist Jimmy with this purpose by generating a report that shows for each disease the male-to-female ratio. 
-- Sort the data in a way that is helpful for Jimmy.

select d.diseaseName , (sum(case when p.gender = 'male' then 1 else 0 end)/ sum(case when p.gender = 'female' then 1 else 0 end)) as male_female_ratio
 from disease d join treatment t on t.diseaseId = d.diseaseID 
join person p on p.personId = t.patientID group by d.diseaseID order by 2 desc;

-- Problem Statement 3: Jacob, from insurance management, has noticed that insurance claims are not made 
-- for all the treatments. He also wants to figure out if the gender of the patient has any impact on the 
-- insurance claim. Assist Jacob in this situation by generating a report that finds for each gender the 
-- number of treatments, number of claims, and treatment-to-claim ratio. And notice if there is a significant 
-- difference between the treatment-to-claim ratio of male and female patients.

select p.gender,count(treatmentid)/sum(case when t.claimid is not null then 1 else 0 end) as treatment_to_claim_ratio from
 treatment t join person p on t.patientID = p.personID group by gender;
 
--  Problem Statement 4: The Healthcare department wants a report about the inventory of pharmacies.
--  Generate a report on their behalf that shows how many units of medicine each pharmacy has in their 
--  inventory, the total maximum retail price of those medicines, and the total price of all the medicines
--  after discount. Note: discount field in keep signifies the percentage of discount on the maximum price.

select p.pharmacyname ,sum(k.quantity) as units_of_medicines, sum(m.maxPrice*k.quantity) as total_mrp_of_medicine,
sum(m.maxPrice*k.quantity-k.quantity*m.maxprice*discount/100) as total_amount_after_discount from pharmacy p join keep k using(pharmacyid)
join medicine m using(medicineid)
group by p.pharmacyid order by 1;

-- Problem Statement 5:  The healthcare department suspects that some pharmacies prescribe more medicines
--  than others in a single prescription, for them, generate a report that finds for each pharmacy the 
--  maximum, minimum and average number of medicines prescribed in their prescriptions. 
select p.pharmacyname,max(medicines_count),min(medicines_count),avg(medicines_count) as average_medicines
from (
select pre.pharmacyid,pre.prescriptionid,count(c.medicineid) as medicines_count from prescription pre join 
contain c using(prescriptionid)
group by pre.pharmacyid,pre.prescriptionid )t join
pharmacy p using(pharmacyid)
 group by p.pharmacyname order by 4 desc;



















