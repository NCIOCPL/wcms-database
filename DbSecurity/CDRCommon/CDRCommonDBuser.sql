
/****** Object:  Role [Gatekeeper_role]    Script Date: 12/24/2007 15:00:31 ******/
EXEC dbo.sp_addrole @rolename = N'Gatekeeper_role'
GO
/****** Object:  Role [prettyurluser_role]    Script Date: 12/24/2007 15:00:31 ******/
EXEC dbo.sp_addrole @rolename = N'prettyurluser_role'
GO
/****** Object:  Role [webAdminUser_role]    Script Date: 12/24/2007 15:00:31 ******/
EXEC dbo.sp_addrole @rolename = N'webAdminUser_role'
GO
/****** Object:  Role [webSiteUser_role]    Script Date: 12/24/2007 15:00:31 ******/
EXEC dbo.sp_addrole @rolename = N'webSiteUser_role'
GO
/****** Object:  User [Gatekeeperuser]    Script Date: 12/24/2007 15:00:31 ******/
EXEC dbo.sp_grantdbaccess @loginame = N'gatekeeperuser', @name_in_db = N'Gatekeeperuser'
GO
/****** Object:  User [prettyurluser]    Script Date: 12/24/2007 15:00:31 ******/
EXEC dbo.sp_grantdbaccess @loginame = N'prettyurluser', @name_in_db = N'prettyurluser'
GO
/****** Object:  User [webAdminUser]    Script Date: 12/24/2007 15:00:31 ******/
EXEC dbo.sp_grantdbaccess @loginame = N'webadminuser', @name_in_db = N'webAdminUser'
GO
/****** Object:  User [websiteuser]    Script Date: 12/24/2007 15:00:32 ******/
EXEC dbo.sp_grantdbaccess @loginame = N'websiteuser', @name_in_db = N'websiteuser'
GO
