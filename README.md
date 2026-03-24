# 🏥 Dashboard SUS — SIH/DATASUS

Pipeline completo de engenharia de dados com análise estratégica 
de internações hospitalares do SIH/DATASUS (2022-2023).

## 📊 Dashboard Power BI — 5 Páginas

| Página | Descrição |
|--------|-----------|
| 1 | Visão Geral por Estado |
| 2 | Top Doenças |
| 3 | Sazonalidade |
| 4 | Perfil Demográfico |
| 5 | Visão Executiva |

## 🔑 Principais Insights

- 💰 Infarto = 8% dos casos mas consome 24% do custo total
- 👴 65+ anos concentra 34,9% de todas as internações
- 🚨 60,29% de urgência — 2,4x acima da meta de 25%
- 📈 Outubro = pico crítico de internações
- 🗺️ SP concentra 25% do volume nacional

## 🛠️ Stack Tecnológica

- Python 3.9
- DuckDB
- dbt Core
- Power BI

## 🏗️ Arquitetura
```
projeto_sus/
├── data/raw/
├── ingestion/
├── dbt_project/
│   └── models/
│       ├── bronze/
│       ├── silver/
│       └── gold/
└── notebooks/
```

## ▶️ Como Executar
```bash
# Instalar dependências
pip install -r requirements.txt

# Gerar dados
python ingestion/download_datasus.py

# Rodar transformações
cd dbt_project
dbt run
dbt test
```