IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[udf_ListToStrings]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[udf_ListToStrings]
GO


CREATE FUNCTION [udf_ListToStrings] 
	(@List varchar(max),
         @Delimiter varchar(2)
         )
RETURNS @TempList TABLE 
	(item varchar(50))
AS

BEGIN

	DECLARE @OrderID varchar(50), @Pos int

	SET @List = LTRIM(RTRIM(@List))+ @Delimiter
	SET @Pos = CHARINDEX(',', @List, 1)

	IF REPLACE(@List, @Delimiter, '') <> ''
	BEGIN
		WHILE @Pos > 0
		BEGIN
			SET @OrderID = LTRIM(RTRIM(LEFT(@List, @Pos - 1)))
			IF @OrderID <> ''
			BEGIN
				INSERT INTO @TempList (item) VALUES (CAST(@OrderID AS varchar(50))) --Use Appropriate conversion
			END
			SET @List = RIGHT(@List, LEN(@List) - @Pos)
			SET @Pos = CHARINDEX(@Delimiter, @List, 1)

		END
	END	

	RETURN
		
END



GO
