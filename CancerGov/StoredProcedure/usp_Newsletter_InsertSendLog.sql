IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_Newsletter_InsertSendLog]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_Newsletter_InsertSendLog]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.usp_Newsletter_InsertSendLog (
	@userID	uniqueidentifier,
	@viewID	uniqueidentifier,
	@result		varchar(20)
)
AS
BEGIN
	INSERT INTO CancerGovStaging.dbo.NewsletterSendLog
		(UserID, NCIViewID, Result)
	VALUES
		(@userID, @viewID, @result)
END
GO
