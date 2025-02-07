--Q1.How many npi numbers appear in the prescriber table but not in the prescription table?

SELECT npi FROM prescriber
EXCEPT
SELECT npi FROM prescription


--Q2a.Find the top five drugs (generic_name) prescribed by prescribers with the 
--specialty of Family Practice.
SELECT distinct generic_name,SUM(total_claim_count) AS total_claims
FROM drug AS d
INNER JOIN prescription AS p1 USING(drug_name)
INNER JOIN prescriber AS p2 USING(npi)
WHERE p2.specialty_description='Family Practice'
GROUP BY generic_name
ORDER BY total_claims DESC
LIMIT 5;


--Q2b.Find the top five drugs (generic_name) prescribed by prescribers with the 
--specialty of Cardiology.
SELECT distinct generic_name,SUM( total_claim_count) AS total_claim
FROM drug AS d
INNER JOIN prescription AS p1 USING(drug_name)
INNER JOIN prescriber AS p2 USING(npi)
WHERE specialty_description='Cardiology'
GROUP BY generic_name
ORDER BY total_claim DESC
LIMIT 5;

--c. Which drugs are in the top five prescribed by Family Practice prescribers and Cardiologists?
--Combine what you did for parts a and b into a single query to answer this question.

SELECT distinct generic_name,SUM(total_claim_count) AS total_claim
FROM drug AS d
INNER JOIN prescription AS p1 USING(drug_name)
INNER JOIN prescriber AS p2 USING(npi)
WHERE specialty_description IN ('Cardiology','Family Practice')
GROUP BY generic_name
ORDER BY total_claim DESC
LIMIT 5;

--Q3a. First, write a query that finds the top 5 prescribers in Nashville 
--in terms of the total number of claims (total_claim_count) across all drugs. 
--Report the npi, the total number of claims, and include a column showing the city.
select * from prescriber where nppes_provider_city ilike '%Nashville%'

SELECT npi,nppes_provider_last_org_name, SUM(total_claim_count) AS total_claim,nppes_provider_city AS City
FROM prescription AS p1
INNER JOIN prescriber AS p2 USING(npi)
WHERE nppes_provider_city ILIKE '%Nashville%'
GROUP BY npi,nppes_provider_last_org_name,City
ORDER BY total_claim DESC
LIMIT 5;

--3b.b. Now, report the same for Memphis.

SELECT npi,nppes_provider_last_org_name, SUM(total_claim_count) AS total_claim,nppes_provider_city AS City
FROM prescription AS p1
INNER JOIN prescriber AS p2 USING(npi)
WHERE nppes_provider_city ILIKE '%Memphis%'
GROUP BY npi,nppes_provider_last_org_name,City
ORDER BY total_claim DESC
LIMIT 5;

--Q3c.Combine your results from a and b, along with the results for Knoxville and Chattanooga.

SELECT npi,nppes_provider_last_org_name, SUM(total_claim_count) AS total_claim,nppes_provider_city AS City
FROM prescription AS p1
INNER JOIN prescriber AS p2 USING(npi)
WHERE nppes_provider_city IN ('NASHVILLE','MEMPHIS','CHATTNOOGA','KNOXVILLE')
GROUP BY npi,nppes_provider_last_org_name,City
ORDER BY total_claim DESC
LIMIT 5;



--Q4.Find all counties which had an above-average number of overdose deaths.
--Report the county name and number of overdose deaths.

SELECT * FROM overdose_deaths;	
SELECT distinct county FROM fips_county 
SELECT ROUND(AVG(overdose_deaths),2) from overdose_deaths

---------------------

SELECT county,SUM(overdose_deaths) AS death
FROM fips_county AS fc
INNER JOIN overdose_deaths AS od ON od.fipscounty=CAST(fc.fipscounty AS numeric)
GROUP BY county
HAVING sum(od.overdose_deaths) > (SELECT ROUND(AVG(overdose_deaths),2) from overdose_deaths)
ORDER BY death DESC;


--Q5a. Write a query that finds the total population of Tennessee.
SELECT *FROM fips_county
SELECT *FROM population

SELECT f.state,SUM(p.population)
FROM fips_county AS f
INNER JOIN population AS p USING(fipscounty)
WHERE f.state='TN'
GROUP BY state

--Q5b. Build off of the query that you wrote in part a to write a query that
--returns for each county that county's name, its population, and the percentage 
--of the total population of Tennessee that is contained in that county.

SELECT (population/(SELECT SUM(p.population)
					FROM fips_county AS f
					INNER JOIN population AS p USING(fipscounty))*100) AS percent_pop 
FROM population AS p
INNER JOIN fips_county AS f USING(fipscounty)
WHERE f.county='ANDERSON'

-----------------MainQuery---------

SELECT f.state,county,p.population,
		ROUND((population/(SELECT SUM(p.population)
					FROM fips_county AS f
					INNER JOIN population AS p USING(fipscounty))*100),2) AS percent_pop 
FROM fips_county AS f
INNER JOIN population AS p USING(fipscounty)
WHERE f.state IN ('TN')
ORDER BY percent_pop DESC;


