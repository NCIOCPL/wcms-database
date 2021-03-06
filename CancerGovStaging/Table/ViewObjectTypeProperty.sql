SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[ViewObjectTypeProperty]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[ViewObjectTypeProperty](
	[NCIObjectID] [uniqueidentifier] NOT NULL,
	[PropertyName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PropertyValue] [varchar](7800) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Comments] [varchar](2500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Description] [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsDefaultValue] [varchar](2500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__ViewObjec__Updat__76A18A26]  DEFAULT (user_name()),
	[UpdateDate] [datetime] NULL CONSTRAINT [DF__ViewObjec__Updat__7795AE5F]  DEFAULT (getdate()),
	[ValueType] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Editable] [bit] NULL CONSTRAINT [DF__ViewObjec__Edita__7889D298]  DEFAULT (1),
 CONSTRAINT [PK_ViewObjectTypeProperty] PRIMARY KEY CLUSTERED 
(
	[NCIObjectID] ASC,
	[PropertyName] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
) ON [PRIMARY]
END
GO
