IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_HotFixProtocolStudyContact_OnDELETE]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	INSERT INTO AuditHotFixProtocolStudyContact (AuditActionType,
		ProtocolID,
		PersonID,
		OrganizationID,
		CountryID,
		StateID,
		Country,
		State,
		City,
		OrganizationName,
		PersonName,
		PhoneNumber,
		OrgInfo,
		UpdateDate,
		UpdateUserID
		)
	SELECT ''DELETE'' as AuditActionType,
		tbl.ProtocolID,
		tbl.PersonID,
		tbl.OrganizationID,
		tbl.CountryID,
		tbl.StateID,
		tbl.Country,
		tbl.State,
		tbl.City,
		tbl.OrganizationName,
		tbl.PersonName,
		tbl.PhoneNumber,
		tbl.OrgInfo,
		tbl.UpdateDate,
		tbl.UpdateUserID
	FROM 	deleted tbl
END

' 
GO
