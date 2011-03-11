IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_UpdateEFormWONewVersion]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_UpdateEFormWONewVersion]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** 	Object:  Stored Procedure dbo.dbo.usp_addeform    
	Purpose: This script can be used for editing eform. This will be a transactional script, which creates a nciview and several viewobjects in eformsegment table.
	Script Date: 8/16/2002 15:43:49 pM ******/

CREATE PROCEDURE dbo.usp_UpdateEFormWONewVersion
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
		    @SegmentName varchar(200),
		    @NCIViewObjectID uniqueidentifier,
		    @TITLE	varchar(250)

	select @TITLE=title from NCIView where NCIViewID=@NCIViewID

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
	** Update all existing segment for this NCIView -- Or we can update each segment if that page exists
	** if not return a 70004 error
	*/		 

		DECLARE Segment_Cursor CURSOR LOCAL FORWARD_ONLY  FOR
			SELECT 	S.SegmentID, V.Type, S.SegmentName
			FROM 		CancerGovStaging..EFormsSegments S, CancerGovStaging..ViewObjects V
			WHERE  	S.SegmentID = V.ObjectID and V.NCIViewID = @NCIviewID 
		FOR READ ONLY 
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_AddEForm
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
		
		OPEN Segment_Cursor 
		IF (@@ERROR <> 0)
		BEGIN
			DEALLOCATE Segment_Cursor 
			ROLLBACK TRAN Tran_AddEForm
			RAISERROR ( 70004, 16, 1)		
			RETURN 70004
		END 
		
		FETCH NEXT FROM Segment_Cursor 
		INTO 	@SegmentID, @SegmentType, @SegmentName

		WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE EFormsSegments 
			SET  	SegmentInfo =#EFormCode.SegmentInfo, 
				SegmentData =#EFormCode.SegmentData
			FROM  EFormsSegments , #EFormCode, ViewObjects  
			WHERE  EFormsSegments.SegmentID = @SegmentID and 
				 ViewObjects.Type =#EFormCode.SegmentType 
				and  EFormsSegments.SegmentName = #EFormCode.SegmentName
				and  ViewObjects.ObjectID = @SegmentID 
		
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN Tran_AddEForm
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 

			FETCH NEXT FROM Segment_Cursor 
			INTO 	@SegmentID, @SegmentType, @SegmentName
		END
	
		CLOSE  Segment_Cursor
		DEALLOCATE  Segment_Cursor


	COMMIT TRAN Tran_AddEForm
	DROP TABLE #EFormCode
	SET NOCOUNT OFF
	RETURN 0 

END
GO
