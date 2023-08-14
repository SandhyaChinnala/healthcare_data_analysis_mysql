use healthcaredb;

/* Problem Statement 1: 
The healthcare department wants a pharmacy report on the percentage of hospital-exclusive medicine prescribed in the year 2022.
Assist the healthcare department to view for each pharmacy, the pharmacy id, pharmacy name, total quantity of medicine prescribed
 in 2022, total quantity of hospital-exclusive medicine prescribed by the pharmacy in 2022, and the percentage of hospital-exclusive 
 medicine to the total medicine prescribed in 2022.Order the result in descending order of the percentage found. */
 
with ps6_1 as (
		select pharmacyid, quantity as total_meds,
		case when hospitalExclusive='s' then quantity
		end as HE_quant
		from pharmacy
		join prescription using (pharmacyid )
		join contain  using ( prescriptionid )
		join treatment using (treatmentid)
		join medicine using (medicineid)
		where year( date ) = 2022
)
select pharmacyid,pharmacyName, 
sum(total_meds) as total_medicine_quan,
sum(HE_quant) as HEquant, 
((sum(HE_quant)/sum(total_meds))*100) as percent
from ps6_1
join pharmacy using(pharmacyId)
group by 1
order by 5 desc;

 
/* Problem Statement 2:  
Sarah, from the healthcare department, has noticed many people do not claim insurance for their treatment. 
She has requested a state-wise report of the percentage of treatments that took place without claiming insurance. 
Assist Sarah by creating a report as per her requirement.
*/ 

select `state`, count(treatmentid) 'treatment_counts', count(claimid), (100 - (count(claimid)/count(treatmentid))*100) as percent
from address join person using(addressid)
join patient on `personid`=`patientid`
join treatment using(patientid)
-- where claimid is null
group by state;

/* with cte as (
select state, count(treatmentid) 'treatment_counts'
from address join person using(addressid)
join patient on `personid`=`patientid`
join treatment using(patientid)
group by state
)
select state, treatment_counts, claims from cte 
where claimid is null; */

/*Problem Statement 3:  
Sarah, from the healthcare department, is trying to understand if some diseases are spreading in a particular region. 
Assist Sarah by creating a report which shows for each state, the number of the most and least treated diseases by the 
patients of that state in the year 2022. */

drop view if exists PS6_3;
create view PS6_3 as (
		select `state`, `diseaseName`, count(treatmentID) 'treatments_count',
		dense_rank() over(partition by state order by state, count(treatmentid) desc) as most,
		dense_rank() over(partition by state order by state, count(treatmentid)) as least
		from address join person using(addressid)
		join patient on `personid`=`patientid`
		join treatment using(patientid)
		join disease using(diseaseid)
		where year(date)=2022
		group by state, diseasename
);
((select `state`, `diseaseName`, `treatments_count`
from PS6_3
where most = 1)
union
( select `state`, `diseaseName`, `treatments_count`
from PS6_3
where least = 1))
order by state;

-- or this below select query 

select * 
from  ( select state,diseaseName as min_tret_disease from ps6_3 where most =1 ) as q1
join ( select state,diseaseName as min_tret_disease from ps6_3 where least =1 ) as q2
using(state );


/* Problem Statement 4: 
Manish, from the healthcare department, wants to know how many registered people are registered as patients as well, in each city. 
Generate a report that shows each city that has 10 or more registered people belonging to it and the number of patients from that 
city as well as the percentage of the patient with respect to the registered people. */

select city, count(personid) `Registered People`, count(patientid) `No of Patients`, 
round((count(patientid)/count(personid))*100, 2) as Ratio
from address join person using(addressid)
left join patient on `personid`=`patientid`
group by city;


/* Problem Statement 5:  
It is suspected by healthcare research department that the substance “ranitidine” might be causing some side effects. 
Find the top 3 companies using the substance in their medicine so that they can be informed about it.*/


select companyName, count(substanceName) as substance_count
from medicine
where substanceName like '%ranitidina%'
group by companyName
order by substance_count desc
limit 3;


 

/*trails of 1st problem
select `pharmacyID`,`pharmacyName`,sum(quantity)  `total` from
			(select `pharmacyID`,`pharmacyName`, `prescriptionID`,quantity `total`,`hospitalExclusive`
			from pharmacy inner join prescription using(`pharmacyID`)
			inner join contain using(`prescriptionID`)
			inner join treatment using(`treatmentID`)
			inner join medicine using(`medicineID`)
			where year(date) = 2022) t
group by 1
having pharmacyId and pharmacyName and total in 
(select pharmacyId,pharmacyName,sum(quantity) as `HE_quants`
from pharmacy join keep using(pharmacyID)
join medicine using(medicineID)
where hospitalExclusive='s'
group by pharmacyID)
;

 with cte_ps61 as (
	with PS6_1 as (
			select `pharmacyID`,`pharmacyName`, `prescriptionID`,quantity,`hospitalExclusive`
			from pharmacy inner join prescription using(`pharmacyID`)
			inner join contain using(`prescriptionID`)
			inner join treatment using(`treatmentID`)
			inner join medicine using(`medicineID`)
			where year(date) = 2022
	)
	select `pharmacyID`,`pharmacyName`, sum(quantity) as total_meds,
	(select sum(quantity) from ps6_1 as c where c.hospitalExclusive='S'  and c.`pharmacyID` = d.`pharmacyID`) as totalHEmeds 
	from ps6_1 as d group by pharmacyId
)
select `pharmacyID`,`pharmacyName`, total_meds, totalHEmeds, ((totalHEmeds/total_meds)*100) as percents
from cte_ps61 order by 5 desc;


select pharmacyId,pharmacyName,sum(quantity) as `HE_quants`
from pharmacy join keep using(pharmacyID)
join medicine using(medicineID)
where hospitalExclusive='s'
group by pharmacyID;
*/            
