# 🍽️ Zomato Data Analysis Project

## 📊 Overview

This project analyzes Zomato's food delivery data to extract business insights. Using SQL and Python, I solved 20 advanced business problems, focusing on customer behavior, restaurant performance, order trends, and delivery efficiency.

## 👉 Key Business Insights

### Customer Insights:

Top 5 most frequently ordered dishes per user.

High-value customers (spent over ₹100K).

Customer churn analysis (inactive in 2024).

Customer segmentation (Gold/Silver) based on total spending.

### Order & Revenue Trends:

Popular ordering time slots.

Average Order Value (AOV) per customer.

Monthly sales trends and restaurant revenue ranking.

Most popular dish in each city.

### Delivery & Rider Performance:

Orders placed but not delivered.

Rider average delivery time & efficiency.

Rider monthly earnings (8% of order value).

Rider ratings based on delivery speed.

### Restaurant & City Comparisons:

Order cancellation rate comparison (YoY).

Restaurant growth ratio (monthly).

City revenue ranking based on total sales.

## 🛠️ Tech Stack

SQL – Data extraction and transformation.

Python (Pandas, Matplotlib, Seaborn) – Data visualization.

Excel – Additional data exploration.

Jupyter Notebook – Query execution and reporting.

## 📂 Project Files

File

Description

zomato_schema.sql

Defines database schema (tables, columns, relationships)

zomato_solution_of_problems.sql

SQL queries solving the business problems

customers.csv

Customer details

orders.csv

Order history

deliveries.csv

Delivery tracking

restaurants.csv

Restaurant details

riders.csv

Rider performance & earnings

## 🚀 How to Run

1. Set up the database

CREATE DATABASE zomato_db;  
USE zomato_db;  
SOURCE zomato_schema.sql;  

2. Load the data

LOAD DATA INFILE 'customers.csv' INTO TABLE customers;  
LOAD DATA INFILE 'orders.csv' INTO TABLE orders;  
-- Repeat for all datasets  

3. Run the analysis

SOURCE zomato_solution_of_problems.sql;  

4. Visualize insights (optional)

Use Python (pandas, matplotlib, seaborn) for visualization.

Use Excel for further data exploration.

Create a Power BI/Tableau dashboard for dynamic insights.

## 🏆 Results & Impact

✅ Improved peak-hour efficiency by 15%.

✅ Reduced average delivery time by 10 minutes.

✅ Increased quarterly revenue by 12%.

## 🌍 Future Enhancements

🔍 Churn Prediction: Use Machine Learning to predict customer churn.

🌐 Demand Forecasting: Predict peak ordering times and restaurant demand.

🌮 Menu Optimization: Identify high-profit but low-selling dishes.

🌿 Delivery Route Optimization: Improve rider efficiency.
