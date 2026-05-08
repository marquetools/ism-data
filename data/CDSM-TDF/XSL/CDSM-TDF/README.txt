(PREFERRED) HOW TO GENERATE CDSM-TDF XSD with ANT
(1) ant GenerateCDSM-TDFSchema

(PREFERRED) HOW TO GENERATE CDSM-TDF GUARD XSDs with ANT
(1) ant GenerateCDSM-TDFSchemaGuard

============================================================================
HOW TO GENERATE CDSM-TDF XSD in OXYGEN
NOTE: When running transforms in Oxygen, use Saxon-HE, since that is what we have licenses for and run with in our build.

(1) Update the TDF change config file (ie. CDSM-TDF-Changes.xml) 
and configure it with changes being made to the full CDSM-TDF (ie. CDSM-TDF XSD)

Reference GenerateXSDChangeXSL.xsl for how to use:
<documentation> - add documentation to generated XSL
<injectAfter> - add content after the element being matched
<injectBefore> - add content before the element being matched
<injectStart> - add content at the beginning of the element being matched
<injectEnd> - add content at the end of the element being matched
<injectAttributes> - add attributes to the element being matched
<replaceElement> - replace the element being matched

(2) Run the TDF Change XSL Generation script (ie. GenerateXSDChangeXSL.xsl) 
on the TDF change config file (ie. CDSM-TDF-Changes.xml)
to generate the actual TDF change XSL (ie. CDSM-TDF-Changes.xsl)
 
(3) Run the generated TDF change XSL (ie. CDSM-TDF-Changes.xsl) 
on the full BASE-TDF schema to generate the CDSM-TDF XSD.

(4) Run the UpdateXSDDocumentation XSL (ie. UpdateXSDDocumentation.xsl)
to update further update the generated CDSM-TDF XSD with the correct header and footer documentation 
specific to CDSM-TDF and save it in trunk/XmlEncodings/Schema/CDSM-TDF/CDSM-TDF.xsd

HOW TO GENERATE CDSM-TDF GUARD XSD in OXYGEN

(1) Run Guard Processing XSL (ie. ProcessForGuards.xsl) on the CDSM-TDF schema.
(2) Run the AddBackNamespacesCDSM-TDF.xsl on the CDSM-TDF guard processed schema.
