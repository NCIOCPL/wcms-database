IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[udf_TrimSpaceForMetaKeyword]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[udf_TrimSpaceForMetaKeyword]
GO

/**********************************************************************************

	Object's name:	udf_TrimSpaceForMetaKeyword
	Object's type:	Function
	Purpose:	To trim space for MetaKeyword
	Author:		2/04/2005	Lijia	For SCR1039

**********************************************************************************/

CREATE FUNCTION dbo.udf_TrimSpaceForMetaKeyword
	(
		@MetaKeyword	VARCHAR(255)
	)

RETURNS VARCHAR(255)

AS


BEGIN 

	WHILE (PATINDEX('% ,%', @MetaKeyword)>0)
	BEGIN
		SET	@MetaKeyword=replace(@MetaKeyword,' ,',',') 
	END

	WHILE (PATINDEX('%, %', @MetaKeyword)>0)
	BEGIN
		SET	@MetaKeyword=replace(@MetaKeyword,', ',',') 
	END

        return @MetaKeyword
END


GO
