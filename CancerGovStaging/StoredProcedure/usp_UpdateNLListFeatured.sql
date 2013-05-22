IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_UpdateNLListFeatured]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_UpdateNLListFeatured]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** 	Object:  Stored Procedure dbo.usp_InsertNewsletter
	Owner:	Jay He
	Script Date: 3/19/2003 14:43:49 pM 
******/

CREATE PROCEDURE dbo.usp_UpdateNLListFeatured
(
 	@NCIViewID	UniqueIdentifier,
	@ListID		UniqueIdentifier,
	@Type		varchar(50),
	@UpdateUserID		varchar(50)
 )
AS
BEGIN
	SET NOCOUNT ON;
	-- We only insert newsletter

	Declare @ViewID	UniqueIdentifier

	select  @ViewID = NCIViewID from viewobjects where objectid=@ListID

	BEGIN TRAN Tran_InsertLinkView
	
	if (@Type ='FEATURED')
	BEGIN
		Update NLListItem 
		Set IsFeatured = 0 
		WHERE ListID =@ListID	
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_InsertLinkView
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
						
		Update NLListItem 
		SET IsFeatured =1 
		WHERE NCIViewID = @NCIViewID AND ListID = @ListID
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_InsertLinkView
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
	END
	ELSE
	BEGIN
		Update NLListItem 
		SET IsFeatured =0 
		WHERE NCIViewID = @NCIViewID AND ListID = @ListID
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_InsertLinkView
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 			
	END	

	Update NCIView
	set 	Status =		'EDIT',
		UpdateDate	= getdate(),  
		UpdateUserID  	=@UpdateUserID  
	where NCIViewID = @ViewID
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_InsertLinkView
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 


	COMMIT TRAN  Tran_InsertLinkView
	SET NOCOUNT OFF

	RETURN 0 

END
GO
GRANT EXECUTE ON [dbo].[usp_UpdateNLListFeatured] TO [webadminuser_role]
GO
