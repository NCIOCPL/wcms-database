IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[GlossXlateTableSelect]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[GlossXlateTableSelect]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE dbo.GlossXlateTableSelect
AS
	SET NOCOUNT ON;
SELECT     SourceID, Name
FROM         dbo.Glossary
ORDER BY (SourceID  * 1)
GO
