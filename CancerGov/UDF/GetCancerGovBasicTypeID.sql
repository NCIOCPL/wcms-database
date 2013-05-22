IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[GetCancerGovBasicTypeID]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[GetCancerGovBasicTypeID]
GO

CREATE FUNCTION dbo.GetCancerGovBasicTypeID()
RETURNS uniqueidentifier 
WITH SCHEMABINDING
AS  

BEGIN 
	RETURN(
		SELECT  DISTINCT TypeID 
		FROM 	dbo.Type 
		WHERE Type.Name = 'CANCERGOV BASIC NULL TYPE'
			AND Type.Scope = 'BASIC'			
	)
END




GO
