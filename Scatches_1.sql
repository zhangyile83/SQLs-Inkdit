


SELECT sum(total_created) AS user_total_created, sum(total_signed) AS user_total_signed FROM
(/* The user table remove the Inkdit official users */ /* Third level sketch */
SELECT * FROM
(/* The combined Table for all users or swticher user removed the timestamp */ /* Sceond level sketch */
SELECT user_id, primary_organization_id, JOINED_num, total_created, total_signed,
FS2FC AS transition_hours, churn_day, registered_day, active_day
FROM
(/* The combined Table for all users with time stamp */ /* Original Version */
SELECT TT1.id AS user_id, TT1.organization_id AS Primary_organization_id, TUO.JOINED_num, TT1.created_at AS registered_at,
TT2.total_created, TT2.first_created AS first_created_at,
TT2.last_created AS last_created_at, TT3.total_signed, TT3.first_signed AS first_signed_at, 
TT3.last_signed AS last_signed_at,
EXTRACT(DAY FROM TT2.first_created - TT1.created_at) AS R2FC, 
EXTRACT(DAY FROM TT3.first_signed - TT1.created_at) AS R2FS,
EXTRACT(EPOCH FROM TT2.first_created - TT3.first_signed)/3600 AS FS2FC,
EXTRACT(DAY FROM TIMESTAMP '2016-10-20 23:00' - GREATEST(TT2.last_created , TT3.last_signed)) AS churn_day,
EXTRACT(DAY FROM TIMESTAMP '2016-10-20 23:00' -  TT1.created_at) AS registered_day,
EXTRACT(DAY FROM GREATEST(TT2.last_created, TT3.last_signed) - LEAST(TT2.first_created, TT3.first_signed)) AS active_day
FROM
(
SELECT users.ID, users.created_at, TOM.organization_id FROM users
LEFT JOIN
(/* TOM is the organization member table */
SELECT user_id, MIN(organization_id) AS organization_id
FROM organization_members
GROUP BY user_id
ORDER BY user_id
) AS TOM
ON users.id = TOM.user_id
ORDER BY id
) AS TT1
LEFT JOIN
(/* Time a userID created first contract and last contract */
SELECT TU.id, COUNT(TC.contract_id) AS total_created, MIN(TC.created_at_date) AS first_created,
MAX(TC.created_at_date) AS last_created
FROM users AS TU
INNER JOIN
(
  SELECT T1.contract_id, T1.creator_user_id, T1.created_by_organization_id, T1.signing_user_id, T2.signed_by_organization_id, 
  T1.created_at_date, T1.signed_at_date FROM
  (
  SELECT    contracts.id         AS contract_id, 
  signings.user_id     AS signing_user_id, 
  signings.created_at  AS signed_at_date,
  contracts.created_at AS created_at_date,
  signings.created_at - contracts.created_at AS sign_time_gap,
  COALESCE(template_creating_user_id, creating_user_id) AS creator_user_id,
  created_by_organization_id AS created_by_organization_id
  FROM      contracts LEFT JOIN signings 
  ON signings.contract_id = contracts.id
  ORDER BY contract_id
  ) AS T1
  /* Add the following to link the signer with their organization */
LEFT JOIN
  (
  SELECT user_id, organization_id AS signed_by_organization_id
  FROM 
  (SELECT user_id, MIN(organization_id) AS organization_id
FROM organization_members
GROUP BY user_id
ORDER BY user_id) AS TT2
  ) AS T2 
  ON T1.signing_user_id = T2.user_id
  ORDER BY contract_id
) AS TC
ON TU.id = TC.creator_user_id
GROUP BY TU.id
) AS TT2
ON TT1.id = TT2.id 
LEFT JOIN
(/* Time a userID signed first contract and last contract */
SELECT TU.id, COUNT(TC.contract_id) AS total_signed, MIN(TC.signed_at_date) AS first_signed,
MAX(TC.signed_at_date) AS last_signed
FROM users AS TU
INNER JOIN
(
  SELECT T1.contract_id, T1.creator_user_id, T1.created_by_organization_id, T1.signing_user_id, T2.signed_by_organization_id, 
  T1.created_at_date, T1.signed_at_date FROM
  (
  SELECT    contracts.id         AS contract_id, 
  signings.user_id     AS signing_user_id, 
  signings.created_at  AS signed_at_date,
  contracts.created_at AS created_at_date,
  signings.created_at - contracts.created_at AS sign_time_gap,
  COALESCE(template_creating_user_id, creating_user_id) AS creator_user_id,
  created_by_organization_id AS created_by_organization_id
  FROM      contracts LEFT JOIN signings 
  ON signings.contract_id = contracts.id
  ORDER BY contract_id
  ) AS T1
  /* Add the following to link the signer with their organization */
  LEFT JOIN
  (
  SELECT user_id, organization_id AS signed_by_organization_id
  FROM 
  (SELECT user_id, MIN(organization_id) AS organization_id
FROM organization_members
GROUP BY user_id
ORDER BY user_id) AS TT2
  ) AS T2 
  ON T1.signing_user_id = T2.user_id
  ORDER BY contract_id
) AS TC
ON TU.id = TC.signing_user_id
GROUP BY TU.id
) AS TT3
ON TT1.id = TT3.id
INNER JOIN
(/* User and the number of their joined organizations */
SELECT user_id, COUNT(user_id) AS JOINED_num
FROM organization_members
GROUP BY user_id
ORDER BY user_id
) AS TUO
ON TT1.id = TUO.user_id
) AS TTTT
WHERE FS2FC > 0
) AS TTTT1

WHERE user_id <> 1 AND user_id <> 11 AND user_id <> 90 AND user_id <> 56628 AND user_id <> 23446 AND user_id <> 271 AND user_id <> 72 
AND user_id <> 55 AND user_id <> 3 AND user_id <> 75
) AS TTTT2