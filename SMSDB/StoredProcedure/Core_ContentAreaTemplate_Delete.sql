IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_ContentAreaTemplate_Delete]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_ContentAreaTemplate_Delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_ContentAreaTemplate_Delete
    @ContentAreaTemplateID uniqueidentifier
    ,@UpdateUserID varchar(50)
AS
BEGIN
	BEGIN TRY
		if (exists (select 1 from dbo.LayoutDefinition where ContentAreaTemplateID = @ContentAreaTemplateID))
			return 10406		

		
--		Delete from dbo.LayoutDefinition
--		Where ContentAreaTemplateID = @ContentAreaTemplateID

		-- 1. Loop each Zone from mapping 
		-- 2. delete zonemap
		-- 3. If zone not used by other template, delete
		-- 4. Delete template itself

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
		FROM	dbo.ContentAreaTemplateZoneMap Where ContentAreaTemplateID = @ContentAreaTemplateID

		--2.
		Delete from dbo.ContentAreaTemplateZoneMap
		Where ContentAreaTemplateID = @ContentAreaTemplateID 

		--3.
		Delete from dbo.TemplateZone
		Where TemplateZoneID = 
			(
				select TemplateZoneID from @Zone
				where TemplateZoneID not in (SELECT	TemplateZoneID
					FROM	dbo.ContentAreaTemplateZoneMap )
			)
		--4
		Delete from dbo.ContentAreaTemplate
		Where ContentAreaTemplateID = @ContentAreaTemplateID
	
	END TRY

	BEGIN CATCH
		RETURN 10405 -- Delete
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_ContentAreaTemplate_Delete] TO [websiteuser_role]
GO
