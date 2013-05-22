IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_RetrieveTopicMacro]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_RetrieveTopicMacro]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.usp_RetrieveMacro
Owner: Jhe 
Purpose: For admin side 
Script Date: 3/17/2003 16:00:49 pm 
******/

CREATE PROCEDURE dbo.usp_RetrieveTopicMacro
(
	@MacroID UniqueIdentifier
)
AS
BEGIN
	SELECT  MacroName,  MacroValue 
	FROM 	TSMacros
	Where MacroID= @MacroID
END
GO
GRANT EXECUTE ON [dbo].[usp_RetrieveTopicMacro] TO [webadminuser_role]
GO
