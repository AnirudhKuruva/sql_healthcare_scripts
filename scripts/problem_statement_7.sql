use healthcare;
-- Problem Statement 1: 
-- Insurance companies want to know if a disease is claimed higher or lower than average.  
-- Write a stored procedure that returns “claimed higher than average” or “claimed lower than average” 
-- when the diseaseID is passed to it. 
-- Hint: Find average number of insurance claims for all the diseases.  If the number of claims for the passed 
-- disease is higher than the average return “claimed higher than average” otherwise “claimed lower than average”.
drop procedure avg_claims;
delimiter //
create procedure avg_claims(in d_id int)
begin 
	declare avgerage decimal(10,6);
	declare avg_req decimal(10,6);
	select count(claimID)/count(treatmentID) into avgerage from treatment t;
	select count(claimID)/ count(treatmentID) into avg_req from treatment where diseaseID = d_id;
    select if(avg_req > avgerage,'claimed higher than average','claimed lower than average') as result;
end //
delimiter ;
call avg_claims(1);
-- Problem Statement 2:  
-- Joseph from Healthcare department has requested for an application which helps him get genderwise 
-- report for any disease. 
-- Write a stored procedure when passed a disease_id returns 4 columns,
-- disease_name, number_of_male_treated, number_of_female_treated, more_treated_gender
-- Where, more_treated_gender is either ‘male’ or ‘female’ based on which gender underwent more often 
-- for the disease, if the number is same for both the genders, the value should be ‘same’.

delimiter //
create procedure disease_gender_report(in d_id int )
begin
	with cte as(
	select diseasename,sum( if(gender="male",1,0)) as number_of_male_treated,sum( if(gender="female",1,0)) as number_of_female_treated
    from treatment t join disease using(diseaseid) join person p on t.patientid=p.personid
    where diseaseid=d_id
    group by diseasename
    )
    select *, case when number_of_male_treated>number_of_female_treated then "Male" 
    when number_of_male_treated<number_of_female_treated then "Female" else "Same" end as more_treated_gender 
    from cte;
end //
delimiter ;
call disease_gender_report(1);

-- Problem Statement 3:  
-- The insurance companies want a report on the claims of different insurance plans.  Write a query that finds the top 3 most and top 3 least claimed insurance plans.
-- The query is expected to return the insurance plan name, the insurance company name which has that plan,
-- and whether the plan is the most claimed or least claimed. 
	with cte as(
    select planname,companyname,row_number() over(order by count(claimid)) as rank_asc,
    row_number() over(order by count(claimid) desc) as rank_desc
    from 
    claim join insuranceplan using(uin) join insurancecompany using(companyid) 
    group by planname,companyname)
    select planname,companyname,if(rank_asc<=3,"least_claimed","most_claimed") as category from
    cte where rank_asc<=3 or rank_desc<=3;

-- 4
-- The healthcare department wants to know which category of patients is being affected the most by each disease.
-- Assist the department in creating a report regarding this.
-- Provided the healthcare department has categorized the patients into the following category.
-- YoungMale: Born on or after 1st Jan  2005  and gender male.

with Patient_Category as
(
SELECT diseaseName,
    CASE
        WHEN dob >= '2005-01-01' AND gender = 'male' THEN 'YoungMale'
        WHEN dob >= '2005-01-01' AND gender = 'female' THEN 'YoungFemale'
        WHEN dob >= '1985-01-01' AND gender = 'male' THEN 'AdultMale'
        WHEN dob >= '1985-01-01' AND gender = 'female' THEN 'AdultFemale'
        WHEN dob >= '1970-01-01' AND gender = 'male' THEN 'MidAgeMale'
        WHEN dob >= '1970-01-01' AND gender = 'female' THEN 'MidAgeFemale'
        WHEN gender = 'male' THEN 'ElderMale'
        WHEN gender = 'female' THEN 'ElderFemale'
        ELSE 'Unknown'
    END AS age_category
from disease
join treatment using(diseaseId)
join patient using(patientId)
join Person on patientid = personId
),Disease_Category_count as
(
	select diseaseName,age_category,count(1) as count_patients,
    row_number() over(partition by diseaseName order by count(1) desc) as ranks
    from Patient_Category
    group by diseaseName,age_category
)
select diseaseName,age_category,count_patients from Disease_category_count
where ranks = 1;



	
    
    
-- Problem Statement 5:  
-- Anna wants a report on the pricing of the medicine. She wants a list of the most expensive and most 
-- affordable medicines only. 
-- Assist anna by creating a report of all the medicines which are pricey and affordable, listing the 
-- companyName, productName, description, maxPrice, and the price category of each. Sort the list in 
-- descending order of the maxPrice.
-- Note: A medicine is considered to be “pricey” if the max price exceeds 1000 and “affordable” if the 
-- price is under 5. Write a query to find 

select companyName, productName, description, maxPrice,if(maxPrice > 1000,'Pricey','Affordable') as Price_category
from medicine 
where maxPrice < 5 or maxPrice > 1000
order by maxPrice desc;

