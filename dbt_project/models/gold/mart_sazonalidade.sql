SELECT
    ano,
    mes,
    nome_mes,
    estacao,
    regiao,
    cid_principal,
    desc_cid,
    COUNT(*)                        AS total_internacoes,
    ROUND(SUM(valor_total), 2)      AS custo_total,
    ROUND(AVG(valor_total), 2)      AS ticket_medio,
    ROUND(AVG(dias_permanencia), 1) AS media_dias
FROM {{ ref('stg_sih_cleaned') }}
GROUP BY ano, mes, nome_mes, estacao, regiao, cid_principal, desc_cid
ORDER BY ano, mes, cid_principal