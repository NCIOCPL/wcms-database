IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_UpdateEForm]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_UpdateEForm]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** 	Object:  Stored Procedure dbo.dbo.usp_addeform    
	Purpose: This script can be used for editing eform. This will be a transactional script, which creates a nciview and several viewobjects in eformsegment table.
	Script Date: 8/16/2002 15:43:49 pM ******/

CREATE PROCEDURE dbo.usp_UpdateEForm
(
	@NCIViewID       	UniqueIdentifier,
	@UpdateUserID		VarChar(40),
	@XML			text,
	@Type			varchar(10)
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
		[SegmentData] [text] NOT NULL
	)
	-----------------------------------------------------------------------------------------------------------
	--Declare Variables
	DECLARE @i_XML int,
		    @SegmentID uniqueidentifier,
		    @SegmentType char(10),
		    @NCIViewObjectID uniqueidentifier,
		    @TITLE	varchar(250)

	select @TITLE=title from NCIView where NCIViewID=@NCIViewID

	DECLARE SegmentCursor CURSOR FOR
		select SegmentID, SegmentType from #EFormCode
	-----------------------------------------------------------------------------------------------------------

	-- Check type and parse help and eform xml differently
	if (@Type ='EFORM')
	BEGIN
		-----------------------------------------------------------------------------------------------------------
		--Insert Whole EForm For Editing
		INSERT INTO #EFormCode(SegmentName, SegmentInfo, SegmentData, SegmentType)
		 Values(@TITLE, '', @XML, 'EFormWCode')
		-----------------------------------------------------------------------------------------------------------
		-----------------------------------------------------------------------------------------------------------
		-----------------------------------------------------------------------------------------------------------
		-----------------------------------------------------------------------------------------------------------
		-- Fill up Temp Table with code pieces

		EXEC sp_xml_preparedocument @i_XML OUTPUT, @XML
		INSERT INTO #EFormCode (SegmentName, SegmentInfo, SegmentData, SegmentType)
			 SELECT SegmentName,
			  SegmentInfo,
			  SegmentData,
			  'EFormSCode' as SegmentType
			 FROM OPENXML(@i_XML, '/eform/page')
			 WITH(
				  SegmentName varchar(255) '@name',
				  SegmentInfo varchar(4000) '@title',
				  SegmentData text '@mp:XMLText')
		EXEC sp_xml_removedocument @i_XML

	END
	ELSE
	BEGIN
		--Insert Whole Help For Editing
		INSERT INTO #EFormCode(SegmentName, SegmentInfo, SegmentData, SegmentType)
		 Values(@TITLE, '', @XML, 'EFormWHelp')

		----------------------------------------------------------------------------------------------------------------
		-----------------------------------------------------------------------------------------------------------
		-- Fill up Temp Table with Help pieces
		EXEC sp_xml_preparedocument @i_XML OUTPUT, @XML
		INSERT INTO #EFormCode (SegmentName, SegmentInfo, SegmentData,SegmentType)	
			SELECT SegmentName,
			 SegmentInfo,
			 SegmentData,
			 'EFormSHelp' as SegmentType
			FROM OPENXML(@i_XML, '/help/helpitem')
			WITH(
				SegmentName varchar(255) '@name',
				SegmentInfo varchar(4000) './short',
				SegmentData text './long')
		EXEC sp_xml_removedocument @i_XML
	----------------------------------------------------------------------------------------------------------------
	END

	BEGIN TRAN Tran_AddEForm
	/*
	** STEP - A
	** Delete all existing segment for this NCIView -- Or we can update each segment if that page exists. Otherwise, insert new segment
	** if not return a 70004 error
	*/		

	if (@Type ='EFORM')
	BEGIN
		SELECT  @NCIViewObjectID = NCIViewObjectID from ViewObjects WHERE NCIViewID= @NCIViewID and type='EFormWCode'

		DELETE from ViewObjectProperty WHERE NCIViewObjectID= @NCIViewObjectID 
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_AddEForm
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END

		DELETE from EFormsSegments WHERE segmentID =(Select objectID from ViewObjects where NCIViewObjectID=@NCIViewObjectID) 
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_AddEForm
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END

		DELETE from ViewObjects WHERE NCIViewObjectID= @NCIViewObjectID and type='EFormWCode'
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_AddEForm
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END


	END
	ELSE
	BEGIN
		SELECT  @NCIViewObjectID = NCIViewObjectID from ViewObjects WHERE NCIViewID= @NCIViewID and type='EFormWHelp'

		DELETE from ViewObjectProperty WHERE NCIViewObjectID= @NCIViewObjectID 
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_AddEForm
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END

		DELETE from EFormsSegments WHERE segmentID =(Select objectID from ViewObjects where NCIViewObjectID=@NCIViewObjectID) 
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_AddEForm
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END

		DELETE from ViewObjects WHERE NCIViewObjectID= @NCIViewObjectID and type='EFormWHelp'
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_AddEForm
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END


	END

	/*
	** STEP - B
	** Insert a new row into NCIView table
	** if not return a 70004 error
	
	UPDATE  ViewProperty
	set  PropertyValue = @Version + 1
	where	NCIViewID = @NCIViewID and PropertyName= 'Version'
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_AddEForm
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END
*/		
	
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
