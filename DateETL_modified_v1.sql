/* The following codes find the time since the organization IDs' created their first contract */
SELECT TEM.created_by_organization_id AS organization_id, TEM.MinCreatTime AS first_create_at,
extract(day FROM current_timestamp - TEM.MinCreatTime) AS User_days,  round(extract(day from current_timestamp - TEM.MinCreatTime)/30.42) AS User_months
FROM
(
SELECT contracts_new.created_by_organization_id, MIN(contracts_new.created_at) MinCreatTime, 
COUNT(contracts_new.created_by_organization_id) AS Total_contract_created
FROM contracts_new Group BY contracts_new.created_by_organization_id ORDER BY MinCreatTime
) AS TEM





/* The following codes find the time (days) since the organization IDs' last created contract */
SELECT TEM.created_by_organization_id AS organization_id, TEM.MaxCreatTime AS last_create_at,
extract(day from current_timestamp - TEM.MaxCreatTime) AS Churn_days, round(extract(day from current_timestamp - TEM.MaxCreatTime)/30.42) AS Churn_months
FROM
(
SELECT contracts_new.created_by_organization_id, MAX(contracts_new.created_at) MaxCreatTime
FROM contracts_new Group BY contracts_new.created_by_organization_id ORDER BY MaxCreatTime DESC
) AS TEM



/* The following codes find the total contracts_new created by the organization IDs */
SELECT created_by_organization_id, count(created_by_organization_id) AS User_total_contracts_new_created
FROM contracts_new
GROUP BY created_by_organization_id
ORDER BY created_by_organization_id



/* Size of the organization */
SELECT organization_id, count(organization_id) AS num_of_members FROM organization_members
GROUP BY organization_id
ORDER BY organization_id



/* The time that the organization register their accounts */
SELECT * FROM organizations
ORDER BY id




/* The combined Table for organizations */
SELECT TOG.id AS orgnaization_id, TOG.created_at AS registered_at, TSZ.num_of_members AS user_num,
TOC.total_contract_created, TOC.first_created_at, TOC.last_created_at,
TOS.total_contract_signed, TOS.first_contract_signed_at AS first_signed_at, 
TOS.last_contract_signed_at AS last_signed_at
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
  COALESCE(template_creating_user_id, creating_user_id) AS creator_user_id,
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
AND TEM1.created_by_organization_id <> TEM2.organization_id
)
/* WHERE created_by_organization_id <> 6 AND created_by_organization_id <> 4 */
GROUP BY signed_by_organization_id /* ORDER BY MinSignTime */
ORDER BY signed_by_organization_id
) AS TOS
ON TOG.id = TOS.signed_by_organization_id






/* This part (TEM3) find the time that the organization's first contract is signed*/
SELECT created_by_organization_id, MIN(signed_at_date) MinCreateTime FROM (
  SELECT    contracts_new.id         AS contract_id, 
  signings.user_id     AS signing_user_id, 
  signings.created_at  AS signed_at_date,
  COALESCE(template_creating_user_id, creating_user_id) AS creator_user_id,
  created_by_organization_id AS created_by_organization_id
  FROM      contracts_new LEFT JOIN signings 
  ON signings.contract_id = contracts_new.id
  ) AS TEM
GROUP BY created_by_organization_id ORDER BY created_by_organization_id




/*This part (TEM4) find the time that the organization sign their first contract*/ /* problematic*/
SELECT organization_id AS signed_by_organization_id, MIN(signed_at_date) First_contract_Sign_Time FROM (
(
  SELECT    contracts_new.id         AS contract_id, 
  signings.user_id     AS signing_user_id, 
  signings.created_at  AS signed_at_date,
  COALESCE(template_creating_user_id, creating_user_id) AS creator_user_id,
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
AND TEM1.created_by_organization_id <> TEM2.organization_id
)
/* WHERE created_by_organization_id <> 6 AND created_by_organization_id <> 4 */
GROUP BY signed_by_organization_id /* ORDER BY MinSignTime */
ORDER BY signed_by_organization_id



/*This part (TEM4) find the time that the organization sign their last contract*/
SELECT organization_id AS signed_by_organization_id, MAX(signed_at_date) last_contract_sign_time FROM (
(
  SELECT    contracts_new.id         AS contract_id, 
  signings.user_id     AS signing_user_id, 
  signings.created_at  AS signed_at_date,
  COALESCE(template_creating_user_id, creating_user_id) AS creator_user_id,
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
AND TEM1.created_by_organization_id <> TEM2.organization_id
)
/* WHERE created_by_organization_id <> 6 AND created_by_organization_id <> 4 */
GROUP BY signed_by_organization_id /* ORDER BY MinSignTime */
ORDER BY signed_by_organization_id


/* organizations that registered an ID vs organizations that actually created account */
SELECT * FROM
(
SELECT organization_id, count(organization_id) AS num_of_members FROM 
(/* The effective user and their organization*/
SELECT user_id, MIN(organization_id) AS organization_id
FROM organization_members
GROUP BY user_id
ORDER BY user_id
) AS T1
GROUP BY organization_id
ORDER BY organization_id) AS TEM1
LEFT JOIN
(
SELECT created_by_organization_id, count(created_by_organization_id) AS User_total_contracts_new_created
FROM contracts_new
GROUP BY created_by_organization_id
ORDER BY created_by_organization_id) AS TEM2
ON TEM1.organization_id = TEM2.created_by_organization_id
/* WHERE TEM2.created_by_organization_id IS NOT NULL



/* 1 user to only 1 organization re-mapping */
SELECT user_id, MIN(organization_id) AS organization_id
FROM organization_members
GROUP BY user_id
ORDER BY user_id



/* Organization's user's last login time */
SELECT organization_id, user_id, last_login_at FROM
(
SELECT user_id, MIN(organization_id) AS organization_id
FROM organization_members
GROUP BY user_id
ORDER BY user_id
) AS T1
INNER JOIN
users_login AS T2
ON T1.user_id = T2.id
ORDER BY last_login_at




/* Organization's user's last login time DISTINCT organization ID */
SELECT organization_id, MAX(last_login_at) FROM
(
SELECT user_id, MIN(organization_id) AS organization_id
FROM organization_members
GROUP BY user_id
ORDER BY user_id
) AS T1
INNER JOIN
users_login AS T2
ON T1.user_id = T2.id
GROUP BY organization_id
ORDER BY organization_id



/* Full contract database */
  SELECT    contracts_new.id         AS contract_id, 
  signings.user_id     AS signing_user_id, 
  signings.created_at  AS signed_at_date,
  contracts_new.created_at AS created_at_date,
  COALESCE(template_creating_user_id, creating_user_id) AS creator_user_id,
  created_by_organization_id AS created_by_organization_id
  FROM      contracts_new LEFT JOIN signings 
  ON signings.contract_id = contracts_new.id
  ORDER BY contract_id



/* Full contract database with both signers and creator's organization information */ /* Important */
  SELECT T1.contract_id, T1.creator_user_id, T1.created_by_organization_id, T1.signing_user_id, T2.signed_by_organization_id, 
  T1.created_at_date, T1.signed_at_date FROM
  (
  SELECT    contracts_new.id         AS contract_id, 
  signings.user_id     AS signing_user_id, 
  signings.created_at  AS signed_at_date,
  contracts_new.created_at AS created_at_date,
  signings.created_at - contracts_new.created_at AS sign_time_gap,
  COALESCE(template_creating_user_id, creating_user_id) AS creator_user_id,
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




/* Number of contracts_new signed by organization users */
SELECT signed_by_organization_id, MIN(signed_at_date) AS first_contract_signed_at, 
COUNT(signed_by_organization_id) AS Total_signed_contracts_new
FROM(
  SELECT T1.contract_id, T1.creator_user_id, T1.created_by_organization_id, T1.signing_user_id, T2.signed_by_organization_id, 
  T1.created_at_date, T1.signed_at_date FROM
  (
  SELECT    contracts_new.id         AS contract_id, 
  signings.user_id     AS signing_user_id, 
  signings.created_at  AS signed_at_date,
  contracts_new.created_at AS created_at_date,
  signings.created_at - contracts_new.created_at AS sign_time_gap,
  COALESCE(template_creating_user_id, creating_user_id) AS creator_user_id,
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
) AS T8
GROUP BY signed_by_organization_id
ORDER BY signed_by_organization_id




/* Summary of organization ID */
SELECT *
FROM
(
SELECT contracts_new.created_by_organization_id, MIN(contracts_new.created_at) AS first_contract_created_at, 
COUNT(contracts_new.created_by_organization_id) AS Total_contract_created
FROM contracts_new Group BY contracts_new.created_by_organization_id ORDER BY first_contract_created_at
) AS TC
LEFT JOIN
(/*The following is the signed information*/
SELECT signed_by_organization_id, MIN(signed_at_date) AS first_contract_signed_at, 
COUNT(signed_by_organization_id) AS Total_signed_contracts_new
FROM(
  SELECT T1.contract_id, T1.creator_user_id, T1.created_by_organization_id, T1.signing_user_id, T2.signed_by_organization_id, 
  T1.created_at_date, T1.signed_at_date FROM
  (
  SELECT    contracts_new.id         AS contract_id, 
  signings.user_id     AS signing_user_id, 
  signings.created_at  AS signed_at_date,
  contracts_new.created_at AS created_at_date,
  signings.created_at - contracts_new.created_at AS sign_time_gap,
  COALESCE(template_creating_user_id, creating_user_id) AS creator_user_id,
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
) AS T8
GROUP BY signed_by_organization_id
ORDER BY signed_by_organization_id
) AS TS
ON TC.created_by_organization_id = TS.signed_by_organization_id




/* Find the organization switcher */
SELECT * FROM
( /* the following table TSW find all the detail information of switchers */
SELECT *, first_contract_created_at - first_contract_signed_at AS transition_gap
FROM
(
SELECT contracts_new.created_by_organization_id, MIN(contracts_new.created_at) AS first_contract_created_at, 
COUNT(contracts_new.created_by_organization_id) AS Total_contract_created
FROM contracts_new Group BY contracts_new.created_by_organization_id ORDER BY first_contract_created_at
) AS TC
INNER JOIN
(/*The following is the signed information*/
SELECT signed_by_organization_id, MIN(signed_at_date) AS first_contract_signed_at, 
COUNT(signed_by_organization_id) AS Total_signed_contracts_new
FROM(
  SELECT T1.contract_id, T1.creator_user_id, T1.created_by_organization_id, T1.signing_user_id, T2.signed_by_organization_id, 
  T1.created_at_date, T1.signed_at_date FROM
  (
  SELECT    contracts_new.id         AS contract_id, 
  signings.user_id     AS signing_user_id, 
  signings.created_at  AS signed_at_date,
  contracts_new.created_at AS created_at_date,
  signings.created_at - contracts_new.created_at AS sign_time_gap,
  COALESCE(template_creating_user_id, creating_user_id) AS creator_user_id,
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
) AS T8
GROUP BY signed_by_organization_id
ORDER BY signed_by_organization_id
) AS TS
ON TC.created_by_organization_id = TS.signed_by_organization_id
WHERE first_contract_created_at > first_contract_signed_at
ORDER BY created_by_organization_id
) AS TSW
UNION ALL /* The following parts are just used to find the total sum of the contracts_new they created */
SELECT NULL, NULL, SUM(total_contract_created), NULL, NULL, SUM(total_signed_contracts_new), NULL
FROM
( /* the following table TSW find all the detail information of switchers */
SELECT *, first_contract_created_at - first_contract_signed_at AS transition_gap
FROM
(
SELECT contracts_new.created_by_organization_id, MIN(contracts_new.created_at) AS first_contract_created_at, 
COUNT(contracts_new.created_by_organization_id) AS Total_contract_created
FROM contracts_new Group BY contracts_new.created_by_organization_id ORDER BY first_contract_created_at
) AS TC
INNER JOIN
(/*The following is the signed information*/
SELECT signed_by_organization_id, MIN(signed_at_date) AS first_contract_signed_at, 
COUNT(signed_by_organization_id) AS Total_signed_contracts_new
FROM(
  SELECT T1.contract_id, T1.creator_user_id, T1.created_by_organization_id, T1.signing_user_id, T2.signed_by_organization_id, 
  T1.created_at_date, T1.signed_at_date FROM
  (
  SELECT    contracts_new.id         AS contract_id, 
  signings.user_id     AS signing_user_id, 
  signings.created_at  AS signed_at_date,
  contracts_new.created_at AS created_at_date,
  signings.created_at - contracts_new.created_at AS sign_time_gap,
  COALESCE(template_creating_user_id, creating_user_id) AS creator_user_id,
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
) AS T8
GROUP BY signed_by_organization_id
ORDER BY signed_by_organization_id
) AS TS
ON TC.created_by_organization_id = TS.signed_by_organization_id
WHERE first_contract_created_at > first_contract_signed_at
ORDER BY transition_gap DESC
) AS TSW



/* User without organization*/ /* useless */
SELECT * FROM
(
  SELECT    contracts_new.id         AS contract_id, 
  signings.user_id     AS signing_user_id, 
  signings.created_at  AS signed_at_date,
  COALESCE(template_creating_user_id, creating_user_id) AS creator_user_id,
  created_by_organization_id AS created_by_organization_id
  FROM      contracts_new LEFT JOIN signings 
  ON signings.contract_id = contracts_new.id
) AS TEM
WHERE signing_user_id IS NOT NULL AND created_by_organization_id IS NOT NULL
AND creator_user_id IS NOT NULL 
ORDER BY created_by_organization_id 




 
/* Aggrated information of userIDs */
/* Time of registration of accounts */
SELECT users.ID, users.created_at, TOM.organization_id FROM users
INNER JOIN
(/* TOM is the organization member table */
SELECT user_id, MIN(organization_id) AS organization_id
FROM organization_members
GROUP BY user_id
ORDER BY user_id
) AS TOM
ON users.id = TOM.user_id
ORDER BY id



/* Time a userID created first contract and last contract */
SELECT TU.id, COUNT(TC.contract_id) AS total_created, MIN(TC.created_at_date) AS first_created,
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
  COALESCE(template_creating_user_id, creating_user_id) AS creator_user_id,
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



/* Time a userID signed first contract and last contract */
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
  COALESCE(template_creating_user_id, creating_user_id) AS creator_user_id,
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


/******************************************* COMBINED USER TABLE ********************************************/
/* Combined big user Table */ /* Important */
SELECT TT1.id AS user_id, TT1.organization_id, TT2.total_created, TT2.first_created AS first_created_at,
TT2.last_created AS last_created_at, TT3.total_signed, TT3.first_signed AS first_signed_at, 
TT3.last_signed AS last_signed_at
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
  SELECT    contracts_new.id         AS contract_id, 
  signings.user_id     AS signing_user_id, 
  signings.created_at  AS signed_at_date,
  contracts_new.created_at AS created_at_date,
  signings.created_at - contracts_new.created_at AS sign_time_gap,
  COALESCE(template_creating_user_id, creating_user_id) AS creator_user_id,
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
  COALESCE(template_creating_user_id, creating_user_id) AS creator_user_id,
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

/******************************************* COMBINED USER TABLE ********************************************/






/*------------------------------ USER SWITCHER ----------------------------------*/
/* User Swicher */
SELECT * FROM
(
SELECT TT1.id AS user_id, TT1.organization_id, TT2.total_created, TT2.first_created AS first_created_at,
TT2.last_created AS last_created_at, TT3.total_signed, TT3.first_signed AS first_signed_at, 
TT3.last_signed AS last_signed_at
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
  SELECT    contracts_new.id         AS contract_id, 
  signings.user_id     AS signing_user_id, 
  signings.created_at  AS signed_at_date,
  contracts_new.created_at AS created_at_date,
  signings.created_at - contracts_new.created_at AS sign_time_gap,
  COALESCE(template_creating_user_id, creating_user_id) AS creator_user_id,
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
  COALESCE(template_creating_user_id, creating_user_id) AS creator_user_id,
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
) AS TTT
WHERE TTT.first_created_at > TTT.first_signed_at

/*------------------------------ USER SWITCHER ----------------------------------*/


/* The organization ID that created some contracts_new and then its users deactivated */
SELECT * FROM
(
SELECT * FROM
(
SELECT T2.organization_id, id AS User_Id, deactivated_at AS User_deactivate FROM
users_deactivated AS T1
INNER JOIN
organization_members AS T2
ON T1.id = T2.user_id) AS TEM1
INNER JOIN
(
SELECT created_by_organization_id
FROM
contracts_new) AS TEM2
ON TEM1.organization_id = TEM2.created_by_organization_id
ORDER BY organization_id) AS T1
INNER JOIN
(
SELECT organization_id, count(organization_id) AS num_of_members FROM organization_members
GROUP BY organization_id
ORDER BY organization_id) AS T2
ON T1.organization_id = T2.organization_id




/* Total number of contracts_new on the platform */
SELECT DISTINCT contract_id
FROM
(
  SELECT    contracts_new.id  AS contract_id, 
  signings.user_id     AS signing_user_id, 
  signings.created_at  AS signed_at_date,
  COALESCE(template_creating_user_id, creating_user_id) AS creator_user_id,
  created_by_organization_id AS created_by_organization_id
  FROM      contracts_new LEFT JOIN signings 
  ON signings.contract_id = contracts_new.id) AS T1
ORDER BY contract_id


/* Just some scipts */
SELECT * FROM
(
  SELECT    contracts_new.id         AS contract_id, 
  signings.user_id     AS signing_user_id, 
  signings.created_at  AS signed_at_date,
  contracts_new.created_at AS created_at_date,
  COALESCE(template_creating_user_id, creating_user_id) AS creator_user_id,
  created_by_organization_id AS created_by_organization_id
  FROM      contracts_new LEFT JOIN signings 
  ON signings.contract_id = contracts_new.id
  ORDER BY contract_id
) AS T1
WHERE signing_user_id = 3529