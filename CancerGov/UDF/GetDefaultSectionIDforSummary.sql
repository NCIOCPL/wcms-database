IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[GetDefaultSectionIDforSummary]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[GetDefaultSectionIDforSummary]
GO

/*
Function provide defsult SectionID for summury.
*/
CREATE FUNCTION dbo.GetDefaultSectionIDforSummary()
RETURNS uniqueidentifier 
AS  

BEGIN 
	RETURN(
		SELECT 	NCISectionID
		FROM 	NCISection
		WHERE  	[Name] = 'cancerinfo'
	)
END








GO
