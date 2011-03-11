IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_AddEForm]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_AddEForm]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** 	Object:  Stored Procedure dbo.dbo.usp_addeform    
	Purpose: This script can be used for adding eform. This will be a transactional script, which creates a nciview and several viewobjects in eformsegment table.
	Script Date: 8/16/2002 15:43:49 pM ******/

CREATE PROCEDURE dbo.usp_AddEForm
(
	@NCIViewID       	UniqueIdentifier,
	@Title              		VarChar(255),
	@ShortTitle      		VarChar(100),
	@Description    		VarChar(1500),
	@URL              		VarChar(1000 ),
	@URLArguments    	VarChar(1000 ),
	@NCITemplateID	UniqueIdentifier,
	@GroupID       		Int,
	@NCISectionID		UniqueIdentifier,
	@ExpirationDate	DateTime,
	@ReleaseDate		DateTime,
	@UpdateUserID		VarChar(40),
	@DisplayDateMode	VarChar(40),
	@EFormXML		ntext,
	@HelpXML		ntext
)
AS
BEGIN
	SET NOCOUNT ON;

-------------------------------------------------------------------------------------------------------------------------------
-- Temp table for eform code segments
	CREATE TABLE #EFormCode (
		[SegmentID] [uniqueidentifier] default newid() ,
		[SegmentName] [varchar] (255) NOT NULL,
		[SegmentInfo] [varchar] (4000),
		[SegmentType] [char] (10) NOT NULL,
		[SegmentData] [ntext] NOT NULL
	)
-----------------------------------------------------------------------------------------------------------
--Declare Variables
	DECLARE @i_XML int,
		    @SegmentID uniqueidentifier,
		    @SegmentType char(10),
		    @NCIViewObjectID uniqueidentifier
	DECLARE SegmentCursor CURSOR FOR
		select SegmentID, SegmentType from #EFormCode
-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
--Insert Whole EForm For Editing
	INSERT INTO #EFormCode(SegmentName, SegmentInfo, SegmentData, SegmentType)
		 Values(@TITLE, '', @EFormXML, 'EFormWCode')
-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
--Insert Whole Help For Editing
	INSERT INTO #EFormCode(SegmentName, SegmentInfo, SegmentData, SegmentType)
		 Values(@TITLE, '', @HelpXML, 'EFormWHelp')
-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
-- Fill up Temp Table with code pieces
	EXEC sp_xml_preparedocument @i_XML OUTPUT, @EFormXML
	INSERT INTO #EFormCode (SegmentName, SegmentInfo, SegmentData, SegmentType)
		 SELECT SegmentName,
			  SegmentInfo,
			  SegmentData,
			  'EFormSCode' as SegmentType
		 FROM OPENXML(@i_XML, '/eform/page')
		 WITH(
			  SegmentName varchar(255) '@name',
			  SegmentInfo varchar(4000) '@title',
			  SegmentData ntext '@mp:XMLText')
	EXEC sp_xml_removedocument @i_XML
----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
-- Fill up Temp Table with Help pieces
	EXEC sp_xml_preparedocument @i_XML OUTPUT, @HelpXML
	INSERT INTO #EFormCode (SegmentName, SegmentInfo, SegmentData,SegmentType)	
		SELECT SegmentName,
			 SegmentInfo,
			 SegmentData,
			 'EFormSHelp' as SegmentType
		FROM OPENXML(@i_XML, '/help/helpitem')
		WITH(
			SegmentName varchar(255) '@name',
			SegmentInfo varchar(4000) './short',
			SegmentData ntext './long')
	EXEC sp_xml_removedocument @i_XML
----------------------------------------------------------------------------------------------------------------

	BEGIN TRAN Tran_AddEForm
	/*
	** STEP - A
	** Insert a new row into NCIView table
	** if not return a 70004 error
	*/		

	INSERT INTO NCIView 
	( Title,  ShortTitle,  [Description],  URL, URLArguments,   NCIViewID,  Status,  IsOnProduction, IsMultiSourced, IsLinkExternal, SpiderDepth,   NCITemplateID, UpdateUSerID, GroupID, NCISectionID, PostedDate, CreateDate, ReleaseDate, ExpirationDate,  DisplayDateMode  )
 	VALUES 
	(@Title, @ShortTitle, @Description, @URL, @URLArguments, @NCIViewID, 'Edit', 0, 0, 0, 3, @NCITemplateID,  @UpdateUSerID, @GroupID, @NCISectionID, GETDATE(), GETDATE(), @ReleaseDate, @ExpirationDate, @DisplayDateMode)			
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_AddEForm
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END
	
	INSERT INTO ViewProperty
	(ViewPropertyID, NCIViewID, PropertyName, PropertyValue, UpdateDate, UpdateUserID)
	VALUES
	(newid(), @NCIViewID, 'Version', '1',  GETDATE(),  @UpdateUserID)
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_AddEForm
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END

	/*
	** STEP - B
	** Add several EFormSegments for the above-created view . Try to use sp_xml_preparedocument and cursor to add each one into the segment table 
	*/		 

	OPEN SegmentCursor
	FETCH NEXT FROM SegmentCursor INTO @SegmentID, @SegmentType
	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO EFormsSegments (SegmentID, SegmentName, SegmentInfo, SegmentData)
		SELECT SegmentID,
			  SegmentName,
			  SegmentInfo,
			  SegmentData
		FROM #EFormCode WHERE SegmentID = @SegmentID
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_AddEForm
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 

		/*
		** STEP - C
		** Add above segmentID into viewobject for the above-created view 
		*/

		
		SET @NCIViewObjectID = newid()

		INSERT INTO ViewObjects 
		(NCIViewObjectID,NCIViewID, ObjectID, Type, UpdateDate, UpdateUserID) 
		VALUES 
		(@NCIViewObjectID,@NCIViewID, @SegmentID, @SegmentType, GETDATE(), @UpdateUserID)
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_AddEForm
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END

		INSERT INTO ViewObjectProperty
		(NCIViewObjectID, PropertyName, PropertyValue, UpdateDate, UpdateUserID)
		VALUES
		(@NCIViewObjectID, 'Version', '1', GETDATE(), @UpdateUserID) 
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_AddEForm
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END		

		FETCH NEXT FROM SegmentCursor INTO @SegmentID, @SegmentType
	END


	COMMIT TRAN Tran_AddEForm
	DROP TABLE #EFormCode
	SET NOCOUNT OFF
	RETURN 0 

END

GO
