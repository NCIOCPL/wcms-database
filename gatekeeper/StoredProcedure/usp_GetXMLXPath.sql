IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_GetXMLXPath]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_GetXMLXPath]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:   dbo.usp_GetXMLXPath    Script Date: 12/15/2006  ******/
/*	NCI - National Cancer Institute
*	
*	File Name:	
*	usp_GetXMLXPath.sql
*
*	Objects Used:
*	12/15/2006  Yiling Chen
*	
*	Change History:
*	12/15/2006 			Script Created
*	To Do:
*
*/
CREATE PROCEDURE dbo.usp_GetXMLXPath
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select * from xmlquery
END


GO
GRANT EXECUTE ON [dbo].[usp_GetXMLXPath] TO [gatekeeper_role]
GO
