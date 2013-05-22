IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetCacheDocument]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetCacheDocument]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.usp_GetCacheDocument
(
	@DocumentID	int,
	@Audience	varchar(255) = NULL,
	@Format		varchar(850) = NULL
)
AS
BEGIN

		SELECT 	TOP 1 
				*
		FROM 		CacheDocument WITH ( READUNCOMMITTED )
		WHERE	DocumentID = @DocumentID
			AND	Audience = @Audience
			AND  	[Format] = @Format

		UPDATE 	CacheDocument  
		SET 		Retrived = ISNULL( Retrived, 0 ) + 1,
				DateLastAccessed = GETDATE()  
		WHERE	DocumentID = @DocumentID
			AND	Audience = @Audience
			AND 	[Format] = @Format

/*
	-- Then Return Data
	IF @Format IS NOT NULL 
	BEGIN
		SELECT 	TOP 1 
				*
		FROM 		CacheDocument  WITH ( READUNCOMMITTED )
		WHERE	DocumentID = @DocumentID
			AND	Audience = @Audience
			AND 	[Format] = @Format


		UPDATE 	CacheDocument  
		SET 		Retrived = ISNULL( Retrived, 0 ) + 1,
				DateLastAccessed = GETDATE()  
		WHERE	DocumentID = @DocumentID
			AND	Audience = @Audience
			AND 	[Format] = @Format
		

	END
	ELSE BEGIN
		SELECT 	TOP 1 
				*
		FROM 		CacheDocument WITH ( READUNCOMMITTED )
		WHERE	DocumentID = @DocumentID
			AND	Audience = @Audience

		UPDATE 	CacheDocument  
		SET 		Retrived = ISNULL( Retrived, 0 ) + 1,
				DateLastAccessed = GETDATE()  
		WHERE	DocumentID = @DocumentID
			AND	Audience = @Audience
	END

*/

END

GO
GRANT EXECUTE ON [dbo].[usp_GetCacheDocument] TO [websiteuser_role]
GO
