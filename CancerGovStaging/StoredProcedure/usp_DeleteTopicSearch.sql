IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_DeleteTopicSearch]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_DeleteTopicSearch]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/*  Object: [usp_DeleteTopicSearch] for deleting admin topic search
*    Created by: Jay He  March 17, 2003
*    Since the topic has a nciview linked to it, we need to delete viewobjects, topic, viewproperty, prettyurl, and then nciview.
*
*/

CREATE PROCEDURE [dbo].[usp_DeleteTopicSearch]
(
	@TopicID uniqueidentifier,
	@UpdateUserID varchar(50) = 'system'  -- Not Used but must support for step command processing
)
AS
BEGIN	
	/*
	** STEP - A
	** First Validate that the guid provided is valid
	** if not return and 70001 error
	*/	
	if(	
	  (@TopicID  IS NULL) OR (NOT EXISTS (SELECT TopicID  FROM CancerGovStaging..TSTopics WHERE TopicID= @TopicID))
	  )	
	BEGIN
		RAISERROR ( 70001, 16, 1)
		RETURN 70001
	END
	/*
	** STEP - B
	** Get ListID for the relevant list in this topic
	*/

	Declare @NCIViewID uniqueidentifier

	select @NCIViewID = nciviewid from viewobjects where objectid=@TopicID

	BEGIN TRAN  Tran_DeleteNCIView

		/*
		** Delete viewobjects from the viewobjects table for this
		** view.
		*/
		delete from CancerGovStaging..viewobjects
		where nciviewid = @NCIViewID
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_DeleteNCIView
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 

		--delete topic 

		DELETE FROM  TSTopics
		WHERE TopicID = @TopicID
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_DeleteNCIView
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 

		/*
		** Delete relevant viewproperty record from the viewproperty table for this
		** view.
		*/
		delete from CancerGovStaging..viewproperty
		where nciviewid = @NCIViewID
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_DeleteNCIView
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 

		/*
		** Delete relevant pretty url record from the pretty url  table for this
		** view.
		*/
		delete from CancerGovStaging..prettyurl 
		where nciviewid = @NCIViewID
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_DeleteNCIView
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 

		/*
		** Delete the view from the listitem table
		*/
		delete from CancerGovStaging..listitem
		where nciviewid =@NCIViewID
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_DeleteNCIView
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END

		
		/*
		** Finally we get to delete the view from the view table
		*/
		delete from CancerGovStaging..nciview
		where nciviewid =@NCIViewID
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_DeleteNCIView
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END

	COMMIT TRAN Tran_DeleteNCIView

	RETURN 0 

END
GO
GRANT EXECUTE ON [dbo].[usp_DeleteTopicSearch] TO [webadminuser_role]
GO
