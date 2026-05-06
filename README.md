# Women's Health Funnel & Retention Analysis

A portfolio project analyzing patient funnel conversion and retention for a digital women's health platform. Synthetic data, but the SQL and analytical approach are the same patterns I use on real claims and event data.

## The headline finding

Endometriosis patients convert from signup to first visit at ~37%, vs. 60-70% for every other diagnosis. The drop concentrates at the provider-match step, which strongly suggests it's a supply-side problem (not enough endo specialists on the platform) rather than patients losing interest.

That kind of insight - finding the segment where a metric breaks, identifying the step where it breaks, and pointing at a likely cause - is the bread and butter of what I do at Point32Health on the prior auth side.

## Repo

```
.
├── README.md
├── requirements.txt
├── data/
│   ├── generate_data.py        # synthetic data generator (5k patients, ~21k events)
│   ├── patients.csv
│   └── events.csv
├── sql/
│   ├── 01_funnel_analysis.sql
│   ├── 02_cohort_retention.sql
│   └── 03_time_to_conversion.sql
├── notebooks/
│   └── funnel_retention_analysis.ipynb    # main deliverable
└── images/                                # exported charts
```

## Running it

```bash
pip install -r requirements.txt
python data/generate_data.py        # optional - csvs are committed
jupyter lab notebooks/funnel_retention_analysis.ipynb
```

I'm using DuckDB to run the SQL files directly against the CSVs - no real database needed. Same SQL works on Postgres / Snowflake / BigQuery / Teradata with minor syntax tweaks (mostly DATE_TRUNC and DATE_DIFF).

## What's in the analysis

1. **Funnel** - step-to-step conversion (Account → Intake → Match → First Visit), then segmented by diagnosis to find where things break
2. **Cohort retention** - monthly cohort heatmap and retention curves
3. **Time to first visit** - distribution of onboarding speed by diagnosis
4. **Recommendations** - prioritized, with quantified opportunity sizing for the top one

## Why women's health?

I'm targeting health tech roles and Midi Health was on my list, so I built this against the kind of vertical they operate in. The funnel structure (signup → intake → match → first visit → ongoing care) matches how most digital specialty care platforms actually work.

## Stack

- Python: pandas, seaborn, matplotlib
- SQL: DuckDB (portable to anything else)
- Domain: women's health, healthcare ops, patient journey analytics
