IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_UpdatePrettyURLFlag]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_UpdatePrettyURLFlag]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**********************************************************************************

	Object's name:	usp_UpdatePrettyURLFlag
	Object's type:	store proc
	Purpose:	Update NCIView
	Author:		10/27/2004	Lijia	

**********************************************************************************/					
					
CREATE PROCEDURE dbo.usp_UpdatePrettyURLFlag

AS
	UPDATE	PrettyURLFlag 
	SET	NeedUpdate = 1



GO
GRANT EXECUTE ON [dbo].[usp_UpdatePrettyURLFlag] TO [gatekeeper_role]
GO
GRANT EXECUTE ON [dbo].[usp_UpdatePrettyURLFlag] TO [websiteuser_role]
GO
