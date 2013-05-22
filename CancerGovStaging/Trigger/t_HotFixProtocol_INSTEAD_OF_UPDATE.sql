IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_HotFixProtocol_INSTEAD_OF_UPDATE]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	--First we update Original Document
	UPDATE Original
	SET 	Original.Comments = New.Comments,
		Original.Title = New.Title ,
		Original.ShortTitle = New.ShortTitle,
		Original.Abstract = New.Abstract,
		Original.DosageForms = New.DosageForms,
		Original.DosageSchedule = New.DosageSchedule,
		Original.EndPoints = New.EndPoints,
		Original.EntryCriteria = New.EntryCriteria,
		Original.Objectives = New.Objectives,
		Original.Outline = New.Outline,
		Original.ProjectedAccrual = New.ProjectedAccrual,
		Original.SpeciaStudyParameters = New.SpeciaStudyParameters,
		Original.Stratification = New.Stratification,
		Original.Warning = New.Warning ,
		Original.CreateDate = New.CreateDate,
		Original.CreateUserID = New.CreateUserID,
		Original.UpdatedDate = New.UpdatedDate,
		Original.ApprovedDate = New.ApprovedDate,
		Original.UpdateUserID = New.UpdateUserID,
		Original.IsApproved = New.IsApproved  
	FROM	HotFixProtocol as Original, 
		inserted as New 	
	WHERE 	Original.ProtocolID = New.ProtocolID

	--Then we log information in to the DocumentAudit table
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
		''UPDATE'' as AuditActionType,
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
