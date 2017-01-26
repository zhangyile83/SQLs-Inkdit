SELECT * FROM
(
SELECT T1.id, T2.created_by_organization_id, 
T1.content 
FROM
(
SELECT
    content, min(id) AS id
    FROM
    contracts
GROUP BY
    content
) AS T1
INNER JOIN
contracts AS T2
ON T1.id = T2.id
) AS TT1


CREATE TABLE distinct_contracts AS
SELECT TTTTT1.id, TTTTT2.created_by_organization_id,
TTTTT2.created_by_user_id, TTTTT2.content, TTTTT2.template_id FROM
(
SELECT
    min(id) AS id
    FROM
    contracts
GROUP BY
    content
) AS TTTTT1
INNER JOIN
(
SELECT TTTT1.id, TTTT1.created_by_organization_id,
TTTT1.created_by_user_id, TTT2.template_id, TTT2.content FROM
contracts AS TTT2
INNER JOIN
(
SELECT id, COALESCE(created_by_organization_id, organization_id) AS created_by_organization_id,
created_by_user_id
FROM
(
SELECT TT1.id, TT1.created_by_organization_id,
TT2.created_by_user_id, TT2.organization_id
FROM
contracts AS TT1
INNER JOIN
(
SELECT T1.id, T1.created_by_user_id, 
T2.organization_id
FROM contracts AS T1
LEFT JOIN
/* 1 user to only 1 organization re-mapping */
(
SELECT user_id, MIN(organization_id) AS organization_id
FROM organization_members
GROUP BY user_id
ORDER BY user_id
) AS T2
ON T1.created_by_user_id = T2.user_id
) AS TT2
ON TT1.id = TT2.id
) AS TTT1
) AS TTTT1
ON TTTT1.id = TTT2.id
ORDER BY created_by_organization_id
) AS TTTTT2
ON TTTTT1.id = TTTTT2.id


SELECT * FROM distinct_contracts
LIMIT 2