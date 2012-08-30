IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[IDP_trig_PRODListItemAudit]'))
EXEC dbo.sp_executesql @statement = N'begin     if @@rowcount = 0 return;
if (exists(select * from inserted) and not exists (select * from deleted)) 
insert into dbo.auditPRODListItem( ListItemInstanceID,ListID,ListItemID,ListItemTypeID,IsFeatured,Priority,CreateUserID,CreateDate,UpdateUserID,UpdateDate,overriddenTitle,overriddenshortTitle,overriddenDescription,OverriddenAnchor,overriddenQuery,FileSize,FileIcon,SupplementalText,AuditActionType       )     select ListItemInstanceID,ListID,ListItemID,ListItemTypeID,IsFeatured,Priority,CreateUserID,CreateDate,UpdateUserID,UpdateDate,overriddenTitle,overriddenshortTitle,overriddenDescription,OverriddenAnchor,overriddenQuery,FileSize,FileIcon,SupplementalText,  ''I''  as AuditActionType     from inserted
else
insert into dbo.auditPRODListItem( ListItemInstanceID,ListID,ListItemID,ListItemTypeID,IsFeatured,Priority,CreateUserID,CreateDate,UpdateUserID,UpdateDate,overriddenTitle,overriddenshortTitle,overriddenDescription,OverriddenAnchor,overriddenQuery,FileSize,FileIcon,SupplementalText,AuditActionType       )     select ListItemInstanceID,ListID,ListItemID,ListItemTypeID,IsFeatured,Priority,CreateUserID,CreateDate,UpdateUserID,UpdateDate,overriddenTitle,overriddenshortTitle,overriddenDescription,OverriddenAnchor,overriddenQuery,FileSize,FileIcon,SupplementalText, case when exists(select * from inserted) then ''U'' else ''D'' end as AuditActionType     from deleted      end
' 
GO
