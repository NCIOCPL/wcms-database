IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_RetrieveMacro]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_RetrieveMacro]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  Stored Procedure dbo.usp_RetrieveTopicMacro
Owner: Jhe 
Purpose: For admin side 
Script Date: 3/17/2003 16:00:49 pm 
******/

CREATE PROCEDURE dbo.usp_RetrieveMacro
AS
BEGIN
	SELECT MacroID, MacroName,MacroValue, IsOnProduction, Status, UpdateUserID, updateDate
	FROM 	TSMacros
	order by MacroName
END


GO
GRANT EXECUTE ON [dbo].[usp_RetrieveMacro] TO [webadminuser_role]
GO
