IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_Newsletter_SetStatus]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_Newsletter_SetStatus]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.usp_Newsletter_SetStatus (
	@viewID	uniqueidentifier,
	@status		varchar(20)
)
AS
BEGIN
	UPDATE CancerGovStaging.dbo.NLIssue
	SET Status = @status
	WHERE NCIViewID = @viewID
END
GO
GRANT EXECUTE ON [dbo].[usp_Newsletter_SetStatus] TO [websiteuser_role]
GO
