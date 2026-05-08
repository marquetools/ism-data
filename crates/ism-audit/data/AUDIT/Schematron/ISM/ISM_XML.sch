<?xml version="1.0" encoding="UTF-8"?>
<!-- UNCLASSIFIED -->
<!-- WARNING: 
    Once compiled into an XSLT the result will 
    be the aggregate classification of all the CVES 
    and included .sch files
-->
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" xmlns:cve="urn:us:gov:ic:cve:v1"
            xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
            xmlns:xs="http://www.w3.org/2001/XMLSchema"
            queryBinding="xslt2">
    <sch:ns uri="urn:us:gov:ic:ism" prefix="ism"/>
    <sch:ns uri="urn:us:gov:ic:cve:v1" prefix="cve"/>
    <sch:ns uri="deprecated:value:function" prefix="dvf"/>
    <sch:p id="codeDesc">This is the root file for the ISM Schematron rule set. It loads all of the required CVEs
        declares some variables and includes all of the Rule .sch files.
    </sch:p>
    <!-- (U) Resources  -->
    <sch:let name="countriesList"
            value="document('../../CVE/ISM/CVEnumISMOwnerProducer.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
    <sch:let name="classificationAllList"
            value="document('../../CVE/ISM/CVEnumISMClassificationAll.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
    <sch:let name="classificationUSList"
            value="document('../../CVE/ISM/CVEnumISMClassificationUS.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
    <sch:let name="ownerProducerList"
            value="document('../../CVE/ISM/CVEnumISMOwnerProducer.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
    <sch:let name="declassExceptionList"
            value="document('../../CVE/ISM/CVEnumISM25X.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
    <sch:let name="FGIsourceOpenList"
            value="document('../../CVE/ISM/CVEnumISMFGIOpen.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
    <sch:let name="FGIsourceProtectedList"
            value="document('../../CVE/ISM/CVEnumISMFGIProtected.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>   
    <sch:let name="nonICmarkingsList"
            value="document('../../CVE/ISM/CVEnumISMNonIC.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
    <sch:let name="releasableToList"
            value="document('../../CVE/ISM/CVEnumISMRelTo.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
    <sch:let name="SCIcontrolsList"
            value="document('../../CVE/ISM/CVEnumISMSCIControls.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
    <sch:let name="SARIdentifierList"
            value="document('../../CVE/ISM/CVEnumISMSAR.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
    <sch:let name="validAttributeList"
            value="document('../../CVE/ISM/CVEnumISMAttributes.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
    <sch:let name="validElementList"
            value="document('../../CVE/ISM/CVEnumISMElements.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
    <sch:let name="noticeList"
            value="document('../../CVE/ISM/CVEnumISMNotice.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
    <sch:let name="nonUSControlsList"
            value="document('../../CVE/ISM/CVEnumISMNonUSControls.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
    <sch:let name="compliesWithList"
            value="document('../../CVE/ISM/CVEnumISMCompliesWith.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
    <sch:let name="atomicEnergyMarkingsList"
            value="document('../../CVE/ISM/CVEnumISMAtomicEnergyMarkings.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
    <sch:let name="displayOnlyToList"
            value="document('../../CVE/ISM/CVEnumISMRelTo.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
    
    <!-- (U) Resources that may include FOUO values -->
    <sch:let name="disseminationControlsList"
            value="document('../../CVE/ISM/CVEnumISMDissem.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
     
    <!--====================-->
    <!-- (U) Universal Lets -->
    <!--====================-->
    <!-- ISM_RESOURCE_ELEMENT (node): The first element with attribute ism:resourceElement='true' -->
    <sch:let name="ISM_RESOURCE_ELEMENT"
            value="(for $each in (//*) return if($each/@ism:resourceElement=true()) then $each else null)[1]"/>
    
    <!-- (U) ISM_RESOURCE_CREATE_DATE (date): The date a Resource was created, or the ism:createDate attribute on the
         ISM_RESOURCE_ELEMENT node. -->
    <sch:let name="ISM_RESOURCE_CREATE_DATE" value="$ISM_RESOURCE_ELEMENT/@ism:createDate"/>
    
    <!-- (U) ISM_CAPCO_RESOURCE (boolean): True if the resource is a CAPCO-applicable resource, or the ism:ownerProducer attribute on the
         ISM_RESOURCE_ELEMENT node contains [USA]. False otherwise. -->
    <sch:let name="ISM_CAPCO_RESOURCE"
            value="index-of(tokenize(normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:ownerProducer)), ' '),'USA') &gt; 0"/>    
    
    <!-- (U) ISM_ICDOCUMENT_APPLIES (boolean): True if the document claims compliance rules for an IC Document, or if the 
         ism:compliesWith attribute of the ISM_RESOURCE_ELEMENT node contains [ICDocument]. False otherwise. -->
    <sch:let name="ISM_ICDOCUMENT_APPLIES"
            value="index-of(tokenize(normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:compliesWith)), ' '),'ICDocument') &gt; 0"/>  
    
    <!-- (U) ISM_DOD5230_24_APPLIES (boolean): True if the document claims compliance with DoD5230.24, or if the 
         ism:compliesWith attribute of the ISM_RESOURCE_ELEMENT node contains [DoD5230.24]. False otherwise. -->
    <sch:let name="ISM_DOD5230_24_APPLIES"
            value="index-of(tokenize(normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:compliesWith)), ' '),'DoD5230.24') &gt; 0"/>
        
    <!-- (U) ISM_ORCON_POC_DATE (date): The date after which a point-of-contact is required for all documents containing ORCON data -->
    <sch:let name="ISM_ORCON_POC_DATE" value="xs:date('2011-03-11')"/>
    
    <!-- (U) Get Banner Attributes -->
    <sch:let name="bannerClassification"
            value="normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:classification))"/>
    <sch:let name="bannerDisseminationControls"
            value="normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:disseminationControls))"/>
    <sch:let name="bannerDisplayOnlyTo"
            value="normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:displayOnlyTo))"/>
    <sch:let name="bannerNonICmarkings"
            value="normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:nonICmarkings))"/>
    <sch:let name="bannerFGIsourceOpen"
            value="normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:FGIsourceOpen))"/>
    <sch:let name="bannerFGIsourceProtected"
            value="normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:FGIsourceProtected))"/>
    <sch:let name="bannerReleasableTo"
            value="normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:releasableTo))"/>
    <sch:let name="bannerSCIcontrols"
            value="normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:SCIcontrols))"/>
    <sch:let name="bannerNotice"
            value="normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:noticeType))"/>
    <sch:let name="bannerAtomicEnergyMarkings"
            value="normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:atomicEnergyMarkings))"/>
    
    <!-- (U) Tokenize Banner Attributes -->
    <sch:let name="bannerDisseminationControls_tok"
            value="tokenize(normalize-space(string($bannerDisseminationControls)), ' ')"/>
    <sch:let name="bannerDisplayOnlyTo_tok"
            value="tokenize(normalize-space(string($bannerDisplayOnlyTo)), ' ')"/>
    <sch:let name="bannerNonICmarkings_tok"
            value="tokenize(normalize-space(string($bannerNonICmarkings)), ' ')"/>
    <sch:let name="bannerFGIsourceOpen_tok"
            value="tokenize(normalize-space(string($bannerFGIsourceOpen)), ' ')"/>
    <sch:let name="bannerFGIsourceProtected_tok"
            value="tokenize(normalize-space(string($bannerFGIsourceProtected)), ' ')"/>
    <sch:let name="bannerReleasableTo_tok"
            value="tokenize(normalize-space(string($bannerReleasableTo)), ' ')"/>
    <sch:let name="bannerSCIcontrols_tok"
            value="tokenize(normalize-space(string($bannerSCIcontrols)), ' ')"/>
    <sch:let name="bannerNotice_tok"
            value="tokenize(normalize-space(string($bannerNotice)), ' ')"/>
    <sch:let name="bannerAtomicEnergyMarkings_tok"
            value="tokenize(normalize-space(string($bannerAtomicEnergyMarkings)), ' ')"/>
        
    <!-- (U) Get all portions that meet ISM_CONTRIBUTES, or all non-resource nodes that do not specify ism:excludeFromRollup='true' -->   
    <!-- (U) Similar portion classifications include ISM_CONTRIBUTES_CLASSIFIED, or all portions meeting ISM_CONTRIBUTES that 
          also have an ism:classification attribute not equal to [U], and ISM_CONTRIBUTES_USA, or all portions meeting ISM_CONTRIBUTES
          that also have an ism:ownerProducer containing [USA]. -->
    <sch:let name="partTags"
            value="//*[@ism:* and not(@ism:excludeFromRollup=true()) and not(generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT))]"/> 
    
    <!-- (U) Get Part Attributes -->
    <sch:let name="partClassification"
            value="for $token in $partTags/@ism:classification return tokenize(normalize-space(string($token)),' ')"/>
    <sch:let name="partDisseminationControls"
            value="for $token in $partTags/@ism:disseminationControls return tokenize(normalize-space(string($token)),' ')"/>
    <sch:let name="partDisplayOnlyTo"
            value="for $token in $partTags/@ism:displayOnlyTo return tokenize(normalize-space(string($token)),' ')"/>
    <sch:let name="partAtomicEnergyMarkings"
            value="for $token in $partTags/@ism:atomicEnergyMarkings return tokenize(normalize-space(string($token)),' ')"/>
    <sch:let name="partNonICmarkings"
            value="for $token in $partTags/@ism:nonICmarkings return tokenize(normalize-space(string($token)),' ')"/>
    <sch:let name="partFGIsourceOpen"
            value="for $token in $partTags/@ism:FGIsourceOpen return tokenize(normalize-space(string($token)),' ')"/>
    <sch:let name="partFGIsourceProtected"
            value="for $token in $partTags/@ism:FGIsourceProtected return tokenize(normalize-space(string($token)),' ')"/>
    <sch:let name="partSCIcontrols"
            value="for $token in $partTags/@ism:SCIcontrols return tokenize(normalize-space(string($token)),' ')"/>
    <sch:let name="partNotice"
            value="for $token in $partTags/@ism:noticeType return tokenize(normalize-space(string($token)),' ')"/>
    <sch:let name="partPocType"
            value="for $token in $partTags/@ism:pocType return tokenize(normalize-space(string($token)),' ')"/>
    
    <!-- (U) Tokenize portion Attributes -->
    <sch:let name="partClassification_tok"
            value="for $token in $partClassification return tokenize(normalize-space(string($token)), ' ')"/>
    <sch:let name="partDisseminationControls_tok"
            value="for $token in $partDisseminationControls return tokenize(normalize-space(string($token)), ' ')"/>
    <sch:let name="partDisplayOnlyTo_tok"
            value="for $token in $partDisplayOnlyTo return tokenize(normalize-space(string($token)), ' ')"/>
    <sch:let name="partAtomicEnergyMarkings_tok"
            value="for $token in $partAtomicEnergyMarkings return tokenize(normalize-space(string($token)), ' ')"/>
    <sch:let name="partNonICmarkings_tok"
            value="for $token in $partNonICmarkings return tokenize(normalize-space(string($token)), ' ')"/>
    <sch:let name="partSCIcontrols_tok"
            value="for $token in $partSCIcontrols return tokenize(normalize-space(string($token)), ' ')"/>
    <sch:let name="partNotice_tok"
            value="for $token in $partNotice return tokenize(normalize-space(string($token)), ' ')"/>
    <sch:let name="partPocType_tok"
            value="for $token in $partPocType return tokenize(normalize-space(string($token)), ' ')"/>
        
    <!-- (U) ISM_NSI_EO_APPLIES (boolean): True if the current Classified National Security Information Executive 
         Order applies to this resource. This will be false if any of the following conditions are true:
         * The document is not a ISM_CAPCO_RESOURCE
         OR 
         * The ISM_RESOURCE_ELEMENT node has attribute ism:classification with a value of [U]
         OR
         * The ISM_RESOURCE_CREATE_DATE is before 11 April 1996 
         OR
         * Every element meeting ISM_CONTRIBUTES_CLASSIFIED also has attribute ism:disseminationControls containing [FRD] or [RD]  
        -->
    <sch:let name="ISM_NSI_EO_APPLIES"
            value="if(not($ISM_CAPCO_RESOURCE) or ($ISM_RESOURCE_ELEMENT/@ism:classification='U') or index-of($partAtomicEnergyMarkings_tok,'FRD')&gt;0 or index-of($partAtomicEnergyMarkings_tok,'RD')&gt;0 or ($ISM_RESOURCE_CREATE_DATE and $ISM_RESOURCE_CREATE_DATE &lt; xs:date('1996-04-14'))) then false() else true()"/>

    <!-- (U) Define countries that are included in the THREE-, FOUR- and FIVE-EYES designations -->
    <sch:let name="TEYE_tok" value="tokenize(string('USA CAN GBR'), ' ')"/>
    <sch:let name="ACGU_tok" value="tokenize(string('USA AUS CAN GBR'), ' ')"/>
    <sch:let name="FVEY_tok" value="tokenize(string('USA AUS CAN GBR NZL'), ' ')"/>

    <!-- (U) Check roll-up of attributes in portions to the banner   -->
    <sch:let name="dcTags"
            value="for $piece in $disseminationControlsList return $piece/text()"/>
    <sch:let name="dcTagsFound"
            value="for $token in $dcTags return if ( index-of($partDisseminationControls_tok,$token) &gt; 0 and (not(index-of($bannerDisseminationControls_tok,$token) &gt; 0))) then $token else null"/>
    <sch:let name="aeaTags"
            value="for $piece in $atomicEnergyMarkingsList return $piece/text()"/>
    <sch:let name="aeaTagsFound"
            value="for $token in $aeaTags return if ( index-of($partAtomicEnergyMarkings_tok,$token) &gt; 0 and (not(index-of($bannerAtomicEnergyMarkings_tok,$token) &gt; 0))) then $token else null"/>
	
    <!-- XSLT Functions for routine tasks -->
        
    <!-- Evaluate the attribute value tokens to determine whether any values 
            have been deprecated by comparing deprecation dates against $curDate. 
            If the value is deprecated, return either an ERROR or WARNING message, 
            depending on the isError flag. -->    
    <xsl:function name="dvf:deprecated" as="xs:string*">
      <xsl:param name="attribute" as="xs:string"/>
      <xsl:param name="depTerms" as="element()*"/>
      <xsl:param name="curDate" as="xs:date?"/>
      <xsl:param name="isError" as="xs:boolean"/>
            <!--$curDate param is optional in order to prevent compiled XSLT from breaking 
                    when otherwise invalid documents are executed against the rules 
                    (e.g. missing @ism:createDate). 
                    
                    Only execute if we have a date to compare against. -->
            <xsl:if test="count($curDate)=1">
             <xsl:for-each select="$depTerms[cve:Value=tokenize($attribute,' ')]">          
                <xsl:if test="($isError and $curDate gt xs:date(@deprecated)) or (not($isError) and $curDate le xs:date(@deprecated))">
                        <xsl:sequence select="concat('[',string(current()/cve:Value),'] has been deprecated and is not authorized for use after  ', current()/@deprecated)"/>
            </xsl:if>
         </xsl:for-each>
      </xsl:if>
   </xsl:function>

   <!--****************************-->
<!-- (U) ISM ID Rules -->
<!--****************************-->

<!--(U) atomicEnergyMarkings-->
   <sch:include href="./Rules/atomicEnergyMarkings/ISM_ID_00173.sch"/>
   <sch:include href="./Rules/atomicEnergyMarkings/ISM_ID_00174.sch"/>
   <sch:include href="./Rules/atomicEnergyMarkings/ISM_ID_00175.sch"/>
   <sch:include href="./Rules/atomicEnergyMarkings/ISM_ID_00176.sch"/>
   <sch:include href="./Rules/atomicEnergyMarkings/ISM_ID_00178.sch"/>
   <sch:include href="./Rules/atomicEnergyMarkings/ISM_ID_00181.sch"/>
   <sch:include href="./Rules/atomicEnergyMarkings/ISM_ID_00182.sch"/>
   <sch:include href="./Rules/atomicEnergyMarkings/ISM_ID_00183.sch"/>
   <sch:include href="./Rules/atomicEnergyMarkings/ISM_ID_00184.sch"/>
   <sch:include href="./Rules/atomicEnergyMarkings/ISM_ID_00185.sch"/>

   <!--(U) classification-->
   <sch:include href="./Rules/classification/ISM_ID_00015.sch"/>
   <sch:include href="./Rules/classification/ISM_ID_00016.sch"/>
   <sch:include href="./Rules/classification/ISM_ID_00040.sch"/>
   <sch:include href="./Rules/classification/ISM_ID_00142.sch"/>

   <!--(U) classifiedBy-->
   <sch:include href="./Rules/classifiedBy/ISM_ID_00017.sch"/>

   <!--(U) compliesWith-->
   <sch:include href="./Rules/compliesWith/ISM_ID_00222.sch"/>

   <!--(U) declassException-->
   <sch:include href="./Rules/declassException/ISM_ID_00133.sch"/>

   <!--(U) derivativelyClassifiedBy-->
   <sch:include href="./Rules/derivativelyClassifiedBy/ISM_ID_00143.sch"/>
   <sch:include href="./Rules/derivativelyClassifiedBy/ISM_ID_00221.sch"/>

   <!--(U) displayOnlyTo-->
   <sch:include href="./Rules/displayOnlyTo/ISM_ID_00167.sch"/>
   <sch:include href="./Rules/displayOnlyTo/ISM_ID_00168.sch"/>

   <!--(U) disseminationControls-->
   <sch:include href="./Rules/disseminationControls/ISM_ID_00026.sch"/>
   <sch:include href="./Rules/disseminationControls/ISM_ID_00028.sch"/>
   <sch:include href="./Rules/disseminationControls/ISM_ID_00030.sch"/>
   <sch:include href="./Rules/disseminationControls/ISM_ID_00031.sch"/>
   <sch:include href="./Rules/disseminationControls/ISM_ID_00033.sch"/>
   <sch:include href="./Rules/disseminationControls/ISM_ID_00034.sch"/>
   <sch:include href="./Rules/disseminationControls/ISM_ID_00094.sch"/>
   <sch:include href="./Rules/disseminationControls/ISM_ID_00107.sch"/>
   <sch:include href="./Rules/disseminationControls/ISM_ID_00124.sch"/>
   <sch:include href="./Rules/disseminationControls/ISM_ID_00140.sch"/>
   <sch:include href="./Rules/disseminationControls/ISM_ID_00164.sch"/>
   <sch:include href="./Rules/disseminationControls/ISM_ID_00169.sch"/>
   <sch:include href="./Rules/disseminationControls/ISM_ID_00213.sch"/>
   <sch:include href="./Rules/disseminationControls/ISM_ID_00215.sch"/>

   <!--(U) FGIsourceOpen-->
   <sch:include href="./Rules/FGIsourceOpen/ISM_ID_00095.sch"/>

   <!--(U) FGIsourceProtected-->
   <sch:include href="./Rules/FGIsourceProtected/ISM_ID_00096.sch"/>
   <sch:include href="./Rules/FGIsourceProtected/ISM_ID_00097.sch"/>
   <sch:include href="./Rules/FGIsourceProtected/ISM_ID_00217.sch"/>

   <!--(U) generalConstraints-->
   <sch:include href="./Rules/generalConstraints/ISM_ID_00002.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00012.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00102.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00103.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00119.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00125.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00126.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00166.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00170.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00179.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00180.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00188.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00189.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00190.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00191.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00192.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00193.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00194.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00195.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00196.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00197.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00198.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00199.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00200.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00201.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00202.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00203.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00204.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00205.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00206.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00207.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00208.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00209.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00210.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00211.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00223.sch"/>
   <sch:include href="./Rules/generalConstraints/ISM_ID_00226.sch"/>

   <!--(U) nonICmarkings-->
   <sch:include href="./Rules/nonICmarkings/ISM_ID_00035.sch"/>
   <sch:include href="./Rules/nonICmarkings/ISM_ID_00036.sch"/>
   <sch:include href="./Rules/nonICmarkings/ISM_ID_00037.sch"/>
   <sch:include href="./Rules/nonICmarkings/ISM_ID_00038.sch"/>
   <sch:include href="./Rules/nonICmarkings/ISM_ID_00148.sch"/>
   <sch:include href="./Rules/nonICmarkings/ISM_ID_00225.sch"/>

   <!--(U) nonUSControls-->
   <sch:include href="./Rules/nonUSControls/ISM_ID_00163.sch"/>

   <!--(U) notice-->
   <sch:include href="./Rules/notice/ISM_ID_00127.sch"/>
   <sch:include href="./Rules/notice/ISM_ID_00128.sch"/>
   <sch:include href="./Rules/notice/ISM_ID_00129.sch"/>
   <sch:include href="./Rules/notice/ISM_ID_00130.sch"/>
   <sch:include href="./Rules/notice/ISM_ID_00134.sch"/>
   <sch:include href="./Rules/notice/ISM_ID_00135.sch"/>
   <sch:include href="./Rules/notice/ISM_ID_00136.sch"/>
   <sch:include href="./Rules/notice/ISM_ID_00137.sch"/>
   <sch:include href="./Rules/notice/ISM_ID_00138.sch"/>
   <sch:include href="./Rules/notice/ISM_ID_00139.sch"/>
   <sch:include href="./Rules/notice/ISM_ID_00150.sch"/>
   <sch:include href="./Rules/notice/ISM_ID_00151.sch"/>
   <sch:include href="./Rules/notice/ISM_ID_00152.sch"/>
   <sch:include href="./Rules/notice/ISM_ID_00153.sch"/>
   <sch:include href="./Rules/notice/ISM_ID_00156.sch"/>
   <sch:include href="./Rules/notice/ISM_ID_00157.sch"/>
   <sch:include href="./Rules/notice/ISM_ID_00158.sch"/>
   <sch:include href="./Rules/notice/ISM_ID_00159.sch"/>
   <sch:include href="./Rules/notice/ISM_ID_00160.sch"/>
   <sch:include href="./Rules/notice/ISM_ID_00161.sch"/>

   <!--(U) ownerProducer-->
   <sch:include href="./Rules/ownerProducer/ISM_ID_00001.sch"/>
   <sch:include href="./Rules/ownerProducer/ISM_ID_00099.sch"/>
   <sch:include href="./Rules/ownerProducer/ISM_ID_00100.sch"/>
   <sch:include href="./Rules/ownerProducer/ISM_ID_00219.sch"/>

   <!--(U) pocType-->
   <sch:include href="./Rules/pocType/ISM_ID_00224.sch"/>

   <!--(U) releasableTo-->
   <sch:include href="./Rules/releasableTo/ISM_ID_00032.sch"/>
   <sch:include href="./Rules/releasableTo/ISM_ID_00041.sch"/>
   <sch:include href="./Rules/releasableTo/ISM_ID_00214.sch"/>

   <!--(U) resourceElement-->
   <sch:include href="./Rules/resourceElement/ISM_ID_00013.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00014.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00056.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00057.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00058.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00059.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00060.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00061.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00062.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00063.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00064.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00065.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00066.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00067.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00068.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00070.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00071.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00072.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00073.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00074.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00075.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00077.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00078.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00079.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00080.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00081.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00082.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00083.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00084.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00085.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00086.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00087.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00088.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00090.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00104.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00105.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00108.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00109.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00110.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00111.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00112.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00113.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00116.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00118.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00132.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00141.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00145.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00146.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00147.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00149.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00154.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00155.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00162.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00165.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00171.sch"/>
   <sch:include href="./Rules/resourceElement/ISM_ID_00227.sch"/>

   <!--(U) SARIdentifier-->
   <sch:include href="./Rules/SARIdentifier/ISM_ID_00121.sch"/>

   <!--(U) SCIcontrols-->
   <sch:include href="./Rules/SCIcontrols/ISM_ID_00042.sch"/>
   <sch:include href="./Rules/SCIcontrols/ISM_ID_00043.sch"/>
   <sch:include href="./Rules/SCIcontrols/ISM_ID_00044.sch"/>
   <sch:include href="./Rules/SCIcontrols/ISM_ID_00045.sch"/>
   <sch:include href="./Rules/SCIcontrols/ISM_ID_00046.sch"/>
   <sch:include href="./Rules/SCIcontrols/ISM_ID_00047.sch"/>
   <sch:include href="./Rules/SCIcontrols/ISM_ID_00048.sch"/>
   <sch:include href="./Rules/SCIcontrols/ISM_ID_00049.sch"/>
   <sch:include href="./Rules/SCIcontrols/ISM_ID_00122.sch"/>
   <sch:include href="./Rules/SCIcontrols/ISM_ID_00123.sch"/>
   <sch:include href="./Rules/SCIcontrols/ISM_ID_00177.sch"/>
   <sch:include href="./Rules/SCIcontrols/ISM_ID_00186.sch"/>
   <sch:include href="./Rules/SCIcontrols/ISM_ID_00187.sch"/>
</sch:schema>
<!-- UNCLASSIFIED -->