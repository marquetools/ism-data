<?xml version="1.0" encoding="UTF-8"?>
<?ICEA master?><!-- Notices - Distribution Notice:
            This document is being made available by the Intelligence Community Chief Information Officer
            to Federal, State, Local, Tribal, and Foreign Partners and associated contractors. Approval for
            any further distribution must be coordinated via the Intelligence Community Chief Information 
            Officer, Mission Engagement Division at standardssupport@dni.gov-->
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
   <sch:ns uri="urn:us:gov:ic:cve" prefix="cve"/>
   <sch:ns uri="http://www.w3.org/1999/xlink" prefix="xlink"/>
   <sch:ns uri="urn:us:gov:ic:ism" prefix="ism"/>
   <sch:ns uri="urn:us:gov:ic:ntk" prefix="ntk"/>
   <sch:ns uri="http://www.w3.org/2001/XMLSchema" prefix="xs"/>

   <!-- ************************************** -->
   <!-- * Abstract Rule and Pattern Includes * -->
   <!-- ************************************** -->
   <sch:include href="./../IC-ID/Lib/ICIdentifierRestrictions.sch"/>

   <!--****************************-->
<!-- (U) ICO-NTK ID Rules -->
<!--****************************-->

<!--(U) -->
   <sch:include href="./Rules/ICO-NTK_ID_00001.sch"/>
   <sch:include href="./Rules/ICO-NTK_ID_00002.sch"/>
   <sch:include href="./Rules/ICO-NTK_ID_00003.sch"/>
</sch:schema>