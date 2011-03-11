IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_ExternalobjectINSTEAD_OF_UPDATE]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	--First we update Original Document
	UPDATE Original
	SET 	
		Original.ExternalobjectID =	New.ExternalobjectID,
		Original.Title		=	New.Title,
		Original.[Format]	=	New.[Format],
		Original.[Description]	=  	New.[Description],
		Original.Path		=	New.Path,
		Original.[Text]		=	New.[Text],
		Original.UpdateDate 	= GETDATE(),	
		Original.UpdateUserID = New.UpdateUserID
	FROM	Externalobject  as Original, inserted as New 	
	WHERE 	Original.ExternalobjectID = New.ExternalobjectID

	--Then we log information in to the DocumentAudit table
	INSERT INTO AuditExternalobject  (
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
		''UPDATE'' as AuditActionType,
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
