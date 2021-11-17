
--Subquery in column list
;WITH Sales_CTE as 
(
select Year(SalesDate) as [Year],SalesID,SalesDate,
(select sum(Quantity*UnitPrice) from SalesDetail where 
SalesDetail.SalesID=Sales.SalesID )as totalamount
 from Sales
)select 
DISTINCT [Year]
,(SELECT SUM(totalamount)FROM Sales_CTE od WHERE Year(od.SalesDate)=Sales_CTE.[Year] and DATEPART(Quarter, od.SalesDate)=1) AS 'Spring'
,(SELECT SUM(totalamount)FROM Sales_CTE od WHERE Year(od.SalesDate)=Sales_CTE.[Year] and DATEPART(Quarter, od.SalesDate)=2) AS 'Summer'
,(SELECT SUM(totalamount)FROM Sales_CTE od WHERE Year(od.SalesDate)=Sales_CTE.[Year] and DATEPART(Quarter, od.SalesDate)=3) AS 'Fall'
,(SELECT SUM(totalamount)FROM Sales_CTE od WHERE Year(od.SalesDate)=Sales_CTE.[Year] and DATEPART(Quarter, od.SalesDate)=4) AS 'Winter'
 from Sales_CTE

-----------------------------------------------------
-----------------------------------------------------
--Apply + Table Valued Function
CREATE FUNCTION dbo.SumSalesPerSeasionOfYear(@YEAR AS INT,@Seasion AS INT)
RETURNS TABLE as
RETURN
select SUM(Quantity*UnitPrice) as total
from Sales
join SalesDetail on Sales.SalesID=SalesDetail.SalesID
where Year(SalesDate)= @YEAR  and DATEPART(Quarter, SalesDate)=@Seasion
GO
-----------------------
  select Distinct Year(SalesDate) as [Year] 
  ,Spring.total as Spring,
  Summer.total as Summer
  , Fall.total as Fall
    ,Winter.total as Winter
 from Sales
    outer APPLY 			
   SumSalesPerSeasionOfYear(Year(SalesDate),1) as Spring
    outer APPLY 			
   SumSalesPerSeasionOfYear(Year(SalesDate),2) as Summer
    outer APPLY 				
   SumSalesPerSeasionOfYear(Year(SalesDate),3) as Fall
     outer APPLY 
   SumSalesPerSeasionOfYear(Year(SalesDate),4) as Winter


-----------------------------------------------------
-----------------------------------------------------
--CASE in column list
 ;WITH Sales_CTE as 
(
select Year(SalesDate) as [Year],DATEPART(Quarter,SalesDate) as Season ,SalesID,SalesDate,
(select sum(Quantity*UnitPrice) from SalesDetail where 
SalesDetail.SalesID=Sales.SalesID )as totalamount
 from Sales
)select
 [Year],
,SUM(CASE WHEN Year(SalesDate)=Sales_CTE.[Year] and DATEPART(Quarter,SalesDate)=1  THEN totalamount ELSE NULL END)  AS 'Spring'
,SUM(CASE WHEN Year(SalesDate)=Sales_CTE.[Year] and DATEPART(Quarter,SalesDate)=2  THEN totalamount ELSE NULL END)  AS 'Summer'
,SUM(CASE WHEN Year(SalesDate)=Sales_CTE.[Year] and DATEPART(Quarter,SalesDate)=3  THEN totalamount ELSE NULL END)  AS 'Fall'
,SUM(CASE WHEN Year(SalesDate)=Sales_CTE.[Year] and DATEPART(Quarter,SalesDate)=4  THEN totalamount  ELSE NULL END)  AS 'Winter'
 from Sales_CTE
 group by [Year]
-----------------------------------------------------
-----------------------------------------------------
--Pivot & SubQuery
select * from 
(
select Year(SalesDate) as [YEAR], 
(case 
      when DATEPART(Quarter, SalesDate)=1 then 'Spring'
      when DATEPART(Quarter, SalesDate)=2 then 'Summer'
      when DATEPART(Quarter, SalesDate)=3 then 'Fall'
	  when DATEPART(Quarter, SalesDate)=4 then 'Winter'
 end) as season,
(select sum(Quantity*UnitPrice) from SalesDetail where 
SalesDetail.SalesID=Sales.SalesID )as totalvalue
from Sales
) sl
PIVOT
	(sum (totalvalue)
		FOR season
		IN([Spring],[Summer],[Fall],[Winter])
	) AS PVT
order by [YEAR]
------------------
--Pivot & Join
select * from 
(
  select Year(SalesDate) as [YEAR], 
(case 
      when DATEPART(Quarter, SalesDate)=1 then 'Spring'
      when DATEPART(Quarter, SalesDate)=2 then 'Summer'
      when DATEPART(Quarter, SalesDate)=3 then 'Fall'
	  when DATEPART(Quarter, SalesDate)=4 then 'Winter'
 end) as season,Quantity*UnitPrice as sm
from Sales
join SalesDetail on Sales.SalesID=SalesDetail.SalesID
) sl
PIVOT
	(sum (sm)
		FOR season
		IN([Spring],[Summer],[Fall],[Winter])
	) AS PVT
order by [YEAR]
--------------------------------














