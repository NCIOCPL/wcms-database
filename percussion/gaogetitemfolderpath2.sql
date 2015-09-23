USE [Percussion]
GO

/****** Object:  UserDefinedFunction [dbo].[gaogetitemFolderPath2]    Script Date: 09/14/2015 12:37:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
if object_id('gaogetitemFolderPath2') is not null
drop function gaogetitemFolderPath2
go

create function [dbo].[gaogetitemFolderPath2](@contentid int
, @sitename varchar(200) )  
returns @r table (folderpath varchar(3000))
as  
BEGIN  

if @sitename = null 
	select @sitename = 'cancergov'
 
insert into @r 
 select dbo.percReport_getFolderpath(owner_id)  
  from dbo.psx_objectRelationship   
 where dependent_id = @contentid and config_id = 3 
and dbo.percReport_getFolderpath(owner_id) like @sitename + '%'

 return
  
  
END  
GO


