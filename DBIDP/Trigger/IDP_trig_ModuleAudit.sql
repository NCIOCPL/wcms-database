IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[IDP_trig_ModuleAudit]'))
EXEC dbo.sp_executesql @statement = N'begin     if @@rowcount = 0 return;
if (exists(select * from inserted) and not exists (select * from deleted)) 
insert into dbo.auditModule( ModuleID,ModuleName,GenericModuleID,CSSID,CreateUserID,CreateDate,UpdateUserID,UpdateDate,AuditActionType       )     select ModuleID,ModuleName,GenericModuleID,CSSID,CreateUserID,CreateDate,UpdateUserID,UpdateDate,  ''I''  as AuditActionType     from inserted
else
insert into dbo.auditModule( ModuleID,ModuleName,GenericModuleID,CSSID,CreateUserID,CreateDate,UpdateUserID,UpdateDate,AuditActionType       )     select ModuleID,ModuleName,GenericModuleID,CSSID,CreateUserID,CreateDate,UpdateUserID,UpdateDate, case when exists(select * from inserted) then ''U'' else ''D'' end as AuditActionType     from deleted      end
' 
GO
