IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_InsertTopicMacro]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_InsertTopicMacro]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** 	Object:  Stored Procedure dbo.usp_InsertTopicMacro
	Owner:	Jay He
	Script Date: 3/19/2003 14:43:49 pM 
******/

CREATE PROCEDURE dbo.usp_InsertTopicMacro
(
		@MacroName 		varchar(512),		
		@MacroValue		varchar(1024),
		@UpdateUserID  	varChar(40)
)
AS
BEGIN
	-- We only insert macro. No need to worry about Term and other issues. 
	INSERT INTO  TSMacros (MacroName, MacroValue, IsOnProduction, Status, UpdateUserID) 
	VALUES 
	(@MacroName,   @MacroValue, 0, 'Edit', @UpdateUserID)
	IF (@@ERROR <> 0)
	BEGIN
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	RETURN 0 

END
GO
GRANT EXECUTE ON [dbo].[usp_InsertTopicMacro] TO [webadminuser_role]
GO
