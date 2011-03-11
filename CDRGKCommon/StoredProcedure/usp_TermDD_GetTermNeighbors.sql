IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_TermDD_GetTermNeighbors]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_TermDD_GetTermNeighbors]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****** Object:  Stored Procedure dbo.usp_TermDD_GetTermNeighbors    Script Date: 7/1/2005 9:31:11 AM ******/

/****** Object:  Stored Procedure dbo.usp_TermDD_GetTermNeighbors    Script Date: 6/28/2005 5:36:54 PM ******/


/**********************************************************************************

	Object's name:	usp_TermDD_GetTermNeighbors
	Object's type:	store proc
	Purpose:	To search the Term Drug Dictionary by string match and also return previous and next <num> matches
	Author:		5/4/2005	Chen Ling
	Change History:
	5/10/2005 	Chen Ling	Updated script to use view
	6/28/2005	Chen Ling	Now shows US brand names also
		

**********************************************************************************/	

CREATE PROCEDURE dbo.usp_TermDD_GetTermNeighbors
	(
	@name	nvarchar(1100),
	@num	int 
	)
AS
BEGIN
	

	DECLARE	@Terms TABLE
		(
		TermID	int,
		PreferredName	nvarchar(1100),
		IsPrevious	char(1)	
		)

	SET ROWCOUNT @num
 
	INSERT INTO @Terms
	SELECT TermID, PreferredName, 'N' IsPrevious
	FROM (
		SELECT TermID, PreferredName, 'N' IsPrevious
		FROM vwTermDrugDictionary
		WHERE cast(lower(PreferredName) as binary(2200)) > cast(lower(@Name) as binary(2200))

		UNION

		SELECT ton.TermID, ton.OtherName as PreferredName, 'N' IsPrevious
		FROM TermOtherName ton, vwTermDrugDictionary tdd
		WHERE ton.OtherNameType = 'US brand name'
		AND ton.TermID = tdd.TermID
		AND cast(lower(ton.OtherName) as binary(2200)) > cast(lower(@Name) as binary(2200))
	) A
	ORDER BY cast(lower(PreferredName) as binary(2200)) ASC

	SET ROWCOUNT @num

	INSERT INTO @Terms
	SELECT TermID, PreferredName, 'Y' IsPrevious
	FROM (
		SELECT TermID, PreferredName, 'Y' IsPrevious
		FROM vwTermDrugDictionary
		WHERE cast(lower(PreferredName) as binary(2200)) < cast(lower(@Name) as binary(2200))

		UNION

		SELECT ton.TermID, ton.OtherName as PreferredName, 'Y' IsPrevious
		FROM TermOtherName ton, vwTermDrugDictionary tdd
		WHERE ton.OtherNameType = 'US brand name'
		AND ton.TermID = tdd.TermID
		AND cast(lower(ton.OtherName) as binary(2200)) < cast(lower(@Name) as binary(2200))
	) A
	ORDER BY cast(lower(PreferredName) as binary(2200)) DESC

	SET ROWCOUNT 0
	
	SELECT * FROM @Terms ORDER BY cast(lower(PreferredName) as binary(2200)) ASC
END

GO
GRANT EXECUTE ON [dbo].[usp_TermDD_GetTermNeighbors] TO [websiteuser_role]
GO
