IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_InsertCacheDocument]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_InsertCacheDocument]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE dbo.usp_InsertCacheDocument
(
	@DocumentID	int,
	@Audience	varchar(255) = NULL,
	@Format		varchar(850) = NULL,
	@DocumentHTML	ntext	
)

AS

INSERT INTO	CacheDocument
		(
			DocumentID, 
			Audience, 
			[Format], 
			DateCached, 
			DocumentHTML
		)
VALUES	
		(
			@DocumentID,
			@Audience,
			@Format, 
			getDate(),
			@DocumentHTML
		)

GO
GRANT EXECUTE ON [dbo].[usp_InsertCacheDocument] TO [websiteuser_role]
GO
