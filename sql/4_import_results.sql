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

BULK INSERT polaris.SILS_duplicate_processing
FROM 'C:\your_file_name_here.csv'
WITH 
( FIELDTERMINATOR = ',',
  ROWTERMINATOR = '0x0a' )