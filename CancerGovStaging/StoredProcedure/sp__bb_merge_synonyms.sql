IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[sp__bb_merge_synonyms]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[sp__bb_merge_synonyms]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC sp__bb_merge_synonyms

@doit tinyint = 0

AS
 
SET NOCOUNT ON

DECLARE @getdate datetime, @UpdateUserID varchar(50),
	@error1 int, @error2 int,
	@rc1 int, @rc2 int, @rc3 int, @rc4 int, 
	@rowcount1 int, @rowcount2 int

SELECT 	@getdate = getdate(), 
	@UpdateUserID = 'TEST_1' -- SET THIS

DECLARE @SynonymID uniqueidentifier
 
-- let's first back up the target table 
IF OBJECT_ID('BestBetSynonyms_PROD_OLD')IS NOT NULL 
	DROP TABLE BestBetSynonyms_PROD_OLD

SELECT * INTO BestBetSynonyms_PROD_OLD
FROM BestBetSynonyms_PROD

IF @doit = 1 
	BEGIN TRAN

-- save missing categorid fk 's 
IF OBJECT_ID('tempdb.dbo.##bb_merge_synonyms_missing_categoryid') IS NOT NULL 
	DROP TABLE ##bb_merge_synonyms_missing_categoryid

SELECT A.SynonymID, A.SynName INTO ##bb_merge_synonyms_missing_categoryid
FROM 	CancerGovStaging.dbo.BestBetSynonyms_ATHENA A -- Source 
WHERE A.IsNegated = 1
AND NOT EXISTS
	(SELECT 1 FROM BestBetCategories P -- Target
		WHERE P.CategoryID = A.CategoryID)

SET @rc1 = @@ROWCOUNT

-- save missing pk 's 
IF OBJECT_ID('tempdb.dbo.##bb_merge_synonyms_missing_pk') IS NOT NULL 
	DROP TABLE ##bb_merge_synonyms_missing_pk

SELECT A.SynonymID, SynName INTO ##bb_merge_synonyms_missing_pk
FROM 	CancerGovStaging.dbo.BestBetSynonyms_ATHENA A -- Source 
WHERE (A.Weight IS NOT NULL
AND NOT EXISTS
	(SELECT 1 FROM BestBetSynonyms_PROD P -- Target
		WHERE P.SynonymID = A.SynonymID)
)
AND A.IsNegated = 0

SET @rc2 = @@ROWCOUNT

-- save process insert pk's
IF OBJECT_ID('tempdb.dbo.##bb_merge_synonyms_process_ins_pk') IS NOT NULL 
	DROP TABLE ##bb_merge_synonyms_process_ins_pk

SELECT A.SynonymID INTO ##bb_merge_synonyms_process_ins_pk
FROM 	CancerGovStaging.dbo.BestBetSynonyms_ATHENA A -- Source 
WHERE 	A.IsNegated = 1
  AND EXISTS
	(SELECT 1 FROM CancerGovStaging.dbo.BestBetCategories P -- Target
		WHERE P.CategoryID = A.CategoryID)

set @rc3 = @@ROWCOUNT

-- save process update pk's
IF OBJECT_ID('tempdb.dbo.##bb_merge_synonyms_process_upd_pk') IS NOT NULL 
	DROP TABLE ##bb_merge_synonyms_process_upd_pk

SELECT A.SynonymID INTO ##bb_merge_synonyms_process_upd_pk
FROM 	CancerGovStaging.dbo.BestBetSynonyms_ATHENA A -- Source 
WHERE A.Weight IS NOT NULL
AND EXISTS
	(SELECT 1 FROM CancerGovStaging.dbo.BestBetSynonyms_PROD P -- Target
		WHERE P.SynonymID = A.SynonymID)


set @rc4 = @@ROWCOUNT

IF @doit = 1
BEGIN

	-- do the insert do 
	INSERT INTO CancerGovStaging.dbo.BestBetSynonyms_PROD  -- Target
	(
		SynonymID,
		CategoryID,
		SynName,
		Weight,
		UpdateDate,
		UpdateUserID,
		IsNegated
	)
	SELECT 
		SynonymID,
		CategoryID,
		SynName,
		Weight,
		UpdateDate,
		UpdateUserID,
		IsNegated

	FROM CancerGovStaging.dbo.BestBetSynonyms_ATHENA A   
	WHERE A.IsNegated = 1
  	AND EXISTS
		(SELECT 1 FROM CancerGovStaging.dbo.BestBetCategories P 
			WHERE P.CategoryID = A.CategoryID)

	SELECT @error1 = @@ERROR, @rowcount1 = @@ROWCOUNT

	--do the update do
	UPDATE CancerGovStaging.dbo.BestBetSynonyms_PROD
	SET
		SynonymID 	= A.SynonymID,
		CategoryID 	= A.CategoryID,
		SynName 	= A.SynName,
		Weight 		= A.Weight,
		UpdateDate 	= A.UpdateDate,
		UpdateUserID 	= A.UpdateUserID,
		IsNegated 	= A.IsNegated
	
	FROM 	CancerGovStaging.dbo.BestBetSynonyms_ATHENA 	A,
		CancerGovStaging.dbo.BestBetSynonyms_PROD 	P 
		
	WHERE P.SynonymID = A.SynonymID
	
	SELECT @error2 = @@ERROR, @rowcount2 = @@ROWCOUNT

	
	IF (@error1 + @error2) = 0 AND (@rc3 = @rowcount1) AND (@rc4 = @rowcount2)  
		COMMIT TRAN
				
	
	ELSE
		IF (@@TRANCOUNT > 0)
			ROLLBACK TRAN


	
END
	
SELECT 	@rc3 			AS 'Insert Rows Processed',
	@rc4 			AS 'Update Rows Processed',
	@rc1			AS 'Insert Rows missing CategoryID',
	@rc2			AS 'Update Rows missing pk'  	

IF @rc1 > 0
	SELECT SynonymID, SynName as 'Insert Rows missing CategoryID' 
	FROM ##bb_merge_synonyms_missing_categoryid
	ORDER BY 1	

IF @rc2 > 0
	SELECT SynonymID, SynName as 'Update Rows missing pk' 
	FROM ##bb_merge_synonyms_missing_pk
	ORDER BY 1	

GO
