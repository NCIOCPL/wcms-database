IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_HotFixProtocol_INSTEAD_OF_DELETE]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	--Delete records from Original table
	DELETE 	Original
	FROM	HotFixProtocol as Original, 
		deleted as Old 	
	WHERE 	Original.ProtocolID = Old.ProtocolID

	INSERT INTO AuditHotFixProtocol (AuditActionType,
		ProtocolID, 
		Comments, 
		Title, 
		ShortTitle, 
		Abstract, 
		DosageForms, 
		DosageSchedule, 
		EndPoints, 
		EntryCriteria, 
		Objectives, 
		Outline, 
		ProjectedAccrual, 
		SpeciaStudyParameters, 
		Stratification, 
		Warning, 
		CreateDate, 
		CreateUserID, 
		UpdatedDate, 
		ApprovedDate, 
		UpdateUserID, 
		IsApproved)
	SELECT 
		''DELETE'' as AuditActionType,
		del.ProtocolID, 
		del.Comments, 
		del.Title, 
		del.ShortTitle, 
		del.Abstract, 
		del.DosageForms, 
		del.DosageSchedule, 
		del.EndPoints, 
		del.EntryCriteria, 
		del.Objectives, 
		del.Outline, 
		del.ProjectedAccrual, 
		del.SpeciaStudyParameters, 
		del.Stratification, 
		del.Warning, 
		del.CreateDate, 
		del.CreateUserID, 
		del.UpdatedDate, 
		del.ApprovedDate, 
		del.UpdateUserID, 
		del.IsApproved
	FROM 	deleted del
END


' 
GO
