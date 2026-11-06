# MetricBloo BI: GA4 E-Commerce Funnel Master (Commercial License)

Thank you for purchasing the GA4 E-Commerce Funnel Master package.  
Follow this 3-step guide to deploy your dashboard in under 60 seconds.

---

## Step 1: Duplicate the Looker Studio Dashboard (1-Click)
1. Open your master template link:  
   👉 **`https://lookerstudio.google.com/reporting/create?c.reportId=metricbloo-ga4-funnel-master`**
2. In the top-right corner, click **"Make a Copy"**.
3. Under **"New Data Source"**:
   - To preview with our demo numbers: leave default synthetic data selected.
   - To connect your live property: select your **Google Analytics 4 Property** or your **BigQuery Project**.
4. Click **"Copy Report"**. Your dashboard is now live in your private workspace.

---

## Step 2: (Optional) Deploy the BigQuery / dbt Model for High Traffic
If your website receives high traffic or hits GA4 API quota limit errors (`10 concurrent requests limit`), use our pre-computed view:
1. Open `dbt_ga4_funnel_view.sql` in this package.
2. In lines 17-18, replace:
   - `{{ var('ga4_project') }}` with your GCP Project ID.
   - `{{ var('ga4_property_id') }}` with your GA4 Property ID.
3. Run the query in BigQuery Console or include it in your dbt repository under `models/marts/`.
4. Connect Looker Studio directly to this view for **instant loading** and **zero quota crashes**.

---

## Step 3: Files Included in this ZIP
- `START_HERE.md`: This setup documentation.
- `dbt_ga4_funnel_view.sql`: Production BigQuery SQL model unnesting `view_item`, `add_to_cart`, `begin_checkout`, `purchase`.
- `ga4_ecommerce_synthetic_demo.csv`: 100% synthetic CSV dataset for testing.
- `COMMERCIAL_LICENSE.txt`: Commercial single-brand license terms.

For async schema support or questions: support@metricbloo.bi
