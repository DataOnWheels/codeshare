/********************************************************
The following script sets up WideWorldDW_2

This database will support the fact tables for the vertical demo


********************************************************/
-- add for external access - elastic queries
CREATE USER elasticuser
	FOR LOGIN elasticuser
	WITH DEFAULT_SCHEMA = dbo
GO

-- Add user to the database datareader role
EXEC sp_addrolemember N'db_datareader', N'elasticuser'

-- add elastic job user
create user elasticjob
  for login elasticjob
  with default_schema = dbo
go

-- add user to database owner role
exec sp_addrolemember N'db_owner', N'elasticjob'
go



-- create Fact_Purchase table
if exists(select 1 from sys.tables where name like 'Fact_Purchase')
  drop table dbo.Fact_Purchase;
go

CREATE TABLE [Fact_Purchase](
	[Purchase Key] [bigint] IDENTITY(1,1) NOT NULL,
	[Date Key] [date] NOT NULL,
	[Supplier Key] [int] NOT NULL,
	[Stock Item Key] [int] NOT NULL,
	[WWI Purchase Order ID] [int] NULL,
	[Ordered Outers] [int] NOT NULL,
	[Ordered Quantity] [int] NOT NULL,
	[Received Outers] [int] NOT NULL,
	[Package] [nvarchar](50) NOT NULL,
	[Is Order Finalized] [bit] NOT NULL,
	[Lineage Key] [int] NOT NULL,
 CONSTRAINT [PK_FactPurchase] PRIMARY KEY CLUSTERED 
(
	[Purchase Key] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO




