--Q1a. Which prescriber had the highest total number of claims (totaled over all drugs)?
--Report the npi and the total number of claims.


SELECT distinct p1.npi,SUM(p2.total_claim_count) AS total_claim
FROM prescriber AS p1
INNER JOIN prescription AS p2 USING(npi)
WHERE nppes_provider_last_org_name IS NOT NULL
GROUP BY p1.npi
ORDER BY total_claim DESC;
--ANSWER npi(1881634483) and total claim(99707)

--Q1b.Repeat the above, but this time report the nppes_provider_first_name,
--nppes_provider_last_org_name, specialty_description, and the total number of claims.

SELECT p1.npi,p1.nppes_provider_first_name,p1.nppes_provider_last_org_name,p1.specialty_description,SUM(p2.total_claim_count) AS total_claim
FROM prescriber AS p1
INNER JOIN prescription AS p2 USING(npi)
WHERE nppes_provider_last_org_name IS NOT NULL
GROUP BY p1.npi,p1.nppes_provider_first_name,p1.nppes_provider_last_org_name,p1.specialty_description
ORDER BY total_claim DESC;


--Q2a.Which specialty had the most total number of claims (totaled over all drugs)?

SELECT p1.specialty_description,SUM(p2.total_claim_count) AS total_claim 
FROM prescriber AS p1
LEFT JOIN prescription AS p2 USING(npi)
GROUP BY p1.specialty_description
ORDER BY total_claim DESC NULLS LAST


--Q2b.Which specialty had the most total number of claims for opioids?

SELECT 
    distinct p2.specialty_description,
   SUM(CASE WHEN d.opioid_drug_flag = 'Y' THEN 1 ELSE 0 END) AS opioid_claims
FROM drug d
INNER JOIN prescription p1 USING(drug_name)
INNER JOIN Prescriber p2 USING(npi)
GROUP BY p2.specialty_description
ORDER BY opioid_claims DESC;
						
--Q2c. Challenge Question: Are there any specialties that appear in the prescriber table
--that have no associated prescriptions in the prescription table?
select distinct(npi) from prescriber--25050
select distinct(npi) from prescription--20592
select specialty_description from prescriber

(SELECT distinct npi FROM prescriber)
EXCEPT
(SELECT distinct npi 
FROM prescriber
INNER JOIN prescription USING(npi));--4458


-------Main Query----
SELECT distinct p1.specialty_description
FROM prescriber p1
EXCEPT
SELECT distinct p2.specialty_description
FROM prescriber p2
INNER JOIN prescription pr USING(npi);


---Q2d.For each specialty, report the percentage of total claims by that 
--specialty which are for opioids. 
--Which specialties have a high percentage of opioids?

SELECT 
    p1.specialty_description, 
    SUM(CASE WHEN d.opioid_drug_flag = 'Y' THEN 1 ELSE 0 END) AS opioid_percent
FROM prescriber AS p1
LEFT JOIN prescription AS p2 USING(npi)
LEFT JOIN drug AS d ON d.drug_name = p2.drug_name
GROUP BY p1.specialty_description
ORDER BY opioid_percent DESC NULLS LAST;
------Main Query---
SELECT 
    p1.specialty_description, 
   SUM(CASE WHEN d.opioid_drug_flag = 'Y' THEN total_claim_count  END) / SUM(p2.total_claim_count)*100 AS opioid_percent
FROM prescriber AS p1
LEFT JOIN prescription AS p2 USING(npi)
LEFT JOIN drug AS d ON d.drug_name = p2.drug_name
GROUP BY p1.specialty_description
ORDER BY opioid_percent DESC NULLS LAST;


select count(distinct specialty_description) from prescriber
select sum(total_claim_count) from prescription


----Q3a.Which drug (generic_name) had the highest total drug cost?
SELECT MAX(total_drug_cost) FROM prescription-2829174

SELECT generic_name 
FROM drug AS d
INNER JOIN prescription p1 USING(drug_name)
WHERE total_drug_cost=(SELECT MAX(total_drug_cost) FROM prescription)

--Q3b.Which drug (generic_name) has the hightest total cost per day?

SELECT generic_name,(total_drug_cost)/(total_day_supply) AS cost_per_day
FROM drug AS d
INNER JOIN prescription p1 USING(drug_name)
GROUP BY generic_name,cost_per_day
ORDER BY cost_per_day DESC
LIMIT 1;



 /*Q4a. For each drug in the drug table, return the drug name and 
then a column named 'drug_type' which says 'opioid' for drugs which have 
opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have
antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs*/

SELECT distinct drug_name,
	   CASE WHEN opioid_drug_flag='Y' THEN 'opioid'
	   	    WHEN antibiotic_drug_flag='Y' THEN 'antibiotic'
	        ELSE 'neither'
	   END AS drug_type
FROM drug
GROUP BY drug_name

--Q4b.Building off of the query you wrote for part a,
--determine whether more was spent (total_drug_cost) on opioids or on antibiotics.

SELECT
    SUM(CASE WHEN d.opioid_drug_flag = 'Y' THEN p.total_drug_cost END) AS opioid_cost,
    SUM(CASE WHEN d.antibiotic_drug_flag = 'Y' THEN p.total_drug_cost END) AS antibiotic_cost
FROM drug AS d
LEFT JOIN prescription AS p USING(drug_name)

--Q5a. How many CBSAs are in Tennessee? 
SELECT COUNT(*) FROM cbsa
WHERE cbsaname LIKE '%TN%';

--Q5b.Which cbsa has the largest combined population? 
--Which has the smallest? Report the CBSA name and total population.)

SELECT cbsaname,sum(population) AS max_pop
FROM cbsa
INNER JOIN population AS p USING(fipscounty)
GROUP BY cbsaname
ORDER BY max_pop DESC
LIMIT 1
-----------------------
SELECT cbsaname,sum(population) AS max_pop
FROM cbsa
INNER JOIN population AS p USING(fipscounty)
GROUP BY cbsaname
ORDER BY max_pop
LIMIT 1


--Q5c.What is the largest (in terms of population) county which is not included in 
--a CBSA? Report the county name and population.
select * from cbsa
select * from population
select * from fips_county

WITH large_pop_county AS
(
    SELECT fipscounty FROM population
    EXCEPT
    SELECT p.fipscounty FROM cbsa
    INNER JOIN population AS p USING(fipscounty)
    INNER JOIN fips_county AS f USING(fipscounty)
)
SELECT fc.county, MAX(p.population) AS max_pop
FROM large_pop_county AS l
INNER JOIN population AS p ON p.fipscounty = l.fipscounty
INNER JOIN fips_county AS fc ON fc.fipscounty = l.fipscounty
GROUP BY fc.county
ORDER BY max_pop DESC;


---Q6a. Find all rows in the prescription table where total_claims is at least 3000.
--Report the drug_name and the total_claim_count.

SELECT p1.drug_name,SUM(p1.total_claim_count)
FROM prescription AS p1
INNER JOIN prescription AS p2 ON p1.drug_name=p2.drug_name
WHERE p1.total_claim_count >=3000
GROUP BY p1.drug_name,p1.total_claim_count


--Q6b. For each instance that you found in part a, add a column that indicates
--whether the drug is an opioid.

SELECT p1.drug_name,SUM(p1.total_claim_count),
		CASE WHEN opioid_drug_flag='Y' THEN 'opioid' ELSE 'no opioid' END
FROM prescription AS p1
INNER JOIN drug AS d ON d.drug_name=p1.drug_name
WHERE p1.total_claim_count >=3000
GROUP BY p1.drug_name,p1.total_claim_count,opioid_drug_flag


--Q6c. Add another column to you answer from the previous part which gives 
--the prescriber first and last name associated with each row.

SELECT p1.drug_name,SUM(p1.total_claim_count),
		CASE WHEN opioid_drug_flag='Y' THEN 'opioid' ELSE 'no opioid' END,
		nppes_provider_first_name,nppes_provider_last_org_name
FROM prescription AS p1
INNER JOIN drug AS d ON d.drug_name=p1.drug_name
LEFT JOIN prescriber AS p2 on p1.npi=p2.npi
WHERE p1.total_claim_count >=3000
GROUP BY p1.drug_name,p1.total_claim_count,opioid_drug_flag,
		nppes_provider_first_name,nppes_provider_last_org_name

/*Q7a. First, create a list of all npi/drug_name combinations for pain management
specialists (specialty_description = 'Pain Management) in the city of Nashville 
(nppes_provider_city = 'NASHVILLE'), where the drug is an opioid 
(opiod_drug_flag = 'Y'). 
Warning: Double-check your query before running it.
You will only need to use the prescriber and drug tables since you don't need 
the claims numbers yet.*/
select * from prescriber WHERE specialty_description ilike '%Pain Management%' AND nppes_provider_city ilike '%NASHVILLE%'


SELECT p1.npi,drug_name
FROM prescriber AS p1
CROSS JOIN drug 
WHERE specialty_description='Pain Management' AND nppes_provider_city ='NASHVILLE' AND opioid_drug_flag='Y'

/*Q7b.report the number of claims per drug per prescriber.
Be sure to include all combinations, whether or not the prescriber had any claims.
You should report the npi, the drug name, and the number of claims (total_claim_count).*/

SELECT p1.npi, drug.drug_name,SUM(p2.total_claim_count) AS total_claim
FROM prescriber AS p1
CROSS JOIN drug
LEFT JOIN prescription p2 ON p1.npi = p2.npi 
						  AND drug.drug_name = p2.drug_name
WHERE p1.specialty_description = 'Pain Management'AND p1.nppes_provider_city = 'NASHVILLE'
     AND drug.opioid_drug_flag = 'Y'
GROUP BY p1.npi, drug.drug_name
ORDER BY p1.npi, drug.drug_name;

--c. Finally, if you have not done so already,
--fill in any missing values for total_claim_count with 0.
--Hint - Google the COALESCE function.

SELECT p1.npi, drug.drug_name,COALESCE(SUM(p2.total_claim_count),0) AS total_claim
FROM prescriber AS p1
CROSS JOIN drug
LEFT JOIN prescription p2 ON p1.npi = p2.npi AND drug.drug_name = p2.drug_name
WHERE p1.specialty_description = 'Pain Management'AND p1.nppes_provider_city = 'NASHVILLE'
     AND drug.opioid_drug_flag = 'Y'
GROUP BY p1.npi, drug.drug_name
ORDER BY p1.npi, drug.drug_name;