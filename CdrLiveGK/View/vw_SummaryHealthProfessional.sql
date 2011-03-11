IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[vw_SummaryHealthProfessional]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[vw_SummaryHealthProfessional]
GO



CREATE view [dbo].[vw_SummaryHealthProfessional]
as

select d.DocumentID, d.DocumentGUID,  d.Version,
			 s.Type, s.Language, s.Title
from Document d, Summary s
where d.DocumentID = s.SummaryID
and d.IsActive = 1
and Audience = 'Health professionals'


GO
GRANT SELECT ON [dbo].[vw_SummaryHealthProfessional] TO [webAdminUser_role]
GO
GRANT SELECT ON [dbo].[vw_SummaryHealthProfessional] ([DocumentID]) TO [webAdminUser_role]
GO
GRANT SELECT ON [dbo].[vw_SummaryHealthProfessional] ([DocumentGUID]) TO [webAdminUser_role]
GO
GRANT SELECT ON [dbo].[vw_SummaryHealthProfessional] ([Version]) TO [webAdminUser_role]
GO
GRANT SELECT ON [dbo].[vw_SummaryHealthProfessional] ([Type]) TO [webAdminUser_role]
GO
GRANT SELECT ON [dbo].[vw_SummaryHealthProfessional] ([Language]) TO [webAdminUser_role]
GO
GRANT SELECT ON [dbo].[vw_SummaryHealthProfessional] ([Title]) TO [webAdminUser_role]
GO
