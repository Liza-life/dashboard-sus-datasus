SELECT
    cid_principal,
    desc_cid,
    uf,
    regiao,
    ano,
    COUNT(*)                        AS total_casos,
    ROUND(SUM(valor_total), 2)      AS custo_total,
    ROUND(AVG(valor_total), 2)      AS custo_medio_caso,
    ROUND(AVG(dias_permanencia), 1) AS media_dias,
    COUNT(*) FILTER (WHERE carater_int ILIKE '%URGENCIA%') AS casos_urgencia
FROM {{ ref('stg_sih_cleaned') }}
GROUP BY cid_principal, desc_cid, uf, regiao, ano
ORDER BY total_casos DESC