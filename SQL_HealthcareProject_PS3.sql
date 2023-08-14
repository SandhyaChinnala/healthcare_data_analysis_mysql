use healthcaredb;

/* Problem Statement 1:  Some complaints have been lodged by patients that 
they have been prescribed hospital-exclusive medicine that they can’t find elsewhere and facing problems due to that. 
Joshua, from the pharmacy management, wants to get a report of which pharmacies have prescribed 
hospital-exclusive medicines the most in the years 2021 and 2022. Assist Joshua to generate the report 
so that the pharmacies who prescribe hospital-exclusive medicine more often are advised to avoid such practice if possible.   */

select `pharmacyName`, count(`hospitalExclusive`)
from pharmacy
inner join prescription using(`pharmacyid`)
inner join treatment using(`treatmentID`)
inner join contain using(`prescriptionID`)
inner join medicine using(`medicineID`)
where `hospitalExclusive` = 'S' and year(date) in (2021, 2022)
group by 1
order by 1;

/* Problem Statement 2: Insurance companies want to assess the performance of their insurance plans. 
Generate a report that shows each insurance plan, the company that issues the plan, and the number of treatments the plan was claimed for.*/

select `planname`, `companyName`,count(`treatmentID`) 'No of treatments'
from insurancecompany
inner join insuranceplan
using(`companyID`)
inner join claim
using(`uin`)
inner join treatment
using(`claimid`)
group by `companyName`, `planname`;

/* Problem Statement 3: Insurance companies want to assess the performance of their insurance plans. 
Generate a report that shows each insurance company's name with their most and least claimed insurance plans. */

drop view if exists company_plan;
create view company_plan as (
		select `companyName`, `planName`, count(`claimid`) claim_Count, dense_rank() over(partition by `companyName` order by count(`claimid`) desc) 'most',
							dense_rank() over(partition by `companyName` order by count(`claimid`)) 'least'
		from insurancecompany
		inner join insuranceplan
		using(`companyid`)
		inner join claim
		using(`uin`)
		group by `companyName`, `planName`
);
((select `companyName`, `planName`, claim_Count
from company_plan
where most=1)
union
(select `companyName`, `planName`, claim_Count
from company_plan
where least=1))
order by `companyName`;

-- select `companyName`, `planName` 'most claimed plan',most, claim_Count, `companyName`, `planName`'least claimed plan', claim_Count, least
-- from company_plan
-- where most = 1 or least=1;

/* Problem Statement 4: The healthcare department wants a state-wise health report to assess 
which state requires more attention in the healthcare sector. 
Generate a report for them that shows the state name, number of registered people in the state, 
number of registered patients in the state, and the people-to-patient ratio. sort the data by people-to-patient ratio. */

SELECT 
    `state`,
    COUNT(`personid`) 'No of registered Persons',
    COUNT(`patientid`) 'No of Patients',
    (COUNT(`personid`) / COUNT(`patientid`)) 'Ratio'
FROM
    address
        INNER JOIN
    person USING (`addressid`)
        left JOIN
    patient ON `personid` = `patientid`
GROUP BY `state`;

/* Problem Statement 5:  Jhonny, from the finance department of Arizona(AZ), 
has requested a report that lists the total quantity of medicine each pharmacy in his state has prescribed 
that falls under Tax criteria I for treatments that took place in 2021. Assist Jhonny in generating the report. */

SELECT 
    `pharmacyName`, SUM(quantity) 'Quantity of Medicines'
FROM
    address
        JOIN
    pharmacy USING (`addressid`)
        JOIN
    prescription USING (`pharmacyid`)
        JOIN
    treatment USING (`treatmentid`)
        JOIN
    contain USING (`prescriptionid`)
        JOIN
    medicine USING (`medicineid`)
WHERE
    state = 'AZ' AND YEAR(date) = 2021
        AND `taxCriteria` = 'I'
GROUP BY 1;

-- -------------------****************************-----------------