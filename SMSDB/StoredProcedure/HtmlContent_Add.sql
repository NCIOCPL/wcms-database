IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[HtmlContent_Add]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[HtmlContent_Add]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Jun Meng
-- Create date: 5/2/2006
-- Description:	Add HTML content
-- =============================================
CREATE PROCEDURE [dbo].[HtmlContent_Add]
	@HtmlContentID	UniqueIdentifier,
	@Title	varchar(255),
	@ImageHTML varchar(max),
	@UserID	varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- To check if a record already exists
	DECLARE @currentID UniqueIdentifier
	SELECT @currentID = HtmlContentID
	FROM HtmlContent
	WHERE HtmlContentID = @HtmlContentID

	-- Insert the record
	IF (@currentID is NULL)
	BEGIN
		BEGIN TRANSACTION

		BEGIN TRY
		-- Insert html content first
		INSERT INTO HtmlContent (HtmlContentID, ImageHTML, 
			CreateUserID, CreateDate)
		VALUES (@HtmlContentID, @ImageHTML, @UserID, GetDate())

		-- Set Title in Object table
		DECLARE @rtnValue int
		EXEC @rtnValue = Core_Object_SetTitle
			@objectID = @HtmlContentID,
			@Title = @Title

		IF (@rtnValue >0)
		BEGIN
			-- Cannot set Title
			ROLLBACK TRANSACTION
			RAISERROR(50003, 16, 1)
		END
		ELSE
			COMMIT TRANSACTION
		END TRY

		BEGIN CATCH
			-- Something wrong
			PRINT ERROR_MESSAGE()
			ROLLBACK TRANSACTION
			RAISERROR (50002, 16, 1)
		END CATCH
	END
	ELSE -- A record alread exists
	BEGIN
		RAISERROR (50001, 16, 1)
		RETURN 50001
	END
END

GO
GRANT EXECUTE ON [dbo].[HtmlContent_Add] TO [websiteuser_role]
GO
