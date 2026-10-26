# UK Doctor Creator Engagement Analysis

SQL and Power BI analysis of engagement rates for 16 UK doctor creators on Instagram, comparing performance by follower size.

## Question
Do doctors with smaller audiences get better engagement than bigger names?

## Data
- Source: HypeAuditor ranking of top UK Health & Medicine Instagram accounts, accessed 26 October 2026.
- Only individuals presenting as medical doctors are included. Brands, charities, nutritionists and non-UK accounts are excluded.
- Engagement rate (ER) = average engagements per post / followers.
- Follower and engagement figures are rounded as published, so ER is approximate.

## Method
1. Loaded the 16 accounts into PostgreSQL (`doctor_creator_analysis.sql`).
2. Calculated ER, authentic engagement share and follower band with SQL views.
3. Calculated median ER per band using `PERCENTILE_CONT`.
4. Connected Power BI to the views to build a one-page dashboard.

## Key findings
| Follower band | Doctors | Median ER |
|---|---|---|
| Under 500K | 6 | 1.14% |
| 500K to 1M | 6 | 0.26% |
| Over 1M | 4 | 0.47% |

- The five highest ERs all belong to doctors with under 500K followers.
- Doctors under 500K averaged about 3.9K engagements per post, more than the 500K to 1M group (about 2.4K).
- The four lowest authentic engagement shares (55% to 72%) were all aesthetics or skin doctors. This uses HypeAuditor's own method, so treat it as a prompt to check audience quality, not proof.


## How to run
1. Create a PostgreSQL database.
2. Run `doctor_creator_analysis.sql`.
3. Connect Power BI to the `doctor_metrics`, `band_summary` and `kpis` views.
