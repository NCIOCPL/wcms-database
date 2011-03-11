IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[Trig_XMLqueryAudit]'))
EXEC dbo.sp_executesql @statement = N'begin     
	if @@rowcount = 0 return;
	if (exists(select * from inserted) and not exists (select * from deleted)) 
		insert into dbo.auditXMLQuery( XMLQueryID,Name,queryText,comments, updateuserid, updatedate, AuditActionType       )    
			 select XMLQueryID,Name,queryText,comments, updateuserid, updatedate, ''I''  as AuditActionType     from inserted
	else
		insert into dbo.auditXMLQuery( XMLQueryID,Name,queryText,comments, updateuserid, updatedate,AuditActionType       )   
			  select XMLQueryID,Name,queryText,comments, updateuserid, updatedate, case when exists(select * from inserted) then ''U'' else ''D'' end as AuditActionType     from deleted      
end
' 
GO
