IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_Template_Newsletter_GetIssueStatus]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_Template_Newsletter_GetIssueStatus]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.usp_Template_Newsletter_GetIssueStatus (
	@viewID	uniqueidentifier
)
AS
BEGIN
	SELECT Status
	FROM CancerGovStaging.dbo.NLIssue
	WHERE NCIViewID = @viewID
END
GO
