# 💳 Credit Card Transaction Analytics – SQL Case Study

[![GitHub stars](https://img.shields.io/github/stars/USER/repo.svg?style=social)](https://github.com/USER/repo/stargazers/)
[![GitHub forks](https://img.shields.io/github/forks/USER/repo.svg?style=social)](https://github.com/USER/repo/network/)
[![License](https://img.shields.io/github/license/USER/repo.svg)](LICENSE)

An end-to-end analytics project on **1.29M credit card transactions** for a US issuer, uncovering insights on customer behavior, merchant performance, category trends, and fraud risk using SQL and supporting tools. [file:60]

---

## 📂 Project Overview

This repository contains a complete case study for **FinPay**, a major US credit card issuer, focused on using large-scale transaction data to drive **growth**, **risk reduction**, and **better partner management**. [file:60]

The analysis answers questions such as:
- Which customers deliver the highest **lifetime value** and how engaged are they? [file:60]  
- Which merchants and categories contribute most to **revenue** and **fraud risk**? [file:60]  
- How do **seasonality** and **time-based patterns** influence revenue and fraud? [file:60]  

---

## 🧱 Data & Tech Stack

**Dataset scale**: [file:60]  
| Metric | Value |
|--------|-------|
| Transactions | 1,290,000 |
| Customers | 983 |
| Merchants | 693 |
| Categories | 14 |
| Date Range | 434 days (2019-01-01 to 2020-06-21) |

**Data model**: Star schema with: [file:60]  
```
Fact: transactions
├── customers (dim)
├── merchants (dim)
├── categories (dim)
└── date (dim)
```

**Tools used**: [file:60]  
```
🐘 PostgreSQL – SQL analytics
🐍 Python (pandas) – data processing
📊 Matplotlib/Seaborn – visualization
```

---

## 🔍 Key Insights

### 👥 1️⃣ Customer Analytics
- **983 customers** analyzed; **924 active** in last 90 days (**94% retention**) [file:60]
- **Avg revenue/customer**: $92.8K [file:60]
- **VIP segment**: Top customers contribute **$275K–$296K** each [file:60]

```
![Customer Analytics](visuals/customer 1: RFM Customer Segmentation*
```

### 🏪 2️⃣ Merchant Performance
- **693 merchants**; **Top 10** generate **$295K–$391K** each [file:60]
- **Pareto pattern**: <2% merchants drive majority of revenue [file:60]

```
![Merchant Revenue](visuals/merchant-pareto.png

*Figure 2: Top 20 Merchants Revenue Distribution*
```

### 🛒 3️⃣ Category Insights
| Category | Revenue % | Risk Level | [file:60] |
|----------|-----------|------------|-----------|
| Grocery POS | **15.85%** | Moderate | |
| Shopping POS | **10.20%** | Low | |
| Shopping Net | **9.46%** | **High** | |
| Gas/Transport | **9.16%** | Low | |

```
![Category Revenue](visuals/category-pie.png

*Figure 3: Category Revenue Share*
```

### 🚨 4️⃣ Fraud Analysis
- **Overall fraud rate**: **0.58%** (7,506 of 1.3M transactions) [file:60]
- **Hotspots**: Late-night transactions, online channels, select merchants (2-2.57%) [file:60]

```
![Fraud Trends](visuals/fraud-timeseries.png

*Figure 4: Fraud Rate Over Time*
```

### 📈 5️⃣ Growth Trends
- **Dec 2019 peak**: **+10% MoM** [file:60]
- **2020 YTD revenue**: **$26.24M** [file:60]
- **Q2 recovery**: **$14.04M** [file:60]

```
![Revenue Trends](visuals/revenue-mom.png

*Figure 5: MoM Revenue with Moving Averages*
```

---

## 🎯 Business Impact

| Initiative | Expected Outcome | [file:60] |
|------------|------------------|-----------|
| Customer Retention | **+15-20% revenue growth** | |
| VIP Program | **+8-12% LTV** | |
| Fraud Controls | **-20-30% fraud reduction** | |
| Merchant Optimization | **-25% churn** | |

---

## 📁 Repository Structure

```
📁 credit-card-analytics/
├── 📁 data/
│   ├── 📁 raw/           # Transaction CSVs
│   └── 📁 processed/     # Cleaned data
├── 📁 sql/
│   ├── 📁 schema/        # DDL scripts
│   ├── 📁 exploration/   # EDA queries
│   └── 📁 analysis/      # Final analytics
├── 📁 notebooks/         # Python EDA
├── 📁 visuals/           # Charts for README
├── 📁 reports/
│   └── Credit-Card-Analytics-Case-Study.pdf
├── 🐳 docker-compose.yml
├── 🐘 init.sql
└── 📄 README.md
```

---

## 🚀 Quick Start

### 1. Clone & Setup
```
git clone https://github.com/USERNAME/credit-card-analytics.git
cd credit-card-analytics
```

### 2. Database (Docker)
```
docker-compose up -d postgres
```

### 3. Load Schema
```
docker exec -i postgres_container psql -U postgres -d creditcard < sql/schema/init.sql
```

### 4. Load Data
```
# Copy CSVs to docker volume, then:
docker exec postgres_container psql -U postgres -d creditcard -c "\copy transactions FROM 'data/raw/transactions.csv' CSV HEADER;"
```

### 5. Run Analysis
```
-- Customer insights
\i sql/analysis/customers.sql

-- Merchant analysis  
\i sql/analysis/merchants.sql

-- Fraud detection
\i sql/analysis/fraud.sql
```

---

## 🛠️ Tech Requirements

| Tool | Version | Purpose |
|------|---------|---------|
| PostgreSQL | 15+ | Analytics database |
| Python | 3.9+ | Data processing |
| Docker | 20+ | Local environment |
| Git | 2.30+ | Version control |

---

## 📊 Visuals Recommendation: **YES** ✅

**Add these 5 charts to `/visuals/` folder:**

1. `customer-rfm.png` → After Customer Analytics section
2. `merchant-pareto.png` → After Merchant Performance  
3. `category-pie.png` → After Category Insights
4. `fraud-timeseries.png` → After Fraud Analysis
5. `revenue-mom.png` → After Growth Trends

**Pro tip**: Export charts at **1200x800px** with white backgrounds to match the professional theme.

---

## 📈 Results Summary

```
💰 Total Revenue Analyzed: $26.24M (2020 YTD)
👥 Active Customers: 94% retention rate
🏪 Top Merchants: <2% drive majority revenue
🚨 Fraud Rate: 0.58% (target: -20-30% reduction)
📊 SQL Queries: 50+ analytical views created
```

---

## 🤝 Contributing

1. Fork the repo
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push (`git push origin feature/AmazingFeature`)
5. Open Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **FinPay** – for the enterprise dataset
- **PostgreSQL** community
- **Omdena** data analytics case studies [file:60]

---

<div align="center">

**⭐ Star this repo if you found it useful!**  
**🐛 Found a bug? [Open an issue](https://github.com/USERNAME/credit-card-analytics/issues/new)**

</div>

![Footer](visuals/footer-analytics.png)
*Credit Card Analytics Case Study – Dec 2025*
```

## 🚀 **Copy-Paste Ready!**

1. **Copy entire code above**
2. **Create `README.md` in your repo root**
3. **Paste and save**
4. **Update `USERNAME/repo` in badges**
5. **Add visuals to `/visuals/` folder**
6. **Commit & push** ✅

**Visuals folder structure:**
```
visuals/
├── customer-rfm.png
├── merchant-pareto.png  
├── category-pie.png
├── fraud-timeseries.png
└── revenue-mom.png
```

Perfect for GitHub! 🎉[1]

[1](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/15242696/fba47cb9-2b5a-4c0a-99d6-cbb77a64eb86/Credit-Card-Analytics-Case-Study.docx)
