IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DocumentManager_Document_Update]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[DocumentManager_Document_Update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].DocumentManager_Document_Update
	@DocumentID uniqueidentifier,
	@Title varchar(255),
	@ShortTitle varchar(50),
	@Description varchar(1500),
	@PrettyURL varchar(512) = null,
	@UpdateUserID varchar(50)
AS
BEGIN
	BEGIN TRY
		
		Update [dbo].[Document]
			set [Title] = @Title
			,[ShortTitle] =@ShortTitle
			,[Description] =@Description
			,[UpdateUserID] =@UpdateUserID
           ,[UpdateDate] = Getdate()
		Where [DocumentID] = @DocumentID

		if (@PrettyURL is not null and len(@PrettyURL) > 0)
		BEGIN
			Update dbo.DocumentPrettyURL
			Set  [PrettyURL] = @PrettyURL
			   ,[UpdateUserID] = @UpdateUserID
			   ,[UpdateDate] =Getdate()
			Where [DocumentID] = @DocumentID
		END

		return 0
	END TRY

	BEGIN CATCH
		declare @error varchar(4000)

		SET @error = ERROR_MESSAGE()
		PRINT @error
			RETURN 125005 
		
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[DocumentManager_Document_Update] TO [websiteuser_role]
GO
