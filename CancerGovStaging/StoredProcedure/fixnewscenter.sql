IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[fixnewscenter]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[fixnewscenter]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE dbo.fixnewscenter AS

begin

DECLARE @nciviewid uniqueidentifier

DECLARE FUTCursor CURSOR FOR
select nciviewid from nciview where nciviewid in (
	select v.nciviewid from nciview v, viewproperty vp where 
		v.nciviewid=vp.nciviewid
		and vp.propertyname='SearchFilter'
		and vp.propertyvalue='News'  
	)

OPEN FUTCursor
FETCH NEXT FROM FUTCursor INTO @nciviewid
	WHILE @@FETCH_STATUS = 0
	BEGIN

	exec usp_deleteNCIView @delview=@nciviewid
	
	FETCH NEXT FROM FUTCursor INTO @nciviewid
	END
end
GO
