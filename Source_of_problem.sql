SELECT * FROM
(
 SELECT    contracts.id         AS contract_id, 
          signings.user_id     AS signing_user_id, 
          signings.created_at  AS signed_at_date,
          COALESCE(template_creating_user_id, creating_user_id) AS creator_user_id,
          created_by_organization_id AS created_by_organization_id
FROM      contracts LEFT JOIN signings 
       ON signings.contract_id = contracts.id
 ) AS TT
       WHERE creator_user_id = 3





SELECT COUNT(*) FROM
(
SELECT * FROM
(
 SELECT    contracts.id         AS contract_id, 
          signings.user_id     AS signing_user_id, 
          signings.created_at  AS signed_at_date,
          template_creating_user_id AS creator_user_id,
          created_by_organization_id AS created_by_organization_id
FROM      contracts LEFT JOIN signings 
       ON signings.contract_id = contracts.id
 ) AS TT
       WHERE creator_user_id = 3
) AS TGG



/* O */    /* U */
 40602      23821
  59         3   55   70   271
 7553        7423    7426    7552
 27563       27555    27561
   
/*2 */
SELECT * FROM contracts
WHERE template_creating_user_id = 3


SELECT * FROM organization_members
WHERE user_id = 7552
  