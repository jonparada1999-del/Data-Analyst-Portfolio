/*
I created this analysis to detect regional profit leakage. By aggregating total profit 
by region, I can identify underperforming territories where operational costs 
might be eroding margins, helping the finance team prioritize audit areas.
*/

SELECT 
    `Order Region`, 
    ROUND(SUM(`ORDER PROFIT PER ORDER`), 2) AS total_profit 
FROM 
    `valid-weaver-487619-r7.supply_chain_analysis.supply_chain_data`
GROUP BY 
    `Order Region`
ORDER BY 
    total_profit ASC;