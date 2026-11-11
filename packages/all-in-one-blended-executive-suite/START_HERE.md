# MetricBloo BI: All-in-One Executive Blended Dashboard (Agency & Multi-Client License)

This package includes full commercial white-label rights for multi-client reporting across GA4 and Google Search Console.

---

## Step 1: Inspect Demo Datasets & Interactive Storefront
1. Preview the 3 synthetic CSV schemas inside `demo_data/` (`ga4_ecommerce_daily_funnel_demo.csv`, `ga4_channel_roas_attribution_demo.csv`, `ga4_cohort_retention_matrix_demo.csv`) or visit:
   **`https://anouarbouch.github.io/metricbloo-bi/`**
2. Upload any CSV directly into Looker Studio ("File Upload" data source) to verify chart schemas before pointing to BigQuery.

---

## Step 2: Deploy the Full dbt Project (Zero Quota / Zero Connector SaaS)
Included in this package is a complete `dbt` project under `dbt/`:
- `dbt/dbt_project.yml`
- `dbt/models/marts/mart_blended_marketing_roi.sql` (joins GA4 landing-page sessions/transactions + Search Console impressions/clicks at 1-to-1 normalized page path grain)
- `dbt/models/marts/mart_ecommerce_funnel_dropoff.sql` (5-step e-commerce conversion waterfall)
- `dbt/models/marts/mart_ai_referral_attribution.sql` (ChatGPT, Claude, Perplexity, Gemini, Copilot session attribution)

Configure your `ga4_project`, `ga4_property_id`, and `gsc_project` variables in `dbt/dbt_project.yml` and execute:
```bash
cd dbt && dbt run
```

---

## Step 3: Files Included in this Package
- `START_HERE.md`: This setup documentation.
- `AGENCY_COMMERCIAL_LICENSE.txt`: Full white-label and multi-client rights.
- `dbt/`: Production dbt project structure.
- `demo_data/`: 3 synthetic CSV files for offline testing.

For schema support: `bouchaara.anouar@gmail.com`
