<?xml version="1.0" encoding="UTF-8"?>
<!--UNCLASSIFIED--><?ICEA master?>
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
    
    <!-- ************************** -->
    <!-- * Namespace declarations * -->
    <!-- ************************** -->
    <sch:ns uri="http://www.w3.org/1999/xlink" prefix="xlink"/>
    <sch:ns uri="http://www.w3.org/2001/XMLSchema" prefix="xs"/>
    <sch:ns uri="http://www.w3.org/1999/XSL/Transform" prefix="xsl"/>
    <sch:ns uri="urn:us:gov:ic:ism" prefix="ism"/>
    <sch:ns uri="urn:us:gov:ic:tdf" prefix="tdf"/>
    <sch:ns uri="urn:us:gov:ic:cve" prefix="cve"/>
   <sch:ns uri="urn:us:gov:ic:cdsmanifest" prefix="cdsm"/>
   
   <sch:p xmlns:ism="urn:us:gov:ic:ism"
          class="codeDesc"
          ism:classification="U"
          ism:ownerProducer="USA">
      This is the root file for the specifications Schematron ruleset. It loads all of the required CVEs, 
      declares some variables, and includes all of the Rule .sch files.</sch:p>
   
   <!-- ************************************** -->
   <!-- * Abstract Rule and Pattern Includes * -->
   <!-- ************************************** -->
   <sch:include href="./Lib/ValidateValidationEnvSchema.sch"/>
   <sch:include href="./Lib/ValidateValidationEnvCVE.sch"/>

   <!--****************************-->
<!-- (U) CDSM-TDF Phases -->
<!--****************************-->
<!--****************************-->
<!-- (U) CDSM-TDF ID Rules -->
<!--****************************-->

<!--(U) -->
   <sch:include href="./Rules/CDSM-TDF_ID_00001.sch"/>
   <sch:include href="./Rules/CDSM-TDF_ID_00002.sch"/>
   <sch:include href="./Rules/CDSM-TDF_ID_00003.sch"/>
   <sch:include href="./Rules/CDSM-TDF_ID_00004.sch"/>
   <sch:include href="./Rules/CDSM-TDF_ID_00005.sch"/>
   <sch:include href="./Rules/CDSM-TDF_ID_00006.sch"/>

   <!--****************************-->
<!-- (U) CDSM-TDF Phases -->
<!--****************************--></sch:schema>
<!--UNCLASSIFIED-->
