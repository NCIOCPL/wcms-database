IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[udf_ListToBigIntTable]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[udf_ListToBigIntTable]
GO


CREATE FUNCTION udf_ListToBigIntTable 
	(@List varchar(max),
         @Delimiter varchar(2)
         )
RETURNS @TempList TABLE 
	(item BigInt)
AS

BEGIN

	DECLARE @OrderID varchar(500), @Pos int

	SET @List = LTRIM(RTRIM(@List))+ @Delimiter
	SET @Pos = CHARINDEX(',', @List, 1)

	IF REPLACE(@List, @Delimiter, '') <> ''
	BEGIN
		WHILE @Pos > 0
		BEGIN
			SET @OrderID = LTRIM(RTRIM(LEFT(@List, @Pos - 1)))
			IF @OrderID <> ''
			BEGIN
				INSERT INTO @TempList (item) VALUES (CAST(@OrderID AS bigint)) --Use Appropriate conversion
			END
			SET @List = RIGHT(@List, LEN(@List) - @Pos)
			SET @Pos = CHARINDEX(@Delimiter, @List, 1)

		END
	END	

	RETURN
		
END



GO
