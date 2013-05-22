IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[udf_GetStateFullName]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[udf_GetStateFullName]
GO




/*	NCI - National Cancer Institute
*	
*	File Name:	
*	udf_GetProtocolSearch.sql
*
*	Objects Used:
*
*	Change History:
*	11/4/2003 	Alex Pidlisnyy	Script Created
*
*	To Do:
*
*/
CREATE FUNCTION dbo.udf_GetStateFullName
(
	@StateAbreviation varchar(8000)
)  
RETURNS varchar(8000)
AS

BEGIN 
	-- declare variables
	declare @FullName varchar(100),
		@tmpStr varchar(8000),
		@tmpStr1 varchar(2)

	-- find StateFullName	
	set @tmpStr1 = ''
	set @tmpStr = ''
	
	DECLARE StateFullName_cursor CURSOR FOR 
	select 	FullName 
	from 	dbo.udf_GetComaSeparatedIDs( @StateAbreviation ) AS S  
		INNER JOIN dbo.PoliticalSubUnit AS PSU with (readuncommitted) 
		ON PSU.ShortName = S.ObjectID
	
	OPEN StateFullName_cursor
	FETCH NEXT FROM StateFullName_cursor INTO @FullName
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
	
		set @tmpStr = @tmpStr + @tmpStr1 + @FullName
		SET @tmpStr1 = ', ' 
	
		FETCH NEXT FROM StateFullName_cursor INTO @FullName
	END
	
	CLOSE StateFullName_cursor
	DEALLOCATE StateFullName_cursor
	
	return ( @tmpStr )
END




GO
