IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetNCIViewDependencies]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetNCIViewDependencies]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/**********************************************************************************

	Object's name:	usp_GetNCIViewDependencies
	Object's type:	store proc
	Purpose:	
	Change history:	

**********************************************************************************/

CREATE PROCEDURE usp_GetNCIViewDependencies
	(
	@documentGUID uniqueidentifier
	)
AS

declare @lists table (listID uniqueidentifier)
declare @Bestbets varchar(4000), @Views varchar(7000)
select @Bestbets = '', @Views  = ''

insert into @lists
select listID from dbo.listItem 
	where nciviewid in
	(select nciviewid from dbo.viewobjects where objectid = @documentGUID and type in ('DOCUMENT','summary_P','summary_HP'))


select @Bestbets = @bestbets + ',' + catName
from @lists l inner join dbo.bestbetcategories bb on l.listid = bb.listid


select @views = @views + ',' + convert(varchar(60), vo.nciviewid)
from @lists l inner join dbo.viewobjects vo on l.listid = vo.objectid


select case when len(@bestbets) > 1 then right(@bestbets, len(@bestbets) -1) else '' end as bestbet 
, case when len(@views) > 1 then right(@views, len(@views) -1) else '' end as nciview




GO
GRANT EXECUTE ON [dbo].[usp_GetNCIViewDependencies] TO [gatekeeper_role]
GO
