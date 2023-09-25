use healthcare;
SELECT medicineID,productName,
CASE productType WHEN 1 THEN 'Generic' WHEN 2 THEN 'Patent' WHEN 3 THEN 'Reference' WHEN 4 THEN 'Similar'
WHEN 5 THEN 'New' WHEN 6 THEN 'Specific' WHEN 7 THEN 'Biological' WHEN 8 THEN 'Dinamized' ELSE 'Unknown'
END AS productTypeInWords
FROM Medicine join keep using(medicineid) 
join pharmacy using(pharmacyid)
WHERE pharmacyname like "HealthDirect" and ( 
(productType IN (1, 2, 3) AND taxCriteria = 'I')
or (productType IN (4, 5, 6) AND taxCriteria = 'II')) order by 1;

-- 2
select t.prescriptionid,t.totalquantity ,case when t.totalquantity<20 then  'low quantity'
when t.totalquantity between 20 and 49 then 'medium quatity' else 'high quantity' end as quantity_tag
from (select prescriptionid,sum(quantity) as totalquantity from contain join prescription 
using(prescriptionID) join pharmacy 
using(pharmacyID) where pharmacyName = "Ally Scripts" group by prescriptionID)t
order by 2 desc ;



-- 3
select k.medicineid,case when quantity>7500 then ' high quantity' else 'low quantity' end as quantity,
case when discount>=30 then 'high discount' when discount=0 then 'no discount' end as discount_category from keep k join 
pharmacy p using(pharmacyid) where p.pharmacyname like 'Spot Rx' and ((quantity<=1000 and discount>=30) 
or (quantity>7500 and discount=0));

-- 4
with Price_Category_Medicine as (
	select productName as medicineName,
    case 
		when maxPrice<0.5*(select avg(maxPrice) from medicine) then 'affordable'
		when maxPrice>2*(select avg(maxPrice) from medicine) then 'costly'
	end as price_category
	from pharmacy ph join keep k using(pharmacyID)
	join medicine using(medicineID) where pharmacyName='HealthDirect' and hospitalExclusive='S'
)
select medicineName,price_category from Price_Category_Medicine where price_category is not null;
-- 5
select personname,gender,dob,
case when dob>='2005-01-01' and gender='male' then 'Youngmale'
when dob>='2005-01-01'and gender ='female' then 'youngfemale'
when dob>'1985-01-01' and dob<'2005-01-01'and gender='male' then 'Adultmale'
when dob>'1985-01-01' and dob<'2005-01-01'and gender='female' then 'Adultfemale'
when p2.dob>'1970-01-01' and p2.dob<'1985-01-01'and p.gender='male' then 'midagemale'
when p2.dob>'1970-01-01' and p2.dob<'1985-01-01'and p.gender='female' then 'midagefemale'
when p2.dob<'1970-01-01' and p.gender='male' then 'Eldermale'
when p2.dob<'1970-01-01' and p.gender='female' then 'Elderfemale'
end as category from person p join patient p2 on p.personid=p2.patientid;
