IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_UpdateTopicSearch]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_UpdateTopicSearch]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** 	Object:  Stored Procedure dbo.usp_UpdateTopicSearch    
	Owner:	Jay He
	Script Date: 3/17/2003 14:43:49 pM 
******/

CREATE PROCEDURE dbo.usp_UpdateTopicSearch
(
	@TopicID			UniqueIdentifier,
	@TopicName 			varchar(50),
	@EditableTopicSearchTerm 	ntext,
	@TopicSearchTerm 		ntext,
	@Title				varChar(255),
	@ShortTitle			varChar(64),
	@Description			varChar(1500),												 
	@UpdateUserID  		VarChar(50)
)
AS
BEGIN

	Declare @NCIViewID	UniqueIdentifier
	

	select @NCIViewID= nciviewID from viewobjects where objectID=@TopicID and type='TSTOPIC'


	BEGIN TRAN Tran_DeleteNCIView

	UPDATE TSTopics 
	set 	TopicName=@TopicName, 
		EditableTopicSearchTerm=@EditableTopicSearchTerm,
		TopicSearchTerm=@TopicSearchTerm,
		UpdateUserID= @UpdateUserID
	where TopicID = @TopicID
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN  Tran_DeleteNCIView
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	UPDATE NCIView
	set 	title = @Title,
		shorttitle= @ShortTitle,
		[description] = @Description,
		status ='EDIT',
		UpdateUserID= @UpdateUserID
	where NCIViewID = @NCIViewID
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN  Tran_DeleteNCIView
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	COMMIT TRAN Tran_DeleteNCIView
	RETURN 0 

END

GO
GRANT EXECUTE ON [dbo].[usp_UpdateTopicSearch] TO [webadminuser_role]
GO
