IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_PrettyUrl_IsUsed]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_PrettyUrl_IsUsed]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************
* Purpose:	Checks to see if a pretty url is being used.
* Author:	BryanP
* Date:		11/5/07
* Params: 
*	
********************************************************/
CREATE PROCEDURE [dbo].[Core_PrettyUrl_IsUsed] 
	@PrettyUrl varchar(512),
	@IsUsed bit OUTPUT
AS
BEGIN
	SET @IsUsed = 0

	if (EXISTS(SELECT PrettyUrlID FROM PrettyUrl WHERE PrettyUrl = @PrettyUrl)
		OR EXISTS(SELECT PrettyUrlID FROM PRODPrettyUrl WHERE PrettyUrl = @PrettyUrl))
		SET @IsUsed = 1
END

GO
GRANT EXECUTE ON [dbo].[Core_PrettyUrl_IsUsed] TO [websiteuser_role]
GO
