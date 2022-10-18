# Setting up the demo
​
1. Create New Azure Resource Group
2. Create New Storage Account for bacpac file (standard BLOB storage)
3. Download Wide World Importers Standard DW bacpac file: https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
4. Upload the bacpac file to your storage account (I recommend using Storage Explorer to do this easily)
5. Create New Azure SQL Server and SQL Database for ElasticJobDb using S0 (we will use the server to restore the backup easily)
6. Browse to you SQL server and choose Import Database
7. Select the bacpac file from storage and complete the process (I recommend using a SQL login for admin)
8. Create three new databases to support elastic query examples - WideWorldDW_1, WideWorldDW_2, WideWorldDW_3 - I recommend S1 to support performance, but any standard or premium SKU will work.
9. Open up Azure Data Studio and connect to your server (you will need to set firewall rules)
10. Connect to Master and run Create elastic user login notebook (You can make Password changes if desired, leave user name to support following scripts. If you change the password, you will need to update the password in other scripts.)
11. Connect to WideWorldDW_2 and run WideWorldDW_2 Setup notebook
12. Connect to WideWorldDW_3 and run WideWorldDW_3 Setup notebook then Connect to WideWorldDW_1 and run WideWorldDW_1 Setup notebook
13. Add Azure Data Factory to your Resource Group
14. Open Azure Data Factory Studio
15. Use the + symbol to open the Copy Data Tool
16. For the source, create a connection for the WideWorldImportersDW-Standard database
17. Select the Fact.Purchase table from the list of existing tables
18. For the destination, create a connection for the WideWorldDW_2 database
19. Validate the mapping to the Fact_Purchase table we created (be sure to select the existing table)
20. Review and Finish - this will run the pipeline and load the table
21. Once completed, add a new Copy Data tool from the +
22. You can select the connection your previously created for the source (WideWorldImportersDW-Standard)
23. Select the following tables: Dimension.Date, Dimension.Stock Item, and Dimension.Supplier from existing tables
24. Add a new connection for the destination to point to the WideWorldDW_3 database
25. Select the existing tables as the targets and check the mappings
26. Review and finish. Now the tables are loaded for the demos
27. From here, you can work with the Elastic query demo notebook to complete the setup and explore using Elastic Query
28. Next, go back to the Resource Group in the Portal
29. Choose add a resource and search for Elastic job agent and add that
30. Give your agent a name and choose the ElasticJobsDb as the database
31. You are now ready to use the Elastic job demo notebook to run the demos for Elastic Jobs
Let me know if you have issues with the instructions or corrections to add.

As these are preview products, these instructions and scripts are accurate as of 10/16/2021.
