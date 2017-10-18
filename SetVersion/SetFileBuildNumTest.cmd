@echo off

echo --------------------------------------------------------
echo The follow test generates a random number, 
echo updates the build, and then reads back from the file.

set BuildNum=%RANDOM%
set InFile=x.dll
set OutFile=o.dll
echo Generated build number %BuildNum%

echo.

if not exist %InFile% (
	echo Cannot run this script because %InFile% was not found.
	goto EOF
)

SetFileBuildNum -b%BuildNum% -i%InFile% -o%OutFile% -q

if %ERRORLEVEL% NEQ 0 (
	echo Something went wrong
) else (
	echo Success!
	echo.
	echo Read from the file:
	SetFileBuildNum -sfalse -i%OutFile% -q
)

echo.
echo --------------------------------------------------------
echo The following test attepts to generate an error
echo by supplying a file that does not exist.

set BuildNum=%RANDOM%
set InFile=doesnotexist.dll
set OutFile=o.dll
echo Generated build number %BuildNum%

echo.

if exist %InFile% (
	echo Cannot run this script because %InFile% was found.
	goto EOF
)

SetFileBuildNum -b%BuildNum% -i%InFile% -o%OutFile% -q

if %ERRORLEVEL% NEQ 0 (
	echo Good, the file didn't exist, and SetFileBuildNum returned non-zero.
	SetFileBuildNum -sfalse -i%InFile% -q
	SetFileBuildNum -sfalse -i%OutFile% -q
) else (	
	echo Something 
)

:EOF