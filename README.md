# databaseChangeLog
My perl scripts for tracking changes to a database via GIT

This is just a repo to show an example of how they work. To have this script work you would need to have a 'production' database and user setup. I may add in a script to setup the demo of it soon.

#setupDemo.sh
This script will create a 'foo' and 'foo_dev' database; create and populate a table in 'foo'; add a 'foo' user and give permissions to 'foo' and 'foo_dev'. Once this has been run you can run the below perl scripts; rebuildDevDB.pl and loadSQL.pl. If I was nice I'd create a second script to take the demo databases and users out...

# scripts/rebuildDevDB.pl
This script is used to drop your current development database and copy the production database to development

#scripts/loadSQL.pl
This script loops through the *.sql files in the SQL/ directory. If the file has not been previously processed it is run; if successful a new line is added to the 'Change_Log' table.

#SQL/*.sql
Filenames are "$datetime-$Summary.sql". By using the datetime the files are run in order.

#DEVELOPMENT / PRODUCTION
Is a config file containing connection information to the database. This is primarily used by other scripts in whatever application I'm working on. The setupDemo.sh script will generate one for you.

