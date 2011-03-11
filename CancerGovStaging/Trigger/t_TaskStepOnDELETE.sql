IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_TaskStepOnDELETE]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	INSERT INTO AuditTaskStep(AuditActionType,
		[StepID],
		[TaskID],
		[ResponsibleGroupID],
		[Name],
		[Description],
		[Status],
		[OrderLevel],
		[AprvStoredProcedure],
		[DisAprvStoredProcedure],
		[OnErrorStoredProcedure],
		[IsAuto],
		[UpdateDate],
		[UpdateUserID]	)
	SELECT ''DELETE'' as AuditActionType,
		tbl.[StepID],
		tbl.[TaskID],
		tbl.[ResponsibleGroupID],
		tbl.[Name],
		tbl.[Description],
		tbl.[Status],
		tbl.[OrderLevel],
		tbl.[AprvStoredProcedure],
		tbl.[DisAprvStoredProcedure],
		tbl.[OnErrorStoredProcedure],
		tbl.[IsAuto],
		tbl.[UpdateDate],
		tbl.[UpdateUserID]	
	FROM 	deleted tbl
END
' 
GO
