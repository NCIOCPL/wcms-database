IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[IDP_trig_MemberAudit]'))
EXEC dbo.sp_executesql @statement = N'begin     if @@rowcount = 0 return;
if (exists(select * from inserted) and not exists (select * from deleted)) 
insert into dbo.auditMember( MemberID,MemberType,AuditActionType       )     select MemberID,MemberType,  ''I''  as AuditActionType     from inserted
else
insert into dbo.auditMember( MemberID,MemberType,AuditActionType       )     select MemberID,MemberType, case when exists(select * from inserted) then ''U'' else ''D'' end as AuditActionType     from deleted      end
' 
GO
