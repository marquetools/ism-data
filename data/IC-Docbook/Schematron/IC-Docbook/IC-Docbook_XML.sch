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
    <sch:ns uri="http://docbook.org/ns/docbook" prefix="d"/>
    <sch:ns uri="urn:us:gov:ic:ism" prefix="ism"/>
    <sch:p xmlns:ism="urn:us:gov:ic:ism"
          ism:classification="U"
          ism:ownerProducer="USA"
          class="codeDesc"/>

   <!--****************************-->
<!-- (U) IC-Docbook ID Rules -->
<!--****************************-->

<!--(U) -->
   <sch:include href="./Rules/IC-Docbook_ID_00001.sch"/>
   <sch:include href="./Rules/IC-Docbook_ID_00002.sch"/>

   <!--****************************-->
<!-- (U) IC-Docbook Phases -->
<!--****************************--></sch:schema>
<!--UNCLASSIFIED-->
