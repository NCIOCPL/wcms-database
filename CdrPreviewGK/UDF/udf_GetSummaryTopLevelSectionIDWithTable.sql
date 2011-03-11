IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[udf_GetSummaryTopLevelSectionIDWithTable]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[udf_GetSummaryTopLevelSectionIDWithTable]
GO
/****** Object:  User Defined Function dbo.udf_GetSummaryTopLevelSectionID    Script Date: 5/12/2004 2:31:14 PM ******/
CREATE FUNCTION [dbo].[udf_GetSummaryTopLevelSectionIDWithTable]
(
	@SummarySectionID	uniqueidentifier
)  
RETURNS nvarchar(50)
 AS  


BEGIN 
	DECLARE @SectionLevel int,
		@ParentSummarySectionID uniqueidentifier,
		@ParentSummarySectionID2 uniqueidentifier,
		@ParentSummarySectionID3 uniqueidentifier,
		@ParentSummarySectionID4 uniqueidentifier,
		@SectionType varchar(20),
		@ReturnValue varchar(50)

	set @ReturnValue = NULL

	SELECT @SectionLevel = SectionLevel, @ParentSummarySectionID = ParentSummarySectionID, @SectionType = SectionType
	FROM SummarySection
	WHERE SummarySectionID = @SummarySectionID

	IF (@SectionType <> 'SummarySection' and rtrim(@SectionType) <> 'Table' and rtrim(@SectionType) <> 'Reference')
		BEGIN
			SET @ReturnValue = null
		END
	ELSE
	IF (@SectionType = 'Reference')
		BEGIN
			SET @ReturnValue =  (
				SELECT TOP 1 SectionID 
				FROM SummarySection 
				WHERE SummarySectionID = @ParentSummarySectionID
				)
		END
	ELSE
	IF (@SectionLevel = 1)
		BEGIN
			SET @ReturnValue = null
		END
	ELSE
	IF (@SectionLevel = 2)
		BEGIN
			SET @ReturnValue =  (
				SELECT TOP 1 SectionID 
				FROM SummarySection 
				WHERE SummarySectionID = @ParentSummarySectionID
				)
		END
	ELSE
	IF (@SectionLevel = 3)
		BEGIN
			SELECT @ParentSummarySectionID2 = ParentSummarySectionID
			FROM SummarySection
			WHERE SummarySectionID = @ParentSummarySectionID

			SET @ReturnValue =  (
				SELECT TOP 1 SectionID 
				FROM SummarySection 
				WHERE SummarySectionID = @ParentSummarySectionID2
				)
		END
	ELSE
	IF (@SectionLevel = 4)
		BEGIN
			SET @ReturnValue =  (
				SELECT TOP 1 SectionID 
				FROM SummarySection 
				WHERE SummarySectionID = @ParentSummarySectionID
				)
		END	
	ELSE
	IF (@SectionLevel = 5)
		BEGIN
			SET @ReturnValue =  (
				SELECT TOP 1 SectionID 
				FROM SummarySection 
				WHERE SummarySectionID = @ParentSummarySectionID
				)
		END


	RETURN @ReturnValue
END
















GO
