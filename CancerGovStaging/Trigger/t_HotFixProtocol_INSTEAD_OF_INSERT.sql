IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_HotFixProtocol_INSTEAD_OF_INSERT]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	--First Insert the ProtocolData
	INSERT INTO HotFixProtocol (
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
	SELECT 	ins.ProtocolID,
		ins.Comments, 
		ins.Title, 
		ins.ShortTitle, 
		ins.Abstract, 
		ins.DosageForms, 
		ins.DosageSchedule, 
		ins.EndPoints, 
		ins.EntryCriteria, 
		ins.Objectives, 
		ins.Outline, 
		ins.ProjectedAccrual, 
		ins.SpeciaStudyParameters, 
		ins.Stratification, 
		ins.Warning, 
		ins.CreateDate, 
		ins.CreateUserID, 
		ins.UpdatedDate, 
		ins.ApprovedDate, 
		ins.UpdateUserID, 
		ins.IsApproved
	FROM 	inserted ins


	--Then we log information in to the AuditProtocolData table
	INSERT INTO AuditHotFixProtocol (
		AuditActionType,
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
		''INSERT'' as AuditActionType,
		ins.ProtocolID,
		ins.Comments, 
		ins.Title, 
		ins.ShortTitle, 
		ins.Abstract, 
		ins.DosageForms, 
		ins.DosageSchedule, 
		ins.EndPoints, 
		ins.EntryCriteria, 
		ins.Objectives, 
		ins.Outline, 
		ins.ProjectedAccrual, 
		ins.SpeciaStudyParameters, 
		ins.Stratification, 
		ins.Warning, 
		ins.CreateDate, 
		ins.CreateUserID, 
		ins.UpdatedDate, 
		ins.ApprovedDate, 
		ins.UpdateUserID, 
		ins.IsApproved
	FROM 	inserted ins
END


' 
GO
