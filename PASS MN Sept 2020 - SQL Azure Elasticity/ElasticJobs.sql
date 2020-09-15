--- SETUP and EXECUTE Elastic Jobs ----

create master key;
go

-- add scoped creds for user databases and master database on the server

if not exists(select 1 from sys.database_scoped_credentials where name = 'elasticjob')
  create database scoped credential elasticjob with identity = 'elasticjob', secret = 'PassMn2020!';
go

if not exists(select 1 from sys.database_scoped_credentials where name = 'masterjob')
  create database scoped credential masterjob with identity = 'masterjob', secret = 'PassMn2020!';
go


-- clean up tasks
exec jobs.sp_delete_job @job_name = 'AddNewTableOrRowRightNow', @force=1;
exec jobs.sp_delete_target_group @target_group_name = 'tgWideWorldDWs';
go

--- create single database target group
exec jobs.sp_add_target_group 'tgWideWorldDWs';
go

exec jobs.sp_add_target_group_member 
	@target_group_name = N'tgWideWorldDWs'
	,@target_type = N'SqlDatabase'
	,@server_name = N'<<servername>>.database.windows.net'
	,@database_name = N'WideWorldDW_1'
; 
go

-- check the jobs tables
select * from jobs.target_groups;
select * from jobs.target_group_members where target_group_name = N'tgWideWorldDWs'

go

-- add a job
exec jobs.sp_add_job @job_name = 'AddNewTableOrRowRightNow'

-- add a job step
exec jobs.sp_add_jobstep 
	@job_name = 'AddNewTableOrRowRightNow'
	, @command = 'if not exists (select 1 from sys.tables where object_id = object_id(''NewTable''))
					create table dbo.NewTable (col1 uniqueidentifier null); insert into dbo.NewTable values (NewID()); '
	, @credential_name = 'elasticjob'
	, @target_group_name = 'tgWideWorldDWs'

-- manually execute the job
exec jobs.sp_start_job 'AddNewTableOrRowRightNow'

-- check status of job executions
select * from jobs.job_executions;

-- check results -- need to run query on WideWorldDW_1

------------------------
-- create server target group
exec jobs.sp_delete_job @job_name = 'AddGuidTable', @force=1;
exec jobs.sp_delete_target_group @target_group_name = 'tbAllDbs';
go

--- create single database target group
exec jobs.sp_add_target_group 'tgAllDbs';
go

exec jobs.sp_add_target_group_member 
	@target_group_name = N'tgAllDbs'
	,@target_type = N'SqlServer'
	,@refresh_credential_name = N'masterjob' -- credential needed to view the current list of Dbs
	,@server_name = N'<<servername>>.database.windows.net'
; 
go

-- check the jobs tables
select * from jobs.target_group_members where target_group_name = N'tgAllDbs'

go

-- add a job
exec jobs.sp_add_job @job_name = 'AddGuidTable'

-- add a job step
exec jobs.sp_add_jobstep 
	@job_name = 'AddGuidTable'
	, @command = 'if not exists (select 1 from sys.tables where object_id = object_id(''GuidTable''))
					create table dbo.GuidTable (col1 uniqueidentifier null); insert into dbo.GuidTable values (NewID()); '
	, @credential_name = 'elasticjob'
	, @target_group_name = 'tgAllDbs'

-- manually execute the job
exec jobs.sp_start_job 'AddGuidTable'

-- check status of job executions
select * from jobs.job_executions where job_name = 'AddGuidTable';

select * from jobs.job_executions where is_active = 1 and job_name = 'AddGuidTable' order by start_time desc;

-- because we don't have credentials set for one database we need to cancel. Use the following with the active guid from the previous query
exec jobs.sp_stop_job '5BDD10D8-6612-491D-AAC5-99C7B00EB136';

-- check results -- need to run query on target databases

-- exclude the problem databases
exec jobs.sp_add_target_group_member
	@target_group_name = 'tgAllDbs'
	, @membership_type = 'Exclude'
	, @target_type = 'SQLDatabase'
	, @server_name = '<<servername>>.database.windows.net'
	, @database_name = 'WideWorldImportersDW-Standard'
;
go
-- the job database is on the same server. The principal does not have permissions here either
exec jobs.sp_add_target_group_member
	@target_group_name = 'tgAllDbs'
	, @membership_type = 'Exclude'
	, @target_type = 'SQLDatabase'
	, @server_name = '<<servername>>.database.windows.net'
	, @database_name = 'ElasticJobDb'
;
go


-- rerun job
exec jobs.sp_start_job 'AddGuidTable'

-- check status of job executions
select * from jobs.job_executions where is_active = 1 and job_name = 'AddGuidTable' order by start_time desc;


