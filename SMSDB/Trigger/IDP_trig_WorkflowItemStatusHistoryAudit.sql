IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[IDP_trig_WorkflowItemStatusHistoryAudit]'))
EXEC dbo.sp_executesql @statement = N'begin     if @@rowcount = 0 return;
if (exists(select * from inserted) and not exists (select * from deleted)) 
insert into dbo.auditWorkflowItemStatusHistory( WorkflowItemID,Action,PostActionStatus,ActionBy,Date,Comment,AuditActionType       )     select WorkflowItemID,Action,PostActionStatus,ActionBy,Date,Comment,  ''I''  as AuditActionType     from inserted
else
insert into dbo.auditWorkflowItemStatusHistory( WorkflowItemID,Action,PostActionStatus,ActionBy,Date,Comment,AuditActionType       )     select WorkflowItemID,Action,PostActionStatus,ActionBy,Date,Comment, case when exists(select * from inserted) then ''U'' else ''D'' end as AuditActionType     from deleted      end
' 
GO
