IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_ResetGKCDRErrorMessages]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_ResetGKCDRErrorMessages]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.usp_ResetGKCDRErrorMessages
AS
BEGIN

EXEC sp_addmessage 69990 ,16, 'ERROR: Document %d  cannot be saved. Unable to load data in to %s table' ,  'us_english', true,replace
EXEC sp_addmessage 69998 ,16, 'ERROR: unable to delete document %d from %s table' ,  'us_english', true,replace
EXEC sp_addmessage 69999 ,16, 'ERROR: MapTable push to Live. Data inconsistent  in %s table' ,  'us_english', true,replace
EXEC sp_addmessage 70000 ,16, 'ERROR: Document %d  cannot be pushed to CDRLiveGK database. Unable to load data in to %s table' ,  'us_english', true,replace
EXEC sp_addmessage 70001 ,16, 'ERROR: Document %d  cannot be pushed to CDRLiveGK database. usp_clearExtracted%sData ERROR' ,  'us_english', true,replace

END


GO
