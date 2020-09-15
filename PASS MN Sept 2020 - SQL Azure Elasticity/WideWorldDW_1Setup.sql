
/********************************************************
The following script sets up WideWorldDW_1


********************************************************/

-- Master key is used to encrypt the credential (Azure does not require a password)
create master key;
go

-- add elastic job user
create user elasticjob
  for login elasticjob
  with default_schema = dbo
go

-- add user to database owner role
exec sp_addrolemember N'db_owner', N'elasticjob'
go


-- clean up demo environment
-- remove tables
if exists(select * from sys.external_tables where name = 'Fact_Purchase')
  drop external table dbo.Fact_Purchase;
go
if exists(select * from sys.external_tables where name = 'dimDate')
  drop external table dbo.dimDate;
go
if exists(select * from sys.external_tables where name = 'dimStockItem')
  drop external table dbo.dimStockItem;
go
if exists(select * from sys.external_tables where name = 'dimSupplier')
  drop external table dbo.dimSupplier;
go
-- remove data sources
if exists(select * from sys.external_data_sources where name = 'dsWideWorldDW_2')
  drop external data source dsWideWorldDW_2;
go
if exists(select * from sys.external_data_sources where name = 'dsWideWorldDW_3')
  drop external data source dsWideWorldDW_3;
go
-- remove credentials
if exists(select * from sys.database_scoped_credentials where name = 'elastic')
  drop database scoped credential elastic;
 go

 -------------------------------------
 --REBUILD STARTS HERE----------------
 -------------------------------------

-- create a scoped credential which matches a user with read access on the target external databases
-- NOTE: Currently AAD accounts are not supported for elastic queries

create database scoped credential elastic with identity = 'elasticuser', secret = 'PassMn2020!';
go

-- Next we create the external data source, we will create two as we will be working across two databases
create external data source dsWideWorldDW_2
  with
	(
		type=RDBMS,
		location='<<servername>>.database.windows.net',
		database_name = 'WideWorldDW_2',
		credential = elastic
	)
;

create external data source dsWideWorldDW_3
  with
	(
		type=RDBMS,
		location='<<servername>>.database.windows.net',
		database_name = 'WideWorldDW_3',
		credential = elastic
	)
;

-- Next we create the tables we want to connect to

create external table dbo.Fact_Purchase
(
	[Purchase Key] bigint NOT NULL,
	[Date Key] date NOT NULL,
	[Supplier Key] int NOT NULL,
	[Stock Item Key] int NOT NULL,
	[WWI Purchase Order ID] int NULL,
	[Ordered Outers] int NOT NULL,
	[Ordered Quantity] int NOT NULL,
	[Received Outers] int NOT NULL,
	[Package] nvarchar(50) NOT NULL,
	[Is Order Finalized] bit NOT NULL
	--,
	--[Lineage Key] int NOT NULL
	)
	with (DATA_SOURCE = dsWideWorldDW_2)
;

-- test the table
select count(*) from dbo.Fact_Purchase;

-- add the dimension tables from _3

create external table [dbo].[dimDate](
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
	[ISO Week Number] [int] NOT NULL
	) 
	with (data_source = dsWideWorldDW_3)
; 
go

create external table [dbo].[dimStockItem](
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
--	[Photo] [varbinary](max) NULL,  -- blob/binary types not supported with the exception of varchar/nvarchar(max)
	[Valid From] [datetime2](7) NOT NULL,
	[Valid To] [datetime2](7) NOT NULL,
	[Lineage Key] [int] NOT NULL
	)
	with (data_source = dsWideWorldDW_3)
;
go

-- remove some of the available columns
create external table [dbo].[dimSupplier](
	[Supplier Key] [int] NOT NULL,
	[WWI Supplier ID] [int] NOT NULL,
	[Supplier] [nvarchar](100) NOT NULL,
	[Category] [nvarchar](50) NOT NULL,
	--[Primary Contact] [nvarchar](50) NOT NULL,
	--[Supplier Reference] [nvarchar](20) NULL,
	--[Payment Days] [int] NOT NULL,
	[Postal Code] [nvarchar](10) NOT NULL
	--,
--	[Valid From] [datetime2](7) NOT NULL,
--	[Valid To] [datetime2](7) NOT NULL,
--	[Lineage Key] [int] NOT NULL
	)
	with (data_source = dsWideWorldDW_3)

;

go

-- columns removed from external table
select * from dbo.dimSupplier;

-- cannot be pulled through, this results in an error
select [Payment Days] from dbo.dimSupplier;

----- complex test

select sum(f.[Ordered Quantity]) as [Total Quantity]
	, si.Brand
	, si.Color
	, su.Supplier
	, su.Category
	, d.[Calendar Year]
from dbo.Fact_Purchase f
	inner join dbo.dimSupplier su on su.[Supplier Key] = f.[Supplier Key]
	inner join dbo.dimStockItem si on si.[Stock Item Key] = f.[Stock Item Key]
	inner join dbo.dimDate d on d.[Date] = f.[Date Key]
where si.Color not like 'N/A'
group by si.Brand
	, si.Color
	, su.Supplier
	, su.Category
	, d.[Calendar Year]
;
go

-- you can execute T-SQL directly as well with the sp_execute_remote; permissions apply as assigned to scoped credential

exec sp_execute_remote N'dsWideWorldDW_3', N'select * from dbo.dimSupplier';
go
