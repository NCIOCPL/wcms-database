IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetBasePrettyUrl]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetBasePrettyUrl]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE dbo.usp_GetBasePrettyUrl
	(
	@ViewID		uniqueidentifier
	)
AS
BEGIN

	declare @purl varchar(2000)

	select @purl=(select top 1 currenturl from prettyurl where nciviewid=@ViewID and IsPrimary=1)

	IF (@purl Is Not Null)
	BEGIN
		select @purl=replace(@purl,'/healthprofessional','')
		select @purl=replace(@purl,'/patient','')
	END

	select @purl as PrettyUrl


END

GO
