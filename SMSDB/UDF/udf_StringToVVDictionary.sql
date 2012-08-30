IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[udf_StringToVVDictionary]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[udf_StringToVVDictionary]
GO
Create Function dbo.udf_StringToVVDictionary 
/**************************************************************************************************
* Name		: udf_StringToVVDictionary
* Purpose	: Converts string to key value pair(s)
* Author	: SRamaiah
* Date		: 09/28/2006
* Returns	: Table - Key(VC 1000), Value(VC 1000)) Pair(s)
* Usage		: Select * from dbo.udf_StringToVVDictionary ('a,65;b,66', ';', ',' )
* Changes	: 
**************************************************************************************************/
( 
	@list varchar(Max) --4k
	, @rowDelimiter varchar(2)  = ';' -- row delimiter
	, @columnDelimiter varchar(2) = ',' -- column delimiter
)
returns @temp table ([key] varchar(1000), [value] varchar(1000))
as

begin
-- declaration
	declare @key varchar(1000),
		@value varchar(1000),
		@posRow int,	--row position
		@posCol int,	--col position
		@item varchar(64)
		
--initialization
	set @list = ltrim(rtrim(@list))+ @rowDelimiter
	set @posRow = charindex(@rowDelimiter, @list, 1)
--execute
	if replace(@list, @rowDelimiter, '') <> ''
	begin
		while @posRow > 0
		begin
			set @item = ltrim(rtrim(left(@list, @posRow - 1)))
			if @item <> ''
			begin			
				set @posCol = charindex(@columnDelimiter, @item, 1)
				if(@posCol > 0)
				begin
					set @key = ltrim(rtrim(left(@item, @posCol - 1)))
					set @value = right(@item, len(@item) - @posCol)
					insert into @temp ([key], [value]) values (@key, @value)
				end
			end
			set @list = right(@list, len(@list) - @posRow)
			set @posRow = charindex(@rowDelimiter, @list, 1)
		end
	end	
	return
end

GO
