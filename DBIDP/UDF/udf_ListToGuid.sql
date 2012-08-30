IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[udf_ListToGuid]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[udf_ListToGuid]
GO


CREATE FUNCTION udf_ListToGuid 
	(	@List varchar(max),
         @Delimiter varchar(2)
         )
RETURNS @TempList TABLE 
	(item uniqueidentifier)
AS

BEGIN

	DECLARE @OrderID varchar(36), @Pos int

	SET @List = LTRIM(RTRIM(@List))+ @Delimiter
	SET @Pos = CHARINDEX(',', @List, 1)

	IF REPLACE(@List, @Delimiter, '') <> ''
	BEGIN
		WHILE @Pos > 0
		BEGIN
			SET @OrderID = LTRIM(RTRIM(LEFT(@List, @Pos - 1)))
			IF @OrderID <> ''
			BEGIN
				INSERT INTO @TempList (item) VALUES (CAST(@OrderID AS uniqueidentifier)) --Use Appropriate conversion
			END
			SET @List = RIGHT(@List, LEN(@List) - @Pos)
			SET @Pos = CHARINDEX(@Delimiter, @List, 1)

		END
	END	

	RETURN
		
END



GO
