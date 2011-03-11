IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[udf_GetListItems]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[udf_GetListItems]
GO
CREATE FUNCTION dbo.udf_GetListItems( @ListID uniqueidentifier )
RETURNS @ResultTable TABLE
	(
	NCIViewID     	uniqueidentifier,
	ItemTitle 	varchar(255)
	)
AS

BEGIN
	DECLARE 	@ModalityTypeID uniqueidentifier,
			@CombinationChemotherapyTypeID uniqueidentifier,
			@OnLineStatusID   	uniqueidentifier,
			@PrimaryTermType	uniqueidentifier
	SELECT 	@ModalityTypeID = dbo.GetCancerGovTypeID( 202 ),
			@CombinationChemotherapyTypeID = dbo.GetCancerGovTypeID( 200 ),
			@OnLineStatusID = dbo.GetCancerGovStatusID( 66 ), -- on-line
			@PrimaryTermType = dbo.GetCancerGovTypeID( 58 )
	
	INSERT INTO 	@ResultTable ( NCIViewID, ItemTitle)
	SELECT	V.NCIViewID, 
			V.Title
	FROM		NCIView AS V 
			INNER JOIN ListItem LI 
			ON LI.NCIViewID = V.NCIViewID 
			AND LI.ListID = @ListID 
	UNION 
	SELECT	V.NCIViewID, 
			V.Title
	FROM		NCIView AS V 
			INNER JOIN ListItem AS LI 
			ON LI.NCIViewID = V.NCIViewID 
			INNER JOIN List AS L 
			ON L.ParentListID = @ListID 
	RETURN
END



















GO
