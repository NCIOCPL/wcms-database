IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[udf_GetComaSeparatedExclusionIDs]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[udf_GetComaSeparatedExclusionIDs]
GO
CREATE FUNCTION dbo.udf_GetComaSeparatedExclusionIDs
	(
	@ComaSeparatedID varchar(8000)
	)
RETURNS @ResultTable TABLE
	(
	ObjectID     varchar(40)
	)
AS

BEGIN
	INSERT INTO @ResultTable 
		SELECT SUBSTRING(ObjectID, 2, LEN(ObjectID) - 1)
		FROM dbo.udf_GetComaSeparatedIDs(@ComaSeparatedID)
		WHERE LEFT(ObjectID, 1) = '!' AND SUBSTRING(ObjectID, 2, LEN(ObjectID) - 1) NOT IN (SELECT ObjectID FROM dbo.udf_GetComaSeparatedIDs(@ComaSeparatedID) WHERE LEFT(ObjectID, 1) <> '!')
		
	RETURN 
END








GO
