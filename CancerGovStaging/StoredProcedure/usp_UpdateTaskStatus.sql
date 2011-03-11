IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].usp_UpdateTaskStatus') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].usp_UpdateTaskStatus
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
		
					
CREATE PROCEDURE dbo.usp_UpdateTaskStatus
(
	@stepID	UniqueIdentifier
)
AS
	SET NOCOUNT OFF;

	Declare @objectID UniqueIdentifier

	Select @objectID = t.objectID from taskStep s, task t where s.StepID = @stepID and s.TaskID = t.TaskID

	if (exists (select * from NCIView where NCIViewID = @objectID))
	BEGIN
		Update NCIView
		set 	Status ='EDIT',
			UpdateDate= getdate()
		where 	NCIViewID = @objectID
		IF (@@ERROR <> 0)
		BEGIN
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
	END
	Else if (exists (select * from dbo.BestBetCategories where CategoryID = @objectID))
	BEGIN
		Update BestBetCategories
		set 	Status ='EDIT',
				UpdateDate= getdate()
		where 	CategoryID = @objectID
		IF (@@ERROR <> 0)
		BEGIN
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
	END
	Else if (exists (select * from dbo.TSMacros where MacroID = @objectID))
	BEGIN
		Update TSMacros
		set 	Status ='EDIT',
				UpdateDate= getdate()
		where 	MacroID = @objectID
		IF (@@ERROR <> 0)
		BEGIN
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
	END


	RETURN 0

GO
GRANT EXECUTE ON [dbo].usp_UpdateTaskStatus TO [webadminuser_role]
GO
