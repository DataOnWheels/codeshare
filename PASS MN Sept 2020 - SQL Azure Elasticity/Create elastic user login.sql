-- ======================================================================================
-- Create SQL Login template for Azure SQL Database and Azure SQL Data Warehouse Database
-- ======================================================================================

-- RUN THIS ON MASTER

CREATE LOGIN elasticuser
	WITH PASSWORD = 'PassMn2020!' 
GO

create login elasticjob
	with password = 'PassMn2020!'
go

create login masterjob
   with password = 'PassMn2020!'
go

-- add elastic job user for master database
create user masterjob
  for login masterjob
  with default_schema = dbo
go

-- add user to database dbmanager role
exec sp_addrolemember N'dbmanager', N'masterjob'
go

