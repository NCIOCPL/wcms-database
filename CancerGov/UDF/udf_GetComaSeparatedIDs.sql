IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[udf_GetComaSeparatedIDs]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[udf_GetComaSeparatedIDs]
GO
CREATE FUNCTION dbo.udf_GetComaSeparatedIDs
	(
	@ComaSeparatedID varchar(8000)
	)
RETURNS @ResultTable TABLE
	(
	ObjectID     varchar(40)
	)
AS

BEGIN
	DECLARE @delimeterPosition  int,
		@tmpStr varchar(8000) ,
		@tmpStrLen int
	
	SELECT @tmpStrLen = LEN(@ComaSeparatedID),
		@tmpStr = @ComaSeparatedID
	
	SELECT @tmpStrLen = ISNULL(@tmpStrLen, 0)

	WHILE  (@tmpStrLen > 0 )
	BEGIN
		SELECT @delimeterPosition = CHARINDEX ( ',', @tmpStr) 

		IF (@delimeterPosition = 0)  
		BEGIN
			INSERT INTO @ResultTable
			SELECT @tmpStr 
			BREAK
		END

		INSERT INTO @ResultTable
		SELECT LTRIM(LEFT( @tmpStr , @delimeterPosition - 1) )

		SELECT @tmpStr = RIGHT ( @tmpStr , (LEN( @tmpStr ) - @delimeterPosition) )

		SELECT @tmpStrLen = LEN(@tmpStr)
		SELECT @tmpStrLen = ISNULL(@tmpStrLen, 0)
	END

	RETURN 
END













GO
