
/********************************************************
The following script sets up WideWorldDW_3

This will create the dimensions
********************************************************/



CREATE USER elasticuser
	FOR LOGIN elasticuser
	WITH DEFAULT_SCHEMA = dbo
GO

-- Add user to the database datareader role
EXEC sp_addrolemember N'db_datareader', N'elasticuser'
-- Add user to the database owner role to support use of sp_execute_remote
--EXEC sp_droprolemember N'db_owner', N'elasticuser'
GO

-- add elastic job user
create user elasticjob
  for login elasticjob
  with default_schema = dbo
go

-- add user to database owner role
exec sp_addrolemember N'db_owner', N'elasticjob'
go


if exists(select 1 from sys.tables where name like 'dimDate')
	drop table dbo.dimDate;
go

CREATE TABLE [dimDate](
	[Date] [date] NOT NULL,
	[Day Number] [int] NOT NULL,
	[Day] [nvarchar](10) NOT NULL,
	[Month] [nvarchar](10) NOT NULL,
	[Short Month] [nvarchar](3) NOT NULL,
	[Calendar Month Number] [int] NOT NULL,
	[Calendar Month Label] [nvarchar](20) NOT NULL,
	[Calendar Year] [int] NOT NULL,
	[Calendar Year Label] [nvarchar](10) NOT NULL,
	[Fiscal Month Number] [int] NOT NULL,
	[Fiscal Month Label] [nvarchar](20) NOT NULL,
	[Fiscal Year] [int] NOT NULL,
	[Fiscal Year Label] [nvarchar](10) NOT NULL,
	[ISO Week Number] [int] NOT NULL,
 CONSTRAINT [PK_dimDate] PRIMARY KEY CLUSTERED 
(
	[Date] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

if exists(select 1 from sys.tables where name like 'dimStockItem')
	drop table dbo.dimStockItem;
go

CREATE TABLE [dimStockItem](
	[Stock Item Key] [int] NOT NULL,
	[WWI Stock Item ID] [int] NOT NULL,
	[Stock Item] [nvarchar](100) NOT NULL,
	[Color] [nvarchar](20) NOT NULL,
	[Selling Package] [nvarchar](50) NOT NULL,
	[Buying Package] [nvarchar](50) NOT NULL,
	[Brand] [nvarchar](50) NOT NULL,
	[Size] [nvarchar](20) NOT NULL,
	[Lead Time Days] [int] NOT NULL,
	[Quantity Per Outer] [int] NOT NULL,
	[Is Chiller Stock] [bit] NOT NULL,
	[Barcode] [nvarchar](50) NULL,
	[Tax Rate] [decimal](18, 3) NOT NULL,
	[Unit Price] [decimal](18, 2) NOT NULL,
	[Recommended Retail Price] [decimal](18, 2) NULL,
	[Typical Weight Per Unit] [decimal](18, 3) NOT NULL,
	[Photo] [varbinary](max) NULL,
	[Valid From] [datetime2](7) NOT NULL,
	[Valid To] [datetime2](7) NOT NULL,
	[Lineage Key] [int] NOT NULL,
 CONSTRAINT [PK_dimStockItem] PRIMARY KEY CLUSTERED 
(
	[Stock Item Key] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

if exists(select 1 from sys.tables where name like 'dimSupplier')
  drop table dimSupplier;
go

CREATE TABLE [dimSupplier](
	[Supplier Key] [int] NOT NULL,
	[WWI Supplier ID] [int] NOT NULL,
	[Supplier] [nvarchar](100) NOT NULL,
	[Category] [nvarchar](50) NOT NULL,
	[Primary Contact] [nvarchar](50) NOT NULL,
	[Supplier Reference] [nvarchar](20) NULL,
	[Payment Days] [int] NOT NULL,
	[Postal Code] [nvarchar](10) NOT NULL,
	[Valid From] [datetime2](7) NOT NULL,
	[Valid To] [datetime2](7) NOT NULL,
	[Lineage Key] [int] NOT NULL,
 CONSTRAINT [PK_dimSupplier] PRIMARY KEY CLUSTERED 
(
	[Supplier Key] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
