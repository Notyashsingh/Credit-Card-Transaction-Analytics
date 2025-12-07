## 💳 Credit Card Transaction Analytics – SQL Case Study

An end-to-end analytics project on **1.29M credit card transactions** for a US issuer, uncovering insights on customer behavior, merchant performance, category trends, and fraud risk using SQL and supporting tools. 

---

## 📂 Project Overview

This repository contains a complete case study for **FinPay**, a major US credit card issuer, focused on using large-scale transaction data to drive **growth**, **risk reduction**, and **better partner management**. 

The analysis answers questions such as:
- Which customers deliver the highest **lifetime value** and how engaged are they?  
- Which merchants and categories contribute most to **revenue** and **fraud risk**?  
- How do **seasonality** and **time-based patterns** influence revenue and fraud? 

---

## 🧱 Data & Tech Stack

**Dataset scale**:
| Metric | Value |
|--------|-------|
| Transactions | 1,290,000 |
| Customers | 983 |
| Merchants | 693 |
| Categories | 14 |
| Date Range | 434 days (2019-01-01 to 2020-06-21) |

**Data model**: Star schema
```
Fact: transactions
├── customers (dim)
├── merchants (dim)
├── categories (dim)
└── date (dim)
```

**Tools used**
```
🐘 PostgreSQL – SQL analytics
🐍 Python (pandas) – data processing
📊 Matplotlib/Seaborn – visualization
```

---

## 🔍 Key Insights

### 👥 1️⃣ Customer Analytics
- **983 customers** analyzed; **924 active** in last 90 days (**94% retention**) 
- **Avg revenue/customer**: $92.8K
- **VIP segment**: Top customers contribute **$275K–$296K** each

![Customer Recency Distribution](https://github.com/Notyashsingh/Credit-Card-Transaction-Analytics---Enterprise-Case-Study/blob/main/Visualizations/Customer%20Recency%20Distribution.png?raw=true)

*Figure 1: Customer Recency Distribution*

### 🏪 2️⃣ Merchant Performance
- **693 merchants**; **Top 10** generate **$295K–$391K** each 
- **Pareto pattern**: <2% merchants drive majority of revenue 

![Merchant Revenue](https://github.com/Notyashsingh/Credit-Card-Transaction-Analytics---Enterprise-Case-Study/blob/main/Visualizations/Pareto%20-%20Top%2020%20Merchants%20by%20Revenue.png?raw=true)

*Figure 2: Top 20 Merchants Revenue Distribution*

### 🛒 3️⃣ Category Insights
| Category | Revenue % | Risk Level |
|----------|-----------|------------|
| Grocery POS | **15.85%** | Moderate |
| Shopping POS | **10.20%** | Low |
| Shopping Net | **9.46%** | **High** |
| Gas/Transport | **9.16%** | Low |

![Category Revenue](https://github.com/Notyashsingh/Credit-Card-Transaction-Analytics---Enterprise-Case-Study/blob/main/Visualizations/Category-wise%20Revenue%20Share.png?raw=true)

*Figure 3: Category Revenue Share*

### 🚨 4️⃣ Fraud Analysis
- **Overall fraud rate**: **0.58%** (7,506 of 1.3M transactions)
- **Hotspots**: Late-night transactions, online channels, select merchants (2-2.57%)

![Fraud Trends](https://github.com/Notyashsingh/Credit-Card-Transaction-Analytics---Enterprise-Case-Study/blob/main/Visualizations/Fraud%20Rate%20Over%20Time.png?raw=true)

*Figure 4: Fraud Rate Over Time*

### 📈 5️⃣ Growth Trends
- **Dec 2019 peak**: **+10% MoM**
- **2020 YTD revenue**: **$26.24M**
- **Q2 recovery**: **$14.04M**

![Revenue Trends](https://github.com/Notyashsingh/Credit-Card-Transaction-Analytics---Enterprise-Case-Study/blob/71113b04a4d4b10964fde2dc936b1c47523c88ad/Visualizations/M-O-M%20Growth.png)

*Figure 5: Month-Over-Month Revenue*

---

## 🎯 Business Impact

| Initiative | Expected Outcome |
|------------|------------------|
| Customer Retention | **+15-20% revenue growth** |
| VIP Program | **+8-12% LTV** | |
| Fraud Controls | **-20-30% fraud reduction** |
| Merchant Optimization | **-25% churn** |

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
├── 📁 visualaizations/           # Charts for README
├── 📁 reports/
│   └── Credit-Card-Analytics-Case-Study.pdf
├── 🐳 docker-compose.yml
├── 🐘 init.sql
└── 📄 README.md
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

- **PostgreSQL** community
- **Omdena** data analytics case studies 

---

<div align="center">

**⭐ Star this repo if you found it useful!**  
**🐛 Found a bug? [Open an issue](https://github.com/notyashsingh/credit-card-analytics/issues/new)**

</div>

*Credit Card Analytics Case Study – Dec 2025*
```
