IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[GetNextVersion]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[GetNextVersion]
GO


CREATE FUNCTION [dbo].[GetNextVersion] 
	(
	@CurrentVersion varchar(50)
	)  
RETURNS varchar(50)
AS  

BEGIN 

	DECLARE @NewVersion varchar(50),
		@SubVersionPosition int
	SELECT @CurrentVersion = ISNULL( @CurrentVersion, '0')
	
	SELECT @SubVersionPosition = PATINDEX ( '%.%' , @CurrentVersion ) 
	
	IF @SubVersionPosition <> 0 
	BEGIN
		SELECT 	@NewVersion = convert(int, LEFT( @CurrentVersion, @SubVersionPosition - 1)) + 1
	END
	ELSE BEGIN
		SELECT 	@NewVersion = ISNULL(NULLIF(LTRIM(RTRIM(@CurrentVersion)),''),'0') + 1
	END 
	
	RETURN (@NewVersion)
END




GO
