IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BestBet_BestBetCategory_Delete]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[BestBet_BestBetCategory_Delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[BestBet_BestBetCategory_Delete]
	@CategoryID uniqueidentifier,
	@UpdateUserID varchar(50)
AS
BEGIN
	DECLARE @listID uniqueidentifier

	select @listID = ListID 
	from BestBetCategory
	where  CategoryID = @CategoryID

	BEGIN TRY
		
		DELETE FROM BestBetSynonym 
		WHERE CategoryID = @CategoryID

		DELETE FROM BestBetCategory
		WHERE CategoryID = @CategoryID
				
		--delete from moduleinstance where objectID = @listID

		delete from listitem
		where listid = @listID

		delete from list
		where listid = @listID

		delete from object where objectID = @listID

	END TRY

	BEGIN CATCH
		
			RETURN 123005  -- BestBet_BestBetCategory_delete
		
	END CATCH 
END


GO
GRANT EXECUTE ON [dbo].[BestBet_BestBetCategory_Delete] TO [websiteuser_role]
GO
