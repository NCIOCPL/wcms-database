IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_InsertTopicSearch]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_InsertTopicSearch]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** 	Object:  Stored Procedure dbo.usp_InsertTopicSearch    
	Owner:	Jay He
	Script Date: 3/17/2003 14:43:49 pM 
******/

CREATE PROCEDURE dbo.usp_InsertTopicSearch
(
		@TopicName 		varchar(256),		
		@EditableTopicSearchTerm ntext,
		@TopicSearchTerm 	ntext,
		@Title              		VarChar(255),
		@ShortTitle      		VarChar(100),
		@Description    		VarChar(1500),
		@GroupID       		Int,	
		@NCISectionID    	UniqueIdentifier,
		@UpdateUserID  	VarChar(40)
)
AS
BEGIN
	SET NOCOUNT ON;

	Declare @TopicID	UniqueIdentifier, 
		@MacroName 	varchar(400),
		@MacroValue	varchar(4000),
		-- for nciview
		@NCIViewID       	UniqueIdentifier,
		@IsLinkExternal  	Bit,
		@Status         	 	Char(10),
		@Type			Char(10),
		@Priority		Int
		
	select 	@TopicID= newid(),  
		@NCIViewID = newid(), 
		@IsLinkExternal=0, 
		@Status   ='EDIT',  
		@Priority=999	, 
		@Type='TSTOPIC'


	BEGIN  TRAN   Tran_TS



	INSERT INTO  TSTopics (TopicID, TopicName, EditableTopicSearchTerm, TopicSearchTerm, UpdateUserID) 
	VALUES 
	(@TopicID, @TopicName, @EditableTopicSearchTerm, @TopicSearchTerm, @UpdateUserID)
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN  Tran_TS
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	-- insert topic view , section and template id are null

	
	INSERT INTO NCIView 
	( Title,  ShortTitle,  [Description],  URL, URLArguments,  NCISectionID, NCIViewID,  IsLinkExternal,  Status,  UpdateUSerID, GroupID)
 	VALUES 
	(@Title, @ShortTitle, @Description, '/search/search_cancertopics.aspx', ('listid=' + convert(varchar(38),@NCIViewID)), @NCISectionID, @NCIViewID, @IsLinkExternal, @Status,   @UpdateUserID, @GroupID)			
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN  Tran_TS
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	/*
	** Add a viewobject TSTOPIC for the above-created view 
	*/	

	INSERT INTO ViewObjects 
	(NCIViewID, ObjectID, Type, Priority) 
	VALUES 
	(@NCIViewID, @TopicID, @Type, @Priority)
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN  Tran_TS
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	COMMIT tran Tran_TS

	SET NOCOUNT OFF
	RETURN 0 

END

GO
GRANT EXECUTE ON [dbo].[usp_InsertTopicSearch] TO [webadminuser_role]
GO
