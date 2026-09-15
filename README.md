# BigBasket Category Performance Diagnostic

## Overview
This project diagnoses BigBasket category performance across a six-month transactional period (January to June 2026) using an integrated data analytics toolchain comprising SQL/SQLite, Google Sheets/Excel, Tableau Public, and Python/Pandas.

## Business Objective
The analysis evaluates monthly category revenue against predefined business category targets, identifies Above Target, Watch, and Critical category tiers, and provides data-driven recommendations to stabilize underperforming product lines and protect key revenue drivers.

## Dataset
- **Products**: 31 products across 6 categories
- **Customers**: 50 unique customers
- **Orders**: 500 unique orders after deduplication
- **Categories**: 6 categories (`Household Essentials`, `Personal Care`, `Bakery`, `Dairy & Eggs`, `Snacks & Beverages`, `Fruits & Vegetables`)
- **Timeframe**: January – June 2026
- **Delivery Status Breakdown**: 434 Delivered, 42 Cancelled, 24 Pending
- **Random Seed**: 42 (ensures deterministic data generation)
- **Raw Input Characteristics**: The raw orders file contains 508 rows, including 8 duplicate order IDs.

## Key Findings
Part 1 SQL analysis evaluated delivered revenue against business targets:

- **Household Essentials**: ₹21,715 vs ₹17,000 target — Above Target — +₹4,715
- **Personal Care**: ₹16,382 vs ₹15,500 target — Above Target — +₹882
- **Bakery**: ₹15,410 vs ₹12,000 target — Above Target — +₹3,410
- **Dairy & Eggs**: ₹14,090 vs ₹16,500 target — Below Target - Watch — -₹2,410
- **Snacks & Beverages**: ₹10,895 vs ₹13,000 target — Below Target - Critical — -₹2,105
- **Fruits & Vegetables**: ₹9,790 vs ₹12,000 target — Below Target - Critical — -₹2,210

**Total SQL Delivered Revenue**: ₹88,282.

*Note on Python Diagnostic Revenue*: The Python diagnostic in `analysis.ipynb` uses deduplicated data, excludes missing `amount_inr` values, and applies IQR upper-fence capping. Consequently, its capped revenue totals are intentionally different from the Part 1 SQL totals.

## Tools and Technologies
- SQLite / SQL
- Google Sheets / Excel
- Tableau Public
- Python
- Pandas
- Matplotlib
- Jupyter Notebook

## Repository Structure
- `generate_data.py`: Synthetic transactional and product data generation script using random seed 42.
- `bigbasket_capstone.db`: SQLite database storing cleaned relational tables (`orders` and `products`).
- `orders_raw.csv`: Raw orders dataset containing 508 records with duplicates and data quality anomalies.
- `products.csv`: Product catalog metadata containing 31 product SKUs, categories, and suppliers.
- `verify.sql`: Automated SQL test suite validating record counts, foreign keys, and integrity constraints.
- `01_foundations.sql`: Foundational SQL queries covering filtering, DISTINCT, aliases, IN, BETWEEN, and NULL checks.
- `02_aggregation_joins.sql`: Relational joins, multi-level aggregations, HAVING filters, and zero-order product identification.
- `03_reporting.sql`: Analytical business reporting, CASE classification, target variance calculations, and monthly export generation.
- `monthly_category_revenue.csv`: Aggregated monthly category revenue export derived from Part 1 SQL reporting.
- `capstone_spreadsheet.xlsx`: Multi-sheet Excel workbook featuring formula modeling, pivot reconciliation, and target tracking.
- `analysis.ipynb`: Comprehensive 25-cell Jupyter Notebook conducting end-to-end exploratory data analysis, IQR outlier capping, and business diagnostics.
- `ai_log.md`: AI co-pilot audit log documenting RCTCF prompts, tool calls, and verification steps.
- `README.md`: Capstone project documentation, methodology, and evaluation summary.

## SQL Analysis
The SQL implementation is organized across three sequential scripts and an automated verification file:
- `verify.sql`: Performs schema validation, row count verification (500 clean orders, 31 products), foreign key integrity checks, and constraint assertions.
- `01_foundations.sql`: Demonstrates basic relational querying, filtering by status and price, column aliasing, set membership (`IN`), range filtering (`BETWEEN`), and missing value auditing (`IS NULL`).
- `02_aggregation_joins.sql`: Implements multi-table joins, category and supplier aggregations, conditional filtering (`HAVING`), and a `LEFT JOIN` identifying zero-order products. `Premium Face Cream 50g` is preserved through a `LEFT JOIN` with an order count of 0.
- `03_reporting.sql`: Constructs multi-condition `CASE` statements for performance tiering, computes variance against category targets, and generates the final monthly category reporting table.

## Spreadsheet Analysis
The `capstone_spreadsheet.xlsx` workbook contains four structured sheets:
- **Monthly Data**: Structured transactional reporting records with computed fields.
- **Pivot Table**: Dynamic aggregation matrix summarizing monthly revenue by category.
- **Category Targets**: Baseline target benchmarks and variance calculation models.
- **Category Summary**: Reconciles category revenue totals directly against SQL benchmarks.

## Tableau Dashboard
- **Tableau Public**: [TABLEAU_PUBLIC_URL_TO_BE_ADDED]

The interactive Tableau dashboard comprises:
- Monthly revenue trend line
- Category revenue vs. target status breakdown
- Total Revenue KPI card
- Delivered Orders KPI card
- Average Order Value KPI card
- Categories Meeting Target KPI card
- Interactive month filter control

## Python Analysis
The `analysis.ipynb` notebook implements a comprehensive 25-cell exploratory and diagnostic workflow:
- Raw dataset profiling and structure inspection
- Deduplication removing 8 duplicate order IDs (508 $\rightarrow$ 500 rows)
- String standardization for city and category casing variations
- Missing `amount_inr` audit (10 records identified and excluded from revenue metrics without imputation)
- Rating null preservation for Cancelled and Pending orders (valid domain missingness)
- Interquartile Range (IQR) outlier detection and upper-fence capping:
  - $Q_1 = \text{₹}90$
  - $Q_3 = \text{₹}275$
  - $\text{IQR} = \text{₹}185$
  - Upper fence $= \text{₹}552.50$
  - 16 high-value outliers identified and capped at the upper fence rather than dropped
- Feature engineering (`month`, `month_name`, `revenue_per_unit`, `is_delivered`)
- Category and supplier dimensional revenue aggregations
- Three Matplotlib visualizations with findings stated directly in chart titles
- Three structured business diagnostic observations organized by **What**, **Why it matters**, and **Next step**

## Data Story and Recommendations
1. Prioritize Snacks & Beverages and Fruits & Vegetables because they are the two Critical categories, with shortfalls of ₹2,105 and ₹2,210 respectively.
2. Protect and expand Household Essentials because it has the highest category revenue and exceeds its target by ₹4,715.

## Reproducibility
1. `generate_data.py` uses random seed 42 to generate the raw transactional and product datasets deterministically.
2. Run `python3 generate_data.py` to regenerate `orders_raw.csv` and `products.csv`.
3. SQL scripts (`01_foundations.sql`, `02_aggregation_joins.sql`, `03_reporting.sql`, `verify.sql`) execute against `bigbasket_capstone.db`.
4. `monthly_category_revenue.csv` is generated from the Part 1 reporting SQL queries.
5. `analysis.ipynb` executes sequentially in a standard Python/Jupyter environment.
6. `capstone_spreadsheet.xlsx` contains the complete spreadsheet analysis and formula models.
7. The Tableau dashboard visualizes the data exported in `monthly_category_revenue.csv`.

## AI Usage
Refer to `ai_log.md` for the complete record of RCTCF prompts, operational tool steps, and verification checkpoints.

## Submission Notes
This repository contains the complete capstone submission. The Tableau Public URL placeholder `[TABLEAU_PUBLIC_URL_TO_BE_ADDED]` must be replaced with the final published URL prior to final evaluation.
