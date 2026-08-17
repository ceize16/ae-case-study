# Voy — Analytics Engineer Case Study

Subscription retention modelling for a subscription-based business, built in dbt against DuckDB (local, chosen over BigQuery for take-home speed — see reasoning in `docs/DESIGN.md`). Tracks retention, churn, cohort curves and customer activity, drillable by country and acquisition taxonomy.

## Quickstart

```powershell
python -m venv .dbtvenv
.dbtvenv\Scripts\Activate        # macOS/Linux: source .dbtvenv/bin/activate
pip install dbt-duckdb duckdb pandas matplotlib

$env:DBT_PROFILES_DIR = (Get-Location).Path   # macOS/Linux: export DBT_PROFILES_DIR=$(pwd)

cd voy_ae_case_study
dbt seed
dbt build       # runs all models + tests
cd ..

python viz\plot_retention_curve.py   # regenerates docs/retention_curve.png
```

## What's here

- **`voy_ae_case_study/`** — the dbt project: the full medallion pipeline, staging → intermediate → marts, from the three raw CSVs (`customers`, `acq_orders`, `activity`) through to a customer-grain activity fact and a cohort retention mart.
- **`docs/DESIGN.md`** — the full write-up: data profiling findings, every modelling decision and why it was made, the medallion architecture, metric definitions, and how each part of the brief is addressed. **Start here** for the reasoning, not just the code.
- **`docs/retention_curve.png`** — the headline visual: cohort retention curve, showing what % of each monthly acquisition cohort is still active at each month of tenure.
- **`viz/plot_retention_curve.py`** — regenerates the chart directly from the built DuckDB warehouse.

## Key models

| Model | Grain | Purpose |
|---|---|---|
| `int_customer_activity_islands` | customer × continuous active span | The crux model — collapses subscription-period-level activity (which overlaps across a customer's concurrent subscriptions) down to customer-level activity, per the brief's rule that subscription count shouldn't affect "active" status |
| `fct_customer_monthly_activity` | customer × month | The core "ready to analyse" output — one row per customer per month they were active, not pre-aggregated |
| `fct_customer_monthly_status` | customer × month | Adds new/retained/churned/reactivated state per customer per month — powers churn and reactivation reporting |
| `mart_cohort_retention` | cohort × tenure × country × taxonomy | Pre-aggregated reporting table powering the retention curve chart |

## Status

The dbt pipeline (staging through marts) is built and tested end to end, including one real bug caught and fixed along the way — a nondeterministic `ORDER BY` in the gaps-and-islands window logic, documented in `docs/DESIGN.md`. The retention curve visual is built; a LookML/full BI layer was scoped but not built, given take-home time constraints — see `docs/DESIGN.md` for how this would be exposed in Looker on Company X's actual stack.

## Stack decisions

- **DuckDB, not BigQuery** — the SQL is close to directly portable; chosen to avoid GCP setup overhead for a take-home. Happy to discuss what would change for BigQuery in the interview.
- **CSVs as dbt seeds**, not sources — DuckDB has no cloud storage to point a source connector at. Seeds are committed to the repo so `dbt seed` works immediately after cloning, with no manual setup.