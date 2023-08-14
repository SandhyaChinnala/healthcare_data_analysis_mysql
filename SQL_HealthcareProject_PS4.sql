use healthcaredb;

/* PS 1 : Display only the medicines of product categories 1, 2, and 3 for medicines 
that come under tax category I and medicines of product categories 4, 5, and 6 for medicines that come under tax category II. */

SELECT 
    medicineid,
    companyname,
    productname,
    `description`,
    substanceName,
    CASE
        WHEN `productType` = 1 THEN 'Generic'
        WHEN `productType` = 2 THEN 'Patent'
        WHEN `productType` = 3 THEN 'Reference'
        WHEN `productType` = 4 THEN 'Similar'
        WHEN `productType` = 5 THEN 'New'
        WHEN `productType` = 6 THEN 'Specific'
        -- WHEN `productType` = 7 THEN 'Biological'
        -- WHEN `productType` = 8 THEN 'Dinamized'
    END 'Product Type',
    taxcriteria
FROM
	medicine
    join keep using(medicineid)
    join pharmacy using(pharmacyid)
WHERE
    pharmacyName = 'HealthDirect'
        AND ((`productType` IN (1 , 2, 3) and `taxCriteria` = 'I') or (`productType` IN (4 , 5, 6) and `taxCriteria` = 'II'));
        

/* Problem Statement 2:  
'Ally Scripts' pharmacy company wants to find out the quantity of medicine prescribed in each of its prescriptions.
Write a query that finds the sum of the quantity of all the medicines in a prescription and if the total quantity 
of medicine is less than 20 tag it as “low quantity”. If the quantity of medicine is from 20 to 49 (both numbers including) tag 
it as “medium quantity“ and if the quantity is more than equal to 50 then tag it as “high quantity”.
Show the prescription Id, the Total Quantity of all the medicines in that prescription, 
and the Quantity tag for all the prescriptions issued by 'Ally Scripts'.*/

SELECT 
    prescriptionID,
    SUM(quantity) 'Total Quantity',
    CASE
        WHEN SUM(quantity) < 20 THEN 'Low Quantity'
        WHEN SUM(quantity) BETWEEN 20 AND 49 THEN 'Medium Quantity'
        WHEN SUM(quantity) >= 50 THEN 'High Quantity'
    END 'Tag'
FROM
    pharmacy
        JOIN
    prescription USING (pharmacyid)
        JOIN
    contain USING (prescriptionid)
WHERE
    pharmacyname = 'Ally scripts'
GROUP BY prescriptionid;


/* Problem Statement 3: 
In the Inventory of a pharmacy 'Spot Rx' the quantity of medicine is considered ‘HIGH QUANTITY’ when the quantity exceeds 7500 
and ‘LOW QUANTITY’ when the quantity falls short of 1000. The discount is considered “HIGH” if the discount rate on a 
product is 30% or higher, and the discount is considered “NONE” when the discount rate on a product is 0%.
 'Spot Rx' needs to find all the Low quantity products with high discounts and all the high-quantity products with no discount 
 so they can adjust the discount rate according to the demand. Write a query for the pharmacy listing all the necessary details relevant to the given requirement.*/

with medicine_discount as (select  productName, quantity,
case when quantity > 7500 then 'High Quantity'
	when quantity < 1000 then 'Low Quantity'
    end 'Quantity Tag',
case when discount >=30 then 'High'
	when discount=0 then 'None'
    end 'Discount tag'
from pharmacy
join keep using(pharmacyid)
join medicine using(medicineid)
where pharmacyname = 'Spot Rx')
select * from medicine_discount
where (`Quantity Tag`='High Quantity' and `Discount tag`='None') or (`Quantity Tag`='Low Quantity' and `Discount tag`='high');

/* Mack, From HealthDirect Pharmacy, wants to get a list of all the affordable and costly, 
hospital-exclusive medicines in the database. Where affordable medicines are the medicines 
that have a maximum price of less than 50% of the avg maximum price of all the medicines in the database, 
nd costly medicines are the medicines that have a maximum price of more than double the avg maximum price of all the medicines in the database.  
Mack wants clear text next to each medicine name to be displayed that identifies the medicine as affordable or costly. 
The medicines that do not fall under either of the two categories need not be displayed.
Write a SQL query for Mack for this requirement.*/

set @avg_price=(select avg(maxPrice) from medicine);
select * from (
select `productName`, maxPrice Price,
	case when maxPrice < (@avg_price/2) then 'Affordable'
		when maxPrice > (2*(@avg_price)) then 'Costly'
        end 'PriceCategory'
from pharmacy
join keep using(pharmacyid)
join medicine using(medicineid)
where `hospitalExclusive`= 'S' and pharmacyName='healthDirect'
group by medicineID
) as t
where `PriceCategory` is not null;

select @avg_price;

/* PS 5: Write a SQL query to list all the patient name, gender, dob, and their category.*/

select `personName`, `gender`, `dob`, 
case when gender= 'Male' and dob >= '2005-01-01' then 'YoungMale'
	when gender= 'Female' and dob >= '2005-01-01' then 'YoungFemale'
    when gender= 'Male' and ('2005-01-01'<  dob >='1985-01-01') then 'AdultMale'
    when gender= 'Female' and ('2005-01-01'< dob>='1985-01-01') then 'AdultFemale'
    when gender= 'Male' and  (dob < '1985-01-01' or dob >= '1970-01-01')  then 'MidAgeMale' 
    when gender= 'female' and (dob < '1985-01-01' or dob >= '1970-01-01') then 'MidAgeFemale'
    when gender= 'Male' and dob<'1970-01-01' then 'ElderMale'
	when gender= 'female' and dob<'1970-01-01' then 'Elderfemale'
end 'PersonCategory'
from patient join person 
on `patientID`=`personID`;



        
        