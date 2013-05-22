IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_HeaderINSTEAD_OF_UPDATE]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	--First we update Original Document
	UPDATE Original
	SET 	
		Original.HeaderID	= 	New.HeaderID,
		Original.[Name]		= 	New.[Name],
		Original.ContentType	= 	New.ContentType,	
		Original.Type		= 	New.Type,
		Original.Data		= 	New.Data,
		Original.IsApproved	= 	New.IsApproved	,
		Original.UpdateDate 	= GETDATE(),	
		Original.UpdateUserID = New.UpdateUserID
	FROM	Header as Original, inserted as New 	
	WHERE 	Original.HeaderID = New.HeaderID

	INSERT INTO AuditHeader (AuditActionType,
		[HeaderId],
		[Name],
		[ContentType],
		[Data],
		[Type],
		[IsApproved], 
		[UpdateUserID],
		[UpdateDate]) 
	SELECT ''UPDATE'' as AuditActionType,
		tbl.[HeaderId],
		tbl.[Name],
		tbl.[ContentType],
		tbl.[Data],
		tbl.[Type],
		tbl.[IsApproved], 
		tbl.[UpdateUserID],
		tbl.[UpdateDate]
	FROM 	inserted tbl
END



' 
GO
