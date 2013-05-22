IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_GeneralComments_Add]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_GeneralComments_Add]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[usp_GeneralComments_Add]
@Comment	nvarchar(max), 
@CommentType	varchar(50)
as
Begin 
	insert into GeneralComments(CommentID, Comment, CommentDate, CommentType)
	values (newid(), @Comment, getdate(), @CommentType)
End

GO
GRANT EXECUTE ON [dbo].[usp_GeneralComments_Add] TO [CDEUser]
GO
