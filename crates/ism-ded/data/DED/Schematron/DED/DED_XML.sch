<?xml version="1.0" encoding="UTF-8"?>
<!--UNCLASSIFIED--><?ICEA master?>
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<!-- WARNING: 
    Once compiled into an XSLT the result will 
    be the aggregate classification of all the CVES 
    and included .sch files
-->
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
    <sch:ns uri="urn:us:gov:ic:ded" prefix="ded"/>
    <sch:ns uri="urn:us:gov:ic:ism" prefix="ism"/>
    <sch:ns uri="urn:us:gov:ic:id" prefix="icid"/>
    <sch:ns uri="urn:us:gov:ic:cve" prefix="cve"/>
    
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
<!-- (U) DED ID Rules -->
<!--****************************-->

<!--(U) -->
   <sch:include href="./Rules/DED_ID_00001.sch"/>
   <sch:include href="./Rules/DED_ID_00002.sch"/>
   <sch:include href="./Rules/DED_ID_00003.sch"/>
   <sch:include href="./Rules/DED_ID_00004.sch"/>
   <sch:include href="./Rules/DED_ID_00005.sch"/>
   <sch:include href="./Rules/DED_ID_00006.sch"/>
   <sch:include href="./Rules/DED_ID_00007.sch"/>

   <!--****************************-->
<!-- (U) DED Phases -->
<!--****************************--></sch:schema>
<!--UNCLASSIFIED-->
