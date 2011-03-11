IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_InsertViewProperty]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_InsertViewProperty]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/****** 	Object:  Stored Procedure dbo.usp_InsertViewObject    
	Purpose: This script can be used for  inserting view property.	
	Script Date: 
	Modification history:
	10/15/2003 11:43:49 pM  Jay He 	-- added new parameter @updateuserID
******/

CREATE PROCEDURE dbo.usp_InsertViewProperty
(
	@NCIViewID		uniqueidentifier,
	@PropertyName		varchar(50),
	@PropertyValue		varchar(7800),
	@UpdateUserID		varchar(40)
)
AS
BEGIN
	BEGIN  TRAN   Tran_Create


	if (not exists (select nciviewid from viewproperty where nciviewid= @NCIViewID and PropertyName = @PropertyName))
	BEGIN
		INSERT INTO ViewProperty
		(NCIViewID, PropertyName, PropertyValue, UpdateDate, UpdateUserID)
		VALUES
		(@NCIViewID, @PropertyName, @PropertyValue, getdate(),@UpdateUserID)
		IF (@@ERROR <> 0)
		BEGIN
			Rollback tran Tran_Create
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END
	END
	ELSE
	BEGIN
		UPDATE ViewProperty
		set 	 PropertyValue	=@PropertyValue, 
			UpdateDate	= getdate(),
			UpdateUserID	=@UpdateUserID
		WHERE NCIViewID= @NCIViewID and PropertyName= @PropertyName
		IF (@@ERROR <> 0)
		BEGIN
			Rollback tran Tran_Create
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END
	END

	if (@PropertyName ='IsPrintAvailable' and @PropertyValue ='YES' )
	BEGIN
		Update PRettyURLFlag
		set needUpdate =1
	END

	UPDATE NCIView
		set status ='EDIT',
		      updatedate = getdate(),
		      UpdateUserID = @UpdateUserID
	WHERE NCIViewID = @NCIViewID			
	IF (@@ERROR <> 0)
	BEGIN
		Rollback tran Tran_Create
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 


	COMMIT tran Tran_Create

	RETURN 0 

END




GO
GRANT EXECUTE ON [dbo].[usp_InsertViewProperty] TO [webadminuser_role]
GO
