/* 
click on Select Postgres Server" at the bottom of your VS Code window
and choose rsm-docker and check if any of the below statements work
all queries below are commented out. remove the "--" in front of a
SELECT statement to make it available to run

press F5 or right-click on the editor window and select "Run Query"

what happens when you try to run a query for a table that is in another
database?
*/

-- SELECT * FROM "flights" LIMIT 5;
-- SELECT * FROM "films" LIMIT 5;
-- SELECT * FROM "mtcars" LIMIT 5;

/* choose WestCoastImporter as the active server and check if the below statement works */
-- SELECT * FROM "buyinggroup" LIMIT 5;

/* choose Northwind as the active server and check if the below statement works */
-- SELECT * FROM "products" LIMIT 5;

/* 
make sure you have the PostgreSQL extension for VS Code
installed (by Chris Kolkman)

make sure to "Select Postgres Server" at the bottom
of the VS Code window and then select a server and a database
*/