@echo off

set argC=0
for %%x in (%*) do Set /A argC+=1

IF /I "%argC%" NEQ "2" (
   echo Usage: Script requires 2 parameters >&2
   echo param 1 is the path of the source IC-Docbook file >&2
   echo param 2 is the path of the output PDF file >&2
   exit /B 1
)

REM The source IC-Docbook file passed in
set SOURCE_FILE=%1

REM The output file
set OUT_FILE=%2

REM Path to IC-Docbook XSLs
set XSL_PATH="../../XSL/IC-Docbook/"

REM The FO Procesor executable (windows)
set FOP_EXE="../../../BuildDependencies/fop/fop-1.0/fop.cmd"

REM The path to the saxon jar file (Either specify the exact path, 
REM of if saxon is on your classpath then just use the jar name)
set SAXON_JAR="../../../BuildDependencies/Saxon/9.4.0.6-HE/saxon9he.jar"

REM Run the ISM Resolver
java -jar %SAXON_JAR% -xsl:%XSL_PATH%/ism/ISMresolver.xsl -s:%SOURCE_FILE% -o:step1.xml

REM Convert to FO
java -jar %SAXON_JAR% -xsl:%XSL_PATH%/fo/FOcustomizationlayer.xsl -s:step1.xml -o:step2.fo

REM Generate PDF Output with FO Processor
%FOP_EXE% -fo step2.fo -pdf %OUT_FILE%