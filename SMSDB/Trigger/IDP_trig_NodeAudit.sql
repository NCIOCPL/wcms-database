IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[IDP_trig_NodeAudit]'))
EXEC dbo.sp_executesql @statement = N'begin     if @@rowcount = 0 return;
if (exists(select * from inserted) and not exists (select * from deleted)) 
insert into dbo.auditNode( NodeID,Title,ShortTitle,Description,ParentNodeID,ShowInNavigation,ShowInBreadCrumbs,Priority,CreateUserID,CreateDate,UpdateUserID,UpdateDate,status,isPublished,DisplayPostedDate,DisplayUpdateDate,DisplayReviewDate,DisplayExpirationDate,DisplayDateMode,AuditActionType       )     select NodeID,Title,ShortTitle,Description,ParentNodeID,ShowInNavigation,ShowInBreadCrumbs,Priority,CreateUserID,CreateDate,UpdateUserID,UpdateDate,status,isPublished,DisplayPostedDate,DisplayUpdateDate,DisplayReviewDate,DisplayExpirationDate,DisplayDateMode,  ''I''  as AuditActionType     from inserted
else
insert into dbo.auditNode( NodeID,Title,ShortTitle,Description,ParentNodeID,ShowInNavigation,ShowInBreadCrumbs,Priority,CreateUserID,CreateDate,UpdateUserID,UpdateDate,status,isPublished,DisplayPostedDate,DisplayUpdateDate,DisplayReviewDate,DisplayExpirationDate,DisplayDateMode,AuditActionType       )     select NodeID,Title,ShortTitle,Description,ParentNodeID,ShowInNavigation,ShowInBreadCrumbs,Priority,CreateUserID,CreateDate,UpdateUserID,UpdateDate,status,isPublished,DisplayPostedDate,DisplayUpdateDate,DisplayReviewDate,DisplayExpirationDate,DisplayDateMode, case when exists(select * from inserted) then ''U'' else ''D'' end as AuditActionType     from deleted      end
' 
GO
