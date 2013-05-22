IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[IDP_trig_PRODModuleInstanceAudit]'))
EXEC dbo.sp_executesql @statement = N'begin     if @@rowcount = 0 return;
if (exists(select * from inserted) and not exists (select * from deleted)) 
insert into dbo.auditPRODModuleInstance( ModuleInstanceID,ZoneInstanceID,ModuleID,Priority,CreateUserID,CreateDate,UpdateUserID,UpdateDate,ObjectID,AuditActionType       )     select ModuleInstanceID,ZoneInstanceID,ModuleID,Priority,CreateUserID,CreateDate,UpdateUserID,UpdateDate,ObjectID,  ''I''  as AuditActionType     from inserted
else
insert into dbo.auditPRODModuleInstance( ModuleInstanceID,ZoneInstanceID,ModuleID,Priority,CreateUserID,CreateDate,UpdateUserID,UpdateDate,ObjectID,AuditActionType       )     select ModuleInstanceID,ZoneInstanceID,ModuleID,Priority,CreateUserID,CreateDate,UpdateUserID,UpdateDate,ObjectID, case when exists(select * from inserted) then ''U'' else ''D'' end as AuditActionType     from deleted      end
' 
GO
