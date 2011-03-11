IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetProtocolDateFirstPublished]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetProtocolDateFirstPublished]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:   dbo.usp_GetProtocolDateFirstPublished    Script Date: 06/06/2007  ******/
/*	NCI - National Cancer Institute
*	
*	File Name:	
*	usp_GetProtocolDateFirstPublished.sql
*
*	Objects Used:
*	 06/06/2007  Yiling Chen
*	
*	Change History:
*	 06/06/2007			Script Created
*	To Do:
*
*/
CREATE PROCEDURE dbo.usp_GetProtocolDateFirstPublished
(
    @ProtocolID	int = null
)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select DateFirstPublished 
	from ProtocolDetail 
	where ProtocolID = @ProtocolID
END


GO
GRANT EXECUTE ON [dbo].[usp_GetProtocolDateFirstPublished] TO [Gatekeeper_role]
GO
