<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
   <sch:ns uri="urn:us:gov:ic:pubs" prefix="pubs"/>
   <sch:ns uri="urn:us:gov:ic:cve:v1" prefix="cve"/>
   <sch:ns uri="http://www.w3.org/1999/xlink" prefix="xlink"/>
   <sch:ns uri="urn:us:gov:ic:ism" prefix="ism"/>
   <sch:ns uri="urn:us:gov:ic:mat" prefix="mat"/>
   <sch:ns uri="urn:us:gov:ic:ntk" prefix="ntk"/>
   <sch:ns uri="urn:us:gov:ic:irm" prefix="irm"/>
   <sch:ns uri="http://www.w3.org/2001/XMLSchema" prefix="xs"/>

   <!--****************************-->
<!-- (U) NTK ID Rules -->
<!--****************************-->

<!--(U) generalConstraints-->
   <sch:include href="./Rules/generalConstraints/NTK_ID_00002.sch"/>

   <!--(U) globalConstraints-->
   <sch:include href="./Rules/globalConstraints/NTK_ID_00004.sch"/>
</sch:schema>