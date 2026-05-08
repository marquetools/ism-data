(PREFERRED) HOW TO GENERATE DHZM-TDF XSD with ANT
(1) ant GenerateDHZM-TDFSchema

(PREFERRED) HOW TO GENERATE DHZM-TDF GUARD XSDs with ANT
(1) ant GenerateDHZM-TDFSchemaGuard

============================================================================
HOW TO GENERATE DHZM-TDF XSD in OXYGEN
NOTE: When running transforms in Oxygen, use Saxon-HE, since that is what we have licenses for and run with in our build.

(1) Update the TDF change config file (ie. DHZM-TDF-Changes.xml) 
and configure it with changes being made to the full DHZM-TDF (ie. DHZM-TDF XSD)

Reference GenerateXSDChangeXSL.xsl for how to use:
<documentation> - add documentation to generated XSL
<injectAfter> - add content after the element being matched
<injectBefore> - add content before the element being matched
<injectStart> - add content at the beginning of the element being matched
<injectEnd> - add content at the end of the element being matched
<injectAttributes> - add attributes to the element being matched
<replaceElement> - replace the element being matched

(2) Run the TDF Change XSL Generation script (ie. GenerateXSDChangeXSL.xsl) 
on the TDF change config file (ie. DHZM-TDF-Changes.xml)
to generate the actual TDF change XSL (ie. DHZM-TDF-Changes.xsl)
 
(3) Run the generated TDF change XSL (ie. DHZM-TDF-Changes.xsl) 
on the full BASE-TDF schema to generate the DHZM-TDF XSD.

(4) Run the UpdateXSDDocumentation XSL (ie. UpdateXSDDocumentation.xsl)
to update further update the generated DHZM-TDF XSD with the correct header and footer documentation 
specific to DHZM-TDF and save it in trunk/XmlEncodings/Schema/DHZM-TDF/DHZM-TDF.xsd

HOW TO GENERATE DHZM-TDF GUARD XSD in OXYGEN

(1) Run Guard Processing XSL (ie. ProcessForGuards.xsl) on the DHZM-TDF schema.
(2) Run the AddBackNamespacesDHZM-TDF.xsl on the DHZM-TDF guard processed schema.

(OPTIONAL) HOW TO GENERATE A COMMENT-FREE DHZM-TDF

(1) Run the StripComments.xsl on the generated DHZM-TDF schema.

