IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_CreateOrUpdateHeader]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_CreateOrUpdateHeader]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** 	Object:  Stored Procedure dbo.usp_InsertNewsletter
	Owner:	Jay He
	Script Date: 3/19/2003 14:43:49 pM 
******/

CREATE PROCEDURE dbo.usp_CreateOrUpdateHeader
(
 	@HeaderID		UniqueIdentifier,
	@Name			varchar(50),
	@Type			varchar(50),
	@Data			text,
	@ContentType		varchar(50),
	@UpdateUserID		varchar(50)						
)
AS
BEGIN
	


	if (not exists (select headerid from header where headerID = @HeaderID))
	BEGIN
		insert into Header 
		(HeaderID, [Name], Type, Data, ContentType, UpdateUserID, IsApproved) 
		values 
		(@HeaderID, @Name, @Type, @Data, @ContentType, @UpdateUserID, 0)
		IF (@@ERROR <> 0)
		BEGIN
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
	END
	ELSE
	BEGIN
		Update  Header 
		set 	Name	=	@Name, 
			Data	=	@Data, 
			ContentType	=@ContentType,
			IsApproved	=0,
			UpdateDate	= getdate(),  
			UpdateUserID  	=@UpdateUserID  
		where   HeaderID = @HeaderID
		IF (@@ERROR <> 0)
		BEGIN
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
	END

	RETURN 0 

END
GO
GRANT EXECUTE ON [dbo].[usp_CreateOrUpdateHeader] TO [webadminuser_role]
GO
