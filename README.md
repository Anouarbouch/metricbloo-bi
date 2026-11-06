# MetricBloo BI: Production Looker Studio & GA4 BigQuery / dbt Templates

[![License: MIT](https://img.shields.io/badge/License-MIT-emerald.svg)](LICENSE)
[![GitHub Pages](https://img.shields.io/badge/Live_Storefront-GitHub_Pages-blue.svg)](https://anouarbouchaara.github.io/metricbloo-bi/)
[![BigQuery](https://img.shields.io/badge/Google-BigQuery-4285F4.svg?logo=google-cloud)](https://cloud.google.com/bigquery)
[![Looker Studio](https://img.shields.io/badge/Looker_Studio-Community_Gallery-orange.svg)](https://lookerstudio.google.com/)
[![dbt Ready](https://img.shields.io/badge/dbt-Ready_Models-FF694B.svg?logo=dbt)](https://www.getdbt.com/)

> **Production-grade Google Looker Studio templates and pre-built BigQuery/dbt SQL models designed for data teams, DTC e-commerce brands, and marketing agencies.**  
> Bypass GA4 API token limits (`10 concurrent requests limit`), eliminate $200–$400/month connector SaaS subscriptions, and deploy executive dashboards in under 60 seconds using 100% synthetic demo datasets.

---

## 🌟 Why MetricBloo BI?

| The Traditional Problem | The MetricBloo BI Solution |
| :--- | :--- |
| **Expensive Recurring Subscriptions:** Supermetrics & Porter Metrics charge $172 to $431/mo to pipe GA4, Ads, and GSC data. | **Zero Recurring Costs:** Native 1-click Google Looker Studio templates + free native Google connectors or BigQuery exports. |
| **GA4 Quota Limit Crashes:** Looker Studio hits `Quota exceeded (14,000 core tokens)` on high-traffic sites. | **Pre-Computed BigQuery Models:** Our dbt SQL models aggregate millions of rows into flattened daily views, costing < $0.05 per query. |
| **Privacy & GDPR Compliance Risks:** Sharing credentials or uploading client PII creates legal liability. | **Zero-Data / Zero-Upload Architecture:** All templates run on deterministic synthetic demo data. You duplicate templates into your own private Google account—we never see your data. |

---

## 📦 Products & SKUs Available

### 🆓 SKU 01: Free AI & LLM Referral Traffic Attribution Dashboard
* **Status:** 100% Free & Open-Source (MIT)
* **What it does:** Categorizes organic traffic from ChatGPT, Claude, Perplexity, Google Gemini, Microsoft Copilot, and Grok into an executive attribution view.
* **Resources:**
  * 📄 [SKU Documentation & Looker Studio Calculated Fields](skus/sku-01-free-ai-referral-attribution/README.md)
  * 💻 [Production BigQuery SQL Model](skus/sku-01-free-ai-referral-attribution/ga4_ai_channel_regex.sql)
  * 🔗 [Duplicate Free Looker Studio Dashboard (1-Click)](https://lookerstudio.google.com/reporting/create?c.reportId=metricbloo-ai-referrals-free)

### 💎 SKU 02: GA4 E-Commerce Drop-Off & Checkout Funnel Master ($129)
* **Status:** Commercial License
* **What it does:** Flattens the complete 5-step e-commerce journey (`view_item` → `add_to_cart` → `begin_checkout` → `add_payment_info` → `purchase`) with drop-off percentages by device, traffic source, and country.
* **Resources:**
  * 📄 [SKU Documentation](skus/sku-02-ga4-ecommerce-dropoff-funnel/README.md)
  * 💻 [dbt GA4 Flattened Funnel View](skus/sku-02-ga4-ecommerce-dropoff-funnel/dbt_ga4_funnel_view.sql)
  * 🛒 [Instant Purchase via Lemon Squeezy ($129)](https://metricbloo.lemonsqueezy.com/checkout/buy/ga4-ecommerce-master)

### 🚀 SKU 03: All-in-One Executive Blended Dashboard ($289)
* **Status:** Commercial & Agency License
* **What it does:** Unifies Google Ads spend, GA4 transactions, and Google Search Console organic ranks onto clean, normalized landing page URLs with zero Supermetrics subscriptions.
* **Resources:**
  * 📄 [SKU Documentation](skus/sku-03-blended-website-master/README.md)
  * 💻 [dbt Multi-Source Blending Model](skus/sku-03-blended-website-master/dbt_blended_marketing_model.sql)
  * 🛒 [Instant Purchase via Lemon Squeezy ($289)](https://metricbloo.lemonsqueezy.com/checkout/buy/blended-website-master)

---

## ⚡ Quick Start: 3 Steps to Deploy in 60 Seconds

1. **Clone or Download This Repository:**
   ```bash
   git clone https://github.com/anouarbouchaara/metricbloo-bi.git
   cd metricbloo-bi
   ```
2. **Preview with Synthetic Demo Data:**
   Open `docs/index.html` in your browser or test our pre-computed CSV files in `docs/demo_data/`.
3. **Connect to Your Own GA4 Property:**
   Open the Looker Studio duplication link, click **"Use My Own Data"**, and select your Google Analytics 4 property or BigQuery project.

---

## 🛠️ Repository Structure

```
metricbloo-bi/
├── .github/workflows/deploy-pages.yml   # Automated GitHub Pages deploy workflow
├── docs/                                # Zero-dependency GitHub Pages storefront
│   ├── index.html                       # Interactive dashboard preview & SQL builder
│   └── demo_data/                       # 100% synthetic e-commerce & ROAS datasets
├── skus/
│   ├── sku-01-free-ai-referral-attribution/ # Free lead magnet & SQL model
│   ├── sku-02-ga4-ecommerce-dropoff-funnel/ # $129 E-Commerce funnel master
│   └── sku-03-blended-website-master/       # $289 Blended multi-channel dashboard
├── dbt/                                 # Production-ready dbt analytics models
│   ├── dbt_project.yml
│   └── models/
│       ├── staging/
│       └── marts/
├── LICENSE                              # MIT License
└── README.md                            # Documentation & Quick Start
```

---

## ⚖️ Zero-Data Privacy & Security Guarantee
- **No Private Data Access:** We never request, host, or store your company's credentials or customer PII.
- **Client-Side Processing:** All SQL generators run 100% in your local browser sandbox.
- **MIT Open-Source Core:** Inspect every line of SQL code before executing on your BigQuery warehouse.

---

© 2026 MetricBloo BI. Built with precision for modern analytics engineering teams.
