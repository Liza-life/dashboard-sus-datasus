import os
import numpy as np
import pandas as pd
import duckdb
from pathlib import Path
from loguru import logger

RAW_DATA_DIR = Path(__file__).parent.parent / "data" / "raw"
DB_PATH      = Path(__file__).parent.parent / "data" / "sus.duckdb"

ESTADOS = ["SP", "RJ", "MG", "BA", "RS", "PR", "CE", "PE", "GO", "SC"]

def criar_diretorios():
    RAW_DATA_DIR.mkdir(parents=True, exist_ok=True)
    DB_PATH.parent.mkdir(parents=True, exist_ok=True)
    logger.info(f"Diretórios verificados: {RAW_DATA_DIR}")

def gerar_dados_simulados(n_registros: int = 50_000) -> pd.DataFrame:
    np.random.seed(42)

    cids = {
        "J18": "Pneumonia", "I21": "Infarto Agudo do Miocárdio",
        "K35": "Apendicite Aguda", "O80": "Parto Normal",
        "N39": "Infecção Urinária", "A09": "Diarreia e Gastroenterite",
        "J44": "DPOC", "I64": "Acidente Vascular Cerebral",
        "E11": "Diabetes Mellitus Tipo 2", "C50": "Neoplasia Maligna da Mama",
        "A90": "Dengue", "B24": "Doença pelo HIV",
        "M54": "Dorsalgia", "F32": "Episódio Depressivo", "G40": "Epilepsia",
    }
    cid_codes  = list(cids.keys())
    cid_weights = [12,8,6,10,9,7,5,6,8,4,7,3,5,5,5]
    cid_probs   = [w/sum(cid_weights) for w in cid_weights]

    procedimentos = [
        "PROC_CIRURGICO_GERAL","PROC_CLINICO_MEDICO","PROC_OBSTETRICIA",
        "PROC_PEDIATRIA","PROC_UTI_ADULTO","PROC_CARDIOLOGIA",
    ]

    anos  = np.random.choice([2022, 2023], n_registros, p=[0.45, 0.55])
    meses = np.random.choice(range(1, 13), n_registros)

    sazonalidade = np.ones(n_registros)
    sazonalidade[meses <= 3]                    = 1.4
    sazonalidade[(meses >= 6) & (meses <= 8)]   = 1.2

    uf_probs = [0.25,0.18,0.13,0.08,0.07,0.07,0.06,0.06,0.05,0.05]
    ufs      = np.random.choice(ESTADOS, n_registros, p=uf_probs)
    cids_col = np.random.choice(cid_codes, n_registros, p=cid_probs)

    custo_base = {
        "J18":2800,"I21":12000,"K35":4500,"O80":1800,"N39":1200,
        "A09":900,"J44":3500,"I64":8000,"E11":2200,"C50":15000,
        "A90":1500,"B24":5000,"M54":1800,"F32":2500,"G40":3200,
    }
    valores = np.array([custo_base[c] for c in cids_col])
    valores = valores * np.random.uniform(0.6, 1.8, n_registros) * sazonalidade

    p_dias = [
        0.190476, 0.161905, 0.123810, 0.095238, 0.076190,
        0.066667, 0.057143, 0.047619, 0.038095, 0.028571,
        0.019048, 0.019048, 0.009524, 0.009524, 0.009524,
        0.009524, 0.009524, 0.009524, 0.009524, 0.009522
    ]

    df = pd.DataFrame({
        "ano_cmpt":        anos,
        "mes_cmpt":        meses,
        "uf":              ufs,
        "cid_principal":   cids_col,
        "desc_cid":        [cids[c] for c in cids_col],
        "procedimento":    np.random.choice(procedimentos, n_registros),
        "valor_total":     valores.round(2),
        "dias_permanencia": np.random.choice(range(1,21), n_registros, p=p_dias),
        "idade":           np.random.choice(range(0,100), n_registros),
        "sexo":            np.random.choice(["M","F"], n_registros, p=[0.48,0.52]),
        "municipio_res":   np.random.randint(1000000,9999999,n_registros).astype(str),
        "carater_int":     np.random.choice(["01-ELETIVO","02-URGENCIA"], n_registros, p=[0.4,0.6]),
    })
    return df

def salvar_raw_csv(df: pd.DataFrame, nome: str):
    caminho = RAW_DATA_DIR / f"{nome}.csv"
    df.to_csv(caminho, index=False, encoding="utf-8")
    logger.success(f"CSV salvo: {caminho} ({len(df):,} linhas)")

def carregar_no_duckdb(df: pd.DataFrame, tabela: str):
    con = duckdb.connect(str(DB_PATH))
    con.execute(f"DROP TABLE IF EXISTS {tabela}")
    con.execute(f"CREATE TABLE {tabela} AS SELECT * FROM df")
    total = con.execute(f"SELECT COUNT(*) FROM {tabela}").fetchone()[0]
    con.close()
    logger.success(f"DuckDB: tabela '{tabela}' criada com {total:,} registros")

def validar_dados(df: pd.DataFrame):
    logger.info(f"Total de linhas   : {len(df):,}")
    logger.info(f"Valor total (R$)  : {df['valor_total'].sum():,.2f}")
    logger.info(f"UFs               : {sorted(df['uf'].unique())}")

if __name__ == "__main__":
    logger.info("Pipeline SUS — Ingestão de Dados")
    criar_diretorios()
    logger.info("Gerando dataset SIH (50.000 internações)...")
    df = gerar_dados_simulados(n_registros=50_000)
    validar_dados(df)
    salvar_raw_csv(df, "sih_raw_2022_2023")
    carregar_no_duckdb(df, "sih_raw")
    logger.success("Ingestão concluída! Próximo passo: dbt run")