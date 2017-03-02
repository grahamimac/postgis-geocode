apt-get update -y
apt-get install wget unzip -y
mkdir gisdata
mkdir gisdata/temp
psql -U postgres -c "INSERT INTO tiger.loader_platform(os, declare_sect, pgbin, wget, unzip_command, psql, path_sep,loader, environ_set_command,county_process_command) SELECT 'standard', replace(replace(declare_sect,'PGDATABASE=geocoder','PGDATABASE=postgres'),'PGPASSWORD=yourpasswordhere','PGPASSWORD=') as declare_sect, pgbin, wget, unzip_command, psql, path_sep,loader, environ_set_command, county_process_command FROM tiger.loader_platform WHERE os = 'sh'"
psql -U postgres -c "SELECT Loader_Generate_Nation_Script('standard')" -d postgres -tA > /gisdata/nation_script_load.sh
sh /gisdata/nation_script_load.sh
psql -U postgres -c "SELECT Loader_Generate_Script(ARRAY['FL'], 'standard')" -d postgres -tA > /gisdata/fl_load.sh
sh /gisdata/fl_load.sh
rm -rf gisdata