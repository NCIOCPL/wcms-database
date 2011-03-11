IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[udf_GetItemsForView]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[udf_GetItemsForView]
GO
CREATE FUNCTION dbo.udf_GetItemsForView( @NCIViewID uniqueidentifier )
RETURNS @ResultTable TABLE
	(
	NCIViewID     	uniqueidentifier,
	ItemTitle 	varchar(255)
	)
AS

BEGIN
	DECLARE 	@ViewListID 	uniqueidentifier

	-- Get corespondent LIST  
	DECLARE Affected_Item CURSOR FOR 
	SELECT 	ObjectID
	FROM 		ViewObjects
	WHERE 	NCIViewID = @NCIViewID		
			AND Type like '%LIST%' 

	OPEN Affected_Item
	FETCH NEXT FROM Affected_Item INTO @ViewListID
	WHILE @@FETCH_STATUS = 0
	BEGIN
		--Get All Items for that list 
		INSERT INTO 	@ResultTable ( NCIViewID, ItemTitle)
		SELECT	V.NCIViewID, 
				V.Title
		FROM		NCIView AS V 
				INNER JOIN ListItem LI 
				ON LI.NCIViewID = V.NCIViewID 
		WHERE 	LI.ListID = @ViewListID
	
		--Get All Items For Child lists
		INSERT INTO 	@ResultTable ( NCIViewID, ItemTitle)
		SELECT	V.NCIViewID, 
				V.Title
		FROM		NCIView AS V 
				INNER JOIN ListItem AS LI 
				ON LI.NCIViewID = V.NCIViewID 
				INNER JOIN List AS L 
				ON L.ListID = LI.ListID 
		WHERE 	L.ParentListID  = @ViewListID

		FETCH NEXT FROM Affected_Item INTO @ViewListID
	END
	CLOSE 	Affected_Item
	DEALLOCATE Affected_Item

	RETURN
END























GO
