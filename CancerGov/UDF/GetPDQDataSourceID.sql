IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[GetPDQDataSourceID]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[GetPDQDataSourceID]
GO

CREATE FUNCTION [dbo].[GetPDQDataSourceID] ()  
RETURNS char(3)
WITH SCHEMABINDING
AS  

BEGIN 
	RETURN('PDQ') 
END


GO
