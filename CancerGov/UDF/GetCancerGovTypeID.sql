IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[GetCancerGovTypeID]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[GetCancerGovTypeID]
GO



/*
Function translate PDQ TypeID in to  CancerGov TypeID bace on the data in database.
*/
CREATE FUNCTION dbo.GetCancerGovTypeID( @PDQTypeID int )
RETURNS uniqueidentifier 
WITH SCHEMABINDING
AS  

BEGIN 
	RETURN(
		
		SELECT ISNULL((SELECT 	TypeID 
				FROM 		dbo.[Type]
				 WHERE 	DataSource = dbo.GetPDQDataSourceID()
						AND SourceID = @PDQTypeID),
			dbo.GetCancerGovBasicTypeID()) AS  TypeID 
	) 
END








GO
