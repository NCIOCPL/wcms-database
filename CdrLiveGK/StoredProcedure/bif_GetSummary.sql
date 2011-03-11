IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[bif_GetSummary]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[bif_GetSummary]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE dbo.bif_GetSummary
	@DocumentID uniqueidentifier
AS
BEGIN

select * from summarysection where summaryGuid=@DocumentID
order by priority

END


GO
GRANT EXECUTE ON [dbo].[bif_GetSummary] TO [webSiteUser_role]
GO
