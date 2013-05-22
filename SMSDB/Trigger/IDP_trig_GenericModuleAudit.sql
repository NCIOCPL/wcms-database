IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[IDP_trig_GenericModuleAudit]'))
EXEC dbo.sp_executesql @statement = N'begin     if @@rowcount = 0 return;
if (exists(select * from inserted) and not exists (select * from deleted)) 
insert into dbo.auditGenericModule( GenericModuleID,Namespace,CreateUserID,CreateDate,UpdateUserID,UpdateDate,category,moduleClass,EditNamespace,EditModuleClass,AssemblyName,IsVirtual,EditAssemblyName,AuditActionType       )     select GenericModuleID,Namespace,CreateUserID,CreateDate,UpdateUserID,UpdateDate,category,moduleClass,EditNamespace,EditModuleClass,AssemblyName,IsVirtual,EditAssemblyName,  ''I''  as AuditActionType     from inserted
else
insert into dbo.auditGenericModule( GenericModuleID,Namespace,CreateUserID,CreateDate,UpdateUserID,UpdateDate,category,moduleClass,EditNamespace,EditModuleClass,AssemblyName,IsVirtual,EditAssemblyName,AuditActionType       )     select GenericModuleID,Namespace,CreateUserID,CreateDate,UpdateUserID,UpdateDate,category,moduleClass,EditNamespace,EditModuleClass,AssemblyName,IsVirtual,EditAssemblyName, case when exists(select * from inserted) then ''U'' else ''D'' end as AuditActionType     from deleted      end
' 
GO
