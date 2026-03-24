WITH base AS (
    SELECT * FROM {{ ref('stg_sih_raw') }}
),

cleaned AS (
    SELECT
        CAST(ano_cmpt        AS INTEGER)          AS ano,
        CAST(mes_cmpt        AS INTEGER)          AS mes,
        UPPER(TRIM(uf))                           AS uf,
        UPPER(TRIM(cid_principal))                AS cid_principal,
        TRIM(desc_cid)                            AS desc_cid,
        UPPER(TRIM(procedimento))                 AS procedimento,
        ROUND(CAST(valor_total AS DOUBLE), 2)     AS valor_total,
        CAST(dias_permanencia AS INTEGER)         AS dias_permanencia,
        CAST(idade            AS INTEGER)         AS idade,
        UPPER(TRIM(sexo))                         AS sexo,
        TRIM(municipio_res)                       AS municipio_res,
        UPPER(TRIM(carater_int))                  AS carater_int,

        CASE
            WHEN CAST(idade AS INTEGER) < 1   THEN '00-Menos de 1 ano'
            WHEN CAST(idade AS INTEGER) < 5   THEN '01-1 a 4 anos'
            WHEN CAST(idade AS INTEGER) < 15  THEN '02-5 a 14 anos'
            WHEN CAST(idade AS INTEGER) < 30  THEN '03-15 a 29 anos'
            WHEN CAST(idade AS INTEGER) < 50  THEN '04-30 a 49 anos'
            WHEN CAST(idade AS INTEGER) < 65  THEN '05-50 a 64 anos'
            ELSE                                   '06-65 anos ou mais'
        END AS faixa_etaria,

        CASE mes_cmpt
            WHEN 1 THEN 'Janeiro'   WHEN 2 THEN 'Fevereiro' WHEN 3  THEN 'Março'
            WHEN 4 THEN 'Abril'     WHEN 5 THEN 'Maio'      WHEN 6  THEN 'Junho'
            WHEN 7 THEN 'Julho'     WHEN 8 THEN 'Agosto'    WHEN 9  THEN 'Setembro'
            WHEN 10 THEN 'Outubro'  WHEN 11 THEN 'Novembro' WHEN 12 THEN 'Dezembro'
        END AS nome_mes,

        CASE
            WHEN CAST(mes_cmpt AS INTEGER) IN (12,1,2) THEN 'Verão'
            WHEN CAST(mes_cmpt AS INTEGER) IN (3,4,5)  THEN 'Outono'
            WHEN CAST(mes_cmpt AS INTEGER) IN (6,7,8)  THEN 'Inverno'
            ELSE 'Primavera'
        END AS estacao,

        CASE uf
            WHEN 'SP' THEN 'Sudeste' WHEN 'RJ' THEN 'Sudeste'
            WHEN 'MG' THEN 'Sudeste' WHEN 'ES' THEN 'Sudeste'
            WHEN 'PR' THEN 'Sul'     WHEN 'SC' THEN 'Sul'
            WHEN 'RS' THEN 'Sul'
            WHEN 'BA' THEN 'Nordeste' WHEN 'CE' THEN 'Nordeste'
            WHEN 'PE' THEN 'Nordeste' WHEN 'MA' THEN 'Nordeste'
            WHEN 'GO' THEN 'Centro-Oeste' WHEN 'DF' THEN 'Centro-Oeste'
            WHEN 'MT' THEN 'Centro-Oeste' WHEN 'MS' THEN 'Centro-Oeste'
            WHEN 'AM' THEN 'Norte'   WHEN 'PA' THEN 'Norte'
            ELSE 'Outras'
        END AS regiao

    FROM base
    WHERE ano_cmpt   IS NOT NULL
      AND mes_cmpt   IS NOT NULL
      AND uf         IS NOT NULL
      AND valor_total > 0
      AND dias_permanencia >= 1
)

SELECT * FROM cleaned