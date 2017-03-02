#!/bin/bash

for geog in county state; do 
	psql -U postgres -c "CREATE TABLE ${geog} (id serial not null primary key, geoid varchar(12))"
	psql -U postgres -c "SELECT AddGeometryColumn ('public','${geog}','geom',4269,'MULTIPOLYGON',2);"
	j=`echo ${geog} | awk '{print toupper($0)}'` 
	k= 
	if [[ "$geog" == zcta510 ]]; then j=ZCTA5 k=10; fi 
	wget http://www2.census.gov/geo/tiger/TIGER2016/${j}/tl_2016_us_${geog}.zip -O ${geog}.zip 
	unzip ${geog}.zip 
	rm ${geog}.zip 
	shp2pgsql -I -s 4269 -g geom tl_2016_us_${geog}.shp | psql -U postgres -d postgres -q 
	rm tl_2016_us_${geog}* 
psql -U postgres -c "INSERT INTO ${geog} (geoid,geom) (SELECT geoid${k}, geom FROM tl_2016_us_${geog})" 
psql -U postgres -c "DROP TABLE tl_2016_us_${geog}" 
psql -U postgres -c "CREATE INDEX ${geog}_index ON ${geog} USING GIST (geom)" 		
done
geog=zipcode
psql -U postgres -c "CREATE TABLE ${geog} (id serial not null primary key, geoid varchar(12))"
psql -U postgres -c "SELECT AddGeometryColumn ('public','${geog}','geom',4269,'MULTIPOLYGON',2);"
wget https://s3.amazonaws.com/ui-twitter/Misc_Helper_Files/US_Zip_Codes.zip -O US_Zip_Codes.zip
unzip US_Zip_Codes.zip
rm US_Zip_Codes.zip
shp2pgsql -I -s 4269 -g geom US_Zip_Codes.shp | psql -U postgres -d postgres -q 
rm US_Zip_Codes.*
psql -U postgres -c "INSERT INTO ${geog} (geoid,geom) (SELECT ZIP_CODE as geoid, geom FROM US_Zip_Codes)" 
psql -U postgres -c "DROP TABLE US_Zip_Codes" 
psql -U postgres -c "CREATE INDEX ${geog}_index ON ${geog} USING GIST (geom)" 	
