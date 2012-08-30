IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DocumentManager_DocumentPrettyURL_Exist]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[DocumentManager_DocumentPrettyURL_Exist]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].DocumentManager_DocumentPrettyURL_Exist
	@DocumentID uniqueidentifier = null,
	@PrettyURL	varchar(512)
AS
BEGIN
	BEGIN TRY

		if (@DocumentID is null)
		BEGIN
			if (exists (select 1 from dbo.PrettyUrl where PrettyURL = @PrettyURL) or 
				exists (select 1 from dbo.DocumentPrettyURL where PrettyURL = @PrettyURL))
			BEGIN
				select 1
			END
			else
			BEGIN
				select 0
			END
		END
		ELSE
		BEGIN
			--Todo: this assumes that only 1 prettyurl for document. Otherwise, we need to 
			-- check documentPrettyURLID
			if (exists (select 1 from dbo.PrettyUrl where PrettyURL = @PrettyURL) or 
				exists (select 1 from dbo.DocumentPrettyURL 
						where (DocumentID != @DocumentID and PrettyURL = @PrettyURL)))
			BEGIN
				select 1
			END
			else
			BEGIN
				select 0
			END
		END

	END TRY

	BEGIN CATCH
		
			RETURN 127001  
		
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[DocumentManager_DocumentPrettyURL_Exist] TO [websiteuser_role]
GO
