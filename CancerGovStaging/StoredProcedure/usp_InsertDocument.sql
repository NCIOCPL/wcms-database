IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_InsertDocument]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_InsertDocument]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** 	Object:  Stored Procedure dbo.usp_InsertLink  
	Purpose: This script can be used for  inserting viewobjects.	Script Date: 4/30/2002 11:43:49 pM ******/

CREATE PROCEDURE dbo.usp_InsertDocument
(
	@DocumentID		uniqueidentifier,
	@Title			varchar(255),
	@ShortTitle		varchar(64),
	@Description		varchar(2500),
	@DataType		char(10),
	@DataSize		int,
	@TOC			text,
	@Data			text,
	@ExpirationDate	DateTime,
	@ReleaseDate		DateTime,
	@PostedDate		DateTime,
	@DisplayDateMode	varchar(20),
	@UpdateUserID		VarChar(40)
)
AS
BEGIN
	SET NOCOUNT ON;
		
	/*
	** Add a viewobject 
	*/	
	INSERT INTO Document 
	( DocumentID, Title, ShortTitle, [Description], DataType, DataSize, TOC, Data, ExpirationDate, ReleaseDate, UpdateUSerID)
	VALUES 
	(@DocumentID, @Title, @ShortTitle, @Description, @DataType, @DataSize, @TOC, @Data, @ExpirationDate, @ReleaseDate, @UpdateUserId)
	IF (@@ERROR <> 0)
	BEGIN
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END


	SET NOCOUNT OFF
	RETURN 0 

END

GO
GRANT EXECUTE ON [dbo].[usp_InsertDocument] TO [webadminuser_role]
GO
