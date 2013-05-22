IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetIncludeContent]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetIncludeContent]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE dbo.usp_GetIncludeContent
	(
	@ViewId	uniqueidentifier,
	@Type		varchar(40) = null
	)
AS
BEGIN
	Select	d.Data, 
		d.Title AS DocTitle, 
		d.TOC, 
		d.DocumentId, 
		d.ShortTitle as DocShortTitle
	from	viewobjects vo, 
		document d
	where 	vo.NCIViewId = @ViewId
		and vo.objectid = d.DocumentId
		and vo.Type = @Type

END
GO
