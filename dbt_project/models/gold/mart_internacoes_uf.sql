SELECT
    uf,
    regiao,
    ano,
    mes,
    nome_mes,
    estacao,
    COUNT(*)                                AS total_internacoes,
    ROUND(SUM(valor_total), 2)              AS custo_total,
    ROUND(AVG(valor_total), 2)              AS ticket_medio,
    ROUND(AVG(dias_permanencia), 1)         AS media_dias_internacao,
    COUNT(*) FILTER (WHERE sexo = 'M')      AS internacoes_masculino,
    COUNT(*) FILTER (WHERE sexo = 'F')      AS internacoes_feminino,
    COUNT(*) FILTER (WHERE carater_int ILIKE '%URGENCIA%') AS internacoes_urgencia,
    COUNT(*) FILTER (WHERE carater_int ILIKE '%ELETIVO%')  AS internacoes_eletivas
FROM {{ ref('stg_sih_cleaned') }}
GROUP BY uf, regiao, ano, mes, nome_mes, estacao
ORDER BY ano, mes, uf