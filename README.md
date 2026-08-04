# Zepto-SQL-data-analysis-project
🛒 Zepto E-commerce SQL Data Analysis Project
📌 **Project Overview** 
This project analyzes a real-world **Zepto Grocery Products Dataset** using **MySQL** to solve business problems and demonstrate advanced SQL skills.

The goal is to simulate how actual data analysts in the e-commerce or retail industries work behind the scenes to use SQL to:

✅ Set up a messy, real-world e-commerce inventory database

✅ Perform Exploratory Data Analysis (EDA) to explore product categories, availability, and pricing inconsistencies

✅ Implement Data Cleaning to handle null values, remove invalid entries, and convert pricing from paise to rupees

✅ Write business-driven SQL queries to derive insights around pricing, inventory, stock availability, revenue and more.

📁 **Dataset Overview**
The dataset was sourced from Kaggle and was originally scraped from Zepto’s official product listings. It mimics what you’d typically encounter in a real-world e-commerce inventory system.

Each row represents a unique SKU (Stock Keeping Unit) for a product. Duplicate product names exist because the same product may appear multiple times in different package sizes, weights, discounts, or categories to improve visibility – exactly how real catalog data looks.

🧾 Columns:
- **sku_id:** Unique identifier for each product (Primary Key)

- **category:** Product category (e.g., Fruits & Vegetables, Dairy, Snacks, Beverages)

- **name:** Name of the product listed on Zepto

- **mrp:** Maximum Retail Price (₹) before discount

- **discountPercent:** Percentage discount offered on the MRP

- **discountedSellingPrice:** Final selling price (₹) after applying the discount

- **availableQuantity:** Number of units currently available in inventory

- **weightInGms:** Weight of the product in grams

- **outOfStock:** Stock availability status (`1 = Out of Stock`, `0 = In Stock`)

- **quantity:** Pack size or quantity of the product (e.g., 500g, 1L, 6 pcs)

- 🔧 **Project Workflow**
Here’s a step-by-step breakdown of what we do in this project:

**1. Database & Table Creation**
We start by creating a SQL table with appropriate data types:

```sql
CREATE TABLE zepto (
    sku_id INT AUTO_INCREMENT PRIMARY KEY,
    category VARCHAR(120),
    name VARCHAR(150) NOT NULL,
    mrp DECIMAL(8,2),
    discountPercent DECIMAL(5,2),
    availableQuantity INT,
    discountedSellingPrice DECIMAL(8,2),
    weightInGms INT,
    outOfStock BOOLEAN,
    quantity INT
);
```

**2. Data Import**
- Loaded CSV file using import feature.
- Loading data in table using the code below :

```sql
LOAD DATA LOCAL INFILE 'YOUR_FILE_PATH/zepto_v22.csv'
INTO TABLE zepto
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
    category,
    name,
    mrp,
    discountPercent,
    availableQuantity,
    discountedSellingPrice,
    weightInGms,
    outOfStock,
    quantity
);
```

## 🔍 3. Data Exploration

- Counted the total number of records in the dataset.
- Viewed a sample of the dataset.
- Checked for NULL values.
- Identified distinct product categories available in the dataset
- Compared in-stock vs out-of-stock product counts
- Detected products present multiple times, representing different SKUs

**4. 🧹 Data Cleaning**
- Identified and removed rows where MRP or discounted selling price was zero
- Converted mrp and discountedSellingPrice from paise to rupees for consistency and readability

**5. 📊 Business Insights**
- Found top 10 best-value products based on discount percentage

- Identified high-MRP products that are currently out of stock

- Estimated potential revenue for each product category

- Filtered expensive products (MRP > ₹500) with minimal discount

- Ranked top 5 categories offering highest average discounts

- Calculated price per gram to identify value-for-money products

- Grouped products based on weight into Low, Medium, and Bulk categories

- Measured total inventory weight per product category
