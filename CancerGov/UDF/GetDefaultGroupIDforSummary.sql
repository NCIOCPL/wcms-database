IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[GetDefaultGroupIDforSummary]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[GetDefaultGroupIDforSummary]
GO

/*
Function provide default GroupID for summary.
*/
CREATE FUNCTION dbo.GetDefaultGroupIDforSummary()
RETURNS int
AS  

BEGIN 
	RETURN( 3 )
END








GO
