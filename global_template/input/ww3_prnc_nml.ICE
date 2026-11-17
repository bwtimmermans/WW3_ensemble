
&FORCING_NML
FORCING%TIMESTART = '<start_year><start_month>01 000000' 
FORCING%TIMESTOP = '<start_year><start_month><stop_day> 230000' 
FORCING%GRID%LATLON = t
FORCING%FIELD%ICE_CONC = t ! Ice concentration
/

&FILE_NML
FILE%FILENAME = 'ice.nc'
FILE%LONGITUDE = 'lon'
FILE%LATITUDE = 'lat'
FILE%VAR(1) = 'ci'
/
