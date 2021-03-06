/****** Object:  Trigger [t_PrettyURLOnDelete]    Script Date: 05/22/2008 17:40:22 ******/਍ഀ
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[t_PrettyURLOnDelete]'))਍ഀ
DROP TRIGGER [dbo].[t_PrettyURLOnDelete]਍ഀ
GO਍ഀ
/****** Object:  Trigger [dbo].[t_PrettyURLOnDelete]    Script Date: 05/22/2008 17:40:16 ******/਍ഀ
SET ANSI_NULLS ON਍ഀ
GO਍ഀ
SET QUOTED_IDENTIFIER On਍ഀ
GO਍ഀ
/****** Object:  Trigger dbo.t_GroupsOnDelete    Script Date: 3/21/2002 14:34:43 PM ******/਍ഀ
CREATE TRIGGER [dbo].[t_PrettyURLOnDelete] ON [dbo].[PrettyURL]਍ഀ
FOR DELETE ਍ഀ
AS਍ഀ
BEGIN਍ഀ
	INSERT INTO AuditPrettyURL (AuditActionType,਍ഀ
	 	PrettyURLID,਍ഀ
		NCIViewID,਍ഀ
		DirectoryID,਍ഀ
		ObjectID,਍ഀ
		RealURL,਍ഀ
		CurrentURL,਍ഀ
		IsNew, ਍ഀ
		UpdateRedirectOrNot, ਍ഀ
		IsPrimary, ਍ഀ
		IsRoot,਍ഀ
		CreateDate,਍ഀ
		UpdateUserID,਍ഀ
		UpdateDate   )਍ഀ
	SELECT 'DELETE' as AuditActionType,਍ഀ
		ins.PrettyURLID,਍ഀ
		ins.NCIViewID,਍ഀ
		ins.DirectoryID,਍ഀ
		ins.ObjectID,਍ഀ
		ins.RealURL,਍ഀ
		ins.CurrentURL,਍ഀ
		ins.IsNew, ਍ഀ
		ins.UpdateRedirectOrNot, ਍ഀ
		ins.IsPrimary, ਍ഀ
		ins.IsRoot,਍ഀ
		ins.CreateDate,਍ഀ
		ins.UpdateUserID,਍ഀ
		ins.UpdateDate ਍ഀ
	FROM 	deleted ins਍ഀ
਍ഀ
	UPDATE prettyURLFlag਍ഀ
	Set NeedUpdate=1਍ഀ
END਍ഀ
਍ഀ
਍ഀ
