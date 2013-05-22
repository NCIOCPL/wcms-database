IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_TaskStepArgumentOnInsert]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	INSERT INTO AuditTaskStepArgument(AuditActionType,
		[StepID],
		[ArgumentOrdinal],
		[ForProcedureX],
		[ArgumentValue],
		[UpdateDate],
		[UpdateUserID]	)
	SELECT ''INSERT'' as AuditActionType,
		tbl.[StepID],
		tbl.[ArgumentOrdinal],
		tbl.[ForProcedureX],
		tbl.[ArgumentValue],
		tbl.[UpdateDate],
		tbl.[UpdateUserID]
	FROM 	inserted tbl
END
' 
GO
