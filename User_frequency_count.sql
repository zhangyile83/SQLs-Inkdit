SELECT content FROM contracts where creator_id = 23820;

SELECT * FROM (select creator_id, count(*) AS totalNum 
FROM contracts group by creator_id) AS foo ORDER BY totalNum


/* Select all the creator ID and created time between two time points */
SELECT * FROM (SELECT creator_id, created_at FROM contracts WHERE created_at BETWEEN '2011-10-1' AND '2012-2-1'
ORDER BY created_at) AS TEM WHERE creator_id <> 6 AND creator_id <> 4


SELECT COUNT(DISTINCT TEM1. signer_id) FROM (SELECT TEM.creator_id, TEM.signer_id, TEM.created_at FROM
(SELECT contracts.creator_id, signings.signer_id, contracts.created_at 
FROM contracts, signings 
WHERE contracts.contract_id = signings.contract_id
ORDER BY created_at) AS TEM
WHERE TEM.creator_id = 6) as TEM1


SELECT TEM1.signer_id, COUNT(TEM1.signer_id) FROM
(SELECT TEM.signer_id FROM
(SELECT contracts.creator_id, signings.signer_id, contracts.created_at 
FROM contracts, signings 
WHERE contracts.contract_id = signings.contract_id) AS TEM
WHERE TEM.creator_id = 6) AS TEM1 GROUP BY TEM1.signer_id ORDER BY TEM1.signer_id


SELECT signings.signer_id, signings.created_at AS MinSignTime, contracts.creator_id, contracts.created_at AS creat_time
FROM contracts
INNER JOIN signings
ON contracts.creator_ID = signings.signer_id


TEM1.signer_id, TEM1.MinSignTime, TEM2.creator_id, TEM2.MinCreatTime

/* The following find the case that the signner become the creator */
SELECT * FROM
(SELECT signings.signer_id, MIN(signings.created_at) MinSignTime
FROM signings Group BY signings.signer_id ORDER BY MinSignTime) AS TEM1
INNER JOIN
(SELECT contracts.creator_id, MIN(contracts.created_at) MinCreatTime
FROM contracts Group BY contracts.creator_id ORDER BY MinCreatTime) AS TEM2
ON TEM1.signer_id = TEM2.creator_id
WHERE MinCreatTime BETWEEN '2011-05-10' AND '2016-05-10' AND MinCreatTime > MinSignTime


/* The following find the case that the creator is also a signer */
SELECT * FROM
(SELECT signings.signer_id, signings.contract_id
FROM signings) AS TEM1
INNER JOIN
(SELECT contracts.creator_id, contracts.contract_id
FROM contracts) AS TEM2
ON TEM1.contract_id = TEM2.contract_id AND TEM1.signer_id = TEM2.creator_id



/* The following find the timestamp that organization user created their first inkdit contract */
SELECT contracts.created_by_organization_id, MIN(contracts.created_at) MinCreatTime
FROM contracts Group BY contracts.created_by_organization_id ORDER BY MinCreatTime


/* The following find the timestamp that organization user created their last inkdit contract */
SELECT contracts.created_by_organization_id, MAX(contracts.created_at) MaxCreatTime
FROM contracts Group BY contracts.created_by_organization_id ORDER BY MaxCreatTime DESC




/* The following find the first time the creator begin to use Inkdit between certain period*/
SELECT COUNT(creator_id) FROM
(SELECT contracts.creator_id, MIN(contracts.created_at) MinCreatTime
FROM contracts Group BY contracts.creator_id ORDER BY MinCreatTime) TEM
WHERE TEM.MinCreatTime BETWEEN '2011-05-10' AND '2016-11-10'

/* Find the monthly average usage for user created between certain period*/
SELECT creator_id FROM
(SELECT contracts.creator_id, MIN(contracts.created_at) MinCreatTime
FROM contracts Group BY contracts.creator_id ORDER BY MinCreatTime) TEM
WHERE TEM.MinCreatTime BETWEEN '2011-05-10' AND '2016-05-10'


/* Select  */
SELECT * FROM users WHERE id = 24472
SELECT * FROM contracts WHERE creator_id = 24472

-- paying userID: 7263  7740  8312  8313  9460 13315 18821 18855 20654 21534 23181 23182 23305 30897 31669 51072 52550 60617
-- paying userID that have logged in record: 7263  7740  8313  9460 13315 18821 20654 21534 23305 30897 31669 51072 52550 60617
-- paying user that have never logged in: 8312, 18855, 23181, 23182 


/* The following find the first time the user created an Inkdit between certain period*/
SELECT TEM1.id, created_at FROM
(SELECT id, created_at, last_login_at
FROM users
WHERE last_login_at BETWEEN '2010-10-1' AND '2018-10-1') AS TEM1
WHERE TEM1.created_at BETWEEN '2011-10-1' AND '2018-10-1' ORDER BY TEM1.id

/* The following user userd STRIP */
SELECT creator_id, SUM(amount) FROM
(SELECT creator_id, contract_id AS CID1
FROM contracts) AS TEM1
INNER JOIN
(SELECT contract_id AS CID2, amount, created_at
FROM stripe_payments) AS TEM2
ON TEM1.CID1 = TEM2.CID2
GROUP BY creator_id

/* Find all IDs */
SELECT count(*) FROM contracts WHERE creator_id = 4

SELECT * FROM contracts WHERE created_at BETWEEN '2011-10-1' AND '2013-6-1'
ORDER BY created_at


/* Joint two tables together to find */
SELECT * FROM
(SELECT *
FROM signings) AS TEM1
INNER JOIN
(SELECT *
FROM contracts) AS TEM2
ON TEM1.contract_id = TEM2.id
WHERE created_by_organization_id > 0 AND contract_id = 64246
ORDER BY contract_id

/* The new database  */
SELECT * FROM (
SELECT    contracts.id         AS contract_id, 
          signings.user_id     AS signing_user_id, 
          signings.created_at  AS signed_at_date,
          COALESCE(template_creating_user_id, creating_user_id) AS creator_user_id,
          created_by_organization_id AS created_by_organization_id
FROM      contracts LEFT JOIN signings 
       ON signings.contract_id = contracts.id
       ORDER BY contract_id) AS TEM

/* Find the user ID and the time that create the first contracts on Inkdit */
SELECT creator_user_id, MIN(signed_at_date) MinSignTime FROM 
(SELECT    contracts.id         AS contract_id, 
          signings.user_id     AS signing_user_id, 
          signings.created_at  AS signed_at_date,
          COALESCE(template_creating_user_id, creating_user_id) AS creator_user_id,
          created_by_organization_id AS created_by_organization_id
FROM      contracts LEFT JOIN signings 
       ON signings.contract_id = contracts.id) AS TEM
       GROUP BY creator_user_id ORDER BY MinSignTime


/* Find the signer ID that who sign their first contract on Inkdit */
SELECT signing_user_id, MIN(signed_at_date) MinSignTime FROM 
(SELECT    contracts.id         AS contract_id, 
          signings.user_id     AS signing_user_id, 
          signings.created_at  AS signed_at_date,
          COALESCE(template_creating_user_id, creating_user_id) AS creator_user_id,
          created_by_organization_id AS created_by_organization_id
FROM      contracts LEFT JOIN signings 
       ON signings.contract_id = contracts.id) AS TEM
       GROUP BY signing_user_id ORDER BY MinSignTime



/* Find the case that the signer become a creator after the signing*/
SELECT * FROM
(SELECT creator_user_id, MIN(signed_at_date) AS MinCreateTime FROM 
(SELECT    contracts.id         AS contract_id, 
          signings.user_id     AS signing_user_id, 
          signings.created_at  AS signed_at_date,
          COALESCE(template_creating_user_id, creating_user_id) AS creator_user_id,
          created_by_organization_id AS created_by_organization_id
FROM      contracts LEFT JOIN signings 
       ON signings.contract_id = contracts.id) AS TEM
       GROUP BY creator_user_id ORDER BY MinCreateTime) AS TEMcreate
       INNER JOIN
       (SELECT signing_user_id, MIN(signed_at_date) MinSignTime FROM 
(SELECT    contracts.id         AS contract_id, 
          signings.user_id     AS signing_user_id, 
          signings.created_at  AS signed_at_date,
          COALESCE(template_creating_user_id, creating_user_id) AS creator_user_id,
          created_by_organization_id AS created_by_organization_id
FROM      contracts LEFT JOIN signings 
       ON signings.contract_id = contracts.id) AS TEM
       GROUP BY signing_user_id ORDER BY MinSignTime) AS TEMsign
       ON TEMsign.signing_user_id = TEMcreate.creator_user_id AND mincreatetime > minsigntime



/* Find the organization ID that who CREATE their first contract on Inkdit */
SELECT COUNT(*) FROM
(
  SELECT created_by_organization_id, MIN(signed_at_date) MinSignTime FROM 
  (SELECT    contracts.id         AS contract_id, 
  signings.user_id     AS signing_user_id, 
  signings.created_at  AS signed_at_date,
  COALESCE(template_creating_user_id, creating_user_id) AS creator_user_id,
  created_by_organization_id AS created_by_organization_id
  FROM      contracts LEFT JOIN signings 
  ON signings.contract_id = contracts.id) AS TEM
  GROUP BY created_by_organization_id ORDER BY MinSignTime
  ) AS TEM1
  WHERE TEM1.MinSignTime BETWEEN '2010-10-1' AND '2018-6-1'



/* Tables containing both signining organization and creating organization*/
 SELECT * FROM(
  SELECT    contracts.id         AS contract_id, 
  signings.user_id     AS signing_user_id, 
  signings.created_at  AS signed_at_date,
  COALESCE(template_creating_user_id, creating_user_id) AS creator_user_id,
  created_by_organization_id AS created_by_organization_id
  FROM      contracts LEFT JOIN signings 
  ON signings.contract_id = contracts.id
) AS TEM1 INNER JOIN 
(
SELECT organization_id, user_id
FROM organization_members
) AS TEM2
ON TEM1.signing_user_id = TEM2.user_id



/* Find the organization creators on Inkdit */
SELECT created_by_organization_id FROM (
  SELECT    contracts.id         AS contract_id, 
  signings.user_id     AS signing_user_id, 
  signings.created_at  AS signed_at_date,
  COALESCE(template_creating_user_id, creating_user_id) AS creator_user_id,
  created_by_organization_id AS created_by_organization_id
  FROM      contracts LEFT JOIN signings 
  ON signings.contract_id = contracts.id
  ) AS TEM
GROUP BY created_by_organization_id ORDER BY created_by_organization_id


/* Find the organization signers on Inkdit */
SELECT organization_id AS signed_by_organization_id, MIN(signed_at_date) MinSignTime FROM (
  SELECT    contracts.id         AS contract_id, 
  signings.user_id     AS signing_user_id, 
  signings.created_at  AS signed_at_date,
  COALESCE(template_creating_user_id, creating_user_id) AS creator_user_id,
  created_by_organization_id AS created_by_organization_id
  FROM      contracts LEFT JOIN signings 
  ON signings.contract_id = contracts.id
) AS TEM1 INNER JOIN 
(
SELECT organization_id, user_id
FROM organization_members
) AS TEM2
ON TEM1.signing_user_id = TEM2.user_id
GROUP BY signed_by_organization_id ORDER BY MinSignTime



/* Find the organization switchers on Inkdit */
SELECT * FROM
(/* This part (TEM3) find the time that the organization created their first contract*/
SELECT created_by_organization_id, MIN(signed_at_date) MinCreateTime FROM (
  SELECT    contracts.id         AS contract_id, 
  signings.user_id     AS signing_user_id, 
  signings.created_at  AS signed_at_date,
  COALESCE(template_creating_user_id, creating_user_id) AS creator_user_id,
  created_by_organization_id AS created_by_organization_id
  FROM      contracts LEFT JOIN signings 
  ON signings.contract_id = contracts.id
  ) AS TEM
GROUP BY created_by_organization_id ORDER BY created_by_organization_id) AS TEM3
INNER JOIN
(/*This part (TEM4) find the time that the organization sign their first contract*/
SELECT organization_id AS signed_by_organization_id, MIN(signed_at_date) MinSignTime FROM (
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
SELECT organization_id, user_id
FROM organization_members
) AS TEM2
ON TEM1.signing_user_id = TEM2.user_id
AND TEM1.created_by_organization_id <> TEM2.organization_id
)
/* WHERE created_by_organization_id <> 6 AND created_by_organization_id <> 4 */
GROUP BY signed_by_organization_id ORDER BY MinSignTime
) AS TEM4
ON TEM3.created_by_organization_id = TEM4.signed_by_organization_id
WHERE MinCreateTime > MinSignTime AND MinCreateTime BETWEEN '2011-1-1' AND '2018-6-1' 
/* AND created_by_organization_id <> 6 AND created_by_organization_id <> 4 */
ORDER BY created_by_organization_id


/* Check the individual user information */
SELECT * FROM contracts WHERE created_by_organization_id = 11370

SELECT * FROM
( SELECT    contracts.id         AS contract_id, 
  signings.user_id     AS signing_user_id, 
  signings.created_at  AS signed_at_date,
  COALESCE(template_creating_user_id, creating_user_id) AS creator_user_id,
  created_by_organization_id AS created_by_organization_id
  FROM      contracts LEFT JOIN signings 
  ON signings.contract_id = contracts.id
) AS TEM WHERE created_by_organization_id = 11370


SELECT * FROM
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
SELECT organization_id, user_id
FROM organization_members
) AS TEM2


/* Output the contract information regarding certain signer */
SELECT created_by_organization_id
FROM (
  SELECT    contracts.id         AS contract_id, 
  signings.user_id     AS signing_user_id, 
  signings.created_at  AS signed_at_date,
  COALESCE(template_creating_user_id, creating_user_id) AS creator_user_id,
  created_by_organization_id AS created_by_organization_id
  FROM      contracts LEFT JOIN signings 
  ON signings.contract_id = contracts.id
) AS TEM1 INNER JOIN 
(
SELECT organization_id, user_id
FROM organization_members
) AS TEM2
ON TEM1.signing_user_id = TEM2.user_id
WHERE organization_id = 10
ORDER BY signed_at_date



/* Output the contract information regarding certain creator */

SELECT * FROM (
  SELECT    contracts.id         AS contract_id, 
  signings.user_id     AS signing_user_id, 
  signings.created_at  AS signed_at_date,
  COALESCE(template_creating_user_id, creating_user_id) AS creator_user_id,
  created_by_organization_id AS created_by_organization_id
  FROM      contracts LEFT JOIN signings 
  ON signings.contract_id = contracts.id
  ) AS TEM
WHERE created_by_organization_id = 10
ORDER BY signed_at_date






/* Remove the case that the creator is 4 or 6 */
SELECT * FROM
(SELECT created_by_organization_id, MIN(signed_at_date) MinCreateTime FROM (
  SELECT    contracts.id         AS contract_id, 
  signings.user_id     AS signing_user_id, 
  signings.created_at  AS signed_at_date,
  COALESCE(template_creating_user_id, creating_user_id) AS creator_user_id,
  created_by_organization_id AS created_by_organization_id
  FROM      contracts LEFT JOIN signings 
  ON signings.contract_id = contracts.id
  ) AS TEM
GROUP BY created_by_organization_id ORDER BY created_by_organization_id) AS TEM3
INNER JOIN
(SELECT organization_id AS signed_by_organization_id, MIN(signed_at_date) MinSignTime FROM (
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
SELECT organization_id, user_id
FROM organization_members
) AS TEM2
ON TEM1.signing_user_id = TEM2.user_id
AND TEM1.created_by_organization_id <> TEM2.organization_id
)
GROUP BY signed_by_organization_id ORDER BY MinSignTime
) AS TEM4
ON TEM3.created_by_organization_id = TEM4.signed_by_organization_id
WHERE MinCreateTime > MinSignTime AND MinCreateTime BETWEEN '2011-1-1' AND '2018-6-1' 
ORDER BY created_by_organization_id




/*balbdfjsdjfklsdjlkfjdskjflks*/
SELECT *
FROM (
                         SELECT    contracts.id         AS contract_id, 
                         signings.user_id     AS signing_user_id, 
                         signings.created_at  AS signed_at_date,
                         COALESCE(template_creating_user_id, creating_user_id) AS creator_user_id,
                         created_by_organization_id AS created_by_organization_id
                         FROM      contracts LEFT JOIN signings 
                         ON signings.contract_id = contracts.id
    ) AS TEM1 INNER JOIN 
                         (
                         SELECT organization_id, user_id
                         FROM organization_members
                         ) AS TEM2
                         ON TEM1.signing_user_id = TEM2.user_id
                         WHERE organization_id = 10 ORDER BY signed_at_date


/* balabala */
SELECT created_by_organization_id
FROM (
                         SELECT    contracts.id         AS contract_id, 
                         signings.user_id     AS signing_user_id, 
                         signings.created_at  AS signed_at_date,
                         COALESCE(template_creating_user_id, creating_user_id) AS creator_user_id,
                         created_by_organization_id AS created_by_organization_id
                         FROM      contracts LEFT JOIN signings 
                         ON signings.contract_id = contracts.id
    ) AS TEM1 INNER JOIN 
                         (
                         SELECT organization_id, user_id
                         FROM organization_members
                         ) AS TEM2
                         ON TEM1.signing_user_id = TEM2.user_id
                         WHERE organization_id = ", ID ,"ORDER BY signed_at_date