# Customer Purchase Behavior and Segmentation
# Project Sales Analysis Readme
This README provides an overview of the SQL queries and analyses performed in the project, along with additional information about integrating the analysis into a Tableau dashboard.

## Table of Contents
1. [Introduction](#introduction)
2. [SQL Queries](#sql-queries)
    1. [Data Exploration](#data-exploration)
    2. [Sales Revenue Analysis](#sales-revenue-analysis)
    3. [RFM Analysis](#rfm-analysis)
    4. [Products Sold Together](#products-sold-together)
    5. [Top Contributing Countries](#top-contributing-countries)
3. [Tableau Integration](#tableau-integration)
4. [Dashboard](#dashboard)
5. [Conclusion and Insights](#conclusion_and_insights)


## Introduction<a name="introduction"></a>

This project involves the analysis of sales data from the `Project1.sales_data_sample` table. The goal is to gain insights into sales performance, customer behavior, and product relationships. Additionally, there is a plan to integrate the analysis into a Tableau dashboard.

## SQL Queries<a name="sql-queries"></a>

### Data Exploration<a name="data-exploration"></a>

The following SQL queries were used for initial data exploration:
- **Unique Values**: Identified unique values in key columns like `status`, `year_id`, `PRODUCTLINE`, `COUNTRY`, and `DEALSIZE`.
- **Distinct Months**: Selected distinct months in the years 2003, 2004, and 2005 for further analysis.

### Sales Revenue Analysis<a name="sales-revenue-analysis"></a>

Sales revenue was analyzed using the following queries:
- **By Product Line**: Analyzed sales revenue by product line.
- **Across Years**: Analyzed sales revenue across different years.
- **Best Sales Month Per Year**: Identified the best sales month per year, including product line details.

### RFM Analysis<a name="rfm-analysis"></a>

The RFM (Recency, Frequency, Monetary Value) analysis was performed to evaluate customer value and segmentation. The steps involved in this analysis are:
- **RFM Calculation**: Calculated RFM values for each customer.
- **RFM Segmentation**: Segmented customers based on their RFM scores into categories like 'lost customers,' 'new customers,' 'loyal,' etc.

### Products Sold Together<a name="products-sold-together"></a>

A query was used to find products often sold together when customers buy two items.

### Top Contributing Countries<a name="top-contributing-countries"></a>

Queries were used to identify the top countries contributing the most to sales in each of the years 2003, 2004, and 2005.

## Tableau Integration<a name="tableau-integration"></a>

To integrate this analysis into Tableau, follow these steps:
1. **Data Connection**: Connect Tableau to the SQL database where the `Project1.sales_data_sample` table resides.
2. **Data Preparation**: Perform any necessary data transformations or cleanups within Tableau to prepare the data for analysis.
3. **Create Visualizations**: Use Tableau's visualization tools to create charts, graphs, and tables based on the SQL analysis.
4. **Build the Dashboard**: Construct a dashboard within Tableau that includes the visualizations created in the previous step.
5. **Interactivity**: Add interactive elements like filters, drop-down menus, or parameters to allow users to explore the data dynamically.
6. **Publish to Tableau Server**: If required, publish the Tableau dashboard to Tableau Server for wider access and sharing.

## Dashboard<a name="dashboard"></a>

The dashboard can include various visualizations and insights generated from the SQL analysis. Here are some potential components for the dashboard:

- Sales Revenue by Product Line over the years.
- Sales Revenue by Deal size.
- Sales Revenue by Year and Product Line.
- Monthly Sales Revenue across Countries. 
- Revenue by Country.
- Customer Distribution by Country.
- Quantity Distribution.
- Sales Distribution.
- RFM Segmentation Distribution.
- RFM Segment by Country.
- Top Product Pairs.
- Buying Set Distribution

<div align=center>
<img src="https://github.com/LL-Laurian/Customer-Purchase-Behavior-and-Segmentation/blob/main/image_src/Sales%20Dash1.png">
</div>
<div align=center>
<img src="https://github.com/LL-Laurian/Customer-Purchase-Behavior-and-Segmentation/blob/main/image_src/Sales%20Dash2.png">
</div>
<div align=center>
<img src="https://github.com/LL-Laurian/Customer-Purchase-Behavior-and-Segmentation/blob/main/image_src/Sales%20Dash3.png">
</div>


## Conclusion and Insights<a name="conclusion_and_insights"></a>

### RFM Segmentation: 
- "Lost_customer" is the largest RFM segment, highlighting the need for re-engagement strategies.
- The "slipping away, cannot lose" segment comes second, suggesting that the valuable customers in the "slipping away" segment deserve attention. since they should not be ignored.
- "Potential churners" and "loyal" segments are roughly balanced., implying a balance between customers showing potential to churn and those demonstrating loyalty.
- "New customers" form the smallest segment., indicating fewer new customer acquisitions.
### Country Contribution:
- The United States (USA) dominates revenue and customer count.
- Spain and France are after the USA.

### Product Line:
- "Classic Cars" is the leading contributor to revenue, followed by "Motorcycles." 
- Products with a "Medium" deal size contribute the most to revenue, suggesting that customers prefer this deal size.

### Sales Trends:
- Across all product lines, there is a noticeable drop in sales. This could indicate a broader market trend or business-specific factors affecting sales performance.

### Monthly Revenue:
- November consistently has the highest revenue every year, except for 2003, where data is missing from May to December.

### Top Revenue Contributor:
- Customer "Mini Gifts Distribution" is the top contributor to revenue, and this is from the USA.

### Products Sold Together:
- Customers most often buy nine items together, followed by fourteen items and then six items. This information can be used to optimize product bundling or marketing strategies.

### Conclusion:
- Strategies can be developed to re-engage the 'lost_customer' segments, retain valuable 'slipping away' customers, prioritize product lines contributing the highest revenue, such as 'Classic Cars' and 'Motorcycles.' Additionally, proactive efforts can be undertaken to comprehend the sales decline observed across all product lines.