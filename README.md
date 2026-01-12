# Customer Level Branch Accessibility and Relationship
Evaluate branch accessibility, service proximity, and funding quality across Toronto’s metropolitan banking network.

## Getting Started: 
1. Report and presentation
2. data/: Contains cleaned datasets used for the analysis
3. notebooks/: Jupyter notebooks
4. visualizations/: Tableau visualizations and dashboard
5. scripts/: Python and SQL scripts for data analysis

### Tools:
Excel, Jupyter, Python, SQL, Tableau

### Data Sources:
This analysis integrates the following cleaned and standardized datasets:
* Statistics Canada Census Metropolitan Areas (CMA)[^1] – official geographic boundaries used to define the Toronto Census Metropolitan Area and ensure consistent spatial scope
* City of Toronto Open Data Neighbourhood Boundaries (WGS84)[^2] – neighborhood level polygons used to assign client residence areas within the City of Toronto
* OpenStreetMap (OSM)[^3] – branch and service location data, including geographic coordinates and address attributes for major Canadian financial institutions
* Synthetic Client & Product Data – generated to simulate realistic wealth management relationships while avoiding personally identifiable information (PII), including account tenure, product mix, transaction behavior, and funding balances
* Synthetic Employee & Branch Data – generated to represent branch staffing structures, including Branch Managers and relationship roles, aligned with realistic banking hierarchies

The analysis will be based on the cleaned master dataset, which has 71 fields, including:
* cust_id: unique synthetic customer identifier (join key)
* cust_name: synthetic customer name
* first_acct_open_dt: opening date of the customer’s first account
* tenure_days: total relationship tenure in days
* uses_mobile_banking: flag for active digital banking usage
* avg_daily_txn_count: estimated average daily transaction volume per client
* total_deposit_balance: total client deposit balance across all products
* nidda_balance: non-interest deposit balance
* ibb_balance: interest deposit balance
* has_checking, has_savings, has_money_market, has_cd: product presence flags
* has_credit_card: active credit card flag
* total_products: total number of active products and services
* primary_branch_id: customer’s most frequently used branch
* primary_branch_in_top3: flag whether the primary branch is among the three closest branches
* top1_branch_id, top2_branch_id, top3_branch_id: nearest branches by distance
* top1_miles, top2_miles, top3_miles: distance to each branch
* top1_minutes, top2_minutes, top3_minutes: estimated travel time

Note: Branch accessibility metrics (distance and estimated travel time) are calculated using projected geometries (UTM Zone 17N) to ensure accurate distance measurements.
  
## Problem Definition
Although the Toronto metropolitan region is generally characterized by strong economic fundamentals and high financial inclusion, service accessibility and relationship depth are unevenly distributed across clients and neighborhoods. Differences in proximity to financial service locations, branch coverage, and digital adoption can materially affect client engagement, funding quality, and operational efficiency.

### Relevance:
Understanding how branch accessibility, service proximity, and client behavior translate into differences in relationship depth and funding quality is critical for several reasons:
* Financial institutions and branch planners require client-level and neighborhood-aware insights to evaluate how physical accessibility and digital adoption influence engagement, product utilization, and branch performance, informing decisions around branch placement, consolidation, and staffing.
* Wealth management and retail banking teams can use localized accessibility metrics to assess how distance and travel time impact client behavior, funding composition (NIDDA vs. interest-bearing balances), and reliance on self-service channels.
* Operational and strategy stakeholders may leverage integrated client, product, and geographic data to identify service gaps, underserved areas, and opportunities for targeted relationship management or digital enablement.
* Analysts and decision-makers benefit from moving beyond aggregate branch metrics to develop more precise, client-centered models of service utilization, funding quality, and operational efficiency across a large metropolitan market.

## Hypothesis
Customers located farther from physical financial service locations or outside dense branch coverage areas exhibit greater reliance on digital channels, lower in-person service utilization, and variations in funding quality.

## Vision
To support data-driven, customer-centric decision-making in retail and wealth banking by revealing how service accessibility, branch proximity, and client behavior translate into differences in relationship depth, funding quality, and operational performance across a large metropolitan market.

## Objective
The primary objective of this analysis is to develop a comprehensive understanding of how branch accessibility, service proximity, and customer behavior shape relationship depth and funding quality across the Toronto metropolitan area. By integrating geographic service data with client-level behavioral and product metrics, this report aims to address the following objectives:
* Visualize the spatial distribution of branch coverage and customer residence locations to identify areas with reduced physical access to in-person financial services.
* Examine how customer engagement and digital adoption vary with distance and travel time to branches, highlighting patterns in service utilization across neighborhoods.
* Assess funding composition (NIDDA vs. interest-bearing balances) as a proxy for relationship quality, evaluating how deposit mix differs among clients with similar balances but differing accessibility profiles.
* Identify customer segments and geographic areas where accessibility constraints and behavioral patterns intersect, highlighting opportunities for targeted branch strategy, staffing optimization, and digital enablement initiatives.

## Review of the Literature
The level of data science and machine learning talent within an organization positively correlates with the adoption of ML technologies. As highlighted in the LinkedIn article, the modern process industry is driven by big data, which includes vast amounts of structured and unstructured data posing significant challenges in efficient data interpretation and management. National AI adoption trends indicate that sectors with high current AI usage will maintain their lead, while sectors such as Accommodation and Food Services exhibit lower adoption rates. The BTOS AI findings, consistent with the 2019 Annual Business Survey (ABS), show that sectors with higher adoption rates have more established practices and experienced talent. In the EdTech industry, machine learning is revolutionizing learning experiences through adaptive learning systems, content recommendation systems, and predictive analytics, contributing to market growth projections by 2027. Despite these advancements, CompTIA identifies barriers to AI adoption, including a lack of skilled professionals, unclear ROI metrics, and the complexity of AI systems. Addressing these barriers through targeted strategies and education can facilitate wider AI and ML adoption, leading to enhanced efficiency and competitiveness in organizations. Consequently, fostering skilled talent within organizations is essential for driving successful ML and AI integration across various industries.

## Key Insights
* Across South Florida census tracts, flooding and hurricanes account for approximately 88% of total expected annual climate-related financial losses, confirming water-related hazards as the dominant driver of household financial risk in the region.

### Dashboard
![image](https://github.com/acsoteldo/Machine-Learning-Adoption-Across-Industries/assets/76544489/a5f8da18-98a8-490f-9fee-7e0dbdc8aece)

## Next Steps
* Design industry-specific workshops to highlight the benefits and applications of machine learning in various sectors.
* Organize events that promote collaboration and idea exchange among professionals to accelerate ML adoption within organizations.
* Provide training programs in machine learning to help professionals enhance their skills, stay current with industry trends, and boost their career prospects.
* Support regulations that encourage innovation while ensuring privacy, security, and fairness, fostering greater confidence in ML technologies.
* Continuously use dataset insights to update and improve the educational sessions, ensuring they remain relevant and effective.

## Contact
For any inquiries or feedback, please contact acsoteldo01@gmail.com.

## References
[^1]: Data Source: Statistics Canada Census Metropolitan Areas (CMA)
https://www12.statcan.gc.ca/census-recensement/2021/geo/sip-pis/boundary-limites/index2021-eng.cfm

[^2]: Data Source: City of Toronto Open Data Neighbourhood Boundaries (WGS84)
https://open.toronto.ca/dataset/neighbourhoods/

[^3]: Data Source: OpenStreetMap (OSM)

