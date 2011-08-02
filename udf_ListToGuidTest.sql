IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].udf_ListToGuidTest') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT')) 
DROP FUNCTION [dbo].udf_ListToGuidTest
GO


CREATE FUNCTION udf_ListToGuidTest 
	(	@List varchar(max),
         @Delimiter varchar(2)
         )
RETURNS @TempList TABLE 
	(item uniqueidentifier)
AS
BEGIN
	declare @i bigint
	select @i = 1
	
	while @i <= len(@list) -35
	BEGIN
		insert into @tempList
		select substring(@list, @i, 36)
		select @i = @i + 36+ 1
	END
	
	
	RETURN
		
END


