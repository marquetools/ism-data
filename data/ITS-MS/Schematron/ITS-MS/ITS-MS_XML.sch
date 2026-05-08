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
    <sch:ns uri="urn:us:gov:ic:tdf" prefix="tdf"/>
    <sch:ns uri="urn:us:gov:ic:ism" prefix="ism"/>
    <sch:ns uri="urn:us:gov:ic:its" prefix="its"/>

   <!--****************************-->
<!-- (U) ITS-MS ID Rules -->
<!--****************************-->

<!--(U) GeneralConstraints-->
   <sch:include href="./Rules/GeneralConstraints/ITS-MS_ID_00001.sch"/>
   <sch:include href="./Rules/GeneralConstraints/ITS-MS_ID_00002.sch"/>
   <sch:include href="./Rules/GeneralConstraints/ITS-MS_ID_00003.sch"/>

   <!--****************************-->
<!-- (U) ITS-MS Phases -->
<!--****************************--></sch:schema>
<!--UNCLASSIFIED-->
