IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_LayoutTemplate_Delete]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_LayoutTemplate_Delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_LayoutTemplate_Delete
    @LayoutTemplateID uniqueidentifier
    ,@UpdateUserID varchar(50)
AS
BEGIN
	BEGIN TRY
		if (exists (select 1 from dbo.LayoutDefinition where LayoutTemplateID = @LayoutTemplateID))
			return 10406		

		DECLARE	@Zone TABLE (
			RowNumber int identity( 1,1),
			TemplateZoneID uniqueidentifier
		);

		--1. Get all From ContentAreaTemplateZoneMap
		INSERT INTO @Zone
			(
				TemplateZoneID
			)
		SELECT	TemplateZoneID
		FROM	dbo.LayoutTemplateZoneMap Where LayoutTemplateID = @LayoutTemplateID

		--2.
		Delete from dbo.LayoutTemplateZoneMap
		Where LayoutTemplateID = @LayoutTemplateID

		--3.
		Delete from dbo.TemplateZone
		Where TemplateZoneID = 
			(
				select TemplateZoneID from @Zone
				where TemplateZoneID not in (SELECT	TemplateZoneID
					FROM	dbo.LayoutTemplateZoneMap )
			)
		--4


		Delete from dbo.LayoutTemplate
		Where LayoutTemplateID = @LayoutTemplateID
	
	END TRY

	BEGIN CATCH
		RETURN 10405 -- Delete
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_LayoutTemplate_Delete] TO [websiteuser_role]
GO
