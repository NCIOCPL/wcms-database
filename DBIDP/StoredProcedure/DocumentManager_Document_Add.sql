IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DocumentManager_Document_Add]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[DocumentManager_Document_Add]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].DocumentManager_Document_Add
	@DocumentID uniqueidentifier,
	@DocumentLibraryID uniqueidentifier,
	@FileName varchar(255),
	@Title varchar(255),
	@ShortTitle varchar(50),
	@Description varchar(1500),
	@DocumentTypeID int,
	@OwnerID  uniqueidentifier,
	@PrettyURL varchar(512) = null,
	@UpdateUserID varchar(50)
AS
BEGIN
	BEGIN TRY
		
		INSERT INTO [dbo].[Document]
           ([DocumentID]
		   ,[DocumentLibraryID]
           ,[FileName]
           ,[Title]
		   ,[ShortTitle]
           ,[Description]
           ,[DocumentTypeID]
           ,[OwnerID]
           ,[UpdateUserID]
           ,[CreateUserID]
           ,[CreateDate]
           ,[UpdateDate])
     VALUES
		(@DocumentID, @DocumentLibraryID, @FileName, @Title, @ShortTitle, @Description, @DocumentTypeID, @OwnerID, 
		@UpdateUserID, @UpdateUserID, Getdate(), Getdate() )

		if (@PrettyURL is null or len(@PrettyURL)=0)
		BEGIN
			select @PrettyURL = '/download/'+ @FileName--SUBSTRING(@Name,1, len(@Name) - PATINDEX('.'))
		END

		Insert into dbo.DocumentPrettyURL
           ([DocumentPrettyURLID]
           ,[DocumentID]
           ,[PrettyURL]
           ,[RealURL]
           ,[IsPrimary]
           ,[CreateUserID]
           ,[CreateDate]
           ,[UpdateUserID]
           ,[UpdateDate])
     VALUES
		(newid(), @DocumentID,  @PrettyURL,  '/download.ashx?DocumentID=' + convert(varchar(36), @DocumentID), 1,
		@UpdateUserID, Getdate(), @UpdateUserID, Getdate() )


		return 0
	END TRY

	BEGIN CATCH
		declare @error varchar(4000)

		SET @error = ERROR_MESSAGE()
		PRINT @error
			RETURN 125003 
		
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[DocumentManager_Document_Add] TO [websiteuser_role]
GO
