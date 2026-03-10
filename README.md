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
* branches_within_1km: count of major-bank branches within 1 km of the client's neighbourhood
* has_credit_card: active credit card flag
* total_products: total number of active products and services
* primary_branch_id: customer’s most frequently used branch
* primary_branch_in_top3: flag whether the primary branch is among the three closest branches
* top1_branch_id, top2_branch_id, top3_branch_id: nearest branches by distance
* top1_km, top2_km, top3_km: distance to each branch
* top1_minutes, top2_minutes, top3_minutes: estimated travel time

Note: Branch accessibility metrics (distance and estimated travel time) are calculated using projected geometries (UTM Zone 17N) to ensure accurate distance measurements. Client-level geographic coordinates were aggregated to the neighbourhood level to preserve privacy and reflect responsible data governance practices.
  
## Problem Definition
Although the Toronto metropolitan region is generally characterized by strong economic fundamentals and high financial inclusion, service accessibility and relationship depth are unevenly distributed across clients and neighbourhoods. Differences in proximity to major bank branches, branch coverage density, and digital adoption can materially affect client engagement, funding quality, and operational efficiency.

### Relevance:
Understanding how branch accessibility, service proximity, and client behaviour translate into differences in relationship depth and funding quality is critical for several reasons:
* Financial institutions and branch planners require client-level and neighbourhood-aware insights to evaluate how physical accessibility and digital adoption influence engagement, product utilization, and branch performance, informing decisions around branch placement, consolidation, and staffing.
* Wealth management and retail banking teams can use localized accessibility metrics to assess how distance and travel time impact client behaviour, funding composition (NIDDA vs. interest-bearing balances), and reliance on self-service channels.
* Operational and strategy stakeholders may leverage integrated client, product, and geographic data to identify service gaps, underserved areas, and opportunities for targeted relationship management or digital enablement.
* Analysts and decision-makers benefit from moving beyond aggregate branch metrics to develop more precise, client-centred models of service utilization, funding quality, and operational efficiency across a large metropolitan market.

## Hypothesis
Clients located farther from physical bank branches or outside dense branch coverage areas exhibit greater reliance on digital channels, lower in-person service utilization, and variations in funding quality.

## Vision
To support data-driven, client-centric decision-making in retail and wealth banking by revealing how service accessibility, branch proximity, and client behaviour translate into differences in relationship depth, funding quality, and operational performance across a large metropolitan market.

## Objective
The primary objective of this analysis is to develop a comprehensive understanding of how branch accessibility, service proximity, and client behaviour shape relationship depth and funding quality across the Toronto metropolitan area. By integrating geographic service data with client-level behavioural and product metrics, this report aims to address the following objectives:
* Visualize the spatial distribution of branch coverage and client residence locations to identify areas with reduced physical access to in-person financial services.
* Examine how client engagement and digital adoption vary with distance and travel time to branches, highlighting patterns in service utilisation across neighbourhoods.
* Assess funding composition (NIDDA vs. interest-bearing balances) as a proxy for relationship quality, evaluating how deposit mix differs among clients with similar balances but differing accessibility profiles.
* Identify client segments and geographic areas where accessibility constraints and behavioural patterns intersect, highlighting opportunities for targeted branch strategy, staffing optimisation, and digital enablement initiatives.

## Review of the Literature
The relationship between branch accessibility and client behaviour is well documented. Research from the Bank of Canada finds that geographical proximity of bank branches materially affects household credit choice, with ongoing branch consolidation potentially reducing financial inclusion, particularly in culturally diverse neighbourhoods [^4]. This dynamic is central to the GTA context examined in this analysis. Branch networks in Canada have been contracting steadily. Physical branches declined from 5,890 in 2018 to approximately 5,656 by 2022, while in-person banking usage fell from 67% to 61% over the same period [^5]. Yet proximity remains relevant, 37% of new account journeys still conclude in-person [^6]. Digital adoption has accelerated alongside this contraction. 65% of Canadians now use mobile banking apps, with adoption highest among younger generations [^5]. Most major banks report the average client visits a branch once a quarter or less, limiting touchpoints even for multi-product clients [^7]. Engagement quality has direct financial implications. 71% of actively engaged clients are likely to remain with their bank long-term [^8], linking service accessibility to deposit stability and relationship depth, the core outcomes this project measures across GTA neighbourhoods.

## Key Insights
**Based on synthetic client data for illustrative purposes only.**
* Among GTA clients with no nearby branch, mobile banking adoption reaches 91% compared to 53% in very high coverage areas, confirming physical inaccessibility as the primary driver of digital channel reliance rather than client preference.
* Clients in the No Nearby Branch and Low Coverage (1–2) tiers collectively represent the largest share of the 5,000-client base yet consistently show the lowest average deposit balances, confirming that volume concentration at lower coverage tiers does not translate into proportionate funding quality.
* Among clients with no nearby branch, 26% bypass closer alternatives to reach their primary branch, suggesting that advisor relationships and brand loyalty override proximity as the dominant drivers of branch selection in underserved areas.
* Despite representing fewer than 100 clients, the Very High Coverage (10+) segment accounts for the highest average deposit balances in the $250K+ band.
* Average daily transactions among clients with no nearby branch are 0.74 compared to 1.50 for high coverage clients, confirming that digital banking in low-access areas functions primarily as a transactional channel.

### Dashboard
<img width="2880" height="1736" alt="Data Project 13 Jan 2026 - Dashboard 1" src="https://github.com/user-attachments/assets/566d1ce1-31a6-43ed-92c1-c8454c30fcb3" />
<img width="2880" height="1738" alt="Data Project 13 Jan 2026 - Dashboard 2" src="https://github.com/user-attachments/assets/7f3dc5f8-de12-48b0-9ecd-c7b3182dfd8f" />

### Demo


## Next Steps
* Extend the branch accessibility analysis to incorporate additional GTA municipalities beyond Toronto, increasing the proportion of Outside Toronto clients and improving neighbourhood-level representativeness.
* Incorporate product-level origination dates into fact_cust_product to enable cohort analysis of product adoption over the client lifecycle.
* Explore predictive modelling of deposit tier migration using coverage, digital adoption, and tenure as input features, transitioning the project from descriptive to prescriptive analytics.
* Present findings to a simulated stakeholder audience to validate dashboard narrative clarity and identify gaps in the branch strategy and digital enablement story.

## Contact
For any inquiries or feedback, please contact acsoteldo01@gmail.com.

## References
[^1]: Data Source: Statistics Canada Census Metropolitan Areas (CMA)
https://www12.statcan.gc.ca/census-recensement/2021/geo/sip-pis/boundary-limites/index2021-eng.cfm

[^2]: Data Source: City of Toronto Open Data Neighbourhood Boundaries (WGS84)
https://open.toronto.ca/dataset/neighbourhoods/

[^3]: Data Source: OpenStreetMap (OSM)

[^4]: Geographical and Cultural Proximity in Retail Banking
https://www.bankofcanada.ca/2023/01/staff-working-paper-2023-2/

[^5]: Banking Industry Statistics in Canada
https://madeinca.ca/banking-industry-statistics-canada/

[^6]: The Future of the Branch
https://bankingjournal.aba.com/2023/07/the-future-of-the-branch-what-can-banks-learn-from-luxury-retail-customer-experiences/

[^7]: Digital Intelligence: Banks are evolving customer engagement strategies to recapture growth
https://www.pwc.com/us/en/industries/financial-services/library/customer-engagement-strategy-evolution.html

[^8]: Elevating Customer Engagement in Banking
https://www.experian.com/blogs/insights/customer-engagement-banking/
