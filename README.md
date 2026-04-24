# Retail Data Business Insights Project

This project addresses a **retail business challenge**:  
How can a mid-sized outdoor apparel company use its transactional data to **understand sales performance, customer behavior, and promotion effectiveness** in order to make better merchandising, marketing, and inventory decisions?

To answer this, I designed a **complete retail database schema**, generated realistic transactional data, and developed a set of **SQL-driven analyses** that translates what a real-world business intelligence team might deliver to decision-makers.

---

## 1. Business Context & Problem Statement

Aurora Outfitters is a specialty retailer competing with brands like Patagonia.  
They sell outdoor clothing and gear across **both in-store and online channels**.  
Leadership wants to answer critical questions, such as:

- Are online and in-store revenues growing at similar rates month over month?  
- Which products and categories are driving the most revenue — and which are underperforming?  
- Are store locations meeting revenue targets, and where is there opportunity to improve?  
- How effective are promotions, and are they driving incremental revenue or just discounting?  
- What percentage of customers are coming back to shop again, and how long between purchases?  
- Are return rates under control, or do some categories need quality checks?

This project simulates the **end-to-end data workflow** to solve these questions — from designing the data model to writing analysis queries.

---

## 2. Project Overview

- **Database Design**  
  Designed a relational schema with 9 interrelated tables: 
  -`Customers`, `Stores`, `Staff`, `Products`, `Promotions`, `Orders`, `OrderItems`, `LineItemPromotions`, and `Returns`.  
  - Enforced referential integrity through primary keys, foreign keys, and cascading rules.

- **Data Generation & Validation**  
  Populated the database with **3 months of realistic data** including 120+ orders, 80+ customers, and promotional activities. Ensured data satisfied business rules like:
  - Some customers have repeat orders
  - Return rates are realistic (5–15%)
  - Products are distributed across multiple categories and sales channels

- **Business Analysis via SQL**  
  Wrote modular queries using joins, window functions, and views to transform transactional data into actionable insights.

---

## 3. Key Business Insights Delivered

1. **Monthly Revenue Trends** – Highlighted channel-level growth patterns to inform marketing and channel investments.
2. **Top Products & Underperformers** – Identified revenue drivers and low performers for merchandising decisions.
3. **Store Performance** – Ranked stores by revenue, showing where to allocate resources.
4. **Customer Repeat Behavior** – Calculated repeat-purchase rate and median reorder gap to inform loyalty initiatives.
5. **Promotion Effectiveness** – Measured revenue contribution of promoted vs. non-promoted items, highlighting promotion ROI.
6. **Return Rates by Category** – Flagged categories exceeding acceptable return thresholds (>10%).
7. **Basket Composition & Order Size** – Helped understand cross-selling opportunities.
8. **High-Value Customers** – Generated a list of top customers for targeted engagement campaigns.
9. **Dead Inventory Check** – Ensured no product was sitting unsold in the most recent month.

---

## 4. Business Value

The output of this project is not just code — it is a **decision support framework**.  
If this were a real company, leadership could use these insights to:

- Adjust inventory buys by category and store  
- Optimize marketing spend between channels  
- Design targeted promotions for high-value and at-risk customers  
- Reduce return rates by investigating flagged categories  

---

## 5. Key Skills Demonstrated

- **SQL DDL & DML** – Schema creation, altering tables, inserting data.
- **Data Validation** – Ensured referential integrity and realistic business rules.
- **Advanced SQL** – Joins, aggregations, subqueries, views, and window functions.
- **Business Insights** – Converted raw data into actionable insights for decision-making.

---

## 6. How to use

1. Run `retail_data_business_insights.sql` in MySQL Workbench to create schema and load data.
2. Execute the analysis queries section by section to reproduce insights.
3. Read `aurora_outfitters_business_case_reflection.pdf` for project learnings, assumptions, and improvement opportunities.

---

## 7. Tech Stack

- **Database:** MySQL  
- **Tooling:** MySQL Workbench for schema design and imports  

---

## 8. Author

Project by **Niharika Sharma** as part of a capstone assignment in SQL, with emphasis on **business-driven analytics**.

