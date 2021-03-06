/****** Object:  Trigger [t_PrettyURLOnINSERT]    Script Date: 05/22/2008 17:39:31 ******/
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[t_PrettyURLOnINSERT]'))
DROP TRIGGER [dbo].[t_PrettyURLOnINSERT]
GO
/****** Object:  Trigger [dbo].[t_PrettyURLOnINSERT]    Script Date: 05/22/2008 17:39:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER On
GO
/****** Object:  Trigger dbo.t_GroupsOnDelete    Script Date: 3/21/2002 14:34:43 PM ******/
CREATE TRIGGER [dbo].[t_PrettyURLOnINSERT] ON [dbo].[PrettyURL]
FOR INSERT
AS
BEGIN
	INSERT INTO AuditPrettyURL (AuditActionType,
	PrettyURLID,
	NCIViewID,
	DirectoryID,
	ObjectID,
	RealURL,
	CurrentURL,
	ProposedURL,
	UpdateRedirectOrNot, 
	IsPrimary, 
	IsRoot,
	CreateDate,
	UpdateUserID,
	UpdateDate)
	SELECT 'INSERT' as AuditActionType,
		ins.PrettyURLID,
		ins.NCIViewID,
		ins.DirectoryID,
		ins.ObjectID,
		ins.RealURL,
		ins.CurrentURL,
		ins.ProposedURL,
		ins.UpdateRedirectOrNot, 
		ins.IsPrimary, 
		ins.IsRoot,
		ins.CreateDate,
		ins.UpdateUserID,
		ins.UpdateDate 
	FROM 	inserted ins


	UPDATE prettyURLFlag
	Set NeedUpdate=1
END



