--creates two tables: 
--1) SILS_duplicates (for storing record information to be exported for Python processing)
--2) SILS_duplicate_processing (for storing merge sets after Python processing)

USE [Polaris]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [Polaris].[SILS_duplicates](
	[bibID] [int] NOT NULL,
	[Title] [varchar](max) NULL,
	[Author] [varchar](max) NULL,
	[PrimaryTOM] [int] NULL,
	[MARCMedium] [varchar](max) NULL,
	[PubDate1] [varchar](4) NULL,
	[Tag008] [varchar](max) NULL,
	[PubDate260] [varchar](max) NULL,
	[Tag24x] [int] NULL,
	[Tag3xx] [int] NULL,
	[Tag5xx] [int] NULL,
	[Tag6xx] [int] NULL,
	[Tag7xx] [int] NULL,
	[Tag856] [int] NULL,
	[TagMisc] [int] NULL,
	[LinkedItems] [int] NULL,
	[Tag300a] [varchar](max) NULL,
	[Tag300b] [varchar](max) NULL,
	[Tag300c] [varchar](max) NULL,
	[Tag490] [varchar](max) NULL,
	[Tag245c] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

USE [Polaris]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [Polaris].[SILS_duplicate_processing] (
	[BibID] [int] NULL,
	[DeletedID] [int] NULL
) ON [PRIMARY]

GO




