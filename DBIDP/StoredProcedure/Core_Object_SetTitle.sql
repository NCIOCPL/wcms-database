IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Object_SetTitle]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_Object_SetTitle]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_Object_SetTitle
	@ObjectID uniqueidentifier,
	@Title varchar(255)
AS
BEGIN
	
	BEGIN TRY
		UPDATE Object
		SET Title = @Title
		WHERE ObjectID = @ObjectID

		return 0		
	END TRY

	BEGIN CATCH
		Print Error_Message()
		RETURN 11905
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_Object_SetTitle] TO [websiteuser_role]
GO
