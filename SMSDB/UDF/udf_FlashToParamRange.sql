IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[udf_FlashToParamRange]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[udf_FlashToParamRange]
GO

CREATE Function [dbo].[udf_FlashToParamRange] 
/**************************************************************************************************
* Name		: udf_FlashToParamRange
* Purpose	: udf_FlashToParamRange
* Author	: Sandar
* Date		: 11/07/2006
* Returns	: 0/1 bit
* Usage		: Select * from dbo.udf_FlashToParamRange ('key,value|key,value', ',', '|' )
* Changes	: 
**************************************************************************************************/
( 
	@list varchar(4096) --4k
	, @delimiter varchar(2)  = ',' -- key value delimiter
	, @delimiter2 varchar(2) = '|' -- item delimiter
)
returns @temp table ( ParamName varchar(100), ParamValue varchar(100))
as

begin
-- declaration
	declare @ParamName varchar(100),
		@ParamValue varchar(100),
        @pos int, 
		@pos2 int,
        @item varchar(4096)
       
		
		
--initialization
	set @list = ltrim(rtrim(@list))+ @delimiter2
	set @pos = charindex(@delimiter2, @list, 1)
--execute
	--if replace(@list, @delimiter, '') <> ''
	begin
		while @pos > 0
		begin
			set @item = ltrim(rtrim(left(@list, @pos - 1)))
			if @item <> ''
			begin			
				set @pos2 = charindex(@delimiter, @item, 1)
				if(@pos2 > 0)
				begin
					set @ParamName = ltrim(rtrim(left(@item, @pos2 - 1)))
					set @ParamValue = right(@item, len(@item) - @pos2)
					insert into @temp (ParamName, ParamValue) values (@ParamName, @ParamValue)
				end
			end
			set @list = right(@list, len(@list) - @pos)
			set @pos = charindex(@delimiter2, @list, 1)
		end
	end	
	return
end


GO
