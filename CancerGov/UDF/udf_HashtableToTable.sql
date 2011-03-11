IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[udf_HashtableToTable]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[udf_HashtableToTable]
GO
Create Function dbo.udf_HashtableToTable 
/**************************************************************************************************
* Name		: udf_HashtableToTable
* Purpose	: udf_HashtableToTable
* Author	: BP
* Date		: 01/25/2007
* Returns	: Table
* Usage		: Select * from dbo.udf_HashtableToTable ('1|2;A|B', '|', ';')
* Changes	: 
**************************************************************************************************/
( 
	@List varchar(4096), --4k
	@KeyValDelimiter char(1),
	@HashTableItemDelimiter char(1)
)
returns @templist table (
	[key] varchar(500),
	value varchar(500)
)
AS

BEGIN
-- declaration
	DECLARE @Item varchar(1000), 
			@pos int,
			@Key varchar(500),
			@Value varchar(500),
			@valPos int

--initialization
	SET @list = ltrim(rtrim(@List))+ @HashTableItemDelimiter
	SET @pos = charindex(@HashTableItemDelimiter, @List, 1)
--execute
	if replace(@List, @HashTableItemDelimiter, '') <> ''
	begin
		while @pos > 0
		begin
			set @Item = ltrim(rtrim(left(@List, @pos - 1)))
			if @Item <> ''
			begin
				--Now that we have a key value pair, we kind of need to do this
				--all over again
				SET @valPos = charindex(@KeyValDelimiter, @Item, 1)
				IF (@valPos <> 0)
				BEGIN
					--There is no value
					 SET @Key = ltrim(rtrim(left(@Item, @valPos - 1)))
					 SET @Value = ltrim(rtrim(right(@Item, len(@Item) - @valPos)))
				END
				ELSE
				BEGIN
					SET @Key = ltrim(rtrim(@Item))
					SET @Value = null
				END
				--insert into @templist (item) values (@item)
				INSERT INTO @templist
				([Key], Value)
				VALUES
				(@Key, @Value)
			end
			set @list = right(@List, len(@List) - @pos)
			set @pos = charindex(@HashTableItemDelimiter, @List, 1)
		end
	end	
	return
end

GO
