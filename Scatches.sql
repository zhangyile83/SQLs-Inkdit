/* The organizations switchers or all the organization ID */ /* Third level sketch */
SELECT * FROM
(/* The combined Table for organizations removed the invalid ID who have never created or signed a contract */ /* Second level sketch */
SELECT organization_id, user_num, total_contract_created, total_contract_signed,
FS2FC AS transition_hours, churn_day, registered_day, active_day
FROM
(/* The combined Table for organizations with all the time stamp */ /* Original Version */
SELECT TOG.id AS organization_id, TOG.created_at AS registered_at, TSZ.num_of_members AS user_num,
TOC.total_contract_created, TOC.first_created_at, TOC.last_created_at,
TOS.total_contract_signed, TOS.first_contract_signed_at AS first_signed_at, 
TOS.last_contract_signed_at AS last_signed_at,
EXTRACT(DAY FROM TOC.first_created_at - TOG.created_at) AS R2FC, 
EXTRACT(DAY FROM TOS.first_contract_signed_at - TOG.created_at) AS R2FS,
EXTRACT(EPOCH FROM TOC.first_created_at - TOS.first_contract_signed_at)/3600 AS FS2FC,
EXTRACT(DAY FROM TIMESTAMP '2016-10-20 23:00' - GREATEST(TOC.last_created_at, TOS.last_contract_signed_at)) AS churn_day,
EXTRACT(DAY FROM TIMESTAMP '2016-10-20 23:00' -  TOG.created_at) AS registered_day,
EXTRACT(DAY FROM GREATEST(TOC.last_created_at, TOS.last_contract_signed_at) - LEAST(TOC.first_created_at, TOS.first_contract_signed_at)) AS active_day
FROM organizations AS TOG
LEFT JOIN
(/* TSZ denotes the size of the organization */
SELECT organization_id, count(organization_id) AS num_of_members FROM organization_members
GROUP BY organization_id
ORDER BY organization_id
) AS TSZ
ON TOG.id = TSZ.organization_id
LEFT JOIN
(/* TOC denotes the organization's created their first and last contract */
SELECT contracts.created_by_organization_id, COUNT(contracts.created_by_organization_id) AS Total_contract_created,
MIN(contracts.created_at) AS first_created_at, MAX(contracts.created_at) AS last_created_at
FROM contracts Group BY contracts.created_by_organization_id
) AS TOC
ON TOG.id = TOC.created_by_organization_id
LEFT JOIN
(/* TOS find the time that the organization sign their first and last contract */
SELECT organization_id AS signed_by_organization_id, 
COUNT(organization_id) AS Total_contract_signed,
MIN(signed_at_date) AS first_contract_signed_at,
MAX(signed_at_date) AS last_contract_signed_at FROM (
(
  SELECT    contracts.id         AS contract_id, 
  signings.user_id     AS signing_user_id, 
  signings.created_at  AS signed_at_date,
  COALESCE(template_creating_user_id, creating_user_id) AS creator_user_id,
  created_by_organization_id AS created_by_organization_id
  FROM      contracts LEFT JOIN signings 
  ON signings.contract_id = contracts.id
) AS TEM1 INNER JOIN 
(
SELECT user_id, MIN(organization_id) AS organization_id
FROM organization_members
GROUP BY user_id
ORDER BY user_id
) AS TEM2
ON TEM1.signing_user_id = TEM2.user_id
AND TEM1.created_by_organization_id <> TEM2.organization_id
)
/* WHERE created_by_organization_id <> 6 AND created_by_organization_id <> 4 */
GROUP BY signed_by_organization_id /* ORDER BY MinSignTime */
ORDER BY signed_by_organization_id
) AS TOS
ON TOG.id = TOS.signed_by_organization_id
) AS TTTG
WHERE total_contract_created > 0 OR total_contract_signed > 0
) AS TTTG1
WHERE transition_hours > 0 AND organization_id <> 4 AND organization_id <> 6
ORDER BY user_num DESC