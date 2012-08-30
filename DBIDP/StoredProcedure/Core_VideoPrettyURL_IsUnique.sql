IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_VideoPrettyURL_IsUnique]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_VideoPrettyURL_IsUnique]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*******************************************************
* Purpose:	Checks to see if a prettyurl is unique
* Author:	AshishB
* Date:		07/05/2007
* Params: 
*	@PrettyURL -- The PrettyURL of the Video to check


********************************************************/
CREATE PROCEDURE [dbo].[Core_VideoPrettyURL_IsUnique] 
	@PrettyURL varchar(512)
AS
BEGIN
	BEGIN
	IF (Exists(SELECT PrettyURL FROM dbo.VideoPrettyURL WHERE PrettyURL = @PrettyURL ))
		RETURN 0
	ELSE
		begin
		IF (Exists(SELECT PrettyURL FROM dbo.DocumentPrettyURL WHERE PrettyURL = @PrettyURL))
							RETURN 0
						ELSE
							begin
							IF (Exists(SELECT PrettyURL FROM dbo.PrettyURL WHERE PrettyURL = @PrettyURL))
							RETURN 0
							ELSE
							RETURN 1
							end
		end
		 
END
		 
END


GO
GRANT EXECUTE ON [dbo].[Core_VideoPrettyURL_IsUnique] TO [websiteuser_role]
GO
