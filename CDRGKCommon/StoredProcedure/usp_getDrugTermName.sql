  

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_getDrugTermName]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetDrugTermName]
GO
CREATE PROCEDURE dbo.usp_getDrugTermName  
 (  
 @criteria nvarchar(2000) ,  
 @TopN int 
  )  
AS  
BEGIN  
set nocount on
    
select top (@topN) termid, preferredName
from
(
  SELECT TermID,  
      PreferredName
  FROM vwTermDrugDictionary  
  WHERE PreferredName LIKE @criteria
  UNION   
  SELECT ton.TermID,  
    ton.OtherName as preferredName
  FROM vwTermDrugDictionary t  
   INNER JOIN TermOtherName ton on t.TermID = ton.TermID  
  WHERE ton.OtherName LIKE @criteria
) a
order by CAST(LOWER(preferredName) AS BINARY)
   
 
 
END  
GO
Grant execute on dbo.usp_getDrugTermName to websiteuser_role  