# MetricBloo BI: All-in-One Executive Blended Dashboard (Agency & Multi-Client License)

Thank you for purchasing the All-in-One Executive Blended Dashboard Suite.  
This package includes full commercial white-label rights for unlimited client reporting across Google Ads, GA4, and Google Search Console.

---

## Step 1: Duplicate the Looker Studio Master Dashboard
1. Open the multi-page agency master template link:  
   👉 **`https://lookerstudio.google.com/reporting/create?c.reportId=metricbloo-blended-master-agency`**
2. In the top-right corner, click **"Make a Copy"**.
3. Map your data sources:
   - **Data Source 1:** Google Analytics 4
   - **Data Source 2:** Google Ads
   - **Data Source 3:** Google Search Console (URL Impression)
4. Click **"Copy Report"**. Customize logos, colors, and client branding with zero restrictions.

---

## Step 2: Deploy the Full dbt Project (Zero Quota / Zero Supermetrics)
Included in this package is a complete `dbt` project:
- `dbt_project.yml`
- `models/mart_blended_marketing_roi.sql` (joins Google Ads spend + GA4 revenue + GSC ranks on clean URLs)
- `models/mart_ecommerce_funnel_dropoff.sql` (e-commerce step waterfall)
- `models/mart_ai_referral_attribution.sql` (ChatGPT, Claude, Perplexity tracking)

Configure GCP project IDs in `dbt_project.yml` and execute:
```bash
dbt run
```

---

## Step 3: Files Included in this Package
- `START_HERE.md`: This setup documentation.
- `AGENCY_COMMERCIAL_LICENSE.txt`: Full white-label and multi-client rights.
- `dbt/`: Production dbt project structure.
- `demo_data/`: 3 synthetic CSV files for offline testing.

For priority schema support: support@metricbloo.bi
