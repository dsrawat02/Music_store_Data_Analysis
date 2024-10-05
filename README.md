# Music Store Data Analysis


## Table of Contents

- [Project Overview](#project-overview)
- [Data Source](#data-source)
- [Database or Tools Used](#database-or-tools-used)
- [Data Preparation](#data-preparation)
- [Exploratory Data Analysis](#exploratory-data-analysis)
- [Results or Findings](#results-or-findings)
- [Recommendations](#recommendations)
- [Limitations](#limitations)


### Project Overview

This project aims to analyze a music playlist database. Using SQL, we'll examine the dataset and help the store comprehend its business growth by answering some questions.


### Data Source

The primary dataset used for the analysis is the 'Music_Store_database.sql' file.


### Database or Tools Used

- Postgre SQL - For analyzing the data
- PgAdmin4


### Data Preparation

In the initial data preparation phase I performed the following tasks:
1. Data loading and inspection.
2. Handling missing values.
3. Data cleaning and formatting.


### Exploratory Data Analysis

EDA involved exploring the sales data to answer key questions, such as:

- Which countries have the most invoices? 
  ```sql
  SELECT billing_country, COUNT(billing_country) AS most_invoices 
  FROM invoice 
  GROUP BY billing_country 
  ORDER BY most_invoices DESC;  
  ```
  
- What are the top 3 values of the total invoice?
  ```sql
  SELECT total 
  FROM invoice 
  ORDER BY total DESC 
  LIMIT 3;
  ```

### Results or Findings

The analysis results are summarized as follows:

The US, Canada, and Brazil are the leading countries in terms of revenue. The US stands out as the top revenue generator. Meanwhile, Prague has emerged as the ideal city for hosting a music festival, generating the most revenue.


### Recommendations

Based on the analysis, I recommend the following actions:

Seasonal Promotions to boost revenue. Prioritize the growth and promotion of Queen's album.


### Limitations

I had to remove zero or missing values from the 'total' column to ensure the accuracy of my analysis.

