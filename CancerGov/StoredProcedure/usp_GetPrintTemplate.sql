IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetPrintTemplate]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetPrintTemplate]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO




/*	NCI - National Cancer Institute
*	
*	Purpose:	
*	- Return PrintTemplate URL for provided @NCIViewID
*
*	Objects Used:
*
*	Rem:
*
*
*	Change History:
*	10/2/2003 	Alex Pidlisnyy	Script Created
*	11/4/2003	Bryan Pizzillo Director's Update Change
*	To Do List:
*	- use transactions
*
*/
/*
	INSERT INTO dbo.TemplateProperty ( NCITemplateID, PropertyName, PropertyValue, IsDefaultValue, Comments, [Description], ValueType, Editable ) VALUES ( 'A451FD26-6907-4421-B95E-2BF82AD0BACB', 'PrintTemplateURL', 'Content_nav_print.aspx', NULL, 'Do not change this URL. Talk to Cancer.gov developers before doing so.', 'URL to the PrintTemplate for the Template.', 'Unbounded text', 0)
	INSERT INTO dbo.TemplateProperty ( NCITemplateID, PropertyName, PropertyValue, IsDefaultValue, Comments, [Description], ValueType, Editable ) VALUES ( '64C492F0-C314-46D2-8566-48F576597ACA', 'PrintTemplateURL', 'DC_Content_nav_print.aspx', NULL, 'Do not change this URL. Talk to Cancer.gov developers before doing so.', 'URL to the PrintTemplate for the Template.', 'Unbounded text', 0)
	INSERT INTO dbo.TemplateProperty ( NCITemplateID, PropertyName, PropertyValue, IsDefaultValue, Comments, [Description], ValueType, Editable ) VALUES ( '05BFA291-F1AE-42F9-ACD2-CDC9E2F892F0', 'PrintTemplateURL', 'Page_Print.aspx', NULL, 'Do not change this URL. Talk to Cancer.gov developers before doing so.', 'URL to the PrintTemplate for the Template.', 'Unbounded text', 0)
	INSERT INTO dbo.TemplateProperty ( NCITemplateID, PropertyName, PropertyValue, IsDefaultValue, Comments, [Description], ValueType, Editable ) VALUES ( 'CE699943-4970-411C-A1A0-A095C095336D', 'PrintTemplateURL', 'Page_Print.aspx', NULL, 'Do not change this URL. Talk to Cancer.gov developers before doing so.', 'URL to the PrintTemplate for the Template.', 'Unbounded text', 0)
	INSERT INTO dbo.TemplateProperty ( NCITemplateID, PropertyName, PropertyValue, IsDefaultValue, Comments, [Description], ValueType, Editable ) VALUES ( '4E21A855-49D3-48EE-B4CB-4568D7C9421D', 'PrintTemplateURL', 'Page_Print.aspx', NULL, 'Do not change this URL. Talk to Cancer.gov developers before doing so.', 'URL to the PrintTemplate for the Template.', 'Unbounded text', 0)
	INSERT INTO dbo.TemplateProperty ( NCITemplateID, PropertyName, PropertyValue, IsDefaultValue, Comments, [Description], ValueType, Editable ) VALUES ( '3A021A3F-BE93-49A6-A20C-973740685159', 'PrintTemplateURL', 'Page_Print.aspx', NULL, 'Do not change this URL. Talk to Cancer.gov developers before doing so.', 'URL to the PrintTemplate for the Template.', 'Unbounded text', 0)
	INSERT INTO dbo.TemplateProperty ( NCITemplateID, PropertyName, PropertyValue, IsDefaultValue, Comments, [Description], ValueType, Editable ) VALUES ( 'EC8B6CB6-9C31-4A46-9463-F964AE7AC06E', 'PrintTemplateURL', 'Page_Print.aspx', NULL, 'Do not change this URL. Talk to Cancer.gov developers before doing so.', 'URL to the PrintTemplate for the Template.', 'Unbounded text', 0)
	INSERT INTO dbo.TemplateProperty ( NCITemplateID, PropertyName, PropertyValue, IsDefaultValue, Comments, [Description], ValueType, Editable ) VALUES ( 'E3212EFE-C56B-4BC3-A7F2-BE47CFBFFCED', 'PrintTemplateURL', 'Page_Print.aspx', NULL, 'Do not change this URL. Talk to Cancer.gov developers before doing so.', 'URL to the PrintTemplate for the Template.', 'Unbounded text', 0)
	INSERT INTO dbo.TemplateProperty ( NCITemplateID, PropertyName, PropertyValue, IsDefaultValue, Comments, [Description], ValueType, Editable ) VALUES ( '967667FF-C4DE-42F0-BDE7-64317082A224', 'PrintTemplateURL', 'Page_Print.aspx', NULL, 'Do not change this URL. Talk to Cancer.gov developers before doing so.', 'URL to the PrintTemplate for the Template.', 'Unbounded text', 0)
	INSERT INTO dbo.TemplateProperty ( NCITemplateID, PropertyName, PropertyValue, IsDefaultValue, Comments, [Description], ValueType, Editable ) VALUES ( 'BF0FB2A7-73FE-43F7-832F-769C860FD58F', 'PrintTemplateURL', 'Page_Print.aspx', NULL, 'Do not change this URL. Talk to Cancer.gov developers before doing so.', 'URL to the PrintTemplate for the Template.', 'Unbounded text', 0)
	INSERT INTO dbo.TemplateProperty ( NCITemplateID, PropertyName, PropertyValue, IsDefaultValue, Comments, [Description], ValueType, Editable ) VALUES ( '559C38CC-A94F-4D82-B9E7-90A6EE7C6576', 'PrintTemplateURL', 'Page_Print.aspx', NULL, 'Do not change this URL. Talk to Cancer.gov developers before doing so.', 'URL to the PrintTemplate for the Template.', 'Unbounded text', 0)
	INSERT INTO dbo.TemplateProperty ( NCITemplateID, PropertyName, PropertyValue, IsDefaultValue, Comments, [Description], ValueType, Editable ) VALUES ( '9B7A3F6C-FF23-4802-96AF-A03BA98F7B2C', 'PrintTemplateURL', 'Page_Print.aspx', NULL, 'Do not change this URL. Talk to Cancer.gov developers before doing so.', 'URL to the PrintTemplate for the Template.', 'Unbounded text', 0)
	INSERT INTO dbo.TemplateProperty ( NCITemplateID, PropertyName, PropertyValue, IsDefaultValue, Comments, [Description], ValueType, Editable ) VALUES ( 'AC4D28B8-654E-4764-899F-32F1BFAA7313', 'PrintTemplateURL', 'Page_Print.aspx', NULL, 'Do not change this URL. Talk to Cancer.gov developers before doing so.', 'URL to the PrintTemplate for the Template.', 'Unbounded text', 0)
	INSERT INTO dbo.TemplateProperty ( NCITemplateID, PropertyName, PropertyValue, IsDefaultValue, Comments, [Description], ValueType, Editable ) VALUES ( 'BB5EA5C8-3C9D-4549-AAE1-B9912FB6F7A0', 'PrintTemplateURL', 'Page_Print.aspx', NULL, 'Do not change this URL. Talk to Cancer.gov developers before doing so.', 'URL to the PrintTemplate for the Template.', 'Unbounded text', 0)
	INSERT INTO dbo.TemplateProperty ( NCITemplateID, PropertyName, PropertyValue, IsDefaultValue, Comments, [Description], ValueType, Editable ) VALUES ( '265FEEAF-2553-4FCB-A446-F0DAC3D6F613', 'PrintTemplateURL', 'Page_Print.aspx', NULL, 'Do not change this URL. Talk to Cancer.gov developers before doing so.', 'URL to the PrintTemplate for the Template.', 'Unbounded text', 0)
	INSERT INTO dbo.TemplateProperty ( NCITemplateID, PropertyName, PropertyValue, IsDefaultValue, Comments, [Description], ValueType, Editable ) VALUES ( '64895958-E443-4D76-86A0-2AFCB214465E', 'PrintTemplateURL', 'Page_Print.aspx', NULL, 'Do not change this URL. Talk to Cancer.gov developers before doing so.', 'URL to the PrintTemplate for the Template.', 'Unbounded text', 0)
	INSERT INTO dbo.TemplateProperty ( NCITemplateID, PropertyName, PropertyValue, IsDefaultValue, Comments, [Description], ValueType, Editable ) VALUES ( '3A1183E1-AEE2-442E-8418-3D103CAC6B0F', 'PrintTemplateURL', 'Page_Print.aspx', NULL, 'Do not change this URL. Talk to Cancer.gov developers before doing so.', 'URL to the PrintTemplate for the Template.', 'Unbounded text', 0)
	INSERT INTO dbo.TemplateProperty ( NCITemplateID, PropertyName, PropertyValue, IsDefaultValue, Comments, [Description], ValueType, Editable ) VALUES ( '55CD82CD-07DD-41A9-93B8-A902AA2EB8BD', 'PrintTemplateURL', 'Page_Print.aspx', NULL, 'Do not change this URL. Talk to Cancer.gov developers before doing so.', 'URL to the PrintTemplate for the Template.', 'Unbounded text', 0)
	INSERT INTO dbo.TemplateProperty ( NCITemplateID, PropertyName, PropertyValue, IsDefaultValue, Comments, [Description], ValueType, Editable ) VALUES ( '9DF36B34-629A-426A-8054-F82FCF026220', 'PrintTemplateURL', 'Page_Print.aspx', NULL, 'Do not change this URL. Talk to Cancer.gov developers before doing so.', 'URL to the PrintTemplate for the Template.', 'Unbounded text', 0)
	INSERT INTO dbo.TemplateProperty ( NCITemplateID, PropertyName, PropertyValue, IsDefaultValue, Comments, [Description], ValueType, Editable ) VALUES ( '578C98FE-C6D7-4AAB-B25D-947906D6CF7F', 'PrintTemplateURL', 'Page_Print.aspx', NULL, 'Do not change this URL. Talk to Cancer.gov developers before doing so.', 'URL to the PrintTemplate for the Template.', 'Unbounded text', 0)
	INSERT INTO dbo.TemplateProperty ( NCITemplateID, PropertyName, PropertyValue, IsDefaultValue, Comments, [Description], ValueType, Editable ) VALUES ( 'FFF2D734-6A7A-46F0-AF38-DA69C8749AD0', 'PrintTemplateURL', 'Page_Print.aspx', NULL, 'Do not change this URL. Talk to Cancer.gov developers before doing so.', 'URL to the PrintTemplate for the Template.', 'Unbounded text', 0)

*/
CREATE PROCEDURE dbo.usp_GetPrintTemplate
	(
	@ViewID uniqueidentifier
	)
AS
BEGIN
	DECLARE	@PrintTemplate varchar(2000)
	
	-- First will be better to check Print Template assigned to the NCIView in the ViewProperty table 
	-- if no information exists then 
	-- (this functionality not implemented yet)

	-- Get global value from the TemplateProperty table 
	SELECT 	TOP 1
		@PrintTemplate = TP.PropertyValue
	FROM 	dbo.NCIView AS V WITH (READUNCOMMITTED)
		INNER JOIN dbo.TemplateProperty AS TP
			ON TP.NCITemplateID = V.NCITemplateID 
			AND PropertyName = 'PrintTemplateURL'
	WHERE	V.NCIViewID = @ViewID 

	-- SELECT @PrintTemplate AS PrintTemplate1
	SELECT ISNULL( @PrintTemplate, 'Page_Print.aspx') AS PrintTemplate

END



GO
GRANT EXECUTE ON [dbo].[usp_GetPrintTemplate] TO [websiteuser_role]
GO
