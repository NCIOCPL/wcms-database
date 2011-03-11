IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[GetViewDate]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[GetViewDate]
GO
CREATE FUNCTION dbo.GetViewDate 
	(
	@ViewID uniqueidentifier
	)  
RETURNS datetime 
AS  

BEGIN 
	DECLARE @DisplayDateMode varchar(20),
		@PrimaryDate datetime,
		@ReleaseDate datetime, 
		@CreateDate datetime, 
		@UpdateDate datetime,
		@PostedDate datetime, 
		@ExpirationDate datetime

	SELECT @DisplayDateMode = LOWER( DisplayDateMode ), 
		@ReleaseDate = ReleaseDate, 
		@CreateDate  = CreateDate, 
		@UpdateDate  =  UpdateDate,
		@PostedDate = PostedDate,
		@ExpirationDate = ExpirationDate
	FROM		NCIView 
	WHERE	NCIViewID=@ViewID 


	IF @DisplayDateMode = 'none'
	BEGIN	
		SELECT @PrimaryDate = @ReleaseDate
	END
	ELSE IF @DisplayDateMode = 'both' 
             BEGIN
		SELECT @PrimaryDate = @ReleaseDate
	END	
	ELSE IF @DisplayDateMode = 'release' 
             BEGIN
		SELECT @PrimaryDate = @ReleaseDate
	END	
	ELSE IF @DisplayDateMode = 'posted' 
             BEGIN
		SELECT @PrimaryDate = @PostedDate
	END	
	ELSE  
             BEGIN
		SELECT @PrimaryDate = @ReleaseDate
	END

	RETURN @PrimaryDate
END
GO
