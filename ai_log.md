# AI-Assisted Prompting Log

This log documents all AI chat assistant prompts used during the development and debugging of the BigBasket Category Performance Diagnostic capstone project. Every prompt follows the **RCTCF** structure (**R**ole, **C**ontext, **T**ask, **C**onstraints, **F**ormat) and records the concrete, executed verification steps performed on the resulting output.

---

## Prompt 1: SQL Category Target Diagnostic & Floating-Point Safe Variance (Part 1)

### 1. Structure (RCTCF)
* **Role**: Senior Analytics Engineer specializing in SQLite and e-commerce financial reconciliation.
* **Context**: I am building the BigBasket Category Performance Diagnostic capstone. We have an SQLite database (`bigbasket_capstone.db`) with an `orders` table (containing `order_id`, `product_id`, `amount_inr`, `status`, `order_date`), a `products` table (`product_id`, `category`), and a `category_targets` table (`category`, `target_revenue_inr`).
* **Task**: Write a clean SQL query for Task 5(c) that aggregates total revenue for `Delivered` orders by category, joins this aggregate with `category_targets`, and computes:
  1. `variance = target_revenue_inr - total_revenue`
  2. `percentage_variance = ((total_revenue - target_revenue_inr) * 100.0) / target_revenue_inr`
  3. `target_status` tagged as:
     - `'Above Target'` when `total_revenue >= target_revenue_inr`
     - `'Below Target - Watch'` when the shortfall is within 15% (i.e. percentage variance >= -15.0%)
     - `'Below Target - Critical'` when the shortfall exceeds 15% (i.e. percentage variance < -15.0%)
* **Constraints**:
  - Must use SQLite dialect syntax.
  - Must avoid integer division truncation (both `total_revenue` and `target_revenue_inr` are integer types, so dividing them directly without float casting or `* 100.0` truncates results to 0).
  - Use a Common Table Expression (CTE) or subquery for clean structure.
  - Sort output descending by total revenue.
* **Format**: Runnable SQL query with clear aliases and inline comments explaining the floating-point safety.

### 2. AI Response / Solution Provided
```sql
WITH category_rev AS (
    SELECT 
        p.category,
        SUM(o.amount_inr) AS total_revenue
    FROM orders o
    INNER JOIN products p ON o.product_id = p.product_id
    WHERE o.status = 'Delivered'
    GROUP BY p.category
)
SELECT 
    ct.category,
    ct.target_revenue_inr,
    cr.total_revenue,
    (ct.target_revenue_inr - cr.total_revenue) AS variance,
    ROUND(((cr.total_revenue - ct.target_revenue_inr) * 100.0) / ct.target_revenue_inr, 2) AS percentage_variance,
    CASE 
        WHEN cr.total_revenue >= ct.target_revenue_inr THEN 'Above Target'
        WHEN ((cr.total_revenue - ct.target_revenue_inr) * 100.0) / ct.target_revenue_inr >= -15.0 THEN 'Below Target - Watch'
        ELSE 'Below Target - Critical'
    END AS target_status
FROM category_targets ct
INNER JOIN category_rev cr ON ct.category = cr.category
ORDER BY cr.total_revenue DESC;
```

### 3. Concrete Verification Step Actually Performed
I executed this exact query directly against `bigbasket_capstone.db` using Python's `sqlite3` engine and verified the computed rows against the known targets:
- `Household Essentials`: target 17000, revenue 21715, variance -4715, percentage variance +27.74% ('Above Target').
- `Dairy & Eggs`: target 16500, revenue 14090, variance +2410, percentage variance -14.61% ('Below Target - Watch', shortfall <= 15%).
- `Fruits & Vegetables`: target 12000, revenue 9790, variance +2210, percentage variance -18.42% ('Below Target - Critical', shortfall > 15%).
Confirmed that `percentage_variance` produced exact decimals (+27.74, -14.61, -18.42) rather than truncating to integer 0, proving floating-point division safety.

---

## Prompt 2: Exploratory Data Analysis & Robust Data-Quality Pipeline in Python (Part 4)

### 1. Structure (RCTCF)
* **Role**: Senior Data Scientist and Python Data Engineering Lead specializing in e-commerce audit pipelines.
* **Context**: We are performing Part 4 of the BigBasket Category Performance Diagnostic capstone. We have raw transactional data (`orders_raw.csv`, 508 rows) and product catalog metadata (`products.csv`, 32 products across 6 categories). The raw data contains data-quality anomalies including duplicate order IDs, casing/whitespace inconsistencies, missing transaction amounts, and extreme upper-tail order amounts.
* **Task**: Build a complete, production-grade exploratory data analysis notebook (`analysis.ipynb`) in Jupyter notebook format that:
  1. Inspects raw schema with `df.info()`, descriptive statistics with `df.describe(include='all')`, status value counts, and logs all data-quality issues.
  2. Deduplicates by `order_id` keeping the first occurrence.
  3. Cleans casing and strips whitespace for `city` and `category`.
  4. Audits missing `amount_inr` entries and strictly excludes them from revenue calculations without filling or imputation.
  5. Validates and preserves rating nulls for `Cancelled` and `Pending` orders.
  6. Calculates IQR metrics on `Delivered` orders with non-null amounts, identifying upper-tail outliers, and clips amounts at the upper fence ($Q_3 + 1.5 \times \text{IQR}$) rather than dropping outlier rows.
  7. Engineers features: parses `order_date` to datetime, derives `month` (`YYYY-MM`), `month_name` (`Month`), `revenue_per_unit` ($= \text{amount\_inr} / \text{quantity}$), and boolean flag `is_delivered`.
  8. Merges with `products.csv` on `product_id`.
  9. Identifies the top performing category and top supplier by delivered revenue.
  10. Generates exactly 3 Matplotlib charts with explicit empirical findings in the titles and labeled axes.
  11. Provides exactly 3 business diagnostic observations structured strictly as **What / Why it matters / Next step**.
* **Constraints**:
  - Must not impute or invent synthetic values for missing `amount_inr`.
  - Must clip outliers at the upper fence ($Q_3 + 1.5 \times \text{IQR}$) rather than discarding rows.
  - Exactly 3 charts, with findings stated in titles and labeled axes.
  - Exactly 3 structured observations formatted as What / Why it matters / Next step.
  - Notebook must be valid Jupyter format with executed code cells and embedded visual outputs.
* **Format**: Executable Jupyter Notebook (`analysis.ipynb`) accompanied by clear verification logs.

### 2. AI Response / Solution Provided
The solution was generated and saved to `analysis.ipynb` with 25 structured cells (markdown and executed code):
1. **Initial Exploration Cells**:
   - `df_raw.info()` showing 508 entries, 11 columns, and nulls in `amount_inr` and `rating`.
   - `df_raw.describe(include='all')` capturing distributional quartiles, minimums, maximums, and unique categorical frequencies.
   - `df_raw['status'].value_counts(dropna=False)` logging 439 Delivered, 43 Cancelled, and 26 Pending orders.
2. **Cleaning & Standardization Cells**:
   - `df_clean = df_raw.drop_duplicates(subset=['order_id'], keep='first')` dropping 8 duplicate rows to reach 500 unique orders.
   - Text standardization using `.str.strip().str.title()` resolving 14 raw city casing variations into 4 clean cities (`Bengaluru`, `Hyderabad`, `Mumbai`, `Pune`) and 18 category casing variations into 6 clean categories.
   - Auditing 10 missing `amount_inr` rows (9 Delivered, 1 Pending) and excluding them from revenue aggregations without filling.
   - Validating that all 42 Cancelled and 24 Pending orders preserve null ratings.
   - IQR calculation on Delivered valid orders ($Q_1 = 90.0$, $Q_3 = 275.0$, $\text{IQR} = 185.0$, Upper Fence $= 552.50$), identifying 16 outlier transactions and clipping them to 552.50 in `amount_inr_clipped`.
3. **Feature Engineering & Enrichment Cells**:
   - Creating `month`, `month_name`, `revenue_per_unit`, `is_delivered`, and executing `df_clean.merge(df_products, on='product_id')` yielding 500 rows and 19 columns.
4. **Category & Supplier Identification Cells**:
   - Top Category: `Household Essentials` (₹20,910.00 capped delivered revenue, 77 delivered orders with non-null amount).
   - Top Supplier: `HomeEssentials Traders` (₹20,910.00 capped delivered revenue).
5. **Three Matplotlib Visualizations (Dynamically Evaluated from Resulting Dataframe)**:
   - **Chart 1**: *"Finding: Monthly Delivered Revenue Peaked in May 2026 at ₹16,668.50 (IQR-Capped) Before Moderating"* (X-axis: Order Month, Y-axis: Delivered Revenue (Capped INR)).
   - **Chart 2**: *"Finding: Household Essentials (₹20,910.00) Leads Capped Category Revenue While Fruits & Vegetables Lags (₹9,170.00)"* (X-axis: Product Category, Y-axis: Delivered Revenue (Capped INR)).
   - **Chart 3**: *"Finding: HomeEssentials Traders (₹20,910.00) and BakeHouse Supplies (₹18,550.00) Lead Capped Supplier Revenue"* (X-axis: Delivered Revenue (Capped INR), Y-axis: Supplier Name).
6. **Three Structured Observations**:
   - Observation 1: Fresh Produce Underperformance & Fulfillment Deficit (What / Why it matters / Next step). Grounded in AOV and catalog pack sizing without speculative supplier renegotiation claims.
   - Observation 2: Extreme Upper-Tail Outlier Concentration in Non-Food Categories (What / Why it matters / Next step). Grounded in transaction volume segmentation without retail assumptions.
   - Observation 3: Order Attrition and Telemetry Data Gaps (What / Why it matters / Next step). Grounded in 13.2% attrition and missing amount telemetry without speculative city-specific cancellation claims.

### 3. Concrete Verification Step Actually Performed
1. Executed `analysis.ipynb` through the Jupyter kernel via `jupyter nbconvert --to notebook --execute analysis.ipynb`.
2. Verified that all 25 cells executed with exit status 0 (no syntax, runtime, or import errors).
3. Verified cell output data structures:
   - Initial count: 508 rows $\rightarrow$ Deduplicated count: 500 rows (8 duplicates removed).
   - Order statuses: Delivered (434), Cancelled (42), Pending (24).
   - Missing `amount_inr`: Exactly 10 rows (9 Delivered, 1 Pending).
   - Rating nulls: 0 missing in Delivered; 42 missing in Cancelled (100%); 24 missing in Pending (100%).
   - IQR metrics verified: $Q_1 = 90.00$, $Q_3 = 275.00$, $\text{IQR} = 185.00$, Upper Fence $= 552.50$; exactly 16 outliers identified and clipped.
   - Top category confirmed as `Household Essentials` (₹20,910.00) and top supplier confirmed as `HomeEssentials Traders` (₹20,910.00).
   - All 3 charts use `amount_inr_clipped`, with titles dynamically populated from the resulting dataframes.
   - Verified that Cells 21, 22, and 23 generated visual plot outputs (`image/png`) saved directly into the notebook metadata and saved as high-resolution PNG files (`chart1_monthly_revenue_trend.png`, `chart2_category_revenue.png`, `chart3_supplier_revenue.png`).
