IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[udf_StringToGVDictionary]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[udf_StringToGVDictionary]
GO
Create Function dbo.udf_StringToGVDictionary 
/**************************************************************************************************
* Name		: udf_StringToGVDictionary
* Purpose	: Converts a string to key(guid) value(varchar1000) pair(s)
* Author	: SRamaiah
* Date		: 09/28/2006
* Returns	: Table - Key(Guid), Value(VC 1000)) Pair(s)
* Usage		: Select * from dbo.udf_StringToGVDictionary (
			  '5C2A1B4F-6C34-484D-802E-0FFECCB7603C,65;F40798AC-87C3-4359-8F49-CF52873A5F14,66', ';', ',' )
* Changes	: 
**************************************************************************************************/
( 
	@list varchar(Max)
	, @rowDelimiter varchar(2)  = ',' -- row delimiter
	, @columnDelimiter varchar(2) = '|' -- column delimiter
)
returns @temp table ([key] uniqueidentifier, [value] varchar(1000))
as

begin
-- declaration
	declare @key uniqueidentifier,
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
