/* Full contract database with both signers and creator's organization information */
  SELECT T1.contract_id, T1.creator_user_id, T1.created_by_organization_id, T1.signing_user_id, T2.signed_by_organization_id, 
  T1.created_at_date, T1.signed_at_date,
  EXTRACT(epoch FROM T1.signed_at_date - T1.created_at_date)/3600 AS time_gap_hours
  FROM
  (
  SELECT    contracts_new.id         AS contract_id, 
  signings.user_id     AS signing_user_id, 
  signings.created_at  AS signed_at_date,
  contracts_new.created_at AS created_at_date,
  signings.created_at - contracts_new.created_at AS sign_time_gap,
  template_creating_user_id AS creator_user_id,
  created_by_organization_id AS created_by_organization_id
  FROM      contracts_new LEFT JOIN signings 
  ON signings.contract_id = contracts_new.id
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


/* The total number of contracts_new created by all organization ID or all switchers */ /* Forth level sketch */
SELECT sum(total_contract_created) AS total_contract_created, sum(total_contract_signed) AS total_contract_signed 
FROM
(/* The organizations switchers or all the organization ID */ /* Third level sketch */
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
SELECT contracts_new.created_by_organization_id, COUNT(contracts_new.created_by_organization_id) AS Total_contract_created,
MIN(contracts_new.created_at) AS first_created_at, MAX(contracts_new.created_at) AS last_created_at
FROM contracts_new Group BY contracts_new.created_by_organization_id
) AS TOC
ON TOG.id = TOC.created_by_organization_id
LEFT JOIN
(/* TOS find the time that the organization sign their first and last contract */
SELECT organization_id AS signed_by_organization_id, 
COUNT(organization_id) AS Total_contract_signed,
MIN(signed_at_date) AS first_contract_signed_at,
MAX(signed_at_date) AS last_contract_signed_at FROM (
(
  SELECT    contracts_new.id         AS contract_id, 
  signings.user_id     AS signing_user_id, 
  signings.created_at  AS signed_at_date,
  template_creating_user_id AS creator_user_id,
  created_by_organization_id AS created_by_organization_id
  FROM      contracts_new LEFT JOIN signings 
  ON signings.contract_id = contracts_new.id
) AS TEM1 INNER JOIN 
(
SELECT user_id, MIN(organization_id) AS organization_id
FROM organization_members
GROUP BY user_id
ORDER BY user_id
) AS TEM2
ON TEM1.signing_user_id = TEM2.user_id
)
/* WHERE created_by_organization_id <> 6 AND created_by_organization_id <> 4 */
GROUP BY signed_by_organization_id /* ORDER BY MinSignTime */
ORDER BY signed_by_organization_id
) AS TOS
ON TOG.id = TOS.signed_by_organization_id
) AS TTTG
WHERE total_contract_created > 0 OR total_contract_signed > 0
) AS TTTG1
WHERE transition_hours > 0
) AS TTTG2




/* Count the total created and signed contracts_new by each group */ /* Fourth level sketch */
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
(
/* Time a userID created first contract and last contract */
SELECT TTK1.id, TTK2.total_created, TTK1.first_created, TTK1.last_created FROM
(
SELECT TU.id, MIN(TC.created_at_date) AS first_created,
MAX(TC.created_at_date) AS last_created
FROM users AS TU
INNER JOIN
(
  SELECT T1.contract_id, T1.creator_user_id, T1.created_by_organization_id, T1.signing_user_id, T2.signed_by_organization_id, 
  T1.created_at_date, T1.signed_at_date FROM
  (
  SELECT    contracts_new.id         AS contract_id, 
  signings.user_id     AS signing_user_id, 
  signings.created_at  AS signed_at_date,
  contracts_new.created_at AS created_at_date,
  signings.created_at - contracts_new.created_at AS sign_time_gap,
  template_creating_user_id AS creator_user_id,
  created_by_organization_id AS created_by_organization_id
  FROM      contracts_new LEFT JOIN signings 
  ON signings.contract_id = contracts_new.id
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
) AS TTK1
INNER JOIN
(
SELECT creator_user_id, COUNT(creator_user_id) AS total_created
FROM
(
SELECT contract_id, MIN(creator_user_id) AS creator_user_id FROM
(
  SELECT T1.contract_id, T1.creator_user_id, T1.created_by_organization_id, T1.signing_user_id, T2.signed_by_organization_id, 
  T1.created_at_date, T1.signed_at_date FROM
  (
  SELECT    contracts_new.id         AS contract_id, 
  signings.user_id     AS signing_user_id, 
  signings.created_at  AS signed_at_date,
  contracts_new.created_at AS created_at_date,
  signings.created_at - contracts_new.created_at AS sign_time_gap,
  template_creating_user_id AS creator_user_id,
  created_by_organization_id AS created_by_organization_id
  FROM      contracts_new LEFT JOIN signings 
  ON signings.contract_id = contracts_new.id
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
) AS TT21
GROUP BY TT21.contract_id
ORDER BY TT21.contract_id
) AS TK2
GROUP BY creator_user_id
ORDER BY creator_user_id
) AS TTK2 
ON TTK1.id = TTK2.creator_user_id
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
  SELECT    contracts_new.id         AS contract_id, 
  signings.user_id     AS signing_user_id, 
  signings.created_at  AS signed_at_date,
  contracts_new.created_at AS created_at_date,
  signings.created_at - contracts_new.created_at AS sign_time_gap,
  template_creating_user_id AS creator_user_id,
  created_by_organization_id AS created_by_organization_id
  FROM      contracts_new LEFT JOIN signings 
  ON signings.contract_id = contracts_new.id
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
/* temporary added */
WHERE primary_organization_id <> 4 AND primary_organization_id <> 6
/* temporary added */
) AS TTTT
WHERE FS2FC > 0
) AS TTTT1
WHERE user_id <> 1 AND user_id <> 11 AND user_id <> 90 AND user_id <> 56628 AND user_id <> 23446 AND user_id <> 271 AND user_id <> 72 
AND user_id <> 55 AND user_id <> 3 AND user_id <> 75
ORDER BY primary_organization_id
) AS TTTT2
