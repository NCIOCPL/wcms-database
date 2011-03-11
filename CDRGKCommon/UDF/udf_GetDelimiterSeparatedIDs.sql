IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[udf_GetDelimiterSeparatedIDs]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[udf_GetDelimiterSeparatedIDs]
GO

/*************************************************************************************************************
*	NCI - National Cancer Institute
*	
*	Purpose:	
*
*	Objects Used:
*
*	Change History:
*	12/16/2002 	Alex Pidlisnyy	Script Created
*	7/7/2003 	Alex Pidlisnyy	Reviewed and updated
*	7/14/2003 	Alex Pidlisnyy	SCR#51
*
*************************************************************************************************************/

CREATE FUNCTION dbo.udf_GetDelimiterSeparatedIDs
	(
	@DelimiterSeparatedIDs varchar(8000),
	@Delimiter char(1) = ','
	)
RETURNS @ResultTable TABLE
	(
	ObjectID     varchar(150)
	)
AS

BEGIN
	-- select * from dbo.udf_GetDelimiterSeparatedIDs( 'a;b;c;d;e;f', ';')
	DECLARE @DelimiterPosition  int,
		@tmpStr varchar(8000) ,
		@tmpStrLen int
	
	SELECT 	@tmpStrLen = ISNULL( LEN( @DelimiterSeparatedIDs ), 0),
		@tmpStr = @DelimiterSeparatedIDs

	WHILE  (@tmpStrLen > 0 )
	BEGIN
		SELECT @DelimiterPosition = CHARINDEX ( @Delimiter, @tmpStr) 

		IF (@DelimiterPosition = 0)  
		BEGIN
			INSERT INTO @ResultTable
			SELECT LTRIM( @tmpStr )
			BREAK
		END

		INSERT INTO @ResultTable
		SELECT LTRIM(LEFT( @tmpStr , @DelimiterPosition - 1) )

		--SELECT @tmpStr = RIGHT ( @tmpStr , (LEN( @tmpStr ) - @DelimiterPosition) )
		SELECT @tmpStr = RIGHT ( @tmpStr , ( @tmpStrLen - @DelimiterPosition) )

		SELECT @tmpStrLen = ISNULL( LEN(@tmpStr) , 0)
	END

	RETURN 
END

GO
