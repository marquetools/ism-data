<?xml version="1.0" encoding="UTF-8"?>
<?ICEA master?><!-- UNCLASSIFIED -->
<!-- Notices - Distribution Notice:
            This document is being made available by the Intelligence Community Chief Information Officer
            to Federal, State, Local, Tribal, and Foreign Partners and associated contractors. Approval for
            any further distribution must be coordinated via the Intelligence Community Chief Information 
            Officer, Mission Engagement Division at standardssupport@dni.gov-->
<!-- WARNING: 
    Once compiled into an XSLT the result will 
    be the aggregate classification of all the CVES 
    and included .sch files
-->
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron"
            xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
            queryBinding="xslt2">
    <sch:ns uri="http://www.w3.org/1999/xlink" prefix="xlink"/>
    <sch:ns uri="http://www.w3.org/2001/XMLSchema" prefix="xs"/>
    <sch:ns uri="urn:us:gov:ic:ism" prefix="ism"/>
    <sch:ns uri="urn:us:gov:ic:arh" prefix="arh"/>

   <!--****************************-->
<!-- (U) RR-SM ID Rules -->
<!--****************************-->

<!--(U) GeneralConstraints-->
   <sch:include href="./Rules/GeneralConstraints/RR-SM_ID_00001.sch"/>
   <sch:include href="./Rules/GeneralConstraints/RR-SM_ID_00002.sch"/>
</sch:schema>