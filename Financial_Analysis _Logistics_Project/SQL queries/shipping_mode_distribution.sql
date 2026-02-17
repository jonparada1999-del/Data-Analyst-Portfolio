/*
I use this query to establish a baseline for our fulfillment strategy. It allows me 
to see the total volume distribution across different shipping modes so I can 
understand our primary delivery methods before deep-diving into performance metrics.
*/

SELECT 
    `Shipping Mode`, 
    COUNT(*) AS total_shipments
FROM 
    `valid-weaver-487619-r7.supply_chain_analysis.supply_chain_data`
GROUP BY 
    `Shipping Mode`
ORDER BY 
    total_shipments DESC;