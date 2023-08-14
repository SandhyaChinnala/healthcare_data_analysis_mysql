
use healthcaredb;

/* Problem Statement 1:  Jimmy, from the healthcare department, has requested a report that shows 
how the number of treatments each age category of patients has gone through in the year 2022. 
The age category is as follows, Children (00-14 years), Youth (15-24 years), Adults (25-64 years), and Seniors (65 years and over).
Assist Jimmy in generating the report. */


create view patient_treatment_table as (
			select patientid, ssn, dob, round(datediff(curdate(), dob)/365) as age, t.date,
			case when round(datediff(curdate(), dob)/365) between 0 and 14 then "Child"
				 when round(datediff(curdate(), dob)/365) between 15 and 24 then "Youth"
				 when round(datediff(curdate(), dob)/365) between 25 and 64 then "Adults"
			else "Seniors"
			end as Age_Category,
            t.treatmentID
			from patient p
			inner join treatment t
			using(patientid)
            where year(t.date)=2022
);

select age_category, count(treatmentid) 
from patient_treatment_table
group by age_category;


/* select concat(cat,'( ',low_age,' - ', high_age, ' )') 'age_category',count(treatmentID) 'treatments' from treatment 
inner join patient using (patientID)
inner join (
	select 0 'low_age', 14 'high_age' ,'children' as 'cat'
    union select 15,24, 'youth'
    union select 25,64, 'adults'
    union select 65, 150, 'seniors') age_table 
on timestampdiff(year,dob,date) between low_age and high_age 
where year(date)=2022 
group by age_category;    */
-- select timestampdiff(year,dob,date) from treatment
-- join patient using(patientid);



/* Problem Statement 2:  Jimmy, from the healthcare department, 
wants to know which disease is infecting people of which gender more often.
Assist Jimmy with this purpose by generating a report that shows for 
each disease the male-to-female ratio. Sort the data in a way that is helpful for Jimmy. */

create view mfRatio as (
	select diseaseName, patientid,
		case when p.gender = 'male' then 'male' end as male,
		case when p.gender = 'female' then 'female' end as female
	from person p
	join patient pt
	on p.personid = pt.patientID
	join treatment t
	using(patientid)
	join disease d
	on d.diseaseID = t.diseaseID
);
select diseasename,
	count(male) Male_count, 
    count(female) Female_count,
    round((count(male)/ count(female)), 2) Ratio,
    case when (count(male)/ count(female)) > 1 then 'Male' 
    else 'Female'
    end as 'Often Infected Gender'
from mfRatio group by diseasename;

/* Problem Statement 3: Jacob, from insurance management, has noticed that insurance 
claims are not made for all the treatments. He also wants to figure out 
if the gender of the patient has any impact on the insurance claim. 
Assist Jacob in this situation by generating a report that finds for each gender 
the number of treatments, number of claims, and treatment-to-claim ratio. 
And notice if there is a significant difference between the treatment-to-claim ratio of male and female patients. */

select gender, count(treatmentid) 'No of Treatments', 
	   count(claimid) 'No of Claims',
       (count(treatmentid)/count(claimid)) 'Treatment-Claim Ratio'
from claim c 
right join treatment t
using(claimid)
inner join person p
on p.personid = t.patientid
group by p.gender;

/* Problem Statement 4: The Healthcare department wants a report about the inventory of pharmacies. 
Generate a report on their behalf that shows how many units of medicine each pharmacy has in their inventory, 
the total maximum retail price of those medicines, and the total price of all the medicines after discount. 
Note: discount field in keep signifies the percentage of discount on the maximum price. */

select 
	ph.pharmacyName,
    count(k.medicineid)  'Total Medicines',
    sum(m.maxPrice) 'Total MRP',
    round(sum(m.maxPrice - ((m.maxPrice*k.discount)/100)), 2) 'Total Price After Discount'
from pharmacy ph 
join keep k
using (pharmacyid)
join medicine m 
using(medicineid)
group by pharmacyid
order by pharmacyname;

/* Problem Statement 5:  The healthcare department suspects that some pharmacies prescribe more medicines than others 
in a single prescription, for them, generate a report that finds for each pharmacy the maximum, 
minimum and average number of medicines prescribed in their prescriptions. */

create view problem4 as (select pharmacyid, prescriptionID, count(medicineid) 'medicine_count'
	 from prescription
     join contain
     using(prescriptionid)
     join medicine
     using(medicineid)
     group by prescriptionid);

select 
		pharmacyname,
        prescriptionid, 
		max(medicine_count), 
        min(medicine_count), 
        avg(medicine_count)
from problem4
join pharmacy ph 
using(pharmacyid)
group by pharmacyname;

-- -------------------****************************-----------------