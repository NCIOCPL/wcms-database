IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_UpdateExternalObject]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_UpdateExternalObject]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** 	Object:  Stored Procedure dbo.usp_UpdateTopicSearch    
	Owner:	Jay He
	Script Date: 7/16/2003 14:43:49 pM 
******/

CREATE PROCEDURE dbo.usp_UpdateExternalObject
(
	@ObjectID		UniqueIdentifier,
	@Title			varchar(255),
	@Path			varchar(500),
	@Format		char(15),
	@Description		varchar(2000),
	@Text			text,
	@UpdateUserID		varchar(40)
)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRAN Tran_AddEForm

	if (len(@Path) >0)
	BEGIN 
		Update ExternalObject 
		set  	Title	= @Title, 
			Path	= @Path,
			[Format]	= @Format,
			[Description] =@Description,
			[Text] =@Text,
			updateUserID= @UpdateUserID, 
			UpdateDate=getdate()
		where ExternalobjectID= @ObjectID
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_AddEForm
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
	END
	ELSE
	BEGIN 
		Update ExternalObject 
		set  	Title	= @Title, 
			[Format]	= @Format,
			[Description] =@Description,
			[Text] =@Text,
			updateUserID= @UpdateUserID, 
			UpdateDate=getdate()
		where ExternalobjectID= @ObjectID
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_AddEForm
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
	END


	Update NCIView
	Set Status ='EDIT'
	where nciviewid =(select nciviewid from viewobjects where objectid =@ObjectID)
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_AddEForm
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END

	COMMIT TRAN Tran_AddEForm
	SET NOCOUNT OFF
	RETURN 0 

END
GO
GRANT EXECUTE ON [dbo].[usp_UpdateExternalObject] TO [webadminuser_role]
GO
