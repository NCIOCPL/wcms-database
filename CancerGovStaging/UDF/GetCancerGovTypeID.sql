IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[GetCancerGovTypeID]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[GetCancerGovTypeID]
GO
CREATE FUNCTION dbo.GetCancerGovTypeID( @PDQTypeID int )
RETURNS uniqueidentifier 
AS  

BEGIN 
	RETURN(
		
		SELECT CancerGov.dbo.GetCancerGovTypeID( @PDQTypeID )
	) 
END




GO
