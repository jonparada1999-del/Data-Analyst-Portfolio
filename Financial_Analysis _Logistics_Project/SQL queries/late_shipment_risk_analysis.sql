/*
I developed this query to identify operational bottlenecks in the shipping process. 
By comparing real versus scheduled shipping days, I can pinpoint which modes 
consistently fail to meet delivery deadlines, allowing for targeted logistics improvements.
*/

SELECT 
    `Shipping Mode`, 
    COUNT(*) AS late_shipments
FROM 
    `valid-weaver-487619-r7.supply_chain_analysis.supply_chain_data`
WHERE 
    `Days for shipping _real_` > `Days for shipment _scheduled_`
GROUP BY 
    `Shipping Mode`
ORDER BY 
    late_shipments DESC;
