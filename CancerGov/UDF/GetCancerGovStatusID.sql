IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[GetCancerGovStatusID]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[GetCancerGovStatusID]
GO

/*
Function translate PDQ StausID in to  CancerGov StatusID bace on the data in database.
*/
CREATE FUNCTION dbo.GetCancerGovStatusID( @PDQStatusID int )
RETURNS uniqueidentifier 
WITH SCHEMABINDING
AS  

BEGIN 
	RETURN(
		SELECT 	StatusID 
		FROM 		dbo.Status
		 WHERE 	DataSource = dbo.GetPDQDataSourceID()
				AND SourceID = @PDQStatusID
	)
END





GO
