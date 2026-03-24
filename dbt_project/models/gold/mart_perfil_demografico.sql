SELECT
    ano,
    uf,
    regiao,
    faixa_etaria,
    sexo,
    COUNT(*)                        AS total_internacoes,
    ROUND(SUM(valor_total), 2)      AS custo_total,
    ROUND(AVG(valor_total), 2)      AS ticket_medio,
    ROUND(AVG(dias_permanencia), 1) AS media_dias
FROM {{ ref('stg_sih_cleaned') }}
GROUP BY ano, uf, regiao, faixa_etaria, sexo
ORDER BY ano, uf, faixa_etaria