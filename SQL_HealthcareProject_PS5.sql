use healthcaredb;

/* Problem Statement 1: 
Johansson is trying to prepare a report on patients who have gone through treatments more than once. 
Help Johansson prepare a report that shows the patient's name, the number of treatments they have undergone, 
and their age, Sort the data in a way that the patients who have undergone more treatments appear on top.*/

select personname, count(treatmentid) as no_of_treatments, round(datediff(date, dob)/365, 0) as Age
from treatment join patient using(patientid)
join person on `personID`=`patientID`
group by patientID
having no_of_treatments > 1
order by no_of_treatments desc;


/* Problem Statement 2:  
Bharat is researching the impact of gender on different diseases, He wants to analyze if a certain disease is more likely to infect a certain gender or not.
Help Bharat analyze this by creating a report showing for every disease how many males and females 
underwent treatment for each in the year 2021. It would also be helpful for Bharat if the male-to-female ratio is also shown.*/

select diseaseName, 
    count(case when gender='Male' then 1 end) as male_count,
      count(case when gender='Female' then 1 end) as female_count,
     round(count(case when gender='Male' then 1 end)/count(case when gender='female' then 1 end), 2) Ratio
from disease
join treatment using(diseaseid)
join patient using(patientid)
join person on `personid`=`patientid`
where year(date) = 2021
group by diseaseName;

/* Problem Statement 3:  
Kelly, from the Fortis Hospital management, has requested a report that shows for each disease, 
the top 3 cities that had the most number treatment for that disease. Generate a report for Kelly’s requirement.*/


select `diseasename`, group_concat(city separator ' , ') 'Top Cities' from (
select diseaseName, city , count(treatmentID) 'No of Treatments',
 rank() over(partition by diseasename order by count(treatmentID) desc) 'CityRank'
from address
join person using(addressid)
join patient on `personid`=`patientid`
join treatment using(patientid)
join disease using(diseaseid)
group by diseaseid, city
) t
where CityRank <= 3
group by diseasename;

/* Problem Statement 4: 
Brooke is trying to figure out if patients with a particular disease are preferring some pharmacies over others or not, 
For this purpose, she has requested a detailed pharmacy report that shows each pharmacy name, and how many prescriptions 
they have prescribed for each disease in 2021 and 2022, She expects the number of prescriptions prescribed in 2021 
and 2022 be displayed in two separate columns. Write a query for Brooke’s requirement.*/

with cte5 as  
(
select pharmacyName, diseaseName, year(date) 'Year', count(prescriptionID) 'pres_count'
from pharmacy
join prescription using(pharmacyid)
join treatment using(treatmentid)
join disease using(diseaseid)
where year(date) in (2021,2022)
group by pharmacyName, diseaseName, Year
)
select pharmacyName, diseaseName, 
ifnull((select pres_count from cte5 c where c.diseasename = d.diseasename and c.pharmacyname=d.pharmacyname and c.year=2021), 0) as '2021_Count',
ifnull((select pres_count from cte5 c where c.diseasename = d.diseasename and c.pharmacyname=d.pharmacyname and c.year=2022), 0) as '2022_Count'
from cte5 d
order by 1;

/* 
Problem Statement 5: Walde, from Rock tower insurance, has sent a requirement for a report that 
presents which insurance company is targeting the patients of which state the most. Write a query for Walde that fulfills the requirement of Walde.
Note: We can assume that the insurance company is targeting a region more if the patients of that region are claiming more insurance of that company.*/

with cte as 
(
select `companyName`, `state`, count(claimid) as 'Claims'
from address join insurancecompany
using(addressid)
join insuranceplan using(companyid)
join claim using(uin)
group by state, companyName
)
select  state, (select companyname from cte c where c.state = d.state limit 1) as 'targeting company', claims  from cte d;


-- -----------------*********************----------------------------

