IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_AddRequestCommentExternalID]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_AddRequestCommentExternalID]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].usp_AddRequestCommentExternalID
	@ExternalRequestID	varchar(50),
	@Source			varchar(50),				-- Source of the request (e.g. 'CDR')
	@Comment		varchar(8000),
	@Status_Code	int OUTPUT,
	@Status_Text	varchar(255) OUTPUT
AS
BEGIN
	BEGIN TRY
	set nocount ON

		SET @Status_Code = 0
		SET @Status_Text = 'OK'

		-- Look up the RequestID
		DECLARE @RequestID int

		select @RequestID = RequestID from dbo.Request
				where ExternalRequestID = @ExternalRequestID and Source = @Source

		-- Abort if record doesn't exist
		IF( @RequestID is null OR @@ROWCOUNT <> 1)
		BEGIN
			SET @Status_Code = -1
			RAISERROR('usp_AddRequestCommentExternalID: No record found for @ExternalRequestID = %s.',
					11, 1, @ExternalRequestID)
		END

		-- Record the comment
		insert into dbo.RequestComment
				(RequestID, Comment, CommentDate)
		values	(@RequestID, @Comment, GETDATE() )


		RETURN 0  --Succesful return 0
	END TRY

	BEGIN CATCH
		SET @Status_Text = ERROR_MESSAGE()
		RETURN 100101  --Error code
	END CATCH 
END


GO
GRANT EXECUTE ON [dbo].[usp_AddRequestCommentExternalID] TO [gatekeeper_role]
GO
