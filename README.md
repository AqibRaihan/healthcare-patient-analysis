## Project Objective

Based on an AnalystBuilder project brief, this project explores a
synthetic healthcare dataset to answer four questions:

1. What does the patient population look like by age?
2. Which diagnosis codes appear most often, and how do they vary by age and sex?
3. How many recorded visit days does each patient have, and which patient IDs have four or more?
4. Which CPT procedure codes appear most often?

## Tools Used

- SQL Server: data exploration and analysis
- Python and pandas: data quality checks
- Power BI: interactive dashboard

The original scenario requested Tableau. I used Power BI, which was
listed as an optional tool.

## Analysis Notes

Visit IDs were reused, so distinct visit dates per patient ID were used
as a proxy for visits. Conflicting birth dates and sex values were
marked Unknown. Diagnosis rankings update for the selected age or sex.
