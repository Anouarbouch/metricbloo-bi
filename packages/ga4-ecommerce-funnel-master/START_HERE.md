# MetricBloo BI: GA4 E-Commerce Funnel Master (Commercial License)

Thank you for purchasing the GA4 E-Commerce Funnel Master package.  
Follow this 3-step guide to deploy your dashboard in under 60 seconds.

---

## Step 1: Review Documentation & Synthetic Demo Data
1. Inspect `ga4_ecommerce_daily_funnel_demo.csv` included in this ZIP to verify the pre-aggregated daily schema columns (`event_date`, `device_category`, `country`, `session_source`, `step_1_view_item_sessions` .. `step_5_purchase_sessions`).
2. Or preview the interactive dashboard and copy SQL snippets at:
   **`https://anouarbouch.github.io/metricbloo-bi/`**

---

## Step 2: Deploy the BigQuery / dbt Model (Zero Quota Limits)
If your website hits GA4 API quota errors (`10 concurrent requests limit`), deploy the pre-computed view in `dbt_ga4_funnel_view.sql`:
1. Open `dbt_ga4_funnel_view.sql` in this package.
2. Replace `{{ var('ga4_project') }}` and `{{ var('ga4_property_id') }}` with your GCP Project ID and GA4 Property ID (or configure them in `dbt_project.yml`).
3. Run the query in BigQuery Console (or under `models/marts/` in dbt) and connect Looker Studio directly to the resulting BigQuery table/view.

---

## Step 3: Files Included in this ZIP
- `START_HERE.md`: This setup documentation.
- `dbt_ga4_funnel_view.sql`: Production BigQuery SQL model unnesting `view_item`, `add_to_cart`, `begin_checkout`, `add_shipping_info`, `add_payment_info`, and `purchase`.
- `ga4_ecommerce_daily_funnel_demo.csv`: 100% synthetic CSV dataset for testing.
- `COMMERCIAL_LICENSE.txt`: Commercial single-brand license terms.

For async schema support or questions: `bouchaara.anouar@gmail.com`
