IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[GetCancerGovStateID]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[GetCancerGovStateID]
GO


/*
Function translate PDQ StateID in to  CancerGov StateID bace on the data in database.
*/
CREATE FUNCTION dbo.GetCancerGovStateID( @PDQStateID int )
RETURNS uniqueidentifier 
WITH SCHEMABINDING
AS  

BEGIN 
	RETURN(
		SELECT 	StateID
		FROM 		dbo.State
		 WHERE 	DataSource = dbo.GetPDQDataSourceID()
				AND SourceID = @PDQStateID
	)
END



GO
