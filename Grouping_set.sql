/*Q1.For the first few exercises, we are going to compare the total number of claims from Interventional Pain Management Specialists compared to those from Pain Managment
specialists.Write a query which returns the total number of claims for these two groups.*/
SELECT specialty_description,SUM(total_claim_count) AS total_claims
FROM prescriber AS p1
INNER JOIN prescription AS p2 USING(npi)
WHERE specialty_description IN ('Interventional Pain Management','Pain Management')
GROUP BY specialty_description

--Q2.Now, let's say that we want our output to also include the total number of claims
--between these two groups.Combine two queries with the UNION keyword to accomplish this. 
SELECT SUM(total_claim_count) AS total_claims
FROM prescriber AS p1
INNER JOIN prescription AS p2 USING(npi)
WHERE specialty_description='Interventional Pain Management' 
OR specialty_description='Pain Management'

