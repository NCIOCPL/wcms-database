IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_updateDCFeatureProperty]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_updateDCFeatureProperty]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** 	Object:  Stored Procedure dbo.dbo.usp_Createinclude 
	Purpose: This script can be used for include files,This will be a transactional script, which creates a nciview and a viewobject.
	Script Date: 1/6/2003 11:43:49 pM 
	Jay He
******/

CREATE PROCEDURE dbo.usp_updateDCFeatureProperty
(
	@NCIViewID       	UniqueIdentifier,
	@PropertyValue		varchar(2500),
	@UpdateUserID       	VarChar(40)
)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRAN Tran_InsertUploadFile

	Delete from ViewProperty where nciviewid in (select N.nciviewid from NCIView N, NCITemplate T where N.NCITemplateID = T.NCITemplateID and T.Name ='CONTENT_DC') and propertyname ='FEATURED'
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_InsertUploadFile
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	INSERT INTO ViewProperty  (NCIViewID, PropertyName, PropertyValue, updateUserID, UpdateDate)
	VALUES
	(@NCIViewID, 'FEATURED', @PropertyValue, @UpdateUserID, getdate())
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_InsertUploadFile
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	
	COMMIT TRAN  Tran_InsertUploadFile
	SET NOCOUNT OFF
	RETURN 0 

END
GO
