SELECT Country, Product_Category, Sub_Category, Age_Group,
SUM(Revenue) AS Total_Revenue, 
SUM(Cost) AS Total_Cost,
SUM(Profit) AS Total_Profit, 
ROUND(AVG(Revenue), 0) AS Avg_Revenue,
ROUND(AVG(Cost), 0) AS Avg_Cost,
ROUND(AVG(Profit), 0) AS Avg_Profit,   
SUM(Order_Quantity) AS Total_Orders,
ROUND(((SUM(Revenue) - SUM(Cost)) / SUM(Cost)), 2) AS ROI
FROM sales_data
GROUP BY Country, Product_Category, Sub_Category, Age_Group
ORDER BY SUM(Profit) DESC
