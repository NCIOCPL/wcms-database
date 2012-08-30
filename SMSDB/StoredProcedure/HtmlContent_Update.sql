IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[HtmlContent_Update]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[HtmlContent_Update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Jun Meng
-- Create date: 05/02/2006
-- Description:	Update HTML content for an instance
-- =============================================
CREATE PROCEDURE [dbo].[HtmlContent_Update] 
	@HtmlContentID	UniqueIdentifier,
	@Title	varchar(255),
	@ImageHTML varchar(max),
	@UserID	varchar(50),
	@LastRowVersion timestamp output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Check the latest rowVersion
	-- If the record has been changed, return error
	DECLARE @CurrentRowVersion timestamp,
		@ContentID UniqueIdentifier

	SELECT @ContentID = HtmlContentID,
		@CurrentRowVersion = LastRowVersion
	FROM HtmlContent
	WHERE HtmlContentID = @HtmlContentID

	IF (@ContentID is NULL)
	BEGIN
		-- There is no such a record, insert it instead ????
		EXECUTE HtmlContent_Add @Title = @Title, @ImageHTML = @ImageHTML,
			@UserID = @UserID
	END
	ELSE
	BEGIN
		IF (@CurrentRowVersion = @LastRowVersion)
		BEGIN
			BEGIN TRANSACTION

			BEGIN TRY
			-- The record was not changed by other user
			UPDATE HtmlContent
			SET 
				ImageHtml = @ImageHTML,
				UpdateUserID = @UserID,
				UpdateDate = GetDate()
			WHERE HtmlContentID = @HtmlContentID
			
			-- Update Title in Object table
			DECLARE @rtnValue int
			EXEC @rtnValue = Core_Object_SetTitle
				@objectID = @HtmlContentID,
				@Title = @Title

			IF (@rtnValue = 0)
				EXEC @rtnValue = Core_Object_SetIsDirty
					@objectID = @HtmlContentID,
					@UpdateUserID = @UserID

			IF (@rtnValue >0)
			BEGIN
				-- Cannot update Title or set dirty
				ROLLBACK TRANSACTION
				RAISERROR(50003, 16, 1);
			END
			ELSE
			BEGIN
				COMMIT TRANSACTION

				-- Get the new row version
				SELECT @LastRowVersion = LastRowVersion
				FROM HtmlContent
				WHERE HtmlContentID = @HtmlContentID
			END			
			END TRY

			BEGIN CATCH
				-- Something wrong
				PRINT ERROR_MESSAGE()
				ROLLBACK TRANSACTION
				RAISERROR(50002, 16, 1);
			END CATCH
		END
		ELSE
		BEGIN
			-- The record has been changed by other user
			RAISERROR (50001, 16, 1);
			RETURN 50001
		END
	END
END

GO
GRANT EXECUTE ON [dbo].[HtmlContent_Update] TO [websiteuser_role]
GO
