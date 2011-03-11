IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_PUCGetProtocolAltId]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_PUCGetProtocolAltId]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Vadim
-- Create date: 5/22/07
-- Description:	<Used by PrettyURLControl>
-- =============================================
CREATE PROCEDURE [dbo].[usp_PUCGetProtocolAltId] 
AS
BEGIN
	SET NOCOUNT ON;
	SELECT ProtocolID, IDString FROM ProtocolAlternateID 
	WHERE IDTypeID = 4
END

GO
GRANT EXECUTE ON [dbo].[usp_PUCGetProtocolAltId] TO [prettyurluser_role]
GO
