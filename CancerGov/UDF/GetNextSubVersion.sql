IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[GetNextSubVersion]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[GetNextSubVersion]
GO


CREATE FUNCTION [dbo].[GetNextSubVersion] 
	(
	@CurrentVersion varchar(50)
	)  
RETURNS varchar(50)
AS  

BEGIN 

	DECLARE @NewVersion varchar(50),
		@SubVersionPosition int
	SELECT @CurrentVersion = ISNULL( @CurrentVersion, '0')
	
	SELECT  @SubVersionPosition = PATINDEX ( '%.%' , REVERSE ( @CurrentVersion ) ) 
	
	IF @SubVersionPosition <> 0 
	BEGIN
		SELECT @NewVersion = LEFT( @CurrentVersion, LEN(@CurrentVersion)-@SubVersionPosition+1 ) + convert(varchar,convert(int, RIGHT(@CurrentVersion, @SubVersionPosition - 1 ) ) + 1)
	END
	ELSE BEGIN
		SELECT @NewVersion = ISNULL(NULLIF(LTRIM(RTRIM(@CurrentVersion)),''),'1') + '.1' 
	END 
	
	RETURN (@NewVersion)
END




GO
