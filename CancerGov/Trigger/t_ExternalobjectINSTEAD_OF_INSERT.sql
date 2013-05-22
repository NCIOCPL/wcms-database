IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_ExternalobjectINSTEAD_OF_INSERT]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	--First Inser the Externalobject
	INSERT INTO Externalobject (	
		ExternalobjectID,
		Title,
		[Format],
		[Description],
		Path,
		[Text],
		UpdateDate,
		UpdateUserID)	
	SELECT 
		ins.ExternalobjectID,
		ins.Title,
		ins.[Format],
		ins.[Description],
		ins.Path,
		ins.[Text],
		ins.UpdateDate,
		ins.UpdateUserID
	FROM 	inserted ins


	--Then we log information in to the DocumentAudit table
	INSERT INTO AuditExternalobject (
		AuditActionType,
		ExternalobjectID,
		Title,
		[Format],
		[Description],
		Path,
		[Text],
		UpdateDate,
		UpdateUserID)	
	SELECT 
		''INSERT'' as AuditActionType,
		ins.ExternalobjectID,
		ins.Title,
		ins.[Format],
		ins.[Description],
		ins.Path,
		ins.[Text],
		ins.UpdateDate,
		ins.UpdateUserID
	FROM 	inserted ins
END
' 
GO
