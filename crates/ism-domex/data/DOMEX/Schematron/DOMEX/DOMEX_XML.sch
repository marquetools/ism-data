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
    <sch:ns uri="http://www.w3.org/1999/xlink" prefix="xlink"/>
    <sch:ns uri="http://www.w3.org/2001/XMLSchema" prefix="xs"/>
    <sch:ns uri="urn:us:gov:ic:ism" prefix="ism"/>
    <sch:ns uri="urn:us:gov:ic:irm" prefix="irm"/>
    <sch:ns uri="urn:us:gov:ic:arh" prefix="arh"/>
    <sch:ns uri="urn:us:gov:ic:tdf" prefix="tdf"/>
    <sch:ns uri="urn:us:mil:ces:metadata:domex" prefix="domex"/>
    <sch:ns uri="urn:us:mil:ces:metadata:domex_identity" prefix="Identity"/>
    <sch:ns uri="urn:CellexReport" prefix="cr"/>
    <sch:ns uri="urn:us:gov:ic:irm" prefix="irm"/>
    <sch:ns uri="urn:us:gov:ic:cve" prefix="cve"/>
    
    <sch:p xmlns:ism="urn:us:gov:ic:ism"
          class="codeDesc"
          ism:classification="U"
          ism:ownerProducer="USA">
        This is the root file for the specifications Schematron ruleset. It loads all of the required CVEs, 
        and includes all of the Rule .sch files.
    </sch:p>
    
    <!-- ************************************** -->
    <!-- * Abstract Rule and Pattern Includes * -->
    <!-- ************************************** -->
    <sch:include href="./Lib/ValidateValidationEnvSchema.sch"/>
    <sch:include href="./Lib/ValidateValidationEnvCVE.sch"/>

   <!--****************************-->
<!-- (U) DOMEX Phases -->
<!--****************************-->
<!--****************************-->
<!-- (U) DOMEX ID Rules -->
<!--****************************-->

<!--(U) GeneralConstraints-->
   <sch:include href="./Rules/GeneralConstraints/DOMEX_ID_00001.sch"/>
   <sch:include href="./Rules/GeneralConstraints/DOMEX_ID_00003.sch"/>
   <sch:include href="./Rules/GeneralConstraints/DOMEX_ID_00004.sch"/>
   <sch:include href="./Rules/GeneralConstraints/DOMEX_ID_00005.sch"/>
   <sch:include href="./Rules/GeneralConstraints/DOMEX_ID_00006.sch"/>
   <sch:include href="./Rules/GeneralConstraints/DOMEX_ID_00007.sch"/>
   <sch:include href="./Rules/GeneralConstraints/DOMEX_ID_00008.sch"/>
   <sch:include href="./Rules/GeneralConstraints/DOMEX_ID_00009.sch"/>
   <sch:include href="./Rules/GeneralConstraints/DOMEX_ID_00010.sch"/>
   <sch:include href="./Rules/GeneralConstraints/DOMEX_ID_00011.sch"/>
   <sch:include href="./Rules/GeneralConstraints/DOMEX_ID_00012.sch"/>
   <sch:include href="./Rules/GeneralConstraints/DOMEX_ID_00013.sch"/>
   <sch:include href="./Rules/GeneralConstraints/DOMEX_ID_00014.sch"/>

   <!--****************************-->
<!-- (U) DOMEX Phases -->
<!--****************************--></sch:schema>
<!--UNCLASSIFIED-->
