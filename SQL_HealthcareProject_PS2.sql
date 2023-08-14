use healthcaredb;

/* Problem Statement 1: A company needs to set up 3 new pharmacies, 
they have come up with an idea that the pharmacy can be set up in cities 
where the pharmacy-to-prescription ratio is the lowest and the number of prescriptions should exceed 100. \
Assist the company to identify those cities where the pharmacy can be set up */

select city, count(pc.prescriptionid) No_of_Prescriptions, 
		COUNT(distinct ph.pharmacyid) 'No of Pharmacies',
        ( COUNT(distinct ph.pharmacyid) / count(pc.prescriptionid)) Ratio
from address a
join pharmacy ph
using(addressid)
join prescription pc
using(pharmacyid)
group by city
having No_of_Prescriptions > 100;

/* Problem Statement 2: The State of Alabama (AL) is trying to manage its healthcare resources 
more efficiently. For each city in their state, they need to identify the disease for 
which the maximum number of patients have gone for treatment. Assist the state for this purpose.
Note: The state of Alabama is represented as AL in Address Table.*/

with cte1 as (select state, city, diseasename, count(patientid) no_of_patients 
from address a
left join person p
using(addressid)
left join treatment t
on (p.personID = t.patientID)
left join disease 
using(diseaseid)
where state='AL'
group by city , diseaseName
) 
select x.city, x.diseasename, x.no_of_patients from
(select *, dense_rank() over(partition by city order by no_of_patients desc) 'rank1'
from cte1) x
where x.rank1=1 order by 3 desc;

-- another way
select city, diseaseName, no_of_patients from (
select *, dense_rank() over(partition by city order by no_of_patients desc) 'rank1' from (
		select state, city, diseasename, count(patientid) no_of_patients 
		from address a
		left join person p
		using(addressid)
		join patient pt on p.personID = pt.patientid
		join treatment t
		using(patientid)
		join disease 
		using(diseaseid)
		where state='AL'
		group by 2,3
) t
) tb
where rank1=1 order by 3 desc;

/* Problem Statement 3: The healthcare department needs a report about insurance plans. 
The report is required to include the insurance plan, which was claimed the most and least for each disease.  
Assist to create such a report. */

-- First way using view
drop view if exists cte2;
create view cte2 as (
		select *, dense_rank() over(partition by `diseaseName` order by `no_of_claims` desc) 'most',
				  dense_rank() over(partition by `diseaseName` order by `no_of_claims`) 'least'
        from
				(select `diseaseName`, `planname`, count(`claimID`) 'no_of_claims'
				from disease
				inner join treatment using(diseaseid)
				inner join claim using(claimid)
				inner join insuranceplan using(uin)
				group by 1,2) t
);

( -- most claimed plans for each disease
(select `diseaseName`, `planname` 'most claimed plan', `no_of_claims` 
from cte2
where most=1)
union 
-- least claimed plans for each disease
(select `diseaseName`, `planname` 'least claimed plan', `no_of_claims` 
from cte2
where least=1))
order by `diseaseName` asc, `no_of_claims` desc;

-- second way, not yet done
select `diseaseName`, `planname` 'most claimed plan', `no_of_claims` from 
		( select *, dense_rank() over(partition by `diseaseName` order by `no_of_claims` desc) 'most' from
				(select `diseaseName`, `planname`, count(`claimID`) 'no_of_claims'
				from disease
				inner join treatment using(diseaseid)
				inner join claim using(claimid)
				inner join insuranceplan using(uin)
				group by 1,2) t
) tb
where most = 1;

/* Problem Statement 4: The Healthcare department wants to know which disease is most likely 
to infect multiple people in the same household. 
For each disease find the number of households that has more than one patient with the same disease. */

select `diseasename`, count(`addressID`) Households from 
		(select diseaseName, addressID 
		from person
		join treatment
		on `personid` = `patientID`
		join disease
		using(`diseaseid`)
		group by 1, 2
		having count(`patientID`) > 1
) t
group by 1
order by 1;

/* 
Problem Statement 5:  An Insurance company wants a state wise report of the treatments to 
claim ratio between 1st April 2021 and 31st March 2022 (days both included). Assist them to create such a report.*/

select 
	`state`, 
    count(`treatmentID`) Treatments, 
    count(`claimid`) Caims, 
    (count(`treatmentID`)/count(`claimid`)) Ratio
from address 
inner join person
using(`addressid`)
inner join patient 
on `personID` = `patientID`
inner join treatment
using(`patientid`)
left join claim 
using(claimID)
where date between '2021-04-01' and '2022-03-31' 
group by 1
order by 1;


-- -------------------****************************-----------------