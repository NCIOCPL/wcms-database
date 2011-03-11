IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_DeleteOldModality]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_DeleteOldModality]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure DBO.usp_DeleteOldModality
as
Begin
declare @s varchar(8000)
select @s = ''
select @s = @s + ',' + convert(varchar(20), modalityID)
from dbo.modality m 
	where not exists (select * from dbo.protocolModality pm where pm.modalityID = m.modalityID)

if len(@s) > 0 
	begin
		delete m from dbo.modality m 
			where not exists (select * from dbo.protocolModality pm where pm.modalityID = m.modalityID)
		IF (@@ERROR <> 0)
			BEGIN
				RAISERROR ( 69998, 16, 1, 0,'Modality')
				RETURN 69998
			END 
		select @s = substring(@s,2,len(@s)-1)
	end

select @s as ModalityID

end

GO
GRANT EXECUTE ON [dbo].[usp_DeleteOldModality] TO [Gatekeeper_role]
GO
