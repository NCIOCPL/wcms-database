IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[GetGLOSSARYDataSourceID]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[GetGLOSSARYDataSourceID]
GO

CREATE FUNCTION [dbo].[GetGLOSSARYDataSourceID] ()  
RETURNS char(3)
WITH SCHEMABINDING
AS  

BEGIN 
	RETURN('GLOSSARYXML') 
END



GO
