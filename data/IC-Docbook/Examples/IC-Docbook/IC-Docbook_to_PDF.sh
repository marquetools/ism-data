#!/bin/bash

# The source IC-Docbook file passed in
SOURCE_FILE=$1

# The output file
OUT_FILE=$2

if [ "$#" -ne 2 ] ; then
   echo "Usage: Script requires 2 parameters" >&2
   echo "param 1 is the path of the source IC-Docbook file" >&2
   echo "param 2 is the path of the output PDF file" >&2
   exit 1
fi 

#Path to IC-Docbook XSLs
XSL_PATH="../../XSL/IC-Docbook/"

# The FO Processor executable (unix)
FOP_EXE="../../../BuildDependencies/fop/fop-1.0/fop"
# The FO Procesor executable (windows)
#FOP_EXE="../../../BuildDependencies/fop/fop-1.0/fop.cmd"

# The path to the saxon jar file (Either specify the exact path, 
# of if saxon is on your classpath then just use the jar name)

# to use new ISM (XSL/ISM) with Saxon 9.4 HE, need to fix Cast to List error (requires further investigation), 
# tokenize() requires 2 parm (fix identified), and import being at top warning (fix identified)
# to use old ISM (XSL/ISM-Old) with Saxon 9.4 HE, nothing else needs to be done 
# older Saxon requires fixes to Cast to List Error, tokenize() require 2 parm, import being at top warning to work with newer ISM
# of which Cast to List Error is not figured out
SAXON_JAR="../../../BuildDependencies/Saxon/9.4.0.6-HE/saxon9he.jar"

# to use new ISM (XSL/ISM) with Saxon 9.4 EE (old license), need to fix tokenize() requires 2 parm (fix identified)
# and import being at top warning (fix identified)
# to use old ISM (XSL/ISM-Old) with Saxon 9.4 EE (old license), nothing else needs to be done
#SAXON_JAR="../../../BuildDependencies/Saxon/9.4.0.6-EE/saxon9ee.jar"

# to use new ISM (XSL/ISM) with Saxon 9.8 HE, nothing else needs to be done as this newer version addresses the errors seen in Saxon 9.4 HE
# to use old ISM (XSL/ISM-Old) with Saxon 9.8 HE, nothing else needs to be done
#SAXON_JAR="../../../BuildDependencies/Saxon/9.8.0.14J-HE/saxon9he.jar"

# Run the ISM Resolver
java -jar $SAXON_JAR -xsl:$XSL_PATH/ism/ISMresolver.xsl -s:$SOURCE_FILE -o:step1.xml

# Convert to FO
java -jar $SAXON_JAR -xsl:$XSL_PATH/fo/FOcustomizationlayer.xsl -s:step1.xml -o:step2.fo

# Generate PDF Output with FO Processor
$FOP_EXE -fo step2.fo -pdf $OUT_FILE