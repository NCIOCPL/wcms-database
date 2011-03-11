IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[sp__bb_push_categories]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[sp__bb_push_categories]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROC sp__bb_push_categories

as
 

SET NOCOUNT ON

DECLARE @CategoryID UniqueIdentifier,
	@UpdateUserID varchar(50)

SET @UpdateUserID = 'UserID1'
 

DECLARE BestBetCategories_cursor CURSOR FAST_FORWARD FOR 

SELECT  CategoryID

FROM CancerGovStaging.dbo.BestBetCategories (NOLOCK)


OPEN BestBetCategories_cursor

FETCH NEXT FROM BestBetCategories_cursor 
INTO        @CategoryID


WHILE @@FETCH_STATUS = 0

BEGIN

   -- PROCESSING
	exec usp_PushBestBetToProduction @CategoryID, @UpdateUserID 
 

   FETCH NEXT FROM BestBetCategories_cursor 

   INTO @CategoryID

 

END

 
CLOSE BestBetCategories_cursor

DEALLOCATE BestBetCategories_cursor

 



GO
