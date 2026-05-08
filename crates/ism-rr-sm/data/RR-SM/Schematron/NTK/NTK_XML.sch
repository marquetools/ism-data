<?xml version="1.0" encoding="UTF-8"?>
<?ICEA master?><!-- Notices - Distribution Notice:
            This document is being made available by the Intelligence Community Chief Information Officer
            to Federal, State, Local, Tribal, and Foreign Partners and associated contractors. Approval for
            any further distribution must be coordinated via the Intelligence Community Chief Information 
            Officer, Mission Engagement Division at standardssupport@dni.gov-->
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
   <sch:ns uri="urn:us:gov:ic:pubs" prefix="pubs"/>
   <sch:ns uri="urn:us:gov:ic:cve" prefix="cve"/>
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
   <sch:include href="./Rules/generalConstraints/NTK_ID_00001.sch"/>
   <sch:include href="./Rules/generalConstraints/NTK_ID_00002.sch"/>
   <sch:include href="./Rules/generalConstraints/NTK_ID_00005.sch"/>
   <sch:include href="./Rules/generalConstraints/NTK_ID_00006.sch"/>
   <sch:include href="./Rules/generalConstraints/NTK_ID_00007.sch"/>
   <sch:include href="./Rules/generalConstraints/NTK_ID_00008.sch"/>
   <sch:include href="./Rules/generalConstraints/NTK_ID_00009.sch"/>

   <!--(U) globalConstraints-->
   <sch:include href="./Rules/globalConstraints/NTK_ID_00003.sch"/>
   <sch:include href="./Rules/globalConstraints/NTK_ID_00004.sch"/>
</sch:schema>