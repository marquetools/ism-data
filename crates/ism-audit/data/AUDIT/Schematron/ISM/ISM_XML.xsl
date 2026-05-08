<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:saxon="http://saxon.sf.net/"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:schold="http://www.ascc.net/xml/schematron"
                xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                xmlns:ism="urn:us:gov:ic:ism"
                xmlns:cve="urn:us:gov:ic:cve:v1"
                xmlns:dvf="deprecated:value:function"
                version="2.0"><!--Implementers: please note that overriding process-prolog or process-root is 
    the preferred method for meta-stylesheets to use where possible. -->
<xsl:param name="archiveDirParameter"/>
   <xsl:param name="archiveNameParameter"/>
   <xsl:param name="fileNameParameter"/>
   <xsl:param name="fileDirParameter"/>
   <xsl:variable name="document-uri">
      <xsl:value-of select="document-uri(/)"/>
   </xsl:variable>

   <!--PHASES-->


<!--PROLOG-->
<xsl:output xmlns:svrl="http://purl.oclc.org/dsdl/svrl" method="xml"
               omit-xml-declaration="no"
               standalone="yes"
               indent="yes"/>

   <!--XSD TYPES FOR XSLT2-->


<!--KEYS AND FUNCTIONS-->
<xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron" name="dvf:deprecated"
                 as="xs:string*">
      <xsl:param name="attribute" as="xs:string"/>
      <xsl:param name="depTerms" as="element()*"/>
      <xsl:param name="curDate" as="xs:date?"/>
      <xsl:param name="isError" as="xs:boolean"/>
            
            <xsl:if test="count($curDate)=1">
             <xsl:for-each select="$depTerms[cve:Value=tokenize($attribute,' ')]">          
                <xsl:if test="($isError and $curDate gt xs:date(@deprecated)) or (not($isError) and $curDate le xs:date(@deprecated))">
                        <xsl:sequence select="concat('[',string(current()/cve:Value),'] has been deprecated and is not authorized for use after  ', current()/@deprecated)"/>
            </xsl:if>
         </xsl:for-each>
      </xsl:if>
   </xsl:function>

   <!--DEFAULT RULES-->


<!--MODE: SCHEMATRON-SELECT-FULL-PATH-->
<!--This mode can be used to generate an ugly though full XPath for locators-->
<xsl:template match="*" mode="schematron-select-full-path">
      <xsl:apply-templates select="." mode="schematron-get-full-path"/>
   </xsl:template>

   <!--MODE: SCHEMATRON-FULL-PATH-->
<!--This mode can be used to generate an ugly though full XPath for locators-->
<xsl:template match="*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">
            <xsl:value-of select="name()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>*:</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>[namespace-uri()='</xsl:text>
            <xsl:value-of select="namespace-uri()"/>
            <xsl:text>']</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="preceding"
                    select="count(preceding-sibling::*[local-name()=local-name(current())                                   and namespace-uri() = namespace-uri(current())])"/>
      <xsl:text>[</xsl:text>
      <xsl:value-of select="1+ $preceding"/>
      <xsl:text>]</xsl:text>
   </xsl:template>
   <xsl:template match="@*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">@<xsl:value-of select="name()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>@*[local-name()='</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>' and namespace-uri()='</xsl:text>
            <xsl:value-of select="namespace-uri()"/>
            <xsl:text>']</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <!--MODE: SCHEMATRON-FULL-PATH-2-->
<!--This mode can be used to generate prefixed XPath for humans-->
<xsl:template match="node() | @*" mode="schematron-get-full-path-2">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text>/</xsl:text>
         <xsl:value-of select="name(.)"/>
         <xsl:if test="preceding-sibling::*[name(.)=name(current())]">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <xsl:text>]</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:if test="not(self::*)">
         <xsl:text/>/@<xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>
   <!--MODE: SCHEMATRON-FULL-PATH-3-->
<!--This mode can be used to generate prefixed XPath for humans 
	(Top-level element has index)-->
<xsl:template match="node() | @*" mode="schematron-get-full-path-3">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text>/</xsl:text>
         <xsl:value-of select="name(.)"/>
         <xsl:if test="parent::*">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <xsl:text>]</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:if test="not(self::*)">
         <xsl:text/>/@<xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>

   <!--MODE: GENERATE-ID-FROM-PATH -->
<xsl:template match="/" mode="generate-id-from-path"/>
   <xsl:template match="text()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.text-', 1+count(preceding-sibling::text()), '-')"/>
   </xsl:template>
   <xsl:template match="comment()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.comment-', 1+count(preceding-sibling::comment()), '-')"/>
   </xsl:template>
   <xsl:template match="processing-instruction()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.processing-instruction-', 1+count(preceding-sibling::processing-instruction()), '-')"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.@', name())"/>
   </xsl:template>
   <xsl:template match="*" mode="generate-id-from-path" priority="-0.5">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:text>.</xsl:text>
      <xsl:value-of select="concat('.',name(),'-',1+count(preceding-sibling::*[name()=name(current())]),'-')"/>
   </xsl:template>

   <!--MODE: GENERATE-ID-2 -->
<xsl:template match="/" mode="generate-id-2">U</xsl:template>
   <xsl:template match="*" mode="generate-id-2" priority="2">
      <xsl:text>U</xsl:text>
      <xsl:number level="multiple" count="*"/>
   </xsl:template>
   <xsl:template match="node()" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>n</xsl:text>
      <xsl:number count="node()"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="string-length(local-name(.))"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="translate(name(),':','.')"/>
   </xsl:template>
   <!--Strip characters--><xsl:template match="text()" priority="-1"/>

   <!--SCHEMA SETUP-->
<xsl:template match="/">
      <svrl:schematron-output xmlns:svrl="http://purl.oclc.org/dsdl/svrl" title="" schemaVersion="">
         <xsl:comment>
            <xsl:value-of select="$archiveDirParameter"/>   
		 <xsl:value-of select="$archiveNameParameter"/>  
		 <xsl:value-of select="$fileNameParameter"/>  
		 <xsl:value-of select="$fileDirParameter"/>
         </xsl:comment>
         <svrl:text>This is the root file for the ISM Schematron rule set. It loads all of the required CVEs
        declares some variables and includes all of the Rule .sch files.
    </svrl:text>
         <svrl:ns-prefix-in-attribute-values uri="urn:us:gov:ic:ism" prefix="ism"/>
         <svrl:ns-prefix-in-attribute-values uri="urn:us:gov:ic:cve:v1" prefix="cve"/>
         <svrl:ns-prefix-in-attribute-values uri="deprecated:value:function" prefix="dvf"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00173</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00173</xsl:attribute>
            <svrl:text>
        [ISM-ID-00173][Error] If ISM_CAPCO_RESOURCE and attribute 
        atomicEnergyMarkings contains a name token starting with 
        [RD-SG] or [FRD-SG], then attribute classification must 
        have a value of [TS], [S], or [C].
        
        Human Readable: Portions in a USA document that contain RD or FRD SIGMA 
        data should be CONFIDENTIAL, SECRET, or TOP SECRET.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. Then we check that the attribute 
		atomicEnergyMarkings has a value of [RD-SG] or [FRD-SG] with a single digit 
		[1-9] or double digit [10-99]. If this element does contain one of those values 
		and its classification is not equal to TS, S or C, then the token is returned. If
		any token is returned, the count will be greater than 0 and the rule will fail.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M76"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00174</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00174</xsl:attribute>
            <svrl:text>
        [ISM-ID-00174][Error] If ISM_CAPCO_RESOURCE and attribute 
        atomicEnergyMarkings contains the name token [RD] or [FRD], 
        then attribute classification must have a value of [TS], [S], or [C].
        
        Human Readable: USA documents with RD or FRD data must be marked CLASSIFIED,
        SECRET, or TOP SECRET.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If it is a CAPCO resource then we check that if we have
        an element having attribute atomicEnergyMarkings with a value of 
        [RD] or [FRD]  then we also have the attribute classification 
        specified with a value of [C], [S], or [TS] on the same element.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M77"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00175</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00175</xsl:attribute>
            <svrl:text>
        [ISM-ID-00175][Error] If ISM_CAPCO_RESOURCE and attribute 
        atomicEnergyMarkings contains the name token [RD-CNWDI], then attribute 
        classification must have a value of [TS] or [S].
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If it is a CAPCO resource then we check that if we have
        an element having attribute atomicEnergyMarkings without a value of 
        [RD-CNWDI] then we return true because the rule does not apply. Otherwise
        we make sure the attribute classification is specified with a value of [S] 
        or [TS] on the same element.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M78"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00176</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00176</xsl:attribute>
            <svrl:text>
        [ISM-ID-00176][Error] If ISM_CAPCO_RESOURCE and attribute 
        atomicEnergyMarkings has a name token containing [RD] or [FRD], 
        then attributes declassDate and declassEvent cannot be specified
        on the resourceElement.
        
        Human Readable: Automatic declassification of documents containing RD or FRD information is prohibited.
        Attributes declassDate and declassEvent cannot be used in the classification authority block when RD or FRD is present.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If it is a CAPCO resource then we check that if we have
        an element having attribute atomicEnergyMarkings with a value containing [RD] or
        [FRD] then we make sure that the resourceElement does not have attributes
        declassDate or declassEvent specified.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M79"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00178</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00178</xsl:attribute>
            <svrl:text>[ISM-ID-00178][Error] If ISM_CAPCO_RESOURCE and attribute 
        atomicEnergyMarkings is specified, then each of its values must be ordered in accordance with 
        CVEnumISMAtomicEnergyMarkings.xml.</svrl:text>
            <svrl:text>To perform sorting, this rule first retrieves the CVE values for the attribute 
        to be sorted, which in this case is atomicEnergyMarkings. Then, each attribute token
        is converted into a numerical value based on its characters. Next, each attribute token is 
        given an order number, which compares its position to that of its value in the CVE file.
        Next, each order number is compared to that of its previous sibling to determine if the tokens
        are in order. If a token is found whose order number is less than that of its previous sibling, 
        0 is returned for its sorted order number. If a token's order number is greater than that of its 
        previous sibling, 1 is returned. If two tokens have the same order number, their original attribute
        values are compared. If the original attribute value contains numbers then the comparison is made 
        on its converted numerical value; otherwise, the comparison is made on its string value. If an 
        attribute value is found whose value is less than that of its previous sibling,  0 is returned
        for its sorted order number; otherwise 2 is returned. Finally, if any tokens are found with 0 as 
        its sorted order number, then the rule fails as those tokens are out of order. 
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M80"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00181</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00181</xsl:attribute>
            <svrl:text>
        [ISM-ID-00181][Error] If ISM_CAPCO_RESOURCE and element’s 
        classification does not have a value of "U" then attribute atomicEnergyMarkings must not 
        contain the name token [UCNI].
        
        Human Readable: UCNI may only be used on UNCLASSIFIED portions.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If it is a CAPCO resource then we check the classification
        attribute of the current element. If it has a value of [U] we return true since 
        this rule only applies to classified elements. If it is not [U] then we check
        that the attribute atomicEnergyMarkings does not have a value of [UCNI].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M81"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00182</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00182</xsl:attribute>
            <svrl:text>
        [ISM-ID-00182][Error] If ISM_CAPCO_RESOURCE and element’s 
        classification does not have a value of "U" then attribute atomicEnergyMarkings must not 
        contain the name token [DCNI].
        
        Human Readable: DCNI may only be used on Unclassified portions.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If it is a CAPCO resource then we check the classification
        attribute of the current element. If it has a value of [U] we return true since 
        this rule only applies to classified elements. If it is not [U] then we check
        that the attribute atomicEnergyMarkings does not have a value of [DCNI].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M82"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00183</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00183</xsl:attribute>
            <svrl:text>
        [ISM-ID-00183][Error] If ISM_CAPCO_RESOURCE and attribute atomicEnergyMarkings contains the name token [RD-SG],
        then it must also contain the name token [RD].
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If it is a CAPCO resource then we check that if we have
        an element having attribute atomicEnergyMarkings with a value of [RD-SG] then we also have
        a value of [RD].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M83"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00184</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00184</xsl:attribute>
            <svrl:text>
        [ISM-ID-00184][Error] If ISM_CAPCO_RESOURCE and attribute atomicEnergyMarkings contains the name token [FRD-SG],
        then it must also contain the name token [FRD].
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If it is a CAPCO resource then we check that if we have
        an element having attribute atomicEnergyMarkings with a value of [FRD-SG] then we also have
        a value of [FRD].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M84"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00185</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00185</xsl:attribute>
            <svrl:text>
        [ISM-ID-00185][Error] If ISM_CAPCO_RESOURCE and attribute atomicEnergyMarkings contains the name token [RD-CNWDI],
        then it must also contain the name token [RD].
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If it is a CAPCO resource then we check that if we have
        an element having attribute atomicEnergyMarkings with a value of [RD-CNWDI] then we also have
        a value of [RD].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M85"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00015</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00015</xsl:attribute>
            <svrl:text>
        [ISM-ID-00015][Error] If ISM_CAPCO_RESOURCE and attribute 
        classification has a value of [U], then attributes releasableTo, SARIdentifier, and SCIcontrols 
        must not be specified.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If it is a CAPCO resource then we check that if we have
        an element having attribute classification with a value of [U] then we do 
        not have attributes releasableTo, SARIdentifier, or SCIcontrols on the 
        same element.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M86"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00016</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00016</xsl:attribute>
            <svrl:text>
        [ISM-ID-00016][Error] If ISM_CAPCO_RESOURCE and attribute 
        classification has a value of [U], then attributes classificationReason, classifiedBy, 
        derivativelyClassifiedBy, declassDate, declassEvent, declassException and 
        derivedFrom must not be specified.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If it is a CAPCO resource then we check that if we have
        an element having attribute classification with a value of [U] then we do 
        not have attributes classifiedBy, declassDate,
        declassEvent, declassException, derivativelyClassifiedBy, or derivedFrom 
        on the same element.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M87"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00040</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00040</xsl:attribute>
            <svrl:text>
        [ISM-ID-00040][Error] If ISM_CAPCO_RESOURCE and attribute 
        ownerProducer contains [USA] then attribute classification must have a value in 
        CVEnumISMClassificationUS.xml.
    </svrl:text>
            <svrl:text>
        To determine the valid values, this rule first retrieves the CVE 
        values for the attribute, which in this case is classification. Then, each attribute token
        is converted into a numerical value based on its characters. Next, each attribute token is 
        given an order number, which compares its position to that of its value in the CVE file. If
        the token is not found, its order number will be -1. If the document is a CAPCO resource and 
        the ownerProducer of this element is 'USA', then the rule will fail if tokens are 
        found with order numbers of -1. The rule will also fail if duplicate values are found for the 
        element, or when its count is greater than 1.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M88"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00142</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00142</xsl:attribute>
            <svrl:text>
        [ISM-ID-00142][Error] If ISM_NSI_EO_APPLIES and attribute classification has a value other than [U]
        then attribute classifiedBy or derivativelyClassifiedBy must be specified on the ISM_RESOURCE_ELEMENT.
        
        Human Readable: Classified data including DOE data requires either an 
        original classifier or a derivative classifier be identified.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If it is a CAPCO resource then we check that if we have
        an element having attribute classification with a value of [U] then we 
        return true because the rule does not apply. Otherwise we make sure that
        the resourceElement has the attribute classifiedBy or
        derivativelyClassifiedBy.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M89"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00017</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00017</xsl:attribute>
            <svrl:text>
        [ISM-ID-00017][Error] If ISM_NSI_EO_APPLIES and attribute 
        classifiedBy is specified, then attribute classificationReason must be specified. 
        
        Human Readable: Documents under E.O. 13526 containing Originally Classified data 
        require a classification reason be identified.
    </svrl:text>
            <svrl:text>
        If current Classified National Security Information Executive Order does not
        apply to this resource then the rule does not apply and we return true. 
        Otherwise we ensure that any element with the attribute classifiedBy also
        has the attribute classificationReason. 
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M90"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00222</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00222</xsl:attribute>
            <svrl:text>
        [ISM-ID-00222][Error] If ISM_ICDOCUMENT_APPLIES, then the pocType attribute with value [ICD-710]
        must also be specified on some element in the document.
        
        Human Readable: A document claiming compliance with ICD-710 must specify a point-of-contact
        to whom questions about the document can be directed.
    </svrl:text>
            <svrl:text>
        If ISM_ICDOCUMENT_APPLIES, then ensure that some element specifies attribute @pocType with
        value 'ICD-710'.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M91"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00133</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00133</xsl:attribute>
            <svrl:text>
        [ISM-ID-00133][Error] If ISM_NSI_EO_APPLIES and attribute 
        declassException is specified and contains the tokens [25X1-human], 
        [50X1-HUM], or [50X2-WMD], then attribute declassDate or declassEvent must NOT be specified.
        
        Human Readable: Documents under E.O. 13526 must not specify declassDate or declassEvent if 
        a declassException of 25X1-human, 50X1-HUM, or 50X2-WMD is specified.
    </svrl:text>
            <svrl:text>
        If current Classified National Security Information Executive Order does not
        apply to this resource then the rule does not apply and we return true. 
        Otherwise we ensure that any element with the attribute declassException
        specified with a value of [25X1-human], [50X1-HUM], or [50X1-WMD], 
        then we ensure that the attribute declassDate or attribute declassEvent 
        are not specified.      
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M92"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00143</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00143</xsl:attribute>
            <svrl:text>
        [ISM-ID-00143][Error] If ISM_CAPCO_RESOURCE and attribute 
        derivativelyClassifiedBy is specified, then attribute derivedFrom must be specified. 
        
        Human Readable: Derivatively Classified data including DOE data requires a derived from value to be identified.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the resource then the rule does not apply
        and we return true. If it is a CAPCO resource then we check that if we have
        an element having attribute derivativelyClassifiedBy then we also have the
        attribute derivedFrom on the same element.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M93"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00221</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00221</xsl:attribute>
            <svrl:text>
        [ISM-ID-00221][Error] If ISM_CAPCO_RESOURCE and attribute 
        derivativelyClassifiedBy is specified, then attribute classificationReason
        must not be specified.
        
        Human Readable: USA documents that are derivatively classified must not
        specify a classification reason.
    </svrl:text>
            <svrl:text>
    	For each element with the attribute derivativelyClassifiedBy specified,
    	we make sure that the attribute classificationReason is not specified.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M94"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00167</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00167</xsl:attribute>
            <svrl:text>[ISM-ID-00167][Error] If ISM_CAPCO_RESOURCE and attribute displayOnlyTo is specified, 
        then each of its values must be ordered in accordance with CVEnumISMRelTo.xml.
    </svrl:text>
            <svrl:text>To perform sorting, this rule first retrieves the CVE values for the attribute 
        to be sorted, which in this case is displayOnlyTo. Then, each attribute token
        is converted into a numerical value based on its characters. Next, each attribute token is 
        given an order number, which compares its position to that of its value in the CVE file.
        Next, each order number is compared to that of its previous sibling to determine if the tokens
        are in order. If a token is found whose order number is less than that of its previous sibling, 
        0 is returned for its sorted order number. If a token's order number is greater than that of its 
        previous sibling, 1 is returned. If two tokens have the same order number, their original attribute
        values are compared. If the original attribute value contains numbers then the comparison is made 
        on its converted numerical value; otherwise, the comparison is made on its string value. If an 
        attribute value is found whose value is less than that of its previous sibling,  0 is returned
        for its sorted order number; otherwise 2 is returned. Finally, if any tokens are found with 0 as 
        its sorted order number, then the rule fails as those tokens are out of order.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M95"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00168</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00168</xsl:attribute>
            <svrl:text>
        [ISM-ID-00168][Error] If ISM_CAPCO_RESOURCE and attribute 
        disseminationControls is not specified or is specified and does not contain the name token 
        [DISPLAYONLY], then attribute displayOnlyTo must not be specified.
        
        Human Readable: If a portion in a USA document is not marked for DISPLAY ONLY dissemination, 
        it must not list countries to which it can be disseminated. 
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If it is a CAPCO resource then we check that if the
        attribute displayOnlyTo is specified then the 
        attribute disseminationControls is also specified that it contains a value of 
        [DISPLAYONLY]
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M96"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00026</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00026</xsl:attribute>
            <svrl:text>[ISM-ID-00026][Error] If ISM_CAPCO_RESOURCE and attribute 
        disseminationControls is specified, then each of its values must be ordered in accordance with 
        CVEnumISMDissem.xml.</svrl:text>
            <svrl:text>To perform sorting, this rule first retrieves the CVE values for the attribute 
        to be sorted, which in this case is disseminationControls. Then, each attribute token
        is converted into a numerical value based on its characters. Next, each attribute token is 
        given an order number, which compares its position to that of its value in the CVE file.
        Next, each order number is compared to that of its previous sibling to determine if the tokens
        are in order. If a token is found whose order number is less than that of its previous sibling, 
        0 is returned for its sorted order number. If a token's order number is greater than that of its 
        previous sibling, 1 is returned. If two tokens have the same order number, their original attribute
        values are compared. If the original attribute value contains numbers then the comparison is made 
        on its converted numerical value; otherwise, the comparison is made on its string value. If an 
        attribute value is found whose value is less than that of its previous sibling,  0 is returned
        for its sorted order number; otherwise 2 is returned. Finally, if any tokens are found with 0 as 
        its sorted order number, then the rule fails as those tokens are out of order.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M97"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00028</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00028</xsl:attribute>
            <svrl:text>
        [ISM-ID-00028][Error] If ISM_CAPCO_RESOURCE and attribute 
        disseminationControls contains the name token [OC], [EYES], or [RELIDO], 
        then attribute classification must have a value of [TS], [S], or [C].
        
        Human Readable: Portions marked for ORCON, EYES ONLY, or RELIDO dissemination 
        in a USA document must be CLASSIFIED, SECRET, or TOP SECRET.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If it is a CAPCO resource then we check that if we have
        an element having attribute disseminationControls with a value of 
        [OC], [EYES], or [RELIDO] then we also have the 
        attribute classification specified with a value of [C], [S], or [TS] on the 
        same element.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M98"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00030</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00030</xsl:attribute>
            <svrl:text>
        [ISM-ID-00030][Error] If ISM_CAPCO_RESOURCE and attribute 
        disseminationControls contains the name token [FOUO], then attribute classification must have 
        a value of [U].
        
        Human Readable: Portions marked for FOUO dissemination in a USA document must be 
        classified UNCLASSIFIED.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If it is a CAPCO resource then we check that if we have
        an element having attribute disseminationControls without a value of 
        [FOUO] then we return true because the rule does not apply. Otherwise
        we make sure the attribute classification is specified with a value of [U] 
        on the same element.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M99"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00031</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00031</xsl:attribute>
            <svrl:text>
        [ISM-ID-00031][Error] If ISM_CAPCO_RESOURCE and attribute 
        disseminationControls contains the name token [REL] or [EYES], then attribute releasableTo 
        must be specified.
        
        Human Readable: USA documents containing REL TO or EYES ONLY dissemination must
        specify to which countries the document is releasable.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If it is a CAPCO resource then we check that if we have
        an element having attribute disseminationControls with a value of 
        [REL] or [EYES] then the attribute releasableTo is specified and does not
        have an empty value set.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M100"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00033</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00033</xsl:attribute>
            <svrl:text>
        [ISM-ID-00033][Error] If ISM_CAPCO_RESOURCE, then 
        tokens [REL], [EYES] and [NF] are mutually exclusive for attribute disseminationControls.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If it is a CAPCO resource then we check that if we have
        an element having attribute disseminationControls and counting 1 for each
        value of [REL], [NF] or [EYES] found. If the count is greater than one then
        then the values are not being used exclusively with respect to each other.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M101"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00034</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00034</xsl:attribute>
            <svrl:text>
        [ISM-ID-00034][Error] If ISM_CAPCO_RESOURCE, then 
        tokens "RELIDO" and "NF" are mutually exclusive for attribute disseminationControls.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If it is a CAPCO resource then we check that if we have
        an element having attribute disseminationControls that does not have
        values [RELIDO] and [NF] at the same time. 
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M102"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00094</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00094</xsl:attribute>
            <svrl:text>
        [ISM-ID-00094][Error] ISM_CAPCO_RESOURCE and attribute 
        disseminationControls contains the name token [REL], then attribute classification must not 
        have a value of [U].
        
        Human Readable: REL may not be used on UNCLASSIFIED portions.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If it is a CAPCO resource then we check the classification
        attribute of the current element. If it does not have value of [U] we return 
        true since this rule only applies to unclassified elements. If it is not [U] 
        then we check that the attribute disseminationControls does not have a value 
        of [REL].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M103"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00107</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00107</xsl:attribute>
            <svrl:text>
        [ISM-ID-00107][Error] If ISM_CAPCO_RESOURCE and attribute 
        disseminationControls contains the name token [IMC] then attribute classification must have a 
        value of [TS] or [S].
        
        Human Readable:  IMCON data is SECRET (S), but may appear with S or TOP SECRET data.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If it is a CAPCO resource then we check the attribute
        classification of the element and return true if it has a value of [S] or
        [TS]. Otherwise we check that the attribute disseminationControls does not
        contain the value [IMC].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M104"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00124</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00124</xsl:attribute>
            <svrl:text>
        [ISM-ID-00124][Warning] If ISM_CAPCO_RESOURCE and
        1. Attribute ownerProducer does not contain [USA].
        AND
        2. Attribute disseminationControls contains [RELIDO]
        
        Human Readable: RELIDO is not authorized for non-US portions.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If it is a CAPCO resource then we check the attribute
        ownerProducer for not having a value of [USA] and that the attribute
        disseminationControls contains a value of [RELIDO] then we return false
        because the resource is not in compliance with the rule.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M105"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00140</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00140</xsl:attribute>
            <svrl:text>
        [ISM-ID-00140][Error] If ISM_CAPCO_RESOURCE and attribute disseminationControls contains
        the name token [NF], then attribute classification must not have a value of [U]
        
        Human Readable: NF may not be used on UNCLASSIFIED portions.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If it is a CAPCO resource then we check the attribute
        classification of the element and return true if it has a value of [U]. 
        Otherwise we check that the attribute disseminationControls does not
        contain the value [NF].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M106"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00164</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00164</xsl:attribute>
            <svrl:text>
        [ISM-ID-00164][Error] If ISM_CAPCO_RESOURCE and attribute 
        disseminationControls contains the name token [RS],
        then attribute classification must have a value of [TS] or [S].
        
        Human Readable: USA documents with RISK SENSITIVE dissemination must
        be classified SECRET or TOP SECRET.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If it is a CAPCO resource then we check the attribute
        classification of the element and return true if it has a value of [S] or
        [TS]. Otherwise we check that the attribute disseminationControls does not
        contain the value [RS].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M107"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00169</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00169</xsl:attribute>
            <svrl:text>
        [ISM-ID-00169][Error] If ISM_CAPCO_RESOURCE, and attribute disseminationControls 
        contains name token [DISPLAYONLY] then tokens [RELIDO] and [NF] may not also be used.
        
        Human Readable: In a USA document, DISPLAY ONLY, RELIDO and NO FOREIGN dissemination are 
        mutually exclusive for a single element.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If it is a CAPCO resource then we check that if we have
        an element having attribute disseminationControls with a value of [DISPLAYONLY] then
        it does not have a value of [RELIDO] or [NF] also.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M108"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00213</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00213</xsl:attribute>
            <svrl:text>
        [ISM-ID-00213][Error] If ISM_CAPCO_RESOURCE and attribute 
        disseminationControls contains the name token [DISPLAYONLY], then attribute displayOnlyTo 
        must be specified.
        
        Human Readable: A USA document with DISPLAY ONLY dissemination must indicate the countries
        to which it can be disseminated.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If it is a CAPCO resource then we check that if we have
        an element having attribute disseminationControls with a value of 
        [DISPLAYONLY] then the attribute displayOnlyTo is specified and does not
        have an empty value set.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M109"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00215</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00215</xsl:attribute>
            <svrl:text>
        [ISM-ID-00215][Error] If ISM_CAPCO_RESOURCE and attribute 
        disseminationControls contains the name token [DISPLAYONLY], 
        then attribute classification must have a value of [TS], [S], or [C].
        
        Human Readable: USA documents with DISPLAYONLY dissemination must be classified
        CLASSIFIED, SECRET, or TOP SECRET.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If it is a CAPCO resource then we check that if we have
        an element having attribute disseminationControls with a value of 
        [DISPLAYONLY] then we also have the attribute classification specified 
        with a value of [C], [S], or [TS] on the same element.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M110"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00095</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00095</xsl:attribute>
            <svrl:text>
        [ISM-ID-00095][Error] If ISM_CAPCO_RESOURCE and attribute FGIsourceOpen is 
        specified then each of its values must be ordered in accordance with CVEnumISMFGIOpen.xml.
    </svrl:text>
            <svrl:text>
        To perform sorting, this rule first retrieves the CVE values for the attribute 
        to be sorted, which in this case is FGIsourceOpen. Then, each attribute token
        is converted into a numerical value based on its characters. Next, each attribute token is 
        given an order number, which compares its position to that of its value in the CVE file.
        Next, each order number is compared to that of its previous sibling to determine if the tokens
        are in order. If a token is found whose order number is less than that of its previous sibling, 
        0 is returned for its sorted order number. If a token's order number is greater than that of its 
        previous sibling, 1 is returned. If two tokens have the same order number, their original attribute
        values are compared. If the original attribute value contains numbers then the comparison is made 
        on its converted numerical value; otherwise, the comparison is made on its string value. If an 
        attribute value is found whose value is less than that of its previous sibling,  0 is returned
        for its sorted order number; otherwise 2 is returned. Finally, if any tokens are found with 0 as 
        its sorted order number, then the rule fails as those tokens are out of order.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M111"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00096</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00096</xsl:attribute>
            <svrl:text>
        [ISM-ID-00096][Error] If ISM_CAPCO_RESOURCE and attribute FGIsourceProtected is specified 
        then each of its values must be ordered in accordance with CVEnumISMFGIProtected.xml.
    </svrl:text>
            <svrl:text>
        To perform sorting, this rule first retrieves the CVE values for the attribute 
        to be sorted, which in this case is FGIsourceProtected. Then, each attribute token
        is converted into a numerical value based on its characters. Next, each attribute token is 
        given an order number, which compares its position to that of its value in the CVE file.
        Next, each order number is compared to that of its previous sibling to determine if the tokens
        are in order. If a token is found whose order number is less than that of its previous sibling, 
        0 is returned for its sorted order number. If a token's order number is greater than that of its 
        previous sibling, 1 is returned. If two tokens have the same order number, their original attribute
        values are compared. If the original attribute value contains numbers then the comparison is made 
        on its converted numerical value; otherwise, the comparison is made on its string value. If an 
        attribute value is found whose value is less than that of its previous sibling,  0 is returned
        for its sorted order number; otherwise 2 is returned. Finally, if any tokens are found with 0 as 
        its sorted order number, then the rule fails as those tokens are out of order.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M112"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00097</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00097</xsl:attribute>
            <svrl:text>
        [ISM-ID-00097][Warning] If ISM_CAPCO_RESOURCE and attribute FGIsourceProtected is 
        specified with a value other than [FGI] then the value(s) must not be discoverable in IC shared spaces.
        
        Human Readable: FGI Protected should rarely if ever be seen outside of an agency's internal systems.    
    </svrl:text>
            <svrl:text>
        Checks that the resource is a CAPCO resource and that the FGIsourceProtected 
        attribute contains only the value [FGI].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M113"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00217</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00217</xsl:attribute>
            <svrl:text>
        [ISM-ID-00217][Error] If ISM_CAPCO_RESOURCE attribute FGIsourceProtected contains [FGI], 
        it must be the only value.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. Otherwise, we make sure that the current element has 
        attribute FGIsourceProtected specified with [FGI] as its only value.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M114"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00002</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00002</xsl:attribute>
            <svrl:text>
        [ISM-ID-00002][Error] For every optional attribute that is used in a document a non-null value must be present.
    </svrl:text>
            <svrl:text>
        This code checks that if an attribute is present and has an empty or whitespace string as a value, then
        we return false since all attributes must have a value specified.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M115"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00012</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00012</xsl:attribute>
            <svrl:text>
        [ISM-ID-00012][Error] If any of the attributes defined in 
        this DES other than DESVersion, unregisteredNoticeType, or pocType are specified for an element, 
        then attributes classification and ownerProducer must be specified for the element.
    </svrl:text>
            <svrl:text>
        This code triggers on elements that have an ISM attribute whose name is not 'DESVersion' and
        it ensures that both the ownerProducer and classification attributes are present 
		on the element.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M116"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00102</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00102</xsl:attribute>
            <svrl:text>
        [ISM-ID-00102][Error] The root element must have the attribute 
        DESVersion in the namespace urn:us:gov:ic:ism.
        
        Human Readable: The data encoding specification version number must be specified on the resource node.
    </svrl:text>
            <svrl:text>
        The code checks that the root node has attribute DESVersion specified.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M117"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00103</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00103</xsl:attribute>
            <svrl:text>
        [ISM-ID-00103][Error] At least one element must have resourceElement true.
    </svrl:text>
            <svrl:text>
        The code loops over all elements which have ISM attributes present and counts the elements which 
        specify the attribute resourceElement. Then it makes sure that the total is greater than zero.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M118"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00119</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00119</xsl:attribute>
            <svrl:text>
        [ISM-ID-00119][Error] If ISM_CAPCO_RESOURCE and 
        1. attribute classification is not [U]
        AND
        2. ISM_ICDOCUMENT_APPLIES
        AND
        3. Attribute disseminationControls must contain one or more of 
            [DISPLAYONLY], [REL], [RELIDO], [EYES], or [NF]

        Human Readable: All classified NSI that claims compliance with ICD 710 must have an appropriate 
        foreign disclosure or release marking.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document, or ICDocument does not apply to the document,
        or the resource is unclassified, then the rule does not apply. 
        Otherwise, we make sure that the attribute disseminationControls contains at least
        one of the values [DISPLAYONLY], [RELIDO], [REL], [EYES], or [NF].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M119"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00125</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00125</xsl:attribute>
            <svrl:text>
        [ISM-ID-00125][Error] If any attributes in namespace 
        urn:us:gov:ic:ism exist, the local name must exist in CVEnumISMAttributes.xml. 
        
        Human Readable: Ensure that attributes in the ISM namespace are defined by ISM.XML.
    </svrl:text>
            <svrl:text>
        To determine the valid values, this rule first retrieves the list of 
        valid attribute names as defined in CVEnumISMAttributes.xml. 
        Next, each attribute token is given an order number, which compares its 
        position to that of its value in the CVE file. If the token is not found, 
        its order number will be -1 and it is considered invalid. If the document 
        is a CAPCO resource, then the rule will fail if invalid tokens are found. 
        The rule will also fail if duplicate values are found for an attribute name.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M120"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00126</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00126</xsl:attribute>
            <svrl:text>
        [ISM-ID-00126][Error] Attributes with namespace urn:us:gov:ic:ism must 
        not appear with attribute @xs:any. 
        
        Human Readable: Ensure that no attributes that appear to be in the ISM namespace, but are not 
        defined by ISM.XML, are used in a schema that might have an xs:any.
    </svrl:text>
            <svrl:text>
        The code checks that any element having ISM attributes does not have the attribute xs:any specified.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M121"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00166</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00166</xsl:attribute>
            <svrl:text>[ISM-ID-00166][Warning] Attribute classification contains a value that will be deprecated.</svrl:text>
            <svrl:text>Traverse the CVE file pulling out deprecated values and their dates. Using the ism:createDate, determine if the values are
        being used but it is still prior to the deprecated date.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M122"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00170</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00170</xsl:attribute>
            <svrl:text>[ISM-ID-00170][Error] Attribute classification must not contain values that have passed their deprecation date.</svrl:text>
            <svrl:text>Traverse the CVE file pulling out deprecated values and their dates. Using the ism:createDate determine if the values are
        being used passed the deprecated date..</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M123"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00179</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00179</xsl:attribute>
            <svrl:text>[ISM-ID-00179][Warning] Attribute disseminationControls contains a value that will be deprecated.</svrl:text>
            <svrl:text>Traverse the CVE file pulling out deprecated values and their dates. Using the ism:createDate, determine if the values are
        being used but it is still prior to the deprecated date.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M124"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00180</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00180</xsl:attribute>
            <svrl:text>[ISM-ID-00180][Error] Attribute disseminationControls must not contain values that have passed their deprecation date.</svrl:text>
            <svrl:text>Traverse the CVE file pulling out deprecated values and their dates. Using the ism:createDate determine if the values are
        being used passed the deprecated date..</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M125"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00188</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00188</xsl:attribute>
            <svrl:text>[ISM-ID-00188][Warning] Attribute FGIsourceOpen contains a value that will be deprecated.</svrl:text>
            <svrl:text>Traverse the CVE file pulling out deprecated values and their dates. Using the ism:createDate, determine if the values are
        being used but it is still prior to the deprecated date.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M126"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00189</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00189</xsl:attribute>
            <svrl:text>[ISM-ID-00189][Error] Attribute FGIsourceOpen must not contain values that have passed their deprecation date.</svrl:text>
            <svrl:text>Traverse the CVE file pulling out deprecated values and their dates. Using the ism:createDate determine if the values are
        being used passed the deprecated date.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M127"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00190</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00190</xsl:attribute>
            <svrl:text>[ISM-ID-00190][Warning] Attribute FGIsourceProtected contains a value that will be deprecated.</svrl:text>
            <svrl:text>Traverse the CVE file pulling out deprecated values and their dates. Using the ism:createDate, determine if the values are
        being used but it is still prior to the deprecated date</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M128"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00191</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00191</xsl:attribute>
            <svrl:text>[ISM-ID-00191][Error] Attribute FGIsourceProtected must not contain values that have passed their deprecation date.</svrl:text>
            <svrl:text>Traverse the CVE file pulling out deprecated values and their dates. Using the ism:createDate determine if the values are
        being used passed the deprecated date.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M129"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00192</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00192</xsl:attribute>
            <svrl:text>[ISM-ID-00192][Warning] Attribute nonICmarkings contains a value that will be deprecated.</svrl:text>
            <svrl:text>Traverse the CVE file pulling out deprecated values and their dates. Using the ism:createDate, determine if the values are
        being used but it is still prior to the deprecated date</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M130"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00193</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00193</xsl:attribute>
            <svrl:text>[ISM-ID-00193][Error] Attribute nonICmarkings must not contain values that have passed their deprecation date.</svrl:text>
            <svrl:text>Traverse the CVE file pulling out deprecated values and their dates. Using the ism:createDate determine if the values are
        being used passed the deprecated date.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M131"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00194</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00194</xsl:attribute>
            <svrl:text>[ISM-ID-00194][Warning] Attribute notice contains a value that will be deprecated.</svrl:text>
            <svrl:text>Traverse the CVE file pulling out deprecated values and their dates. Using the ism:createDate, determine if the values are
        being used but it is still prior to the deprecated date</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M132"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00195</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00195</xsl:attribute>
            <svrl:text>[ISM-ID-00195][Error] Attribute notice must not contain values that have passed their deprecation date.</svrl:text>
            <svrl:text>Traverse the CVE file pulling out deprecated values and their dates. Using the ism:createDate determine if the values are
        being used passed the deprecated date.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M133"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00196</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00196</xsl:attribute>
            <svrl:text>[ISM-ID-00196][Warning] Attribute ownerProducer contains a value that will be deprecated.</svrl:text>
            <svrl:text>Traverse the CVE file pulling out deprecated values and their dates. Using the ism:createDate, determine if the values are
        being used but it is still prior to the deprecated date</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M134"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00197</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00197</xsl:attribute>
            <svrl:text>[ISM-ID-00197][Error] Attribute ownerProducer must not contain values that have passed their deprecation date.</svrl:text>
            <svrl:text>Traverse the CVE file pulling out deprecated values and their dates. Using the ism:createDate determine if the values are
        being used passed the deprecated date.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M135"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00198</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00198</xsl:attribute>
            <svrl:text>[ISM-ID-00198][Warning] Attribute releasableTo contains a value that will be deprecated.</svrl:text>
            <svrl:text>Traverse the CVE file pulling out deprecated values and their dates. Using the ism:createDate, determine if the values are
        being used but it is still prior to the deprecated date</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M136"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00199</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00199</xsl:attribute>
            <svrl:text>[ISM-ID-00199][Error] Attribute releasableTo must not contain values that have passed their deprecation date.</svrl:text>
            <svrl:text>Traverse the CVE file pulling out deprecated values and their dates. Using the ism:createDate determine if the values are
        being used passed the deprecated date.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M137"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00200</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00200</xsl:attribute>
            <svrl:text>[ISM-ID-00200][Warning] Attribute displayOnlyTo contains a value that will be deprecated.</svrl:text>
            <svrl:text>Traverse the CVE file pulling out deprecated values and their dates. Using the ism:createDate date, determine if the values are
        being used but it is still prior to the deprecated date</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M138"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00201</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00201</xsl:attribute>
            <svrl:text>[ISM-ID-00201][Error] Attribute displayOnlyTo must not contain values that have passed their deprecation date.</svrl:text>
            <svrl:text>Traverse the CVE file pulling out deprecated values and their dates. Using the ism:createDate determine if the values are
        being used passed the deprecated date.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M139"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00202</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00202</xsl:attribute>
            <svrl:text>[ISM-ID-00202][Warning] Attribute SARIdentifier contains a value that will be deprecated.</svrl:text>
            <svrl:text>Traverse the CVE file pulling out deprecated values and their dates. Using the ism:createDate, determine if the values are
        being used but it is still prior to the deprecated date</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M140"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00203</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00203</xsl:attribute>
            <svrl:text>[ISM-ID-00203][Error] Attribute SARIdentifier must not contain values that have passed their deprecation date.</svrl:text>
            <svrl:text>Traverse the CVE file pulling out deprecated values and their dates. Using the ism:createDate determine if the values are
        being used passed the deprecated date.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M141"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00204</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00204</xsl:attribute>
            <svrl:text>[ISM-ID-00204][Warning] Attribute SCIControls contains a value that will be deprecated.</svrl:text>
            <svrl:text>Traverse the CVE file pulling out deprecated values and their dates. Using the ism:createDate, determine if the values are
        being used but it is still prior to the deprecated date</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M142"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00205</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00205</xsl:attribute>
            <svrl:text>[ISM-ID-00205][Error] Attribute SCIcontrols must not contain values that have passed their deprecation date.</svrl:text>
            <svrl:text>Traverse the CVE file pulling out deprecated values and their dates. Using the ism:createDate determine if the values are
        being used passed the deprecated date.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M143"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00206</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00206</xsl:attribute>
            <svrl:text>[ISM-ID-00206][Warning] Attribute declassException contains a value that will be deprecated.</svrl:text>
            <svrl:text>Traverse the CVE file pulling out deprecated values and their dates. Using the ism:createDate, determine if the values are
        being used but it is still prior to the deprecated date</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M144"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00207</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00207</xsl:attribute>
            <svrl:text>[ISM-ID-00207][Error] Attribute declassException must not contain values that have passed their deprecation date.</svrl:text>
            <svrl:text>Traverse the CVE file pulling out deprecated values and their dates. Using the ism:createDate determine if the values are
        being used passed the deprecated date.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M145"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00208</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00208</xsl:attribute>
            <svrl:text>[ISM-ID-00208][Warning] Attribute atomicEnergyMarkings contains a value that will be deprecated.</svrl:text>
            <svrl:text>Traverse the CVE file pulling out deprecated values and their dates. Using the ism:createDate determine if the values are
        being used prior to the deprecated date.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M146"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00209</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00209</xsl:attribute>
            <svrl:text>[ISM-ID-00209][Error] Attribute atomicEnergyMarkings must not contain values that have passed their deprecation date.</svrl:text>
            <svrl:text>Traverse the CVE file pulling out deprecated values and their dates. Using the ism:createDate determine if the values are
        being used passed the deprecated date.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M147"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00210</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00210</xsl:attribute>
            <svrl:text>[ISM-ID-00210][Warning] Attribute nonUSControls contains a value that will be deprecated.</svrl:text>
            <svrl:text>Traverse the CVE file pulling out deprecated values and their dates. Using the ism:createDate, determine if the values are
        being used but it is still prior to the deprecated date</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M148"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00211</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00211</xsl:attribute>
            <svrl:text>[ISM-ID-00211][Error] Attribute nonUSControls must not contain values that have passed their deprecation date.</svrl:text>
            <svrl:text>Traverse the CVE file pulling out deprecated values and their dates. Using the ism:createDate determine if the values are
        being used passed the deprecated date.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M149"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00223</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00223</xsl:attribute>
            <svrl:text>
        [ISM-ID-00223][Error] If any elements in namespace 
        urn:us:gov:ic:ism exist, the local name must exist in CVEnumISMElements.xml. 
        
        Human Readable: Ensure that elements in the ISM namespace are defined by ISM.XML.
    </svrl:text>
            <svrl:text>
        To determine the valid values, this rule first retrieves the list of 
        valid element names as defined in CVEnumISMElements.xml. The test will 
        pass if there exists in the list an element name that matches the name
        of the current element. 
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M150"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00226</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00226</xsl:attribute>
            <svrl:text>
        [ISM-ID-00226][Error] @ism:noticeType and @ism:unregisteredNoticeType
        may not both be used on the same element. 
        
        Human Readable: Ensure that the ISM attributes noticeType and
        unregisteredNoticeType are not used on the same element.
    </svrl:text>
            <svrl:text>
        Any element that has either @ism:noticeType or @ism:unregisteredNoticeType. 
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M151"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00035</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00035</xsl:attribute>
            <svrl:text>
        [ISM-ID-00035][Error] If ISM_CAPCO_RESOURCE and attribute nonICmarkings is 
        specified, then each of its values must be ordered in accordance with CVEnumISMNonIC.xml.
    </svrl:text>
            <svrl:text>
        To perform sorting, this rule first retrieves the CVE values for the attribute 
        to be sorted, which in this case is nonICmarkings. Then, each attribute token
        is converted into a numerical value based on its characters. Next, each attribute token is 
        given an order number, which compares its position to that of its value in the CVE file.
        Next, each order number is compared to that of its previous sibling to determine if the tokens
        are in order. If a token is found whose order number is less than that of its previous sibling, 
        0 is returned for its sorted order number. If a token's order number is greater than that of its 
        previous sibling, 1 is returned. If two tokens have the same order number, their original attribute
        values are compared. If the original attribute value contains numbers then the comparison is made 
        on its converted numerical value; otherwise, the comparison is made on its string value. If an 
        attribute value is found whose value is less than that of its previous sibling,  0 is returned
        for its sorted order number; otherwise 2 is returned. Finally, if any tokens are found with 0 as 
        its sorted order number, then the rule fails as those tokens are out of order.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M152"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00036</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00036</xsl:attribute>
            <svrl:text>
        [ISM-ID-00036][Error] If ISM_CAPCO_RESOURCE and attribute nonICmarkings 
        contains the name token [SC], then attribute classification must have a 
        value of [TS], [S], or [C].        
        
        Human Readable: SC data must be marked CONFIDENTIAL, SECRET or TOP SECRET in USA documents.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If it is a CAPCO resource then we check if the attribute
        disseminationControls contains the value [SC] and if it does we check that
        the classification attribute has a value of [C], [S], or [TS].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M153"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00037</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00037</xsl:attribute>
            <svrl:text>
        [ISM-ID-00037][Error] If ISM_CAPCO_RESOURCE and attribute nonICmarkings contains 
        the name token [SINFO], [SBU], or [SBU-NF], then attribute classification must 
        have a value of [U].
        
        Human Readable: SINFO, SBU, and SBU-NF data must be marked UNCLASSIFIED in USA documents.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If it is a CAPCO resource then we check if the attribute
        nonICmarkings contains a value of [SINFO], [SBU], or [SBU-NF] then the
        classification attribute must have a value of [U].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M154"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00038</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00038</xsl:attribute>
            <svrl:text>
        [ISM-ID-00038][Error] If ISM_CAPCO_RESOURCE, then Name tokens [XD] and [ND] are mutually 
        exclusive for attribute nonICmarkings.
        
        Human Readable: USA documents must not specify both XD and ND on a single element.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If it is a CAPCO resource then we check that the attribute
        nonICmarkings does not contain both a value of [XD] and a value of [ND].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M155"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00148</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00148</xsl:attribute>
            <svrl:text>
        [ISM-ID-00148][Error] If ISM_CAPCO_RESOURCE, then Name tokens [LES] and [LES-NF] are mutually
        exclusive for attribute nonICmarkings.
        
        Human Readable: USA documents must not specify both LES and LES-NF on a single element.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If it is a CAPCO resource then we check that the attribute
        nonICmarkings does not contain both a value of [LES] and a value of [LES-NF].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M156"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00225</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00225</xsl:attribute>
            <svrl:text>
        [ISM-ID-00225][Error] If ISM-ICDOCUMENT-APPLIES, then attribute ism:nonICmarkings must not 
        be specified with a value containing any name token starting with [ACCM]. 
        
        Human Readable: ACCM tokens are not valid for documents that claim compliance with IC rules.
    </svrl:text>
            <svrl:text>
        For each element which specifies attribute ism:nonICmarkings, if $ISM-ICDOCUMENT-APPLIES,
        then we make sure that attribute ism:nonICmarkings is not specified with a value containing
        a token which starts with [ACCM].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M157"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00163</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00163</xsl:attribute>
            <svrl:text>
        [ISM-ID-00163][Error] If attribute nonUSControls exists the attribute ownerProducer must equal [NATO].
        
        Human Readable: NATO is the only owner of classification markings for which nonUSControls are currently authorized.
    </svrl:text>
            <svrl:text>
        The code ensures that any element containing the attribute nonUSControls also has 
        attribute ownerProducer specified with a value of [NATO].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M158"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00127</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00127</xsl:attribute>
            <svrl:text>
        [ISM-ID-00127][Error] If ISM_CAPCO_RESOURCE and:
        1. Any element meeting ISM_CONTRIBUTES in the document has the attribute atomicEnergyMarkings containing [RD]
        AND
        2. No element meeting ISM_CONTRIBUTES in the document has notice containing [RD].
        
        Human Readable: USA documents containing RD data must also have an RD notice.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document and the element is not excluded from the rollup
        then the rule does not apply and we return true. If the current element has attribute atomicEnergyMarkings
        specified with a value containing [RD], then we make sure that attribute notice is specified 
        with a value containing [RD] in one of the portions of the document.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M159"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00128</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00128</xsl:attribute>
            <svrl:text>
        [ISM-ID-00128][Error] If ISM_CAPCO_RESOURCE and:
        1. Any element meeting ISM_CONTRIBUTES in the document has the attribute atomicEnergyMarkings containing [FRD]
        AND
        2. No element meeting ISM_CONTRIBUTES in the document has notice containing [FRD]
        
        Human Readable: USA documents containing FRD data must also have an FRD notice.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document and the element is not excluded from the rollup
        then the rule does not apply and we return true. If the current element has attribute atomicEnergyMarkings
        specified with a value containing [FRD], then we make sure that attribute notice is specified 
        with a value containing [FRD] in one of the portions of the document.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M160"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00129</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00129</xsl:attribute>
            <svrl:text>
        [ISM-ID-00129][Error] If ISM_CAPCO_RESOURCE and:
        1. Any element meeting ISM_CONTRIBUTES in the document has the attribute disseminationControls containing [IMC]
        AND
        2. No element meeting ISM_CONTRIBUTES in the document has notice containing [IMC]
        
        Human Readable: USA documents containing IMC data must also have an IMC notice.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document and the element is not excluded from the rollup
        then the rule does not apply and we return true. If the current element has attribute disseminationControls
        specified with a value containing [IMC], then we make sure that attribute notice is specified 
        with a value containing [IMC] in one of the portions of the document.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M161"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00130</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00130</xsl:attribute>
            <svrl:text>
        [ISM-ID-00130][Error] If ISM_CAPCO_RESOURCE and:
        1. Any element meeting ISM_CONTRIBUTES in the document has the attribute disseminationControls containing [FISA]
        AND
        2. No element meeting ISM_CONTRIBUTES in the document has notice containing [FISA]
        
        Human Readable: USA documents containing FISA data must also have an FISA notice.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document and the element is not excluded from the rollup
        then the rule does not apply and we return true. If the current element has attribute disseminationControls
        specified with a value containing [FISA], then we make sure that attribute notice is specified 
        with a value containing [FISA] in one of the portions of the document.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M162"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00134</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00134</xsl:attribute>
            <svrl:text>
        [ISM-ID-00134][Error] If ISM_CAPCO_RESOURCE and:
        1. Any element meeting ISM_CONTRIBUTES in the document has the attribute nonICmarkings containing [DS]
        AND
        2. No element meeting ISM_CONTRIBUTES in the document has the attribute notice containing [DS]
        
        Human Readable: USA documents containing DS data must also have a DS notice.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document and the element is not excluded from the rollup
        then the rule does not apply and we return true. If the current element has attribute nonICmarkings specified 
        with a value containing [DS], then we make sure that attribute notice is specified 
        with a value containing [DS] in one of the portions of the document.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M163"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00135</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00135</xsl:attribute>
            <svrl:text>
        [ISM-ID-00135][Warning] If ISM_CAPCO_RESOURCE and:
        1. No element meeting ISM_CONTRIBUTES in the document has the attribute atomicEnergyMarkings containing [RD]
        AND
        2. Any element meeting ISM_CONTRIBUTES in the document has the attribute notice containing [RD]
        
        Human Readable: USA documents containing an RD notice must also have RD data.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document and the element is not excluded from the rollup
        then the rule does not apply and we return true. If  the current element is the resourceElement
        then the rule does not apply and we return true. If the current element has attribute notice specified 
        with a value containing [RD], then we make sure that attribute atomicEnergyMarkings is specified 
        with a value containing [RD] in one of the portions of the document.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M164"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00136</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00136</xsl:attribute>
            <svrl:text>
        [ISM-ID-00136][Warning] If ISM_CAPCO_RESOURCE and:
        1. No element without ism:excludeFromRollup=true() in the document has the attribute atomicEnergyMarkings containing [FRD]
        AND
        2. Any element without ism:excludeFromRollup=true() in the document has the attribute notice containing [FRD]
        
        Human Readable: USA documents containing an FRD notice must also have FRD data.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document and the element is not excluded from the rollup
        then the rule does not apply and we return true. If the current element has attribute notice specified 
        with a value containing [FRD], then we make sure that attribute atomicEnergyMarkings is specified 
        with a value containing [FRD] in one of the portions of the document.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M165"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00137</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00137</xsl:attribute>
            <svrl:text>
        [ISM-ID-00137][Warning] If ISM_CAPCO_RESOURCE and:
        1. No element without ism:excludeFromRollup=true() in the document has the attribute disseminationControls containing [IMC]
        AND
        2. Any element without ism:excludeFromRollup=true() in the document has the attribute notice containing [IMC]
        
        Human Readable: USA documents containing an IMC notice must also have IMC data.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document and the element is not excluded from the rollup
        then the rule does not apply and we return true. If the current element has attribute notice specified 
        with a value containing [IMC] and is not excluded from the rollup, then we make sure that 
        attribute disseminationControls is specified with a value containing [IMC] in one of the 
        portions of the document.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M166"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00138</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00138</xsl:attribute>
            <svrl:text>
        [ISM-ID-00138][Warning] If ISM_CAPCO_RESOURCE and:
        1. No element without ism:excludeFromRollup=true() in the document has the attribute nonICmarkings containing [DS]
        AND
        2. Any element without ism:excludeFromRollup=true() in the document has the attribute notice containing [DS]
        
        Human Readable: USA documents containing a DS notice must also have DS data. 
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document and the element is not excluded from the rollup
        then the rule does not apply and we return true. If the current element has attribute notice specified 
        with a value containing [DS] and is not excluded from the rollup, then we make sure that 
        attribute nonICmarkings is specified with a value containing [DS] in one of the 
        portions of the document.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M167"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00139</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00139</xsl:attribute>
            <svrl:text>
        [ISM-ID-00139][Warning] If ISM_CAPCO_RESOURCE and:
        1. No element without ism:excludeFromRollup=true() in the document has the attribute disseminationControls containing [FISA]
        AND
        2. Any element without ism:excludeFromRollup=true() in the document has the attribute notice containing [FISA]
        
        Human Readable: USA documents containing an FISA notice must also have FISA data. 
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document and the element is not excluded from the rollup
        then the rule does not apply and we return true. If the current element has attribute notice specified 
        with a value containing [FISA] and is not excluded from the rollup, then we make sure that 
        attribute disseminationControls is specified with a value containing [FISA] in one of the 
        portions of the document.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M168"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00150</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00150</xsl:attribute>
            <svrl:text>
        [ISM-ID-00150][Error] If ISM_CAPCO_RESOURCE and:
        1. Any element meeting ISM_CONTRIBUTES in the document has the attribute nonICmarkings containing [LES]
        AND
        2. No element meeting ISM_CONTRIBUTES in the document has notice containing [LES]
        
        Human Readable: USA documents containing LES data must also have an LES notice. 
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document or the element is excluded from the rollup
        then the rule does not apply and we return true. If  the current element is the resourceElement
        then the rule does not apply and we return true. If the current element has attribute nonICmarkings 
        specified with a value containing [LES], then we make sure that attribute notice is specified with 
        a value containing [LES] in one of the portions of the document.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M169"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00151</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00151</xsl:attribute>
            <svrl:text>
        [ISM-ID-00151][Warning] If ISM_CAPCO_RESOURCE and:
        1. No element without ism:excludeFromRollup=true() in the document has the attribute nonICmarkings containing [LES]
        AND
        2. Any element without ism:excludeFromRollup=true() in the document has the attribute notice containing [LES]    
        
        Human Readable: USA documents containing an LES notice must also have LES data. 
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document and the element is not excluded from the rollup
        then the rule does not apply and we return true. If the current element has attribute notice specified 
        with a value containing [LES] and it is included in the rollup, then we make sure that 
        attribute nonICmarkings is specified with a value containing [LES] in one of the portions of the document.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M170"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00152</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00152</xsl:attribute>
            <svrl:text>
        [ISM-ID-00152][Error] If ISM_CAPCO_RESOURCE and:
        1. Any element meeting ISM_CONTRIBUTES in the document has the attribute nonICmarkings containing [LES-NF]
        AND
        2. No element meeting ISM_CONTRIBUTES in the document has notice containing [LES-NF]
        
        Human Readable: USA documents containing LES-NF data must also have an LES-NF notice. 
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document and the element is not excluded from the rollup
        then the rule does not apply and we return true. If the current element specifies attribute 
        nonICmarkings with a value containing [LES-NF], then we make sure that attribute notice is 
        specified with a value containing [LES-NF] in one of the portions of the document.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M171"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00153</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00153</xsl:attribute>
            <svrl:text>
        [ISM-ID-00153][Error] If ISM_CAPCO_RESOURCE and:
        1. No element without ism:excludeFromRollup=true() in the document has the attribute nonICmarkings containing [LES-NF]
        AND
        2. Any element without ism:excludeFromRollup=true() in the document has the attribute notice containing [LES-NF].
        
        Human Readable: USA documents containing an LES-NF notice must also have LES-NF data. 
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document and the element is not excluded from the rollup
        then the rule does not apply and we return true. If the current element has attribute notice specified 
        with a value containing [LES-NF] and it is included in the rollup, then we make sure that 
        attribute nonICmarkings is specified with a value containing [LES-NF] in one of the portions of the document.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M172"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00156</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00156</xsl:attribute>
            <svrl:text>
        [ISM-ID-00156][Error] If ISM-CAPCO-RESOURCE and:
        1. The attribute notice contains on of the [DoD-Dist-B], [DoD-Dist-C], [DoD-Dist-D], [DoD-Dist-E],
        [DoD-Dist-F], or [DoD-Dist-X]
        AND
        2. Attribute noticeDate is not specified
        AND
        3. Attribute pocType is not specified on some element in the document with the same 
           value as that of notice 
        
        Human Readable: DoD distribution statements B, C, D ,E ,F, and X all require a Date and a POC.
    </svrl:text>
            <svrl:text>
        For every element that has a @noticeType attribute in a CAPCO document, if the 
        value of @noticeType is specified with a value containing [DoD-Dist-B], 
        [DoD-Dist-C], [DoD-Dist-D], [DoD-Dist-E], [DoD-Dist-F], or [DoD-Dist-X], 
        then we make sure that attribute @noticeDate is specified on the current element, and 
        somewhere in the document, the @pocType attribute is specified with the given value 
        of @noticeType.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M173"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00157</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00157</xsl:attribute>
            <svrl:text>
        [ISM-ID-00157][Error] If ISM_CAPCO_RESOURCE and:
        1. The attribute notice contains one of the [DoD-Dist-B], [DoD-Dist-C], [DoD-Dist-D], or [DoD-Dist-E]
        AND
        2. The attribute noticeReason is not specified.
        
        Human Readable: DoD distribution statements B, C, D , or E  all require a reason.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If the current element has attribute notice specified 
        with a value containing [DoD-Dist-B], [DoD-Dist-C], [DoD-Dist-D], [DoD-Dist-E], 
        or [DoD-Dist-F], then we make sure that attribute noticeReason is also specified 
        on the resourceElement.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M174"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00158</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00158</xsl:attribute>
            <svrl:text>
        [ISM-ID-00158][Error] If ISM_CAPCO_RESOURCE and:
        1. ISM_DoD5230_24_Applies
        AND
        2. attribute classification of ISM_RESOURCE_ELEMENT is not [U]
        AND
        3. The attribute notice does not contain one of [DoD-Dist-B], [DoD-Dist-C], [DoD-Dist-D], [DoD-Dist-E], or [DoD-Dist-F].
        
        Human Readable: All classified documents that claim compliance with DoD5230.24 must use one of DoD 
        distribution statements B, C, D, E, or F.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If DoD-5230-24 does not apply then the rule does not apply
        and we return true. If the resource is Unclassified then the rule does not apply
        and we return true. Otherwise, we make sure that the resourceElement attribute notice 
        does not contain a value of [DoD-Dist-B], [DoD-Dist-C], [DoD-Dist-D], [DoD-Dist-E], 
        or [DoD-Dist-F].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M175"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00159</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00159</xsl:attribute>
            <svrl:text>
        [ISM-ID-00159][Error] If ISM_CAPCO_RESOURCE and:
        1. attribute classification of ISM_RESOURCE_ELEMENT is not [U]
        AND
        2. The attribute notice does contains [DoD-Dist-A].
        
        Human Readable: Distribution statement A (Public Release) is forbidden on classified documents.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If the document is Unclassified then the rule does not apply
        and we return true. Otherwise, we check that the current element does not have attribute 
        notice specified with a value containing [DoD-Dist-A].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M176"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00160</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00160</xsl:attribute>
            <svrl:text>
        [ISM-ID-00160][Error] If ISM_CAPCO_RESOURCE and:
        1. The attribute notice of ISM_RESOURCE_ELEMENT does contain [DoD-Dist-A]
        AND
        2. attribute disseminationControls contains any of [FOUO], [PR], [DSEN], OR [FISA]
        AND
        3. attribute atomicEnergyMarkings contains any of [DCNI] or [UCNI].
        
        Human Readable: Distribution statement A (Public Release) is incompatible 
        with [FOUO], [PR], [DCNI], [UCNI], [DSEN], OR [FISA].
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If it is a CAPCO resource then we check that if the resourceElement 
        has attribute notice containing a value of [DoD-Dist-A] that the resourceElement's attribute
        disseminationControls does not contain values [FOUO], [PR], [DSEN], or [FISA] and attribute
        atomicEnergyMarkings does not contain values [UCNI] or [DCNI].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M177"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00161</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00161</xsl:attribute>
            <svrl:text>
        [ISM-ID-00161][Error] If ISM_CAPCO_RESOURCE and:
        1. The attribute notice of ISM_RESOURCE_ELEMENT does contains [DoD-Dist-A]
        AND
        2. attribute nonICmarkings contains any of [SINFO], [XD], [ND], [SBU], [SBU-NF], [LES], OR [LES-NF].
        
        Human Readable: Distribution statement A (Public Release) is incompatible with [SINFO], [XD], [ND], [SBU], [SBU-NF], [LES], OR [LES-NF].
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If it is a CAPCO resource and the resourceElement has 
        attribute notice specified with a value containing [DoD-Dist-A], then we make sure that
        the resourceElement's attribute nonICmarkings does not contain values 
        [SINFO], [XD], [ND], [SBU], [SBU-NF], [LES], or [LES-NF].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M178"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00001</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00001</xsl:attribute>
            <svrl:text>
        [ISM-ID-00001][Error] The attribute ownerProducer, when it exists, must have
        a non-null value.
    </svrl:text>
            <svrl:text>
        This code makes sure that if ownerProducer is specified that it contains
        content that is a non-whitespace value.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M179"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00099</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00099</xsl:attribute>
            <svrl:text>
        [ISM-ID-00099][Error] If ISM_CAPCO_RESOURCE attribute ownerProducer contains [FGI], 
        it must be the only value.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. Otherwise, we make sure that the current element has 
        attribute ownerProducer specified with [FGI] as its only value.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M180"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00100</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00100</xsl:attribute>
            <svrl:text>
          [ISM-ID-00100][Error] If ISM_CAPCO_RESOURCE and attribute ownerProducer is specified, 
          then each of its values must be ordered in accordance with CVEnumISMOwnerProducer.xml.
       </svrl:text>
            <svrl:text>
          To perform sorting, this rule first retrieves the CVE values for the attribute 
          to be sorted, which in this case is ownerProducer. Then, each attribute token
          is converted into a numerical value based on its characters. Next, each attribute token is 
          given an order number, which compares its position to that of its value in the CVE file.
          Next, each order number is compared to that of its previous sibling to determine if the tokens
          are in order. If a token is found whose order number is less than that of its previous sibling, 
          0 is returned for its sorted order number. If a token's order number is greater than that of its 
          previous sibling, 1 is returned. If two tokens have the same order number, their original attribute
          values are compared. If the original attribute value contains numbers then the comparison is made 
          on its converted numerical value; otherwise, the comparison is made on its string value. If an 
          attribute value is found whose value is less than that of its previous sibling,  0 is returned
          for its sorted order number; otherwise 2 is returned. Finally, if any tokens are found with 0 as 
          its sorted order number, then the rule fails as those tokens are out of order.
       </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M181"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00219</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00219</xsl:attribute>
            <svrl:text>
        [ISM-ID-00219][Error] If element meets ISM_CONTRIBUTES and attribute ownerProducer contains [FGI], 
        then FGIsourceProtected must have a value of [FGI].
        
        Human Readable: Any non-resource element that contributes to the document's banner roll-up and has
        FOREIGN GOVERNMENT INFORMATION (FGI) must also specify attribute FGIsourceProtected with token FGI.
    </svrl:text>
            <svrl:text>
        If not ISM_CONTRIBUTES then return true, otherwise, we make sure that if the current 
        element has attribute ownerProducer specified with [FGI] then FGIsourceProtected 
        also has a value of [FGI].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M182"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00224</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00224</xsl:attribute>
            <svrl:text>
        [ISM-ID-00224][Error] If ISM_CAPCO_RESOURCE and any element meeting ISM_CONTRIBUTES 
        in the document has the attribute disseminationControls containing [OC], then the 
        attribute @ism:pocType with value [ORCON] must be specified on some element in the document. 
        
        Human Readable: In accordance with the ORCON Memo dated March 11, 2011, 
        USA documents containing ORIGINATOR CONTROLLED data must specify a 
        point-of-contact to whom adjudication decisions about those data can be directed.  
    </svrl:text>
            <svrl:text>
        The rule will apply to the resource element of a CAPCO document that was created after
        the date after which ORCON points-of-contact became required. For this element, if 
        ORCON data is found, then the code checks if the attribute @ism:pocType is specified 
        with the value 'ORCON' on some element. Otherwise, the rule does not apply and 
        true is returned.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M183"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00032</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00032</xsl:attribute>
            <svrl:text>
        [ISM-ID-00032][Error] If ISM_CAPCO_RESOURCE and attribute 
        disseminationControls is not specified, or is specified and does not contain the name token 
        [REL] or [EYES], then attribute releasableTo must not be specified.
        
        Human Readable: USA documents must only specify to which countries it is 
        authorized for release if dissemination information contains REL TO or EYES ONLY data. 
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If the attribute releasableTo is specified, then we make sure
        that the attribute disseminationControls is specified with a value containing
        [EYES] or [REL].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M184"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00041</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00041</xsl:attribute>
            <svrl:text>
        [ISM-ID-00041][Error] If ISM_CAPCO_RESOURCE and attribute releasableTo is specified, 
        then each of its values must be ordered in accordance with CVEnumISMRelTo.xml.
    </svrl:text>
            <svrl:text>
        To perform sorting, this rule first retrieves the CVE values for the attribute 
        to be sorted, which in this case is releasableTo. Then, each attribute token
        is converted into a numerical value based on its characters. Next, each attribute token is 
        given an order number, which compares its position to that of its value in the CVE file.
        Next, each order number is compared to that of its previous sibling to determine if the tokens
        are in order. If a token is found whose order number is less than that of its previous sibling, 
        0 is returned for its sorted order number. If a token's order number is greater than that of its 
        previous sibling, 1 is returned. If two tokens have the same order number, their original attribute
        values are compared. If the original attribute value contains numbers then the comparison is made 
        on its converted numerical value; otherwise, the comparison is made on its string value. If an 
        attribute value is found whose value is less than that of its previous sibling,  0 is returned
        for its sorted order number; otherwise 2 is returned. Finally, if any tokens are found with 0 as 
        its sorted order number, then the rule fails as those tokens are out of order.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M185"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00214</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00214</xsl:attribute>
            <svrl:text>
        [ISM-ID-00214][Error] If ISM_CAPCO_RESOURCE then attribute 
        releasableTo must start with [USA].
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If the attribute releasableTo is specified, then we make sure
        that it starts with [USA].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M186"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00013</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00013</xsl:attribute>
            <svrl:text>
        [ISM-ID-00013][Error] If ISM_NSI_EO_APPLIES then either attribute classifiedBy or 
        derivedFrom must be specified on the ISM_RESOURCE_ELEMENT. 
        
        Human Readable: Documents under E.O. 13526 must have classification authority block information.
    </svrl:text>
            <svrl:text>
        If the current Classified National Security Information Executive Order
        does not apply to the document then the rule does not apply and we return true.
        Otherwise, we make sure that the resourceElement has attribute
        classifiedBy or derivedFrom specified.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M187"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00014</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00014</xsl:attribute>
            <svrl:text>
        [ISM-ID-00014][Error] If ISM_NSI_EO_APPLIES then one or more of the following 
        attributes: declassDate, declassEvent, or declassException must be specified on the ISM_RESOURCE_ELEMENT.
        
        Human Readable: Documents under E.O. 13526 must have declassification instructions included in the 
        classification authority block information.
    </svrl:text>
            <svrl:text>
        If the current Classified National Security Information Executive Order
        does not apply to the document then the rule does not apply and we return true.
        Otherwise, we make sure that the resourceElement has attribute
        declassDate, declassEvent, or declassException specified.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M188"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00056</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00056</xsl:attribute>
            <svrl:text>
        [ISM-ID-00056][Error] If ISM_CAPCO_RESOURCE and attribute classification of 
        ISM_RESOURCE_ELEMENT has a value of [U] then no element meeting ISM_CONTRIBUTES_USA in the document may have 
        a classification attribute of [C], [S] or [TS].
        
        Human Readable: USA UNCLASSIFIED documents can’t have TOP SECRET, SECRET, or CONFIDENTIAL data.    
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If the resourceElement has attribute classification
        specified with a value of [U], then we make sure that no portion with ownerProducer containing
        USA has attribute classification specified with a value of [C], [S], or [TS].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M189"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00057</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00057</xsl:attribute>
            <svrl:text>
        [ISM-ID-00057][Error] If ISM_CAPCO_RESOURCE and attribute classification of ISM_RESOURCE_ELEMENT 
        has a value of [U] then no element meeting ISM_CONTRIBUTES in the document may have a classification attribute of [R].
        
        Human Readable: USA UNCLASSIFIED documents cannot have RESTRICTED data. 
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply and 
        we return true. If the resourceElement has attribute classification specified 
        with a value of [U], then we make sure that no portion has attribute 
        classification specified with a value of [R].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M190"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00058</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00058</xsl:attribute>
            <svrl:text>
        [ISM-ID-00058][Error] If ISM_CAPCO_RESOURCE and attribute classification of ISM_RESOURCE_ELEMENT 
        has a value of [C] then no element meeting ISM_CONTRIBUTES_USA in the document may have a classification attribute of [S] or [TS].
        
        Human Readable: USA CONFIDENTIAL documents can't have TOP SECRET or SECRET data.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply and we return 
        true. If the resourceElement has attribute classification specified with a value of 
        [C], then we make sure that no portion with ownerProducer containing USA has attribute 
        classification specified with a value of [TS] or [S]. 
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M191"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00059</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00059</xsl:attribute>
            <svrl:text>
        [ISM-ID-00059][Error] If ISM_CAPCO_RESOURCE and attribute classification of ISM_RESOURCE_ELEMENT 
        has a value of [S] then no element meeting ISM_CONTRIBUTES_USA in the document may have a classification attribute of [TS].
        
        Human Readable: USA SECRET documents can't have TOP SECRET data.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply and 
        we return true. If the resourceElement has attribute classification specified 
        with a value of [S], then we make sure that no portion with ownerProducer containing
        USA has attribute classification specified with a value of [TS].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M192"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00060</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00060</xsl:attribute>
            <svrl:text>
        [ISM-ID-00060][Error] If ISM_CAPCO_RESOURCE and any element meeting ISM_CONTRIBUTES in the document 
        have the attribute SCIcontrols containing a value of [SI] then the ISM_RESOURCE_ELEMENT element’s SCIcontrols must contain [SI].
        
        Human Readable: USA documents having SI data must have SI at the resource level.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If the current element has attribute 
        SCIcontrols specified with a value containing [SI] and does not have attribute 
        excludeFromRollup set to true, then we make sure that the resourceElement
        has attribute SCIcontrols specified with a value containing [SI].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M193"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00061</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00061</xsl:attribute>
            <svrl:text>
        [ISM-ID-00061][Error] If ISM_CAPCO_RESOURCE and any element meeting ISM_CONTRIBUTES in the document 
        have the attribute SCIcontrols containing a value of [SI-G] then the ISM_RESOURCE_ELEMENT element’s SCIcontrols must contain [SI-G].
        
        Human Readable: USA documents having SI-G data must have SI-G at the resource level.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If the current element has attribute 
        SCIcontrols specified with a value containing [SI-G] and does not have attribute 
        excludeFromRollup set to true, then we make sure that the resourceElement
        has attribute SCIcontrols specified with a value containing [SI-G].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M194"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00062</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00062</xsl:attribute>
            <svrl:text>
        [ISM-ID-00062][Error] If ISM_CAPCO_RESOURCE and any element meeting ISM_CONTRIBUTES in the document 
        have the attribute SCIcontrols containing a value of [TK] then the ISM_RESOURCE_ELEMENT node’s SCIcontrols must contain [TK].
        
        Human Readable: USA documents having TK data must have TK at the resource level.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If the current element has attribute 
        SCIcontrols specified with a value containing [TK] and does not have attribute 
        excludeFromRollup set to true, then we make sure that the resourceElement
        has attribute SCIcontrols specified with a value containing [TK].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M195"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00063</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00063</xsl:attribute>
            <svrl:text>
        [ISM-ID-00063][Error] If ISM_CAPCO_RESOURCE and any element meeting ISM_CONTRIBUTES in the document 
        have the attribute SCIcontrols containing a value of [HCS] then the ISM_RESOURCE_ELEMENT node’s SCIcontrols must contain [HCS].
        
        Human Readable: USA documents having HCS data must have HCS at the resource level.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If the current element has attribute 
        SCIcontrols specified with a value containing [HCS] and does not have 
        attribute excludeFromRollup set to true, then we make sure that the resourceElement
        has attribute SCIcontrols specified with a value containing [HCS].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M196"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00064</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00064</xsl:attribute>
            <svrl:text>
        [ISM-ID-00064][Error] If ISM_CAPCO_RESOURCE and any element meeting ISM_CONTRIBUTES in the document 
        have the attribute FGIsourceOpen containing any value then the ISM_RESOURCE_ELEMENT must have either 
        FGIsourceOpen or FGIsourceProtected with a value. 
        
        Human Readable: USA documents having FGI Open data must have FGI Open or FGI Protected at the resource level.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If the current element has attribute 
        FGIsourceOpen specified and does not have attribute excludeFromRollup set to true, 
        then we make sure that the resourceElement has one of the following attributes 
        specified: FGIsourceOpen or FGIsourceProtected.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M197"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00065</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00065</xsl:attribute>
            <svrl:text>
        [ISM-ID-00065][Error] If ISM_CAPCO_RESOURCE and any element meeting ISM_CONTRIBUTES in the document 
        have the attribute FGIsourceProtected containing any value then the ISM_RESOURCE_ELEMENT must have FGIsourceProtected with a value.
        
        Human Readable: USA documents having FGI Protected data must have FGI Protected at the resource level.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If any element has attribute FGIsourceProtected specified 
        with a non-empty value and does not have attribute excludeFromRollup set to true, 
        then we make sure that the banner has attribute FGIsourceProtected specified with 
        a non-empty value.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M198"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00066</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00066</xsl:attribute>
            <svrl:text>
        [ISM-ID-00066][Error] If ISM_CAPCO_RESOURCE and: 
        1. Any element meeting ISM_CONTRIBUTES in the document has the attribute disseminationControls containing [FOUO]
        AND
        2. ISM_RESOURCE_ELEMENT has the attribute classification [U]
        AND
        3. No element meeting ISM_CONTRIBUTES in the document has nonICmarkings containing [SBU], [SBU-NF], [LES], [LES-NF]
        
        Then the ISM_RESOURCE_ELEMENT must have disseminationControls containing [FOUO].
        
        Human Readable: USA Unclassified documents having FOUO data and not having SBU, SBU-NF, LES, or LES-NF must have 
        FOUO at the resource level.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document, then the rule does not apply
        and we return true. Verify that this is actually the ISM_RESOURCE_ELEMENT
        If the resourceElement has attribute classification specified
        with a value other than [U], then the rule does not apply and we return true. If the
		banner has attribute disseminationControls specified with a value containing [FOUO], 
		or no element has attribute disseminationControls specified with value containing [FOUO], 
		then the rule does not apply and we return true. Otherwise, we make sure that an 
		element has attribute nonICmarkings specified with a value of [SBU], [SBU-NF], [LES], 
		or [LES-NF]. 
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M199"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00067</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00067</xsl:attribute>
            <svrl:text>
        [ISM-ID-00067][Error] If ISM_CAPCO_RESOURCE and any element meeting ISM_CONTRIBUTES 
        in the document has the attribute disseminationControls containing [OC] then the ISM_RESOURCE_ELEMENT must have 
        disseminationControls containing [OC]. 
        
        Human Readable: USA documents having ORCON data must have ORCON at the resource level.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. We make sure that no element does not have attribute excludeFromRollup 
        set to true has attribute disseminationControls specified
        with a value containing [OC] unless the resourceElement also has attribute
        disseminationControls specified with a value containing [OC].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M200"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00068</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00068</xsl:attribute>
            <svrl:text>
        [ISM-ID-00068][Error] If ISM_CAPCO_RESOURCE and any element meeting ISM_CONTRIBUTES 
        in the document have the attribute disseminationControls containing [IMC] then the ISM_RESOURCE_ELEMENT must have 
        disseminationControls containing [IMC].
        
        Human Readable: USA documents having IMCON data must have IMCON at the resource level.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. We make sure that no element that does not have attribute excludeFromRollup 
        set to true has attribute disseminationControls specified with a value containing [IMC] 
        unless the resourceElement also has attribute disseminationControls specified with a value 
        containing [IMC].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M201"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00070</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00070</xsl:attribute>
            <svrl:text>
        [ISM-ID-00070][Error] If ISM_CAPCO_RESOURCE and any element meeting ISM_CONTRIBUTES 
        in the document have the attribute disseminationControls containing [NF] then the ISM_RESOURCE_ELEMENT must have 
        disseminationControls containing [NF].
        
        Human Readable: USA documents having NF data must have NF at the resource level.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. We make sure that no element that does not have attribute excludeFromRollup 
        set to true has attribute disseminationControls specified
        with a value containing [NF] unless the resourceElement also has attribute
        disseminationControls specified with a value containing [NF].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M202"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00071</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00071</xsl:attribute>
            <svrl:text>
        [ISM-ID-00071][Error] If ISM_CAPCO_RESOURCE and any element meeting ISM_CONTRIBUTES 
        in the document have the attribute disseminationControls containing [PR] then the ISM_RESOURCE_ELEMENT must have 
        disseminationControls containing [PR].
        
        Human Readable: USA documents having PROPIN data must have PROPIN at the resource level.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. We make sure that no element that does not have attribute excludeFromRollup 
        set to true has attribute disseminationControls specified
        with a value containing [PR] unless the resourceElement also has attribute
        disseminationControls specified with a value containing [PR].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M203"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00072</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00072</xsl:attribute>
            <svrl:text>
        [ISM-ID-00072][Error] If ISM_CAPCO_RESOURCE and any element meeting ISM_CONTRIBUTES 
        in the document have the attribute atomicEnergyMarkings containing [RD] then the ISM_RESOURCE_ELEMENT must have 
        atomicEnergyMarkings containing [RD].
        
        Human Readable: USA documents having Restricted Data (RD) must have RD at the resource level.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. We make sure that no element that does not have attribute excludeFromRollup 
        set to true has attribute atomicEnergyMarkings specified
        with a value containing [RD] unless the resourceElement also has attribute
        atomicEnergyMarkings specified with a value containing [RD].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M204"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00073</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00073</xsl:attribute>
            <svrl:text>
        [ISM-ID-00073][Error] If ISM_CAPCO_RESOURCE and any element meeting ISM_CONTRIBUTES 
        in the document have the attribute atomicEnergyMarkings containing [RD-CNWDI] then the ISM_RESOURCE_ELEMENT must have 
        atomicEnergyMarkings containing [RD-CNWDI].
        
        Human Readable: USA documents having Restricted CNWDI Data must have Restricted CNWDI Data at the resource level.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. We make sure that no element that does not have attribute excludeFromRollup 
        set to true has attribute atomicEnergyMarkings specified
        with a value containing [RD-CNWDI] unless the resourceElement also has attribute
        atomicEnergyMarkings specified with a value containing [RD-CNWDI].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M205"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00074</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00074</xsl:attribute>
            <svrl:text>
        [ISM-ID-00074][Error] If ISM_CAPCO_RESOURCE and any element meeting ISM_CONTRIBUTES 
        in the document has the attribute atomicEnergyMarkings containing [RD-SG-##] then the ISM_RESOURCE_ELEMENT must have 
        atomicEnergyMarkings containing [RD-SG-##]. ## represent digits 1 through 99 the ## must match.
        
        Human Readable: USA documents having Restricted SIGMA-## Data must have the same Restricted SIGMA-## Data at the resource level.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. We make sure that no element that does not have attribute excludeFromRollup 
        set to true has attribute atomicEnergyMarkings specified
        with a value containing [RD-SG-##], where ## is represented by a regular expression matching
        numbers 1 through 99, unless the resourceElement also has attribute
        atomicEnergyMarkings specified with a value containing [RD-SG-##].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M206"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00075</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00075</xsl:attribute>
            <svrl:text>
        [ISM-ID-00075][Error] If ISM_CAPCO_RESOURCE and any element meeting ISM_CONTRIBUTES in the 
        document have the attribute atomicEnergyMarkings containing [FRD] then the ISM_RESOURCE_ELEMENT must have atomicEnergyMarkings 
        containing [FRD].
        
        Human Readable: USA documents having Formerly Restricted Data (FRD) must have FRD at the resource level.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. We make sure that no element that does not have attribute excludeFromRollup 
        set to true has attribute atomicEnergyMarkings specified
        with a value containing [FRD], unless the resourceElement also has attribute
        atomicEnergyMarkings specified with a value containing [FRD].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M207"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00077</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00077</xsl:attribute>
            <svrl:text>
        [ISM-ID-00077][Error] If ISM_CAPCO_RESOURCE and any element meeting ISM_CONTRIBUTES in the 
        document has the attribute atomicEnergyMarkings containing [FRD-SG-##] then the ISM_RESOURCE_ELEMENT must have 
        atomicEnergyMarkings containing [FRD-SG-##]. ## represent digits 1 through 99 the ## must match.
        
        Human Readable: USA documents having Formerly Restricted SIGMA-## Data must have the same Formerly Restricted SIGMA-## Data at 
        the resource level.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. We make sure that no element that does not have attribute excludeFromRollup 
        set to true has attribute atomicEnergyMarkings specified
        with a value containing [FRD-SG-##], where ## is represented by a regular expression matching
        numbers 1 through 99, unless the resourceElement also has attribute
        atomicEnergyMarkings specified with a value containing [FRD-SG-##].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M208"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00078</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00078</xsl:attribute>
            <svrl:text>
        [ISM-ID-00078][Error] If ISM_CAPCO_RESOURCE and the ISM_RESOURCE_ELEMENT node's 
        classification has the value of [U] and any element meeting ISM_CONTRIBUTES in the document has the attribute atomicEnergyMarkings 
        containing [DCNI] then the ISM_RESOURCE_ELEMENT must have atomicEnergyMarkings containing [DCNI].
        
        Human Readable: Unclassified USA documents having DCNI Data must have DCNI at the resource level.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If the resourceElement has attribute classification specified
        with a value other than [U] then the rule does not apply and we return true. 
        Otherwise, we make sure that no element has attribute atomicEnergyMarkings specified
        with a value containing [DCNI] and does not have attribute excludeFromRollup set to true, 
        unless the resourceElement also has attribute
        atomicEnergyMarkings specified with a value containing [DCNI].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M209"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00079</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00079</xsl:attribute>
            <svrl:text>
        [ISM-ID-00079][Error] If ISM_CAPCO_RESOURCE and ISM_RESOURCE_ELEMENT element’s classification 
        has the value of [U] and any element meeting ISM_CONTRIBUTES in the document has the attribute atomicEnergyMarkings containing 
        [UCNI] then the ISM_RESOURCE_ELEMENT must have atomicEnergyMarkings containing [UCNI].
        
        Human Readable: Unclassified USA documents having UCNI Data must have UCNI at the resource level.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If the resourceElement has attribute classification specified
        with a value other than [U] then the rule does not apply and we return true. 
        Otherwise, we make sure that no element has attribute atomicEnergyMarkings specified
        with a value containing [UCNI] and does not have attribute excludeFromRollup set to true,
        unless the resourceElement also has attribute
        atomicEnergyMarkings specified with a value containing [UCNI].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M210"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00080</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00080</xsl:attribute>
            <svrl:text>
        [ISM-ID-00080][Error] If ISM_CAPCO_RESOURCE and any element meeting ISM_CONTRIBUTES in the 
        document have the attribute disseminationControls containing [DSEN] then the ISM_RESOURCE_ELEMENT must have disseminationControls 
        containing [DSEN].
        
        Human Readable: USA documents having DSEN Data must have DSEN at the resource level.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. We make sure that no element that does not have attribute excludeFromRollup 
        set to true has attribute disseminationControls specified
        with a value containing [DSEN], unless the resourceElement also has attribute
        disseminationControls specified with a value containing [DSEN].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M211"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00081</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00081</xsl:attribute>
            <svrl:text>
        [ISM-ID-00081][Error] If ISM_CAPCO_RESOURCE and any element meeting ISM_CONTRIBUTES in the 
        document have the attribute disseminationControls containing [FISA] then the ISM_RESOURCE_ELEMENT must have disseminationControls 
        containing [FISA].
        
        Human Readable: USA documents having FISA Data must have FISA at the resource level.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. We make sure that no element that does not have attribute excludeFromRollup 
        set to true has attribute disseminationControls specified
        with a value containing [FISA] and does not have attribute excludeFromRollup set to true, 
        unless the resourceElement also has attribute
        disseminationControls specified with a value containing [FISA].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M212"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00082</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00082</xsl:attribute>
            <svrl:text>
        [ISM-ID-00082][Error] If ISM_CAPCO_RESOURCE and any element meeting ISM_CONTRIBUTES in the 
        document have the attribute nonICmarkings containing [SC] then the ISM_RESOURCE_ELEMENT must have nonICmarkings containing [SC].
        
        Human Readable: USA documents having SC Data must have SC at the resource level.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If any element has attribute nonICmarkings specified
        with a value containing [SC] and does not have attribute excludeFromRollup 
        set to true, then we make sure that the resourceElement 
        also has attribute nonICmarkings specified with a value containing [SC].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M213"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00083</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00083</xsl:attribute>
            <svrl:text>
        [ISM-ID-00083][Error] If ISM_CAPCO_RESOURCE and any element meeting ISM_CONTRIBUTES in the 
        document have the attribute nonICmarkings containing [SINFO] then the ISM_RESOURCE_ELEMENT must have nonICmarkings containing [SINFO].
        
        Human Readable: USA documents having SINFO Data must have SINFO at the resource level.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document or the banner is classified then the 
        rule does not apply and we return true. If any element has attribute nonICmarkings 
        specified with a value containing [SINFO] and does not have attribute 
        excludeFromRollup set to true, then we make sure that the resourceElement 
        also has attribute nonICmarkings specified with a value containing [SINFO].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M214"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00084</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00084</xsl:attribute>
            <svrl:text>
        [ISM-ID-00084][Error] If ISM_CAPCO_RESOURCE and any element meeting ISM_CONTRIBUTES in the document 
        have the attribute nonICmarkings containing [DS] then the ISM_RESOURCE_ELEMENT must have nonICmarkings containing [DS]. 
        
        Human Readable: USA documents having DS Data must have DS at the resource level.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If any element has attribute nonICmarkings specified
        with a value containing [DS] and does not have attribute excludeFromRollup 
        set to true, then we make sure that the resourceElement 
        also has attribute nonICmarkings specified with a value containing [DS].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M215"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00085</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00085</xsl:attribute>
            <svrl:text>
        [ISM-ID-00085][Error] If ISM_CAPCO_RESOURCE and any element meeting ISM_CONTRIBUTES in the document 
        has the attribute nonICmarkings containing [XD] and does not have any element meeting ISM_CONTRIBUTES in the document having the 
        attribute nonICmarkings containing [ND] then the ISM_RESOURCE_ELEMENT must have nonICmarkings containing [XD].
        
        Human Readable: USA documents having XD Data and not having ND must have XD at the resource level.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If any element has attribute nonICmarkings specified
        with a value containing [XD] and no element has attribute nonICmarkings
        specified with a value containing [ND] and does not have attribute excludeFromRollup 
        set to true, then we make sure that the resourceElement 
        has attribute nonICmarkings specified with a value containing [XD].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M216"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00086</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00086</xsl:attribute>
            <svrl:text>
        [ISM-ID-00086][Error] If ISM_CAPCO_RESOURCE and any element in the document:
        1. Meets ISM_CONTRIBUTES
        AND
        2. Has the attribute nonICmarkings containing [ND]
        Then the ISM_RESOURCE_ELEMENT must have nonICmarkings containing [ND].
        
        Human Readable: USA documents having ND Data must have ND at the resource level.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If any element has attribute nonICmarkings specified
        with a value containing [ND] and does not have attribute excludeFromRollup 
        set to true, then we make sure that the resourceElement 
        has attribute nonICmarkings specified with a value containing [ND].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M217"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00087</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00087</xsl:attribute>
            <svrl:text>
        [ISM-ID-00087][Error] If ISM_CAPCO_RESOURCE and there exist at least 2 elements in the document:
        1. Each element: Meets ISM_CONTRIBUTES
        AND
        2. One of the elements: Has the attribute nonICmarkings containing [SBU-NF]
        AND
        3. One of the elements: Has the attribute classification NOT having a value of [U]
        Then the ISM_RESOURCE_ELEMENT must have disseminationControls containing [NF].
        
        Human Readable: Classified USA documents having SBU-NF Data must have NF at the resource level.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If any element has attribute nonICmarkings specified
        with a value containing [SBU-NF], does not have attribute excludeFromRollup set to 
        true, and the resourceElement has attribute classification
        specified with a value other than [U], then we make sure that the resourceElement 
        has attribute disseminationControls specified with a value containing [NF].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M218"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00088</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00088</xsl:attribute>
            <svrl:text>
        [ISM-ID-00088][Error] If ISM_CAPCO_RESOURCE and releasableTo is specified on 
        the resource element then all classified portions must specify releasableTo.
        
        Human Readable: USA documents having any classified portion that is not 
        RELEASABLE (REL) cannot be REL at the resource level.
    </svrl:text>
            <svrl:text>
        If CAPCO rules apply to the document, we verify that all portions either have 
        the attribute classification specified with a value of [U] or classified portions 
        of the document have the attribute releasableTo. 
        
        Attribute releasableTo is only valid on an element if attribute 
        disseminationControls is specified with a value containing [REL] or [EYES], 
        as [REL] supersedes [EYES] in the banner.
                
        If any elements do not meet either of the two requirements stated above, 
        then the assertion fails since attribute releasableTo appears on 
        the banner but is not present on all classified portions.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M219"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00090</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00090</xsl:attribute>
            <svrl:text>
        [ISM-ID-00090][Error] If ISM_CAPCO_RESOURCE and any element: 
        1. Meets ISM_CONTRIBUTES
        AND
        2. Has the attribute disseminationControls containing [REL]
        Then the ISM_RESOURCE_ELEMENT must not have attribute disseminationControls containing [EYES]. 
        
        Human Readable: USA documents with any portion that is REL must not be EYES at the resource level.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If any element has attribute disseminationControls specified
        with a value containing [REL], then we make sure that the resourceElement 
        has attribute disseminationControls specified with a value other than [EYES].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M220"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00104</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00104</xsl:attribute>
            <svrl:text>
        [ISM-ID-00104][Error] If ISM_CAPCO_RESOURCE and any element in the document:
        1. Meets ISM_CONTRIBUTES
        AND
        2. Has the attribute nonICmarkings containing [SBU-NF]
        AND
        3. The ISM_RESOURCE_ELEMENT has attribute classification equal to [U]
        Then the ISM_RESOURCE_ELEMENT must have nonICmarkings containing [SBU-NF].
        
        Human Readable: Unclassified USA documents having SBU-NF must have SBU-NF at the resource level.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If any element has attribute nonICmarkings specified
        with a value containing [SBU-NF] and the resourceElement has the attribute
        classification specified with a value of [U], then we make sure that the resourceElement 
        has attribute nonICmarkings specified with a value other than [SBU-NF].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M221"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00105</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00105</xsl:attribute>
            <svrl:text>
        [ISM-ID-00105][Error] If ISM_CAPCO_RESOURCE and any element in the document: 
        1. Meets ISM_CONTRIBUTES
        AND
        2. Has the attribute nonICmarkings containing [SBU]
        AND
        3. The ISM_RESOURCE_ELEMENT has attribute classification equal to [U]
        Then the ISM_RESOURCE_ELEMENT must have nonICmarkings containing [SBU].
        
        Human Readable: Unclassified USA documents having SBU must have SBU at the resource level.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If any element has attribute nonICmarkings specified
        with a value containing [SBU] and the resourceElement has the attribute
        classification specified with a value of [U], then we make sure that the resourceElement 
        has attribute nonICmarkings specified with a value of [SBU].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M222"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00108</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00108</xsl:attribute>
            <svrl:text>
        [ISM-ID-00108][Error] If ISM_CAPCO_RESOURCE and attribute classification 
        of ISM_RESOURCE_ELEMENT has a value of [TS] and attribute compilationReason does not have a value then at least 
        one element meeting ISM_CONTRIBUTES in the document must have a classification attribute of [TS]. 
        
        Human Readable: USA TS documents not using compilation must have TS data.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. Then make sure we are looking at the resourceElement and 
        if the resourceElement has attribute classification specified 
        with a value of [TS] and the resourceElement has attribute compilationReason specified 
        with an empty value, then we make sure that at least one element in the document has 
        attribute classification specified with a value of [TS].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M223"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00109</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00109</xsl:attribute>
            <svrl:text>
        [ISM-ID-00109][Error] If ISM_CAPCO_RESOURCE and attribute classification of ISM_RESOURCE_ELEMENT 
        has a value of [S] and attribute compilationReason does not have a value then at least one element meeting ISM_CONTRIBUTES in the 
        document must have a classification attribute of [S].
        
        Human Readable: USA S documents not using compilation must have S data.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If the resourceElement has attribute classification specified 
        with a value of [S] and the resourceElement has attribute compilationReason specified 
        with an empty value, then we make sure that at least one element in the document has 
        attribute classification specified with a value of [S].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M224"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00110</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00110</xsl:attribute>
            <svrl:text>
        [ISM-ID-00110][Error] If ISM_CAPCO_RESOURCE and attribute classification of ISM_RESOURCE_ELEMENT 
        has a value of [C] and attribute compilationReason does not have a value then at least one element meeting ISM_CONTRIBUTES in the 
        document must have a classification attribute of [C]. 
        
        Human Readable: USA C documents not using compilation must have C data.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If the resourceElement has attribute classification specified 
        with a value of [C] and the resourceElement has attribute compilationReason specified 
        with an empty value, then we make sure that at least one element in the document has 
        attribute classification specified with a value of [C].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M225"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00111</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00111</xsl:attribute>
            <svrl:text>
        [ISM-ID-00111][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols of ISM_RESOURCE_ELEMENT contains 
        [SI] and attribute compilationReason does not have a value then at least one element meeting ISM_CONTRIBUTES in the document must have a 
        SCIcontrols attribute containing [SI].
        
        Human Readable: USA SI documents not using compilation must have SI data.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If the resourceElement has attribute SCIcontrols specified 
        with a value containing [SI] and the resourceElement has attribute compilationReason specified 
        with an empty value, then we make sure that at least one element in the document has 
        attribute SCIcontrols specified with a value containing [SI].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M226"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00112</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00112</xsl:attribute>
            <svrl:text>
        [ISM-ID-00112][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols of ISM_RESOURCE_ELEMENT contains 
        [SI-G] and attribute compilationReason does not have a value then at least one element meeting ISM_CONTRIBUTES in the document must have 
        a SCIcontrols attribute containing [SI-G].
        
        Human Readable: USA SI-G documents not using compilation must have SI-G data.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If the resourceElement has attribute SCIcontrols specified 
        with a value containing [SI-G] and the resourceElement has attribute compilationReason specified 
        with an empty value, then we make sure that at least one element in the document has 
        attribute SCIcontrols specified with a value containing [SI-G].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M227"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00113</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00113</xsl:attribute>
            <svrl:text>
        [ISM-ID-00113][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols of ISM_RESOURCE_ELEMENT contains 
        [TK] and attribute compilationReason does not have a value then at least one element meeting ISM_CONTRIBUTES in the document must have a 
        SCIcontrols attribute containing [TK].
        
        Human Readable: USA TK documents not using compilation must have TK data.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If the resourceElement has attribute SCIcontrols specified 
        with a value containing [TK] and the resourceElement has attribute compilationReason specified 
        with an empty value, then we make sure that at least one element in the document has 
        attribute SCIcontrols specified with a value containing [TK].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M228"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00116</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00116</xsl:attribute>
            <svrl:text>
        [ISM-ID-00116][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols of ISM_RESOURCE_ELEMENT contains 
        [HCS] and attribute compilationReason does not have a value then at least one element meeting ISM_CONTRIBUTES in the document must have a 
        SCIcontrols attribute containing [HCS].
        
        Human Readable: USA HCS documents not using compilation must have HCS data.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If the resourceElement has attribute SCIcontrols specified 
        with a value containing [HCS] and the resourceElement has attribute compilationReason specified 
        with an empty value, then we make sure that at least one element in the document has 
        attribute SCIcontrols specified with a value containing [HCS].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M229"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00118</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00118</xsl:attribute>
            <svrl:text>
        [ISM-ID-00118][Error] The first element in document order having 
        resourceElement true must have createDate specified.
    </svrl:text>
            <svrl:text>
        We make sure that the resourceElement has attribute createDate specified.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M230"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00132</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00132</xsl:attribute>
            <svrl:text>
        [ISM-ID-00132][Error] If ISM_CAPCO_RESOURCE and the ISM_RESOURCE_ELEMENT has the 
        attribute disseminationControls containing [RELIDO] then every element meeting 
        ISM_CONTRIBUTES_CLASSIFIED in the document must have the attribute 
        disseminationControls containing [RELIDO].
        
        Human Readable: USA documents having RELIDO at the resource level must have every classified portion having RELIDO.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If the resourceElement has attribute disseminationControls specified 
        with a value containing [RELIDO], then we make sure that the number of elements in the document
        that have attribute classification specified with a value other than [U] and attribute 
        disseminationControls specified with a value containing [RELIDO] is the same as the number 
        of elements in the document that have attribute classification specified with a value other than [U].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M231"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00141</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00141</xsl:attribute>
            <svrl:text>
        [ISM-ID-00141][Error] If ISM_NSI_EO_APPLIES and 
        1. ISM_RESOURCE_ELEMENT attribute declassException does not have a value of [25X1-human], [50X1-HUM], or [50X2-WMD]
        AND
        2. ISM_RESOURCE_ELEMENT attribute declassDate is not specified
        AND
        3. ISM_RESOURCE_ELEMENT attribute declassEvent is not specified
        AND
        4. ISM_RESOURCE_ELEMENT attribute atomicEnergyMarkings is not specified
           with a value of [RD] or [FRD]
            
        Human Readable: Documents under E.O. 13526 require declassDate or declassEvent unless 
        25X1-human, 50X1-HUM, 50X2-WMD, RD, or FRD is specified.
    </svrl:text>
            <svrl:text>
        If the current Classified National Security Information Executive Order
        does not apply to the document then the rule does not apply
        and we return true. If the resourceElement has attribute declassException specified 
        with a value of [25X1-human], [50X1-HUM], or [50X2-WMD], then the rule does not apply and we return true. If 
        the resourceElement has attribute atomicEnergyMarkings specified with a value containing
        [RD] or [FRD] then the rule does not apply and we return true. Otherwise, we make sure
        that the resourceElement has attribute declassDate specified or attribute declassEvent 
        specified.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M232"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00145</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00145</xsl:attribute>
            <svrl:text>
        [ISM-ID-00145][Error] If ISM_CAPCO_RESOURCE and any element in the document: 
        1. Meets ISM_CONTRIBUTES
        AND
        2. Has the attribute nonICmarkings containing [LES]
        AND
        3. No element meeting ISM_CONTRIBUTES in the document has nonICmarkings containing any of [LES-NF]
        Then the ISM_RESOURCE_ELEMENT must have nonICmarkings containing [LES].
        
        Human Readable: USA documents having LES and not having LES-NF must have LES at the resource level.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If any element has attribute nonICmarkings specified 
        with a value containing [LES] and no element has attribute nonICmarkings specified 
        with a value containing [LES-NF], then we make sure that the resourceElement has attribute 
        nonICmarkings specified with a value containing [LES].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M233"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00146</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00146</xsl:attribute>
            <svrl:text>
        [ISM-ID-00146][Error] If ISM_CAPCO_RESOURCE and there exist at least 2 elements in the document:
        1. Each element: Meets ISM_CONTRIBUTES
        AND
        2. One of the elements: Has the attribute nonICmarkings containing [LES-NF]
        AND
        3. One of the elements: meets ISM_CONTRIBUTES_CLASSIFIED
        Then the ISM_RESOURCE_ELEMENT must have disseminationControls containing [NF].
        
        Human Readable: Classified USA documents having LES-NF Data must have NF at the resource level.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If any element has attribute nonICmarkings specified 
        with a value containing [LES-NF] and the resourceElement has attribute classification specified 
        with a value other than [U], then we make sure that the resourceElement has attribute 
        disseminationControls specified with a value containing [NF].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M234"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00147</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00147</xsl:attribute>
            <svrl:text>
        [ISM-ID-00147][Error] If ISM_CAPCO_RESOURCE and there exist at least 2 elements in the document:
        1. Each element: Meets ISM_CONTRIBUTES
        AND
        2. One of the elements: Has the attribute nonICmarkings containing [LES-NF]
        AND
        3. One of the elements: meets ISM_CONTRIBUTES_CLASSIFIED
        Then the ISM_RESOURCE_ELEMENT must have nonICmarkings containing [LES].
        
        Human Readable: Classified USA documents having LES-NF Data must have LES at the resource level.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If any element has attribute nonICmarkings specified 
        with a value containing [LES-NF] and the resourceElement has attribute classification specified 
        with a value other than [U], then we make sure that the resourceElement has attribute nonICmarkings
        specified with a value containing [LES].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M235"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00149</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00149</xsl:attribute>
            <svrl:text>
        [ISM-ID-00149][Error] If ISM_CAPCO_RESOURCE and 
        1. Any element in the document meets ISM_CONTRIBUTES in the document has 
           the attribute nonICmarkings contain [LES-NF]
        AND
        2. ISM_RESOURCE_ELEMENT has the attribute classification [U]
        THEN the ISM_RESOURCE_ELEMENT must have nonICmarkings containing [LES-NF]
        
        Human Readable: Unclassified USA documents having LES-NF must have LES-NF at the resource level.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If any element has attribute nonICmarkings specified 
        with a value containing [LES-NF] and the resourceElement has attribute classification specified 
        with a value of [U], then we make sure that the resourceElement has attribute nonICmarkings
        specified with a value containing [LES-NF].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M236"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00154</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00154</xsl:attribute>
            <svrl:text>
        [ISM-ID-00154][Error] If ISM_CAPCO_RESOURCE and 
        1. Attribute disseminationControls of ISM_RESOURCE_ELEMENT contains [FOUO]
        AND
        2. Attribute compilationReason does not have a value then at least one element meeting ISM_CONTRIBUTES
           in the document must have a disseminationControls attribute contain [FOUO].
        
        Human Readable: USA FOUO documents not using compilation must have FOUO data.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If the resourceElement has attribute disseminationControls specified 
        with a value containing [FOUO] and the resourceElement has attribute compilationReason specified 
        with an empty value, then we make sure that at least one element in the document has 
        attribute disseminationControls specified with a value containing [FOUO].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M237"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00155</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00155</xsl:attribute>
            <svrl:text>
        [ISM-ID-00155][Error] If ISM_CAPCO_RESOURCE and 
        1. ISM_DoD5230_24_Applies
        AND
        2. Attribute notice of ISM_RESOURCE_ELEMENT does not contain one of 
        [DoD-Dist-A], [DoD-Dist-B], [DoD-Dist-C], [DoD-Dist-D], [DoD-Dist-E], [DoD-Dist-F], or [DoD-Dist-X]
        
        Human Readable: All USA documents that claim compliance with DoD5230.24 must have a distribution statement
        for the entire document.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If ISM_DoD5230_24_Applies does not apply to the document
        then the rule does not apply and we return true. Otherwise, we make sure that
        the resourceElement has attribute notice specified with a value containing
        [DoD-Dist-A], [DoD-Dist-B], [DoD-Dist-C], [DoD-Dist-D], [DoD-Dist-E], [DoD-Dist-F],
        or [DoD-Dist-X].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M238"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00162</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00162</xsl:attribute>
            <svrl:text>
        [ISM-ID-00162][Error] If ISM_CAPCO_RESOURCE and 
        1. ISM_DoD5230_24_Applies
        AND
        2. Attribute notice of ISM_RESOURCE_ELEMENT contains more than one of 
        [DoD-Dist-A], [DoD-Dist-B], [DoD-Dist-C], [DoD-Dist-D], [DoD-Dist-E], [DoD-Dist-F], or [DoD-Dist-X]
        
        Human Readable: All USA documents that claim compliance with DoD5230.24 must have only 1 distribution statement
        for the entire document.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If ISM_DoD5230_24_Applies does not apply to the document
        then the rule does not apply and we return true. Otherwise, we make sure that
        the resourceElement has attribute notice specified with a value containing
        only one of [DoD-Dist-A], [DoD-Dist-B], [DoD-Dist-C], [DoD-Dist-D], 
        [DoD-Dist-E], [DoD-Dist-F], or [DoD-Dist-X].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M239"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00165</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00165</xsl:attribute>
            <svrl:text>
        [ISM-ID-00165][Error] If ISM_CAPCO_RESOURCE and any element meeting ISM_CONTRIBUTES in the
        document have the attribute disseminationControls containing [RS] then the 
        ISM_RESOURCE_ELEMENT must have disseminationControls containing [RS].
        
        Human Readable: USA documents having RISK SENSITIVE (RS) data must have RS at the resource level.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If any element has attribute disseminationControls
        specified with a value containing [RS], then we make sure that the
        resourceElement has attribute disseminationControls specified with a value
        containing [RS].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M240"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00171</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00171</xsl:attribute>
            <svrl:text>
        [ISM-ID-00171][Warning] If ISM_CAPCO_RESOURCE and displayOnlyTo is specified on 
        the resource element then all classified portions must specify displayOnlyTo.
        
        Human Readable: USA documents having DISPLAYONLY data at the resource level
        must have all classified portions authorized for DISPLAYONLY.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. Otherwise, we loop over all portions of the document and count 
        the number of elements which have attribute classification specified with a value 
        other than [U] and do not have attribute displayOnlyTo.
        
        The loop checks, if the current element has attribute classification specified with 
        a value other than [U], or has attribute displayOnlyTo, then the rule does not 
        apply to this element and we return 0. Otherwise, we return 1 to indicate the element 
        is classified but does not specify attribute displayOnlyTo.
        
        If the count of elements not meeting either of the two requirements stated above is 
        greater than zero, then the assertion fails since attribute displayOnly appears on 
        the banner but is not present on all classified portions.

    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M241"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00227</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00227</xsl:attribute>
            <svrl:text>
        [ISM-ID-00227][Error] Attribute @noticeType may only appear on the 
        resource node when it contains the values [DoD-Dist-A], [DoD-Dist-B], 
        [DoD-Dist-C], [DoD-Dist-D], [DoD-Dist-E], [DoD-Dist-F], or [DoD-Dist-X].
        
        Human Readable: Documents may only specify a document-level notice if
        it pertains to DoD Distribution.
    </svrl:text>
            <svrl:text>
        For every resource element with the @ism:noticeType attribute specified,
        this rule ensures that the attribute's value starts with the string 
        'DoD-Dist-'. Otherwise, the rule returns false.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M242"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00121</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00121</xsl:attribute>
            <svrl:text>
        [ISM-ID-00121][Error] If ISM_CAPCO_RESOURCE and attribute SARIdentifier 
        is specified, then each of its values must be ordered in accordance 
        with CVEnumISMSAR.xml.
    </svrl:text>
            <svrl:text>To perform sorting, this rule first retrieves the CVE values for the attribute 
        to be sorted, which in this case is SARIdentifier. Then, each attribute token
        is converted into a numerical value based on its characters. Next, each attribute token is 
        given an order number, which compares its position to that of its value in the CVE file.
        Next, each order number is compared to that of its previous sibling to determine if the tokens
        are in order. If a token is found whose order number is less than that of its previous sibling, 
        0 is returned for its sorted order number. If a token's order number is greater than that of its 
        previous sibling, 1 is returned. If two tokens have the same order number, their original attribute
        values are compared. If the original attribute value contains numbers then the comparison is made 
        on its converted numerical value; otherwise, the comparison is made on its string value. If an 
        attribute value is found whose value is less than that of its previous sibling,  0 is returned
        for its sorted order number; otherwise 2 is returned. Finally, if any tokens are found with 0 as 
        its sorted order number, then the rule fails as those tokens are out of order.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M243"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00042</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00042</xsl:attribute>
            <svrl:text>[ISM-ID-00042][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols is specified, each of its values must be 
        ordered in accordance with CVEnumISMSCIControls.xml.
    </svrl:text>
            <svrl:text>To perform sorting, this rule first retrieves the CVE values for the attribute 
        to be sorted, which in this case is SCIcontrols. Then, each attribute token
        is converted into a numerical value based on its characters. Next, each attribute token is 
        given an order number, which compares its position to that of its value in the CVE file.
        Next, each order number is compared to that of its previous sibling to determine if the tokens
        are in order. If a token is found whose order number is less than that of its previous sibling, 
        0 is returned for its sorted order number. If a token's order number is greater than that of its 
        previous sibling, 1 is returned. If two tokens have the same order number, their original attribute
        values are compared. If the original attribute value contains numbers then the comparison is made 
        on its converted numerical value; otherwise, the comparison is made on its string value. If an 
        attribute value is found whose value is less than that of its previous sibling,  0 is returned
        for its sorted order number; otherwise 2 is returned. Finally, if any tokens are found with 0 as 
        its sorted order number, then the rule fails as those tokens are out of order.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M244"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00043</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00043</xsl:attribute>
            <svrl:text>
        [ISM-ID-00043][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [SI], then attribute 
        classification must have a value of [TS], [S], or [C].
        
        Human Readable: A USA document containing Special Intelligence (SI) data must be 
        classified CONFIDENTIAL, SECRET, or TOP SECRET.  
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If the current element has attribute SCIcontrols specified
        with a value containing [SI], then we make sure that attribute classification
        has a value of [TS], [S], or [C].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M245"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00044</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00044</xsl:attribute>
            <svrl:text>
        [ISM-ID-00044][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [SI-G], then attribute 
        classification must have a value of [TS].
        
        Human Readable: A USA document containing Special Intelligence (SI) GAMMA compartment data 
        must be classified TOP SECRET.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If the current element has attribute SCIcontrols specified
        with a value containing [SI-G], then we make sure that attribute classification
        has a value of [TS].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M246"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00045</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00045</xsl:attribute>
            <svrl:text>
        [ISM-ID-00045][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [SI-G], then attribute 
        disseminationControls must contain the name token [OC].
        
        Human Readable: A USA document containing Special Intelligence (SI) GAMMA compartment data must 
        be marked for ORIGINATOR CONTROLLED dissemination.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If the current element has attribute SCIcontrols specified
        with a value containing [SI-G], then we make sure that attribute disseminationControls
        contains the value [OC].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M247"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00046</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00046</xsl:attribute>
            <svrl:text>
        [ISM-ID-00046][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains 
        a name token starting with [SI-ECI], then attribute classification must have a 
        value of [TS].
        
        Human Readable: A USA document containing Special Intelligence (SI) ECI compartment
        data must be classified TOP SECRET.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If the current element has attribute classification specified
        with a value of [TS] then the rule does not apply and we return true. 
        Otherwise, we make sure that attribute SCIcontrols does not contain the value [SI-ECI].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M248"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00047</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00047</xsl:attribute>
            <svrl:text>
        [ISM-ID-00047][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains 
        the name token [TK], then attribute classification must have a value of [TS] or [S].
        
        Human Readable: A USA document containing TALENT KEYHOLE data must be classified
        SECRET or TOP SECRET.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If the current element has attribute SCIcontrols specified
        with a value containing [TK], then we make sure that attribute classification
        has a value of [TS] or [S].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M249"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00048</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00048</xsl:attribute>
            <svrl:text>
        [ISM-ID-00048][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [HCS], then attribute 
        classification must have a value of [TS], [S], or [C].
        
        Human Readable: A USA document containing HCS data must be classified CONFIDENTIAL, SECRET, or TOP SECRET.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If the current element has attribute SCIcontrols specified
        with a value containing [HCS], then we make sure that attribute classification
        has a value of [TS], [S], or [C].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M250"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00049</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00049</xsl:attribute>
            <svrl:text>
        [ISM-ID-00049][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [HCS], then attribute 
        disseminationControls must contain the name token [NF].
        
        Human Readable: A USA document containing HCS data must be marked for NO FOREIGN dissemination.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If the current element has attribute SCIcontrols specified
        with a value containing [HCS], then we make sure that attribute disseminationControls
        contains the value [NF].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M251"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00122</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00122</xsl:attribute>
            <svrl:text>
        [ISM-ID-00122][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [KDK], then attribute 
        classification must have a value of [TS] or [S].
        
        Human Readable: A USA document with KLONDIKE data must be classified SECRET or TOP SECRET.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If the current element has attribute SCIcontrols specified
        with a value containing [KDK], then we make sure that attribute classification
        has a value [TS] or [S].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M252"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00123</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00123</xsl:attribute>
            <svrl:text>
        [ISM-ID-00123][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [KDK], then attribute 
        disseminationControls must contain the name token [NF].
        
        Human Readable: A USA document containing KLONDIKE data must also be marked for NO FOREIGN dissemination.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If the current element has attribute SCIcontrols specified
        with a value containing [KDK], then we make sure that attribute disseminationControls contains
        the value [NF].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M253"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00177</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00177</xsl:attribute>
            <svrl:text>
        [ISM-ID-00177][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [SI-ECI],
        then it must also contain the name token [SI].
        
        Human Readable: A USA document containing Special Intelligence (SI) ECI compartment data must also
        specify that it contains SI data.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If the current element has attribute SCIcontrols specified
        with a value containing [SI-ECI], then we make sure that attribute SCIcontrols also contains
        the value [SI].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M254"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00186</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00186</xsl:attribute>
            <svrl:text>
        [ISM-ID-00186][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [SI-G-XXXX],
        then it must also contain the name token [SI-G].
        
        Human Readable: A USA document that contains Special Intelligence (SI) GAMMA sub-compartments must
        also specify that it contains SI-GAMMA compartment data.
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If the current element has attribute SCIcontrols specified
        with a value containing [SI-G-XXXX], where X is represented by the regular expression character
        class [A-Z], then we make sure that attribute SCIcontrols also contains the value [SI-G].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M255"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00187</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00187</xsl:attribute>
            <svrl:text>
        [ISM-ID-00187][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [SI-G],
        then it must also contain the name token [SI].
        
        Human Readable: A USA document that contains Special Intelligence (SI) -GAMMA compartment data must also specify that 
        it contains SI data. 
    </svrl:text>
            <svrl:text>
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If the current element has attribute SCIcontrols specified
        with a value containing [SI-G], then we make sure that attribute SCIcontrols also contains the value [SI].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M256"/>
      </svrl:schematron-output>
   </xsl:template>

   <!--SCHEMATRON PATTERNS-->
<xsl:param name="countriesList"
              select="document('../../CVE/ISM/CVEnumISMOwnerProducer.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="classificationAllList"
              select="document('../../CVE/ISM/CVEnumISMClassificationAll.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="classificationUSList"
              select="document('../../CVE/ISM/CVEnumISMClassificationUS.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="ownerProducerList"
              select="document('../../CVE/ISM/CVEnumISMOwnerProducer.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="declassExceptionList"
              select="document('../../CVE/ISM/CVEnumISM25X.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="FGIsourceOpenList"
              select="document('../../CVE/ISM/CVEnumISMFGIOpen.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="FGIsourceProtectedList"
              select="document('../../CVE/ISM/CVEnumISMFGIProtected.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="nonICmarkingsList"
              select="document('../../CVE/ISM/CVEnumISMNonIC.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="releasableToList"
              select="document('../../CVE/ISM/CVEnumISMRelTo.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="SCIcontrolsList"
              select="document('../../CVE/ISM/CVEnumISMSCIControls.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="SARIdentifierList"
              select="document('../../CVE/ISM/CVEnumISMSAR.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="validAttributeList"
              select="document('../../CVE/ISM/CVEnumISMAttributes.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="validElementList"
              select="document('../../CVE/ISM/CVEnumISMElements.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="noticeList"
              select="document('../../CVE/ISM/CVEnumISMNotice.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="nonUSControlsList"
              select="document('../../CVE/ISM/CVEnumISMNonUSControls.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="compliesWithList"
              select="document('../../CVE/ISM/CVEnumISMCompliesWith.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="atomicEnergyMarkingsList"
              select="document('../../CVE/ISM/CVEnumISMAtomicEnergyMarkings.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="displayOnlyToList"
              select="document('../../CVE/ISM/CVEnumISMRelTo.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="disseminationControlsList"
              select="document('../../CVE/ISM/CVEnumISMDissem.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="ISM_RESOURCE_ELEMENT"
              select="(for $each in (//*) return if($each/@ism:resourceElement=true()) then $each else null)[1]"/>
   <xsl:param name="ISM_RESOURCE_CREATE_DATE" select="$ISM_RESOURCE_ELEMENT/@ism:createDate"/>
   <xsl:param name="ISM_CAPCO_RESOURCE"
              select="index-of(tokenize(normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:ownerProducer)), ' '),'USA') &gt; 0"/>
   <xsl:param name="ISM_ICDOCUMENT_APPLIES"
              select="index-of(tokenize(normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:compliesWith)), ' '),'ICDocument') &gt; 0"/>
   <xsl:param name="ISM_DOD5230_24_APPLIES"
              select="index-of(tokenize(normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:compliesWith)), ' '),'DoD5230.24') &gt; 0"/>
   <xsl:param name="ISM_ORCON_POC_DATE" select="xs:date('2011-03-11')"/>
   <xsl:param name="bannerClassification"
              select="normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:classification))"/>
   <xsl:param name="bannerDisseminationControls"
              select="normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:disseminationControls))"/>
   <xsl:param name="bannerDisplayOnlyTo"
              select="normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:displayOnlyTo))"/>
   <xsl:param name="bannerNonICmarkings"
              select="normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:nonICmarkings))"/>
   <xsl:param name="bannerFGIsourceOpen"
              select="normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:FGIsourceOpen))"/>
   <xsl:param name="bannerFGIsourceProtected"
              select="normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:FGIsourceProtected))"/>
   <xsl:param name="bannerReleasableTo"
              select="normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:releasableTo))"/>
   <xsl:param name="bannerSCIcontrols"
              select="normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:SCIcontrols))"/>
   <xsl:param name="bannerNotice"
              select="normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:noticeType))"/>
   <xsl:param name="bannerAtomicEnergyMarkings"
              select="normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:atomicEnergyMarkings))"/>
   <xsl:param name="bannerDisseminationControls_tok"
              select="tokenize(normalize-space(string($bannerDisseminationControls)), ' ')"/>
   <xsl:param name="bannerDisplayOnlyTo_tok"
              select="tokenize(normalize-space(string($bannerDisplayOnlyTo)), ' ')"/>
   <xsl:param name="bannerNonICmarkings_tok"
              select="tokenize(normalize-space(string($bannerNonICmarkings)), ' ')"/>
   <xsl:param name="bannerFGIsourceOpen_tok"
              select="tokenize(normalize-space(string($bannerFGIsourceOpen)), ' ')"/>
   <xsl:param name="bannerFGIsourceProtected_tok"
              select="tokenize(normalize-space(string($bannerFGIsourceProtected)), ' ')"/>
   <xsl:param name="bannerReleasableTo_tok"
              select="tokenize(normalize-space(string($bannerReleasableTo)), ' ')"/>
   <xsl:param name="bannerSCIcontrols_tok"
              select="tokenize(normalize-space(string($bannerSCIcontrols)), ' ')"/>
   <xsl:param name="bannerNotice_tok"
              select="tokenize(normalize-space(string($bannerNotice)), ' ')"/>
   <xsl:param name="bannerAtomicEnergyMarkings_tok"
              select="tokenize(normalize-space(string($bannerAtomicEnergyMarkings)), ' ')"/>
   <xsl:param name="partTags"
              select="//*[@ism:* and not(@ism:excludeFromRollup=true()) and not(generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT))]"/>
   <xsl:param name="partClassification"
              select="for $token in $partTags/@ism:classification return tokenize(normalize-space(string($token)),' ')"/>
   <xsl:param name="partDisseminationControls"
              select="for $token in $partTags/@ism:disseminationControls return tokenize(normalize-space(string($token)),' ')"/>
   <xsl:param name="partDisplayOnlyTo"
              select="for $token in $partTags/@ism:displayOnlyTo return tokenize(normalize-space(string($token)),' ')"/>
   <xsl:param name="partAtomicEnergyMarkings"
              select="for $token in $partTags/@ism:atomicEnergyMarkings return tokenize(normalize-space(string($token)),' ')"/>
   <xsl:param name="partNonICmarkings"
              select="for $token in $partTags/@ism:nonICmarkings return tokenize(normalize-space(string($token)),' ')"/>
   <xsl:param name="partFGIsourceOpen"
              select="for $token in $partTags/@ism:FGIsourceOpen return tokenize(normalize-space(string($token)),' ')"/>
   <xsl:param name="partFGIsourceProtected"
              select="for $token in $partTags/@ism:FGIsourceProtected return tokenize(normalize-space(string($token)),' ')"/>
   <xsl:param name="partSCIcontrols"
              select="for $token in $partTags/@ism:SCIcontrols return tokenize(normalize-space(string($token)),' ')"/>
   <xsl:param name="partNotice"
              select="for $token in $partTags/@ism:noticeType return tokenize(normalize-space(string($token)),' ')"/>
   <xsl:param name="partPocType"
              select="for $token in $partTags/@ism:pocType return tokenize(normalize-space(string($token)),' ')"/>
   <xsl:param name="partClassification_tok"
              select="for $token in $partClassification return tokenize(normalize-space(string($token)), ' ')"/>
   <xsl:param name="partDisseminationControls_tok"
              select="for $token in $partDisseminationControls return tokenize(normalize-space(string($token)), ' ')"/>
   <xsl:param name="partDisplayOnlyTo_tok"
              select="for $token in $partDisplayOnlyTo return tokenize(normalize-space(string($token)), ' ')"/>
   <xsl:param name="partAtomicEnergyMarkings_tok"
              select="for $token in $partAtomicEnergyMarkings return tokenize(normalize-space(string($token)), ' ')"/>
   <xsl:param name="partNonICmarkings_tok"
              select="for $token in $partNonICmarkings return tokenize(normalize-space(string($token)), ' ')"/>
   <xsl:param name="partSCIcontrols_tok"
              select="for $token in $partSCIcontrols return tokenize(normalize-space(string($token)), ' ')"/>
   <xsl:param name="partNotice_tok"
              select="for $token in $partNotice return tokenize(normalize-space(string($token)), ' ')"/>
   <xsl:param name="partPocType_tok"
              select="for $token in $partPocType return tokenize(normalize-space(string($token)), ' ')"/>
   <xsl:param name="ISM_NSI_EO_APPLIES"
              select="if(not($ISM_CAPCO_RESOURCE) or ($ISM_RESOURCE_ELEMENT/@ism:classification='U') or index-of($partAtomicEnergyMarkings_tok,'FRD')&gt;0 or index-of($partAtomicEnergyMarkings_tok,'RD')&gt;0 or ($ISM_RESOURCE_CREATE_DATE and $ISM_RESOURCE_CREATE_DATE &lt; xs:date('1996-04-14'))) then false() else true()"/>
   <xsl:param name="TEYE_tok" select="tokenize(string('USA CAN GBR'), ' ')"/>
   <xsl:param name="ACGU_tok" select="tokenize(string('USA AUS CAN GBR'), ' ')"/>
   <xsl:param name="FVEY_tok" select="tokenize(string('USA AUS CAN GBR NZL'), ' ')"/>
   <xsl:param name="dcTags"
              select="for $piece in $disseminationControlsList return $piece/text()"/>
   <xsl:param name="dcTagsFound"
              select="for $token in $dcTags return if ( index-of($partDisseminationControls_tok,$token) &gt; 0 and (not(index-of($bannerDisseminationControls_tok,$token) &gt; 0))) then $token else null"/>
   <xsl:param name="aeaTags"
              select="for $piece in $atomicEnergyMarkingsList return $piece/text()"/>
   <xsl:param name="aeaTagsFound"
              select="for $token in $aeaTags return if ( index-of($partAtomicEnergyMarkings_tok,$token) &gt; 0 and (not(index-of($bannerAtomicEnergyMarkings_tok,$token) &gt; 0))) then $token else null"/>

   <!--PATTERN ISM-ID-00173-->


	<!--RULE -->
<xsl:template match="*[@ism:atomicEnergyMarkings]" priority="1000" mode="M76">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:atomicEnergyMarkings]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else                               count(                 for $token in tokenize(string(./@ism:atomicEnergyMarkings), ' ') return                          if(matches($token,'^F?RD-SG')                      and not( matches(./@ism:classification,'^(TS|S|C)$')))                          then $token                                         else null             )=0             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else count( for $token in tokenize(string(./@ism:atomicEnergyMarkings), ' ') return if(matches($token,'^F?RD-SG') and not( matches(./@ism:classification,'^(TS|S|C)$'))) then $token else null )=0">
               <xsl:attribute name="id">ISM-00173</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00173][Error] If ISM_CAPCO_RESOURCE and attribute 
            atomicEnergyMarkings contains a name token starting with [RD-SG] or [FRD-SG], then attribute 
            classification must have a value of [TS], [S], or [C].
            
            Human Readable: Portions in a USA document that contain RD or FRD SIGMA 
            data should be CONFIDENTIAL, SECRET, or TOP SECRET.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M76"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M76"/>
   <xsl:template match="@*|node()" priority="-2" mode="M76">
      <xsl:apply-templates select="*" mode="M76"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00174-->


	<!--RULE -->
<xsl:template match="*[@ism:atomicEnergyMarkings]" priority="1000" mode="M77">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:atomicEnergyMarkings]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else                               count(                 for $token in tokenize(string(./@ism:atomicEnergyMarkings), ' ') return                          if(matches($token,'^(F?RD)$')                         and not( matches(./@ism:classification,'^(TS|S|C)$')))                          then $token                                         else null             )=0             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else count( for $token in tokenize(string(./@ism:atomicEnergyMarkings), ' ') return if(matches($token,'^(F?RD)$') and not( matches(./@ism:classification,'^(TS|S|C)$'))) then $token else null )=0">
               <xsl:attribute name="id">ISM-00174</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00174][Error] If ISM_CAPCO_RESOURCE and attribute 
            atomicEnergyMarkings contains the name token [RD] or [FRD], 
            then attribute classification must have a value of [TS], [S], or [C].
            
            Human Readable: USA documents with RD or FRD data must be marked CLASSIFIED,
            SECRET, or TOP SECRET.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M77"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M77"/>
   <xsl:template match="@*|node()" priority="-2" mode="M77">
      <xsl:apply-templates select="*" mode="M77"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00175-->


	<!--RULE -->
<xsl:template match="*[@ism:atomicEnergyMarkings]" priority="1000" mode="M78">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:atomicEnergyMarkings]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else             if(not(index-of(tokenize(string(./@ism:atomicEnergyMarkings),' '),'RD-CNWDI')&gt;0))                 then true()                  else matches(./@ism:classification,'^(TS|S)$')             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if(not(index-of(tokenize(string(./@ism:atomicEnergyMarkings),' '),'RD-CNWDI')&gt;0)) then true() else matches(./@ism:classification,'^(TS|S)$')">
               <xsl:attribute name="id">ISM-00175</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00175][Error] If ISM_CAPCO_RESOURCE and attribute 
            atomicEnergyMarkings contains the name token [RD-CNWDI], then attribute 
            classification must have a value of [TS] or [S].
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M78"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M78"/>
   <xsl:template match="@*|node()" priority="-2" mode="M78">
      <xsl:apply-templates select="*" mode="M78"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00176-->


	<!--RULE -->
<xsl:template match="*[@ism:atomicEnergyMarkings]" priority="1000" mode="M79">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:atomicEnergyMarkings]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else             count(                 for $each in tokenize(string(./@ism:atomicEnergyMarkings),' ') return                     if(matches($each, '^(F?RD)$'))                         then if($ISM_RESOURCE_ELEMENT/@ism:declassDate                                 or $ISM_RESOURCE_ELEMENT/@ism:declassEvent)                                  then 1                                   else null                         else null             )=0             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else count( for $each in tokenize(string(./@ism:atomicEnergyMarkings),' ') return if(matches($each, '^(F?RD)$')) then if($ISM_RESOURCE_ELEMENT/@ism:declassDate or $ISM_RESOURCE_ELEMENT/@ism:declassEvent) then 1 else null else null )=0">
               <xsl:attribute name="id">ISM-00176</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00176][Error] Automatic declassification of documents containing RD or FRD information is prohibited.
            Attributes declassDate and declassEvent cannot be used in the classification authority block when RD or FRD is present.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M79"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M79"/>
   <xsl:template match="@*|node()" priority="-2" mode="M79">
      <xsl:apply-templates select="*" mode="M79"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00178-->


	<!--RULE -->
<xsl:template match="*[@ism:atomicEnergyMarkings]" priority="1000" mode="M80">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:atomicEnergyMarkings]"/>
      <xsl:variable name="capcoRestriction" select="true()"/>
      <xsl:variable name="errMsg_AlphabeticalOrder"
                    select="             '[ISM-ID-00178][Error] If ISM_CAPCO_RESOURCE and attribute              atomicEnergyMarkings is specified, then each of its values must be ordered in accordance with              CVEnumISMAtomicEnergyMarkings.xml.'"/>
      <xsl:variable name="dataFileElems" select="$atomicEnergyMarkingsList"/>
      <xsl:variable name="attrValues" select="./@ism:atomicEnergyMarkings"/>
      <xsl:variable name="attrValueTokens" select="tokenize(string($attrValues),' ')"/>
      <xsl:variable name="convertStrToNum"
                    select="             for $token in $attrValueTokens return                 number(string-join(                     for $index in 1 to string-length($token) return                         for $char in substring($token, $index, 1) return                             if (contains(string('0123456789'), $char)) then                                 $char                             else if (contains(string('ABCDEFGHI'), $char)) then                                 translate(string($char), 'ABCDEFGHI', '123456789')                             else if (contains(string('JKLMNOPQRS'), $char)) then                                 concat('1', translate(string($char), 'JKLMNOPQRS', '0123456789'))                             else if (contains(string('TUVWXYZ'), $char)) then                                 concat('2', translate(string($char), 'TUVWXYZ', '0123456'))                             else '0'                 , ''))             "/>
      <xsl:variable name="orderNums"
                    select="             for $token in $attrValueTokens return                  if ($dataFileElems[matches($token,concat('^',text(),'$'))]) then                      count(($dataFileElems[matches($token,concat('^',text(),'$'))])/preceding::*) + 1                 else -1"/>
      <xsl:variable name="sortedOrderNums"
                    select="             for $index in distinct-values(for $token in $orderNums return index-of($orderNums,$token)) return                  if($index = 1 or $orderNums[$index] &gt; $orderNums[$index - 1]) then 1                 else if ($orderNums[$index] &lt; $orderNums[$index - 1]) then 0                 else                     if (matches($attrValueTokens[$index], '[0-9]') or matches($attrValueTokens[$index - 1], '[0-9]')) then                         if ($convertStrToNum[$index - 1] &gt; $convertStrToNum[$index]) then 0                         else 2                     else                           if (compare($attrValueTokens[$index - 1],$attrValueTokens[$index])=1) then 0                         else 2             "/>
      <xsl:variable name="hasUnsorted" select="count(index-of($sortedOrderNums,0)) &gt; 0"/>
      <xsl:variable name="unsortedValues"
                    select="             if ($hasUnsorted) then                 distinct-values(                     for $token in index-of($sortedOrderNums,0) return                         $attrValueTokens[$token]                  )             else null             "/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not($hasUnsorted)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($hasUnsorted)">
               <xsl:attribute name="id">ISM-00178</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="$errMsg_AlphabeticalOrder"/>
                  <xsl:text/>
            The following values are out of order [<xsl:text/>
                  <xsl:value-of select="$unsortedValues"/>
                  <xsl:text/>] for [<xsl:text/>
                  <xsl:value-of select="$attrValueTokens"/>
                  <xsl:text/>] </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M80"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M80"/>
   <xsl:template match="@*|node()" priority="-2" mode="M80">
      <xsl:apply-templates select="*" mode="M80"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00181-->


	<!--RULE -->
<xsl:template match="*[@ism:atomicEnergyMarkings]" priority="1000" mode="M81">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:atomicEnergyMarkings]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else                if(./@ism:classification='U') then true() else                 not(index-of(tokenize(string(./@ism:atomicEnergyMarkings), ' '),'UCNI')&gt;0)             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if(./@ism:classification='U') then true() else not(index-of(tokenize(string(./@ism:atomicEnergyMarkings), ' '),'UCNI')&gt;0)">
               <xsl:attribute name="id">ISM-00181</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00181][Error] UCNI may only be used on UNCLASSIFIED portions.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M81"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M81"/>
   <xsl:template match="@*|node()" priority="-2" mode="M81">
      <xsl:apply-templates select="*" mode="M81"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00182-->


	<!--RULE -->
<xsl:template match="*[@ism:atomicEnergyMarkings]" priority="1000" mode="M82">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:atomicEnergyMarkings]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else                if(./@ism:classification='U') then true() else                 not(index-of(tokenize(string(./@ism:atomicEnergyMarkings), ' '),'DCNI')&gt;0)             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if(./@ism:classification='U') then true() else not(index-of(tokenize(string(./@ism:atomicEnergyMarkings), ' '),'DCNI')&gt;0)">
               <xsl:attribute name="id">ISM-00182</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00182][Error] DCNI may only be used on Unclassified portions.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M82"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M82"/>
   <xsl:template match="@*|node()" priority="-2" mode="M82">
      <xsl:apply-templates select="*" mode="M82"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00183-->


	<!--RULE -->
<xsl:template match="*[@ism:atomicEnergyMarkings]" priority="1000" mode="M83">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:atomicEnergyMarkings]"/>
      <xsl:variable name="atc_tok" select="tokenize(string(./@ism:atomicEnergyMarkings),' ')"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else             if(count(for $each in $atc_tok return if(matches($each, '^RD-SG')) then $each else null)&gt;0)                 then index-of($atc_tok, 'RD')&gt;0                 else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if(count(for $each in $atc_tok return if(matches($each, '^RD-SG')) then $each else null)&gt;0) then index-of($atc_tok, 'RD')&gt;0 else true()">
               <xsl:attribute name="id">ISM-00183</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00183][Error] If ISM_CAPCO_RESOURCE and attribute atomicEnergyMarkings contains the name token [RD-SG],
            then it must also contain the name token [RD].
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M83"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M83"/>
   <xsl:template match="@*|node()" priority="-2" mode="M83">
      <xsl:apply-templates select="*" mode="M83"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00184-->


	<!--RULE -->
<xsl:template match="*[@ism:atomicEnergyMarkings]" priority="1000" mode="M84">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:atomicEnergyMarkings]"/>
      <xsl:variable name="atc_tok" select="tokenize(string(./@ism:atomicEnergyMarkings),' ')"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else             if(count(for $each in $atc_tok return if(matches($each, '^FRD-SG')) then $each else null)&gt;0)                 then index-of($atc_tok, 'FRD')&gt;0                 else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if(count(for $each in $atc_tok return if(matches($each, '^FRD-SG')) then $each else null)&gt;0) then index-of($atc_tok, 'FRD')&gt;0 else true()">
               <xsl:attribute name="id">ISM-00184</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00184][Error] If ISM_CAPCO_RESOURCE and attribute atomicEnergyMarkings contains the name token [FRD-SG],
            then it must also contain the name token [FRD].
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M84"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M84"/>
   <xsl:template match="@*|node()" priority="-2" mode="M84">
      <xsl:apply-templates select="*" mode="M84"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00185-->


	<!--RULE -->
<xsl:template match="*[@ism:atomicEnergyMarkings]" priority="1000" mode="M85">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:atomicEnergyMarkings]"/>
      <xsl:variable name="atc_tok" select="tokenize(string(./@ism:atomicEnergyMarkings),' ')"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else             if(index-of($atc_tok, 'RD-CNWDI')&gt;0)                 then index-of($atc_tok, 'RD')&gt;0                 else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if(index-of($atc_tok, 'RD-CNWDI')&gt;0) then index-of($atc_tok, 'RD')&gt;0 else true()">
               <xsl:attribute name="id">ISM-00185</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00185][Error] If ISM_CAPCO_RESOURCE and attribute atomicEnergyMarkings contains the name token [RD-CNWDI],
            then it must also contain the name token [RD].
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M85"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M85"/>
   <xsl:template match="@*|node()" priority="-2" mode="M85">
      <xsl:apply-templates select="*" mode="M85"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00015-->


	<!--RULE -->
<xsl:template match="*[@ism:classification and $ISM_CAPCO_RESOURCE]" priority="1000"
                 mode="M86">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:classification and $ISM_CAPCO_RESOURCE]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(./@ism:classification='U'                and (./@ism:releasableTo or ./@ism:SARIdentifier                      or ./@ism:SCIcontrols))                 then false()                  else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(./@ism:classification='U' and (./@ism:releasableTo or ./@ism:SARIdentifier or ./@ism:SCIcontrols)) then false() else true()">
               <xsl:attribute name="id">ISM-00015</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00015][Error] If ISM_CAPCO_RESOURCE and attribute 
            classification has a value of [U], then attributes releasableTo, SARIdentifier, and SCIcontrols 
            must not be specified.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M86"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M86"/>
   <xsl:template match="@*|node()" priority="-2" mode="M86">
      <xsl:apply-templates select="*" mode="M86"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00016-->


	<!--RULE -->
<xsl:template match="*[@ism:classification and $ISM_CAPCO_RESOURCE]" priority="1000"
                 mode="M87">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:classification and $ISM_CAPCO_RESOURCE]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(matches(./@ism:classification,'^U$')                 and (./@ism:classificationReason                     or ./@ism:classifiedBy                     or ./@ism:declassDate                     or ./@ism:declassEvent                     or ./@ism:declassException                     or ./@ism:derivativelyClassifiedBy                     or ./@ism:derivedFrom))              then false() else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(matches(./@ism:classification,'^U$') and (./@ism:classificationReason or ./@ism:classifiedBy or ./@ism:declassDate or ./@ism:declassEvent or ./@ism:declassException or ./@ism:derivativelyClassifiedBy or ./@ism:derivedFrom)) then false() else true()">
               <xsl:attribute name="id">ISM-00016</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00016][Error] If ISM_CAPCO_RESOURCE and attribute 
            classification has a value of [U], then attributes classificationReason, classifiedBy, 
            derivativelyClassifiedBy, declassDate, declassEvent, declassException, 
            and derivedFrom must not be specified.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M87"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M87"/>
   <xsl:template match="@*|node()" priority="-2" mode="M87">
      <xsl:apply-templates select="*" mode="M87"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00040-->


	<!--RULE -->
<xsl:template match="*[@ism:classification and $ISM_CAPCO_RESOURCE]" priority="1000"
                 mode="M88">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:classification and $ISM_CAPCO_RESOURCE]"/>
      <xsl:variable name="errMsg_ValueNotFound"
                    select="'             [ISM-ID-00040][Error] If ISM_CAPCO_RESOURCE and attribute              ownerProducer contains [USA] then attribute classification must have a value in              CVEnumISMClassificationUS.xml.'             "/>
      <xsl:variable name="dataFileElems" select="$classificationUSList"/>
      <xsl:variable name="attrValues" select="./@ism:classification"/>
      <xsl:variable name="attrValueTokens" select="tokenize(string($attrValues),' ')"/>
      <xsl:variable name="capco" select="contains(string(./@ism:ownerProducer), 'USA')"/>
      <xsl:variable name="orderNums"
                    select="             for $token in $attrValueTokens return              if ($dataFileElems[matches($token,concat('^',text(),'$'))]) then              count(($dataFileElems[matches($token,concat('^',text(),'$'))])/preceding::*) + 1             else -1"/>
      <xsl:variable name="hasInvalids" select="count(index-of($orderNums,-1)) &gt; 0"/>
      <xsl:variable name="invalidValues"
                    select="             if ($hasInvalids) then             distinct-values(             for $token in index-of($orderNums,-1) return             $attrValueTokens[$token]              )             else null             "/>
      <xsl:variable name="hasDups"
                    select="count(distinct-values($attrValueTokens)) != count($attrValueTokens)"/>
      <xsl:variable name="dupValues"
                    select="             if ($hasDups) then             distinct-values(             for $token in $attrValueTokens return             if (count(index-of($attrValueTokens,$token)) &gt; 1) then $attrValueTokens[index-of($attrValueTokens,$token)[1]]              else null             )                else null             "/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="if(not($capco)) then true() else not($hasInvalids)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($capco)) then true() else not($hasInvalids)">
               <xsl:attribute name="id">ISM-00040</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="$errMsg_ValueNotFound"/>
                  <xsl:text/>
            Invalid value of [<xsl:text/>
                  <xsl:value-of select="$invalidValues"/>
                  <xsl:text/>]</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not($hasDups)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($hasDups)">
               <xsl:attribute name="flag">undefined</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Duplicate values found [<xsl:text/>
                  <xsl:value-of select="$dupValues"/>
                  <xsl:text/>] for [<xsl:text/>
                  <xsl:value-of select="$attrValueTokens"/>
                  <xsl:text/>] </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M88"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M88"/>
   <xsl:template match="@*|node()" priority="-2" mode="M88">
      <xsl:apply-templates select="*" mode="M88"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00142-->


	<!--RULE -->
<xsl:template match="*[@ism:classification and $ISM_NSI_EO_APPLIES]" priority="1000"
                 mode="M89">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:classification and $ISM_NSI_EO_APPLIES]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(./@ism:classification='U') then true() else                  ($ISM_RESOURCE_ELEMENT/@ism:classifiedBy                  or $ISM_RESOURCE_ELEMENT/@ism:derivativelyClassifiedBy)             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(./@ism:classification='U') then true() else ($ISM_RESOURCE_ELEMENT/@ism:classifiedBy or $ISM_RESOURCE_ELEMENT/@ism:derivativelyClassifiedBy)">
               <xsl:attribute name="id">ISM-00142</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00142][Error] Classified data including DOE data requires either an original classifier or a derivative classifier be identified.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M89"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M89"/>
   <xsl:template match="@*|node()" priority="-2" mode="M89">
      <xsl:apply-templates select="*" mode="M89"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00017-->


	<!--RULE -->
<xsl:template match="*[@ism:classifiedBy and $ISM_NSI_EO_APPLIES]" priority="1000" mode="M90">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:classifiedBy and $ISM_NSI_EO_APPLIES]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="./@ism:classificationReason"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="./@ism:classificationReason">
               <xsl:attribute name="id">ISM-00017</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00017][Error] If ISM_NSI_EO_APPLIES and attribute 
            classifiedBy is specified, then attribute classificationReason must be specified. 
            
            Human Readable: Documents under E.O. 13526 containing Originally Classified data 
            require a classification reason be identified.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M90"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M90"/>
   <xsl:template match="@*|node()" priority="-2" mode="M90">
      <xsl:apply-templates select="*" mode="M90"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00222-->


	<!--RULE -->
<xsl:template match="/*[$ISM_ICDOCUMENT_APPLIES]" priority="1000" mode="M91">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*[$ISM_ICDOCUMENT_APPLIES]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="index-of($partPocType_tok, 'ICD-710') &gt; 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="index-of($partPocType_tok, 'ICD-710') &gt; 0">
               <xsl:attribute name="id">ISM-00222</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00222][Error] If ISM_ICDOCUMENT_APPLIES, then the pocType attribute with value [ICD-710]
            must also be specified on some element in the document.
            
            Human Readable: A document claiming compliance with ICD-710 must specify a point-of-contact
            to whom questions about the document can be directed.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M91"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M91"/>
   <xsl:template match="@*|node()" priority="-2" mode="M91">
      <xsl:apply-templates select="*" mode="M91"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00133-->


	<!--RULE -->
<xsl:template match="*[@ism:declassException and $ISM_NSI_EO_APPLIES]" priority="1000"
                 mode="M92">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:declassException and $ISM_NSI_EO_APPLIES]"/>
      <xsl:variable name="dd" select="exists(./@ism:declassDate)"/>
      <xsl:variable name="de" select="exists(./@ism:declassEvent)"/>
      <xsl:variable name="paddedDeclassEx"
                    select="concat(' ', normalize-space(string(./@ism:declassException)), ' ')"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not(matches($paddedDeclassEx, ' (25X1-human|50X1-HUM|50X2-WMD) ')))                 then true()              else not($dd or $de)             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not(matches($paddedDeclassEx, ' (25X1-human|50X1-HUM|50X2-WMD) '))) then true() else not($dd or $de)">
               <xsl:attribute name="id">ISM-00133</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00133][Error] If ISM_NSI_EO_APPLIES and attribute 
            declassException is specified and contains the tokens [25X1-human], 
            [50X1-HUM], or [50X2-WMD], then attribute declassDate or 
            declassEvent must NOT be specified. Invalid presence of 
            <xsl:text/>
                  <xsl:value-of select="if($dd) then 'declassDate' else null"/>
                  <xsl:text/>
                  <xsl:text/>
                  <xsl:value-of select="if($dd and $de) then ' and ' else null"/>
                  <xsl:text/>
                  <xsl:text/>
                  <xsl:value-of select="if($de) then 'declassEvent' else null"/>
                  <xsl:text/>.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M92"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M92"/>
   <xsl:template match="@*|node()" priority="-2" mode="M92">
      <xsl:apply-templates select="*" mode="M92"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00143-->


	<!--RULE -->
<xsl:template match="*[@ism:derivativelyClassifiedBy and $ISM_CAPCO_RESOURCE]"
                 priority="1000"
                 mode="M93">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:derivativelyClassifiedBy and $ISM_CAPCO_RESOURCE]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="./@ism:derivedFrom"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="./@ism:derivedFrom">
               <xsl:attribute name="id">ISM-00143</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00143][Error] Derivatively Classified data including DOE data requires a derived from value to be identified.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M93"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M93"/>
   <xsl:template match="@*|node()" priority="-2" mode="M93">
      <xsl:apply-templates select="*" mode="M93"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00221-->


	<!--RULE -->
<xsl:template match="*[@ism:derivativelyClassifiedBy and $ISM_CAPCO_RESOURCE]"
                 priority="1000"
                 mode="M94">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:derivativelyClassifiedBy and $ISM_CAPCO_RESOURCE]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not(@ism:classificationReason)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(@ism:classificationReason)">
               <xsl:attribute name="id">ISM-00221</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
        	[ISM-ID-00221][Error] If ISM_CAPCO_RESOURCE and attribute 
        	derivativelyClassifiedBy is specified, then attribute classificationReason
        	must not be specified.
        	
        	Human Readable: USA documents that are derivatively classified must not
        	specify a classification reason.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M94"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M94"/>
   <xsl:template match="@*|node()" priority="-2" mode="M94">
      <xsl:apply-templates select="*" mode="M94"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00167-->


	<!--RULE -->
<xsl:template match="*[@ism:displayOnlyTo]" priority="1000" mode="M95">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:displayOnlyTo]"/>
      <xsl:variable name="errMsg_AlphabeticalOrder"
                    select="'             [ISM-ID-00167][Error] If ISM_CAPCO_RESOURCE and attribute displayOnlyTo is specified,              then each of its values must be ordered in accordance with CVEnumISMRelTo.xml.             '"/>
      <xsl:variable name="dataFileElems" select="$displayOnlyToList"/>
      <xsl:variable name="attrValues" select="./@ism:displayOnlyTo"/>
      <xsl:variable name="attrValueTokens" select="tokenize(string($attrValues),' ')"/>
      <xsl:variable name="convertStrToNum"
                    select="             for $token in $attrValueTokens return                 number(string-join(                     for $index in 1 to string-length($token) return                         for $char in substring($token, $index, 1) return                         if (contains(string('0123456789'), $char)) then                             $char                         else if (contains(string('ABCDEFGHI'), $char)) then                             translate(string($char), 'ABCDEFGHI', '123456789')                         else if (contains(string('JKLMNOPQRS'), $char)) then                             concat('1', translate(string($char), 'JKLMNOPQRS', '0123456789'))                         else if (contains(string('TUVWXYZ'), $char)) then                             concat('2', translate(string($char), 'TUVWXYZ', '0123456'))                         else '0'                 , ''))             "/>
      <xsl:variable name="orderNums"
                    select="             for $token in $attrValueTokens return                  if ($dataFileElems[matches($token,concat('^',text(),'$'))]) then                      count(($dataFileElems[matches($token,concat('^',text(),'$'))])/preceding::*) + 1                 else -1"/>
      <xsl:variable name="sortedOrderNums"
                    select="             for $index in distinct-values(for $token in $orderNums return index-of($orderNums,$token)) return                  if($index = 1 or $orderNums[$index] &gt; $orderNums[$index - 1]) then 1                 else if ($orderNums[$index] &lt; $orderNums[$index - 1]) then 0                 else                     if (matches($attrValueTokens[$index], '[0-9]') or matches($attrValueTokens[$index - 1], '[0-9]')) then                         if ($convertStrToNum[$index - 1] &gt; $convertStrToNum[$index]) then 0                         else 2                     else                           if (compare($attrValueTokens[$index - 1],$attrValueTokens[$index])=1) then 0                         else 2             "/>
      <xsl:variable name="hasUnsorted" select="count(index-of($sortedOrderNums,0)) &gt; 0"/>
      <xsl:variable name="unsortedValues"
                    select="             if ($hasUnsorted) then                 distinct-values(                     for $token in index-of($sortedOrderNums,0) return                         $attrValueTokens[$token]                  )             else null             "/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not($hasUnsorted)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($hasUnsorted)">
               <xsl:attribute name="id">ISM-00167</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="$errMsg_AlphabeticalOrder"/>
                  <xsl:text/>
            The following values are out of order [<xsl:text/>
                  <xsl:value-of select="$unsortedValues"/>
                  <xsl:text/>] for [<xsl:text/>
                  <xsl:value-of select="$attrValueTokens"/>
                  <xsl:text/>] </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M95"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M95"/>
   <xsl:template match="@*|node()" priority="-2" mode="M95">
      <xsl:apply-templates select="*" mode="M95"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00168-->


	<!--RULE -->
<xsl:template match="*[@ism:displayOnlyTo and $ISM_CAPCO_RESOURCE]" priority="1000"
                 mode="M96">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:displayOnlyTo and $ISM_CAPCO_RESOURCE]"/>
      <xsl:variable name="dissemTok" select="tokenize(string(./@ism:disseminationControls),' ')"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="index-of($dissemTok,'DISPLAYONLY')&gt;0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="index-of($dissemTok,'DISPLAYONLY')&gt;0">
               <xsl:attribute name="id">ISM-00168</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00168][Error] If ISM_CAPCO_RESOURCE and attribute 
            disseminationControls is not specified or is specified and does not contain the name token 
            [DISPLAYONLY], then attribute displayOnlyTo must not be specified.
            
            Human Readable: If a portion in a USA document is not marked for DISPLAY ONLY dissemination, 
            it must not list countries to which it can be disseminated.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M96"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M96"/>
   <xsl:template match="@*|node()" priority="-2" mode="M96">
      <xsl:apply-templates select="*" mode="M96"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00026-->


	<!--RULE -->
<xsl:template match="*[@ism:disseminationControls and $ISM_CAPCO_RESOURCE]" priority="1000"
                 mode="M97">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:disseminationControls and $ISM_CAPCO_RESOURCE]"/>
      <xsl:variable name="capcoRestriction" select="true()"/>
      <xsl:variable name="errMsg_AlphabeticalOrder"
                    select="             '[ISM-ID-00026][Error] If ISM_CAPCO_RESOURCE and attribute              disseminationControls is specified, then each of its values must be ordered in accordance with              CVEnumISMDissem.xml.'"/>
      <xsl:variable name="dataFileElems" select="$disseminationControlsList"/>
      <xsl:variable name="attrValues" select="./@ism:disseminationControls"/>
      <xsl:variable name="attrValueTokens" select="tokenize(string($attrValues),' ')"/>
      <xsl:variable name="convertStrToNum"
                    select="             for $token in $attrValueTokens return                 number(string-join(                     for $index in 1 to string-length($token) return                         for $char in substring($token, $index, 1) return                             if (contains(string('0123456789'), $char)) then                                 $char                             else if (contains(string('ABCDEFGHI'), $char)) then                                 translate(string($char), 'ABCDEFGHI', '123456789')                             else if (contains(string('JKLMNOPQRS'), $char)) then                                 concat('1', translate(string($char), 'JKLMNOPQRS', '0123456789'))                             else if (contains(string('TUVWXYZ'), $char)) then                                 concat('2', translate(string($char), 'TUVWXYZ', '0123456'))                             else '0'                 , ''))             "/>
      <xsl:variable name="orderNums"
                    select="             for $token in $attrValueTokens return                  if ($dataFileElems[matches($token,concat('^',text(),'$'))]) then                      count(($dataFileElems[matches($token,concat('^',text(),'$'))])/preceding::*) + 1                 else -1"/>
      <xsl:variable name="sortedOrderNums"
                    select="             for $index in distinct-values(for $token in $orderNums return index-of($orderNums,$token)) return                  if($index = 1 or $orderNums[$index] &gt; $orderNums[$index - 1]) then 1                 else if ($orderNums[$index] &lt; $orderNums[$index - 1]) then 0                 else                     if (matches($attrValueTokens[$index], '[0-9]') or matches($attrValueTokens[$index - 1], '[0-9]')) then                         if ($convertStrToNum[$index - 1] &gt; $convertStrToNum[$index]) then 0                         else 2                     else                           if (compare($attrValueTokens[$index - 1],$attrValueTokens[$index])=1) then 0                         else 2             "/>
      <xsl:variable name="hasUnsorted" select="count(index-of($sortedOrderNums,0)) &gt; 0"/>
      <xsl:variable name="unsortedValues"
                    select="             if ($hasUnsorted) then                 distinct-values(                     for $token in index-of($sortedOrderNums,0) return                         $attrValueTokens[$token]                  )             else null             "/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not($hasUnsorted)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($hasUnsorted)">
               <xsl:attribute name="id">ISM-00026</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="$errMsg_AlphabeticalOrder"/>
                  <xsl:text/>
            The following values are out of order [<xsl:text/>
                  <xsl:value-of select="$unsortedValues"/>
                  <xsl:text/>] for [<xsl:text/>
                  <xsl:value-of select="$attrValueTokens"/>
                  <xsl:text/>] </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M97"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M97"/>
   <xsl:template match="@*|node()" priority="-2" mode="M97">
      <xsl:apply-templates select="*" mode="M97"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00028-->


	<!--RULE -->
<xsl:template match="*[@ism:disseminationControls and $ISM_CAPCO_RESOURCE]" priority="1000"
                 mode="M98">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:disseminationControls and $ISM_CAPCO_RESOURCE]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="                           count(for $token in tokenize(string(./@ism:disseminationControls), ' ') return                        if(matches($token,'^(OC|EYES|RELIDO)$')                       and not( matches(./@ism:classification,'^(TS|S|C)$')))                           then $token                                          else null             )=0             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(for $token in tokenize(string(./@ism:disseminationControls), ' ') return if(matches($token,'^(OC|EYES|RELIDO)$') and not( matches(./@ism:classification,'^(TS|S|C)$'))) then $token else null )=0">
               <xsl:attribute name="id">ISM-00028</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00028][Error] If ISM_CAPCO_RESOURCE and attribute 
            disseminationControls contains the name token [OC], [EYES], or [RELIDO], 
            then attribute classification must have a value of [TS], [S], or [C].
            
            Human Readable: Portions marked for ORCON, EYES ONLY, or RELIDO dissemination 
            in a USA document must be CLASSIFIED, SECRET, or TOP SECRET.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M98"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M98"/>
   <xsl:template match="@*|node()" priority="-2" mode="M98">
      <xsl:apply-templates select="*" mode="M98"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00030-->


	<!--RULE -->
<xsl:template match="*[@ism:disseminationControls and $ISM_CAPCO_RESOURCE]" priority="1000"
                 mode="M99">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:disseminationControls and $ISM_CAPCO_RESOURCE]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="                  if(index-of(tokenize(string(@ism:disseminationControls),' '),'FOUO')&gt;0)                 then @ism:classification='U'                 else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(index-of(tokenize(string(@ism:disseminationControls),' '),'FOUO')&gt;0) then @ism:classification='U' else true()">
               <xsl:attribute name="id">ISM-00030</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00030][Error] If ISM_CAPCO_RESOURCE and attribute 
            disseminationControls contains the name token [FOUO], then attribute classification must have 
            a value of [U].
            
            Human Readable: Portions marked for FOUO dissemination in a USA document must be 
            classified UNCLASSIFIED.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M99"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M99"/>
   <xsl:template match="@*|node()" priority="-2" mode="M99">
      <xsl:apply-templates select="*" mode="M99"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00031-->


	<!--RULE -->
<xsl:template match="*[@ism:disseminationControls and $ISM_CAPCO_RESOURCE]" priority="1000"
                 mode="M100">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:disseminationControls and $ISM_CAPCO_RESOURCE]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(matches(concat(' ',string-join(string(@ism:disseminationControls),' '),' '), ' (REL|EYES) '))                 then @ism:releasableTo                 else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(matches(concat(' ',string-join(string(@ism:disseminationControls),' '),' '), ' (REL|EYES) ')) then @ism:releasableTo else true()">
               <xsl:attribute name="id">ISM-00031</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00031][Error] If ISM_CAPCO_RESOURCE and attribute 
            disseminationControls contains the name token [REL] or [EYES], then attribute releasableTo 
            must be specified.
            
            Human Readable: USA documents containing REL TO or EYES ONLY dissemination must
            specify to which countries the document is releasable.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M100"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M100"/>
   <xsl:template match="@*|node()" priority="-2" mode="M100">
      <xsl:apply-templates select="*" mode="M100"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00033-->


	<!--RULE -->
<xsl:template match="*[@ism:disseminationControls and $ISM_CAPCO_RESOURCE]" priority="1000"
                 mode="M101">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:disseminationControls and $ISM_CAPCO_RESOURCE]"/>
      <xsl:variable name="dissemTok" select="tokenize(string(./@ism:disseminationControls),' ')"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="                not(               count((                     if(index-of($dissemTok,'REL')&gt;0) then 1 else null,                     if(index-of($dissemTok,'NF')&gt;0) then 1 else null,                     if(index-of($dissemTok, 'EYES')&gt;0) then 1 else null)               ) &gt; 1             )             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not( count(( if(index-of($dissemTok,'REL')&gt;0) then 1 else null, if(index-of($dissemTok,'NF')&gt;0) then 1 else null, if(index-of($dissemTok, 'EYES')&gt;0) then 1 else null) ) &gt; 1 )">
               <xsl:attribute name="id">ISM-00033</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00033][Error] If ISM_CAPCO_RESOURCE, then 
            tokens [REL], [EYES] and [NF] are mutually exclusive for attribute disseminationControls.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M101"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M101"/>
   <xsl:template match="@*|node()" priority="-2" mode="M101">
      <xsl:apply-templates select="*" mode="M101"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00034-->


	<!--RULE -->
<xsl:template match="*[@ism:disseminationControls and $ISM_CAPCO_RESOURCE]" priority="1000"
                 mode="M102">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:disseminationControls and $ISM_CAPCO_RESOURCE]"/>
      <xsl:variable name="dissemTok" select="tokenize(string(./@ism:disseminationControls),' ')"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not(index-of($dissemTok,'RELIDO')&gt;0 and index-of($dissemTok,'NF')&gt;0)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(index-of($dissemTok,'RELIDO')&gt;0 and index-of($dissemTok,'NF')&gt;0)">
               <xsl:attribute name="id">ISM-00034</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00034][Error] If ISM_CAPCO_RESOURCE, then 
            tokens "RELIDO" and "NF" are mutually exclusive for attribute disseminationControls.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M102"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M102"/>
   <xsl:template match="@*|node()" priority="-2" mode="M102">
      <xsl:apply-templates select="*" mode="M102"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00094-->


	<!--RULE -->
<xsl:template match="*[@ism:disseminationControls and $ISM_CAPCO_RESOURCE]" priority="1000"
                 mode="M103">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:disseminationControls and $ISM_CAPCO_RESOURCE]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not(./@ism:classification='U')) then true() else                 not(index-of(tokenize(string(./@ism:disseminationControls), ' '),'REL')&gt;0)             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not(./@ism:classification='U')) then true() else not(index-of(tokenize(string(./@ism:disseminationControls), ' '),'REL')&gt;0)">
               <xsl:attribute name="id">ISM-00094</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00094][Error] REL may not be used on UNCLASSIFIED portions.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M103"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M103"/>
   <xsl:template match="@*|node()" priority="-2" mode="M103">
      <xsl:apply-templates select="*" mode="M103"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00107-->


	<!--RULE -->
<xsl:template match="*[@ism:disseminationControls and $ISM_CAPCO_RESOURCE]" priority="1000"
                 mode="M104">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:disseminationControls and $ISM_CAPCO_RESOURCE]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(matches(./@ism:classification,'^(TS|S)$')) then true() else                 not(index-of(tokenize(string(./@ism:disseminationControls), ' '),'IMC')&gt;0)             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(matches(./@ism:classification,'^(TS|S)$')) then true() else not(index-of(tokenize(string(./@ism:disseminationControls), ' '),'IMC')&gt;0)">
               <xsl:attribute name="id">ISM-00107</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00107][Error] IMCON data is SECRET (S), but may appear with S or TOP SECRET data.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M104"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M104"/>
   <xsl:template match="@*|node()" priority="-2" mode="M104">
      <xsl:apply-templates select="*" mode="M104"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00124-->


	<!--RULE -->
<xsl:template match="*[@ism:disseminationControls and $ISM_CAPCO_RESOURCE]" priority="1000"
                 mode="M105">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:disseminationControls and $ISM_CAPCO_RESOURCE]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not(index-of(tokenize(string(./@ism:ownerProducer),' '),'USA')&gt;0)                and index-of(tokenize(string(./@ism:disseminationControls),' '), 'RELIDO')&gt;0)                  then false()                  else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not(index-of(tokenize(string(./@ism:ownerProducer),' '),'USA')&gt;0) and index-of(tokenize(string(./@ism:disseminationControls),' '), 'RELIDO')&gt;0) then false() else true()">
               <xsl:attribute name="id">ISM-00124</xsl:attribute>
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00124][Warning] RELIDO is not authorized for non-US portions.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M105"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M105"/>
   <xsl:template match="@*|node()" priority="-2" mode="M105">
      <xsl:apply-templates select="*" mode="M105"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00140-->


	<!--RULE -->
<xsl:template match="*[@ism:disseminationControls and $ISM_CAPCO_RESOURCE]" priority="1000"
                 mode="M106">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:disseminationControls and $ISM_CAPCO_RESOURCE]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not(./@ism:classification='U')) then true() else                 not(index-of(tokenize(string(./@ism:disseminationControls),' '), 'NF')&gt;0)             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not(./@ism:classification='U')) then true() else not(index-of(tokenize(string(./@ism:disseminationControls),' '), 'NF')&gt;0)">
               <xsl:attribute name="id">ISM-00140</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00140][Error] NF may not be used on UNCLASSIFIED portions.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M106"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M106"/>
   <xsl:template match="@*|node()" priority="-2" mode="M106">
      <xsl:apply-templates select="*" mode="M106"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00164-->


	<!--RULE -->
<xsl:template match="*[@ism:disseminationControls and $ISM_CAPCO_RESOURCE]" priority="1000"
                 mode="M107">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:disseminationControls and $ISM_CAPCO_RESOURCE]"/>
      <xsl:variable name="dissemTok" select="tokenize(string(./@ism:disseminationControls), ' ')"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(matches(./@ism:classification,'^(TS|S)$')) then true() else                 not(index-of($dissemTok,'RS')&gt;0)              "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(matches(./@ism:classification,'^(TS|S)$')) then true() else not(index-of($dissemTok,'RS')&gt;0)">
               <xsl:attribute name="id">ISM-00164</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00164][Error] If ISM_CAPCO_RESOURCE and attribute 
            disseminationControls contains the name token [RS],
            then attribute classification must have a value of [TS] or [S].
            
            Human Readable: USA documents with RISK SENSITIVE dissemination must
            be classified SECRET or TOP SECRET.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M107"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M107"/>
   <xsl:template match="@*|node()" priority="-2" mode="M107">
      <xsl:apply-templates select="*" mode="M107"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00169-->


	<!--RULE -->
<xsl:template match="*[@ism:disseminationControls and $ISM_CAPCO_RESOURCE]" priority="1000"
                 mode="M108">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:disseminationControls and $ISM_CAPCO_RESOURCE]"/>
      <xsl:variable name="dissemTok" select="tokenize(string(./@ism:disseminationControls),' ')"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(index-of($dissemTok,'DISPLAYONLY')&gt;0)                 then not(index-of($dissemTok,'RELIDO')&gt;0                          or index-of($dissemTok,'NF')&gt;0)                 else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(index-of($dissemTok,'DISPLAYONLY')&gt;0) then not(index-of($dissemTok,'RELIDO')&gt;0 or index-of($dissemTok,'NF')&gt;0) else true()">
               <xsl:attribute name="id">ISM-00169</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00169][Error] If ISM_CAPCO_RESOURCE, and attribute disseminationControls 
            contains name token [DISPLAYONLY] then tokens [RELIDO] and [NF] may not also be used.
            
            Human Readable: In a USA document, DISPLAY ONLY, RELIDO and NO FOREIGN dissemination are 
            mutually exclusive for a single element.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M108"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M108"/>
   <xsl:template match="@*|node()" priority="-2" mode="M108">
      <xsl:apply-templates select="*" mode="M108"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00213-->


	<!--RULE -->
<xsl:template match="*[@ism:disseminationControls and $ISM_CAPCO_RESOURCE]" priority="1000"
                 mode="M109">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:disseminationControls and $ISM_CAPCO_RESOURCE]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(index-of(tokenize(string(./@ism:disseminationControls),' '),'DISPLAYONLY')&gt;0)             then ./@ism:displayOnlyTo and not(./@ism:displayOnlyTo = '')             else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(index-of(tokenize(string(./@ism:disseminationControls),' '),'DISPLAYONLY')&gt;0) then ./@ism:displayOnlyTo and not(./@ism:displayOnlyTo = '') else true()">
               <xsl:attribute name="id">ISM-00031</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00213][Error] If ISM_CAPCO_RESOURCE and attribute 
            disseminationControls contains the name token [DISPLAYONLY], then attribute displayOnlyTo 
            must be specified.
            
            Human Readable: A USA document with DISPLAY ONLY dissemination must indicate the countries
            to which it can be disseminated.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M109"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M109"/>
   <xsl:template match="@*|node()" priority="-2" mode="M109">
      <xsl:apply-templates select="*" mode="M109"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00215-->


	<!--RULE -->
<xsl:template match="*[@ism:disseminationControls and $ISM_CAPCO_RESOURCE]" priority="1000"
                 mode="M110">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:disseminationControls and $ISM_CAPCO_RESOURCE]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(index-of(tokenize(string(./@ism:disseminationControls), ' '),'DISPLAYONLY')&gt;0)                 then matches(./@ism:classification,'^(TS|S|C)$')                 else true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(index-of(tokenize(string(./@ism:disseminationControls), ' '),'DISPLAYONLY')&gt;0) then matches(./@ism:classification,'^(TS|S|C)$') else true()">
               <xsl:attribute name="id">ISM-00215</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00215][Error] If ISM_CAPCO_RESOURCE and attribute 
            disseminationControls contains the name token [DISPLAYONLY], 
            then attribute classification must have a value of [TS], [S], or [C].    
            
            Human Readable: USA documents with DISPLAYONLY dissemination must be classified
            CLASSIFIED, SECRET, or TOP SECRET.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M110"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M110"/>
   <xsl:template match="@*|node()" priority="-2" mode="M110">
      <xsl:apply-templates select="*" mode="M110"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00095-->


	<!--RULE -->
<xsl:template match="*[@ism:FGIsourceOpen and $ISM_CAPCO_RESOURCE]" priority="1000"
                 mode="M111">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:FGIsourceOpen and $ISM_CAPCO_RESOURCE]"/>
      <xsl:variable name="errMsg_AlphabeticalOrder"
                    select="'             [ISM-ID-00095][Error] If ISM_CAPCO_RESOURCE and attribute FGIsourceOpen is              specified then each of its values must be ordered in accordance with CVEnumISMFGIOpen.xml.             '"/>
      <xsl:variable name="dataFileElems" select="$FGIsourceOpenList"/>
      <xsl:variable name="attrValues" select="string(./@ism:FGIsourceOpen)"/>
      <xsl:variable name="attrValueTokens" select="tokenize(string($attrValues),' ')"/>
      <xsl:variable name="convertStrToNum"
                    select="             for $token in $attrValueTokens return                 number(string-join(                     for $index in 1 to string-length($token) return                         for $char in substring($token, $index, 1) return                             if (contains(string('0123456789'), $char)) then                                 $char                             else if (contains(string('ABCDEFGHI'), $char)) then                                 translate(string($char), 'ABCDEFGHI', '123456789')                             else if (contains(string('JKLMNOPQRS'), $char)) then                                 concat('1', translate(string($char), 'JKLMNOPQRS', '0123456789'))                             else if (contains(string('TUVWXYZ'), $char)) then                                 concat('2', translate(string($char), 'TUVWXYZ', '0123456'))                             else '0'                 , ''))             "/>
      <xsl:variable name="orderNums"
                    select="             for $token in $attrValueTokens return                  if ($dataFileElems[matches($token,concat('^',text(),'$'))]) then                      count(($dataFileElems[matches($token,concat('^',text(),'$'))])/preceding::*) + 1                 else -1"/>
      <xsl:variable name="sortedOrderNums"
                    select="             for $index in distinct-values(for $token in $orderNums return index-of($orderNums,$token)) return                  if($index = 1 or $orderNums[$index] &gt; $orderNums[$index - 1]) then 1                 else if ($orderNums[$index] &lt; $orderNums[$index - 1]) then 0                 else                     if (matches($attrValueTokens[$index], '[0-9]') or matches($attrValueTokens[$index - 1], '[0-9]')) then                         if ($convertStrToNum[$index - 1] &gt; $convertStrToNum[$index]) then 0                         else 2                     else                           if (compare($attrValueTokens[$index - 1],$attrValueTokens[$index])=1) then 0                         else 2             "/>
      <xsl:variable name="hasUnsorted" select="count(index-of($sortedOrderNums,0)) &gt; 0"/>
      <xsl:variable name="unsortedValues"
                    select="             if ($hasUnsorted) then                 distinct-values(                     for $token in index-of($sortedOrderNums,0) return                         $attrValueTokens[$token]                  )             else null             "/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not($hasUnsorted)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($hasUnsorted)">
               <xsl:attribute name="id">ISM-00095</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="$errMsg_AlphabeticalOrder"/>
                  <xsl:text/>
            The following values are out of order [<xsl:text/>
                  <xsl:value-of select="$unsortedValues"/>
                  <xsl:text/>] for [<xsl:text/>
                  <xsl:value-of select="$attrValueTokens"/>
                  <xsl:text/>] </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M111"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M111"/>
   <xsl:template match="@*|node()" priority="-2" mode="M111">
      <xsl:apply-templates select="*" mode="M111"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00096-->


	<!--RULE -->
<xsl:template match="*[@ism:FGIsourceProtected and $ISM_CAPCO_RESOURCE]" priority="1000"
                 mode="M112">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:FGIsourceProtected and $ISM_CAPCO_RESOURCE]"/>
      <xsl:variable name="errMsg_AlphabeticalOrder"
                    select="'             [ISM-ID-00096][Error] If ISM_CAPCO_RESOURCE and attribute FGIsourceProtected is specified              then each of its values must be ordered in accordance with CVEnumISMFGIProtected.xml.             '"/>
      <xsl:variable name="dataFileElems" select="$FGIsourceProtectedList"/>
      <xsl:variable name="attrValues" select="string(./@ism:FGIsourceProtected)"/>
      <xsl:variable name="attrValueTokens" select="tokenize(string($attrValues),' ')"/>
      <xsl:variable name="convertStrToNum"
                    select="             for $token in $attrValueTokens return                 number(string-join(                     for $index in 1 to string-length($token) return                         for $char in substring($token, $index, 1) return                             if (contains(string('0123456789'), $char)) then                                 $char                             else if (contains(string('ABCDEFGHI'), $char)) then                                 translate(string($char), 'ABCDEFGHI', '123456789')                             else if (contains(string('JKLMNOPQRS'), $char)) then                                 concat('1', translate(string($char), 'JKLMNOPQRS', '0123456789'))                             else if (contains(string('TUVWXYZ'), $char)) then                                 concat('2', translate(string($char), 'TUVWXYZ', '0123456'))                             else '0'                 , ''))             "/>
      <xsl:variable name="orderNums"
                    select="             for $token in $attrValueTokens return                  if ($dataFileElems[matches($token,concat('^',text(),'$'))]) then                      count(($dataFileElems[matches($token,concat('^',text(),'$'))])/preceding::*) + 1                 else -1"/>
      <xsl:variable name="sortedOrderNums"
                    select="             for $index in distinct-values(for $token in $orderNums return index-of($orderNums,$token)) return                  if($index = 1 or $orderNums[$index] &gt; $orderNums[$index - 1]) then 1                 else if ($orderNums[$index] &lt; $orderNums[$index - 1]) then 0                 else                     if (matches($attrValueTokens[$index], '[0-9]') or matches($attrValueTokens[$index - 1], '[0-9]')) then                         if ($convertStrToNum[$index - 1] &gt; $convertStrToNum[$index]) then 0                         else 2                     else                           if (compare($attrValueTokens[$index - 1],$attrValueTokens[$index])=1) then 0                         else 2             "/>
      <xsl:variable name="hasUnsorted" select="count(index-of($sortedOrderNums,0)) &gt; 0"/>
      <xsl:variable name="unsortedValues"
                    select="             if ($hasUnsorted) then                 distinct-values(                     for $token in index-of($sortedOrderNums,0) return                         $attrValueTokens[$token]                  )             else null             "/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not($hasUnsorted)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($hasUnsorted)">
               <xsl:attribute name="id">ISM-00096</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="$errMsg_AlphabeticalOrder"/>
                  <xsl:text/>
            The following values are out of order [<xsl:text/>
                  <xsl:value-of select="$unsortedValues"/>
                  <xsl:text/>] for [<xsl:text/>
                  <xsl:value-of select="$attrValueTokens"/>
                  <xsl:text/>] </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M112"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M112"/>
   <xsl:template match="@*|node()" priority="-2" mode="M112">
      <xsl:apply-templates select="*" mode="M112"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00097-->


	<!--RULE -->
<xsl:template match="*[@ism:FGIsourceProtected and $ISM_CAPCO_RESOURCE]" priority="1000"
                 mode="M113">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:FGIsourceProtected and $ISM_CAPCO_RESOURCE]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="normalize-space(string(./@ism:FGIsourceProtected))='FGI'             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="normalize-space(string(./@ism:FGIsourceProtected))='FGI'">
               <xsl:attribute name="id">ISM-00097</xsl:attribute>
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00097][Warning] FGI Protected should rarely if ever be seen outside of an agency's internal systems.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M113"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M113"/>
   <xsl:template match="@*|node()" priority="-2" mode="M113">
      <xsl:apply-templates select="*" mode="M113"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00217-->


	<!--RULE -->
<xsl:template match="*[@ism:FGIsourceProtected and $ISM_CAPCO_RESOURCE]" priority="1000"
                 mode="M114">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:FGIsourceProtected and $ISM_CAPCO_RESOURCE]"/>
      <xsl:variable name="opTok" select="tokenize(string(@ism:FGIsourceProtected),' ')"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             not(index-of($opTok,'FGI')&gt;0 and count($opTok)&gt;1)             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(index-of($opTok,'FGI')&gt;0 and count($opTok)&gt;1)">
               <xsl:attribute name="id">ISM-00217</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00217][Error] If ISM_CAPCO_RESOURCE attribute FGIsourceProtected contains [FGI], 
            it must be the only value.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M114"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M114"/>
   <xsl:template match="@*|node()" priority="-2" mode="M114">
      <xsl:apply-templates select="*" mode="M114"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00002-->


	<!--RULE -->
<xsl:template match="*[@ism:*]" priority="1000" mode="M115">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:*]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="                 every $attribute in ./@ism:* satisfies                     not(normalize-space(string($attribute)) = '')             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $attribute in ./@ism:* satisfies not(normalize-space(string($attribute)) = '')">
               <xsl:attribute name="id">ISM-00002</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00002][Error] For every optional attribute that is used in a document a non-null value must be present.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M115"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M115"/>
   <xsl:template match="@*|node()" priority="-2" mode="M115">
      <xsl:apply-templates select="*" mode="M115"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00012-->


	<!--RULE -->
<xsl:template match="*[@ism:* except (@ism:pocType | @ism:DESVersion | @ism:unregisteredNoticeType)]"
                 priority="1000"
                 mode="M116">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:* except (@ism:pocType | @ism:DESVersion | @ism:unregisteredNoticeType)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="               (./@ism:ownerProducer and ./@ism:classification)             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="(./@ism:ownerProducer and ./@ism:classification)">
               <xsl:attribute name="id">ISM-00012</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00012][Error] If any of the attributes defined in 
            this DES other than DESVersion, unregisteredNoticeType, or pocType are specified for an element, 
            then attributes classification and ownerProducer must be specified for the element.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M116"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M116"/>
   <xsl:template match="@*|node()" priority="-2" mode="M116">
      <xsl:apply-templates select="*" mode="M116"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00102-->


	<!--RULE -->
<xsl:template match="/*" priority="1000" mode="M117">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             ./@ism:DESVersion             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="./@ism:DESVersion">
               <xsl:attribute name="id">ISM-00102</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00102][Error] The root element must have the attribute 
            DESVersion in the namespace urn:us:gov:ic:ism.
            
            Human Readable: The data encoding specification version number must be specified on the resource node.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M117"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M117"/>
   <xsl:template match="@*|node()" priority="-2" mode="M117">
      <xsl:apply-templates select="*" mode="M117"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00103-->


	<!--RULE -->
<xsl:template match="/*" priority="1000" mode="M118">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             count(                 for $token in //*[(@ism:*)] return                  if($token/@ism:resourceElement=true()) then 1 else null             ) &gt; 0             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( for $token in //*[(@ism:*)] return if($token/@ism:resourceElement=true()) then 1 else null ) &gt; 0">
               <xsl:attribute name="id">ISM-00103</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00103][Error] At least one element must have resourceElement true.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M118"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M118"/>
   <xsl:template match="@*|node()" priority="-2" mode="M118">
      <xsl:apply-templates select="*" mode="M118"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00119-->


	<!--RULE -->
<xsl:template match="*[@ism:* except (@ism:pocType | @ism:DESVersion | @ism:unregisteredNoticeType)                              and $ISM_CAPCO_RESOURCE                              and $ISM_ICDOCUMENT_APPLIES                              and not(@ism:classification='U')]"
                 priority="1000"
                 mode="M119">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:* except (@ism:pocType | @ism:DESVersion | @ism:unregisteredNoticeType)                              and $ISM_CAPCO_RESOURCE                              and $ISM_ICDOCUMENT_APPLIES                              and not(@ism:classification='U')]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="some $token in tokenize(string(@ism:disseminationControls), ' ')                      satisfies $token=('RELIDO','REL','EYES','DISPLAYONLY','NF')             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="some $token in tokenize(string(@ism:disseminationControls), ' ') satisfies $token=('RELIDO','REL','EYES','DISPLAYONLY','NF')">
               <xsl:attribute name="id">ISM-00119</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00119][Error] All classified NSI that claims compliance with ICD 710 must have an appropriate 
            foreign disclosure or release marking.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M119"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M119"/>
   <xsl:template match="@*|node()" priority="-2" mode="M119">
      <xsl:apply-templates select="*" mode="M119"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00125-->


	<!--RULE -->
<xsl:template match="*[@ism:* and $ISM_CAPCO_RESOURCE]" priority="1000" mode="M120">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:* and $ISM_CAPCO_RESOURCE]"/>
      <xsl:variable name="errMsg_ValueNotFound"
                    select="'             [ISM-ID-00125][Error] If any attributes in namespace              urn:us:gov:ic:ism exist, the local name must exist in CVEnumISMAttributes.xml.         '"/>
      <xsl:variable name="dataFileElems" select="$validAttributeList"/>
      <xsl:variable name="attrValues" select="string-join(./@ism:*/local-name(),' ')"/>
      <xsl:variable name="attrValueTokens" select="tokenize(string($attrValues),' ')"/>
      <xsl:variable name="orderNums"
                    select="             for $token in $attrValueTokens return                  if ($dataFileElems[matches($token,concat('^',text(),'$'))]) then                      count(($dataFileElems[matches($token,concat('^',text(),'$'))])/preceding::*) + 1                 else -1"/>
      <xsl:variable name="hasInvalids" select="count(index-of($orderNums,-1)) &gt; 0"/>
      <xsl:variable name="invalidValues"
                    select="             if ($hasInvalids) then                 distinct-values(                     for $token in index-of($orderNums,-1) return                         $attrValueTokens[$token]                  )             else null             "/>
      <xsl:variable name="hasDups"
                    select="count(distinct-values($attrValueTokens)) != count($attrValueTokens)"/>
      <xsl:variable name="dupValues"
                    select="             if ($hasDups) then                 distinct-values(                     for $token in $attrValueTokens return                         if (count(index-of($attrValueTokens,$token)) &gt; 1) then                              $attrValueTokens[index-of($attrValueTokens,$token)[1]]                          else null                 )                else null             "/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not($hasInvalids)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($hasInvalids)">
               <xsl:attribute name="id">ISM-00125</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="$errMsg_ValueNotFound"/>
                  <xsl:text/>
            Invalid value of [<xsl:text/>
                  <xsl:value-of select="$invalidValues"/>
                  <xsl:text/>]</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not($hasDups)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($hasDups)">
               <xsl:attribute name="flag">undefined</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Duplicate values found [<xsl:text/>
                  <xsl:value-of select="$dupValues"/>
                  <xsl:text/>] for [<xsl:text/>
                  <xsl:value-of select="$attrValueTokens"/>
                  <xsl:text/>] </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M120"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M120"/>
   <xsl:template match="@*|node()" priority="-2" mode="M120">
      <xsl:apply-templates select="*" mode="M120"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00126-->


	<!--RULE -->
<xsl:template match="*[@ism:*]" priority="1000" mode="M121">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:*]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             not(./@xs:any)             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(./@xs:any)">
               <xsl:attribute name="id">ISM-00126</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00126][Error] Attributes with namespace urn:us:gov:ic:ism must 
            not appear with attribute @xs:any. 
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M121"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M121"/>
   <xsl:template match="@*|node()" priority="-2" mode="M121">
      <xsl:apply-templates select="*" mode="M121"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00166-->


	<!--RULE -->
<xsl:template match="*[@ism:classification]" priority="1000" mode="M122">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:classification]"/>
      <xsl:variable name="depTerms"
                    select="document('../../CVE/ISM/CVEnumISMClassificationAll.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated]"/>
      <xsl:variable name="isError" select="false()"/>
      <xsl:variable name="reportWarn"
                    select="             dvf:deprecated(string(./@ism:classification), $depTerms, $ISM_RESOURCE_CREATE_DATE, $isError)             "/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count($reportWarn)=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count($reportWarn)=0">
               <xsl:attribute name="id">ISM-00166</xsl:attribute>
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00166][Warning] For attribute classification, value(s) <xsl:text/>
                  <xsl:value-of select="$reportWarn"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M122"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M122"/>
   <xsl:template match="@*|node()" priority="-2" mode="M122">
      <xsl:apply-templates select="*" mode="M122"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00170-->


	<!--RULE -->
<xsl:template match="*[@ism:classification]" priority="1000" mode="M123">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:classification]"/>
      <xsl:variable name="depTerms"
                    select="document('../../CVE/ISM/CVEnumISMClassificationAll.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated]"/>
      <xsl:variable name="isError" select="true()"/>
      <xsl:variable name="reportErr"
                    select="             dvf:deprecated(string(./@ism:classification), $depTerms, $ISM_RESOURCE_CREATE_DATE, $isError)             "/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count($reportErr)=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count($reportErr)=0">
               <xsl:attribute name="id">ISM-00170</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00170][Error] For attribute classification, value(s) <xsl:text/>
                  <xsl:value-of select="$reportErr"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M123"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M123"/>
   <xsl:template match="@*|node()" priority="-2" mode="M123">
      <xsl:apply-templates select="*" mode="M123"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00179-->


	<!--RULE -->
<xsl:template match="*[@ism:disseminationControls]" priority="1000" mode="M124">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:disseminationControls]"/>
      <xsl:variable name="depTerms"
                    select="document('../../CVE/ISM/CVEnumISMDissem.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated]"/>
      <xsl:variable name="isError" select="false()"/>
      <xsl:variable name="reportWarn"
                    select="             dvf:deprecated(string(./@ism:disseminationControls), $depTerms, $ISM_RESOURCE_CREATE_DATE, $isError)             "/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count($reportWarn)=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count($reportWarn)=0">
               <xsl:attribute name="id">ISM-00179</xsl:attribute>
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00179][Warning] For attribute disseminationControls, value(s) <xsl:text/>
                  <xsl:value-of select="$reportWarn"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M124"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M124"/>
   <xsl:template match="@*|node()" priority="-2" mode="M124">
      <xsl:apply-templates select="*" mode="M124"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00180-->


	<!--RULE -->
<xsl:template match="*[@ism:disseminationControls]" priority="1000" mode="M125">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:disseminationControls]"/>
      <xsl:variable name="depTerms"
                    select="document('../../CVE/ISM/CVEnumISMDissem.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated]"/>
      <xsl:variable name="isError" select="true()"/>
      <xsl:variable name="reportErr"
                    select="             dvf:deprecated(string(./@ism:disseminationControls), $depTerms, $ISM_RESOURCE_CREATE_DATE, $isError)             "/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count($reportErr)=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count($reportErr)=0">
               <xsl:attribute name="id">ISM-00180</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00180][Error] For attribute disseminationControls, value(s) <xsl:text/>
                  <xsl:value-of select="$reportErr"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M125"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M125"/>
   <xsl:template match="@*|node()" priority="-2" mode="M125">
      <xsl:apply-templates select="*" mode="M125"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00188-->


	<!--RULE -->
<xsl:template match="*[@ism:FGIsourceOpen]" priority="1000" mode="M126">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:FGIsourceOpen]"/>
      <xsl:variable name="depTerms"
                    select="document('../../CVE/ISM/CVEnumISMFGIOpen.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated]"/>
      <xsl:variable name="isError" select="false()"/>
      <xsl:variable name="reportWarn"
                    select="             dvf:deprecated(string(./@ism:FGIsourceOpen), $depTerms, $ISM_RESOURCE_CREATE_DATE, $isError)             "/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count($reportWarn)=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count($reportWarn)=0">
               <xsl:attribute name="id">ISM-00188</xsl:attribute>
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00188][Warning] For attribute FGIsourceOpen, value(s) <xsl:text/>
                  <xsl:value-of select="$reportWarn"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M126"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M126"/>
   <xsl:template match="@*|node()" priority="-2" mode="M126">
      <xsl:apply-templates select="*" mode="M126"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00189-->


	<!--RULE -->
<xsl:template match="*[@ism:FGIsourceOpen]" priority="1000" mode="M127">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:FGIsourceOpen]"/>
      <xsl:variable name="depTerms"
                    select="document('../../CVE/ISM/CVEnumISMFGIOpen.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated]"/>
      <xsl:variable name="isError" select="true()"/>
      <xsl:variable name="reportErr"
                    select="             dvf:deprecated(string(./@ism:FGIsourceOpen), $depTerms, $ISM_RESOURCE_CREATE_DATE, $isError)             "/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count($reportErr)=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count($reportErr)=0">
               <xsl:attribute name="id">ISM-00189</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00189][Error] For attribute FGIsourceOpen, value(s) <xsl:text/>
                  <xsl:value-of select="$reportErr"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M127"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M127"/>
   <xsl:template match="@*|node()" priority="-2" mode="M127">
      <xsl:apply-templates select="*" mode="M127"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00190-->


	<!--RULE -->
<xsl:template match="*[@ism:FGIsourceProtected]" priority="1000" mode="M128">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:FGIsourceProtected]"/>
      <xsl:variable name="depTerms"
                    select="document('../../CVE/ISM/CVEnumISMFGIProtected.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated]"/>
      <xsl:variable name="isError" select="false()"/>
      <xsl:variable name="reportWarn"
                    select="             dvf:deprecated(string(./@ism:FGIsourceProtected), $depTerms, $ISM_RESOURCE_CREATE_DATE, $isError)             "/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count($reportWarn)=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count($reportWarn)=0">
               <xsl:attribute name="id">ISM-00190</xsl:attribute>
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00190][Warning] For attribute FGIsourceProtected, value(s) <xsl:text/>
                  <xsl:value-of select="$reportWarn"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M128"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M128"/>
   <xsl:template match="@*|node()" priority="-2" mode="M128">
      <xsl:apply-templates select="*" mode="M128"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00191-->


	<!--RULE -->
<xsl:template match="*[@ism:FGIsourceProtected]" priority="1000" mode="M129">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:FGIsourceProtected]"/>
      <xsl:variable name="depTerms"
                    select="document('../../CVE/ISM/CVEnumISMFGIProtected.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated]"/>
      <xsl:variable name="isError" select="true()"/>
      <xsl:variable name="reportErr"
                    select="             dvf:deprecated(string(./@ism:FGIsourceProtected), $depTerms, $ISM_RESOURCE_CREATE_DATE, $isError)             "/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count($reportErr)=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count($reportErr)=0">
               <xsl:attribute name="id">ISM-00191</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00191][Error] For attribute FGIsourceProtected, value(s) <xsl:text/>
                  <xsl:value-of select="$reportErr"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M129"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M129"/>
   <xsl:template match="@*|node()" priority="-2" mode="M129">
      <xsl:apply-templates select="*" mode="M129"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00192-->


	<!--RULE -->
<xsl:template match="*[@ism:nonICmarkings]" priority="1000" mode="M130">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:nonICmarkings]"/>
      <xsl:variable name="depTerms"
                    select="document('../../CVE/ISM/CVEnumISMNonIC.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated]"/>
      <xsl:variable name="isError" select="false()"/>
      <xsl:variable name="reportWarn"
                    select="             dvf:deprecated(string(./@ism:nonICmarkings), $depTerms, $ISM_RESOURCE_CREATE_DATE, $isError)             "/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count($reportWarn)=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count($reportWarn)=0">
               <xsl:attribute name="id">ISM-00192</xsl:attribute>
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00192][Warning] For attribute nonICmarkings, value(s) <xsl:text/>
                  <xsl:value-of select="$reportWarn"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M130"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M130"/>
   <xsl:template match="@*|node()" priority="-2" mode="M130">
      <xsl:apply-templates select="*" mode="M130"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00193-->


	<!--RULE -->
<xsl:template match="*[@ism:nonICmarkings]" priority="1000" mode="M131">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:nonICmarkings]"/>
      <xsl:variable name="depTerms"
                    select="document('../../CVE/ISM/CVEnumISMNonIC.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated]"/>
      <xsl:variable name="isError" select="true()"/>
      <xsl:variable name="reportErr"
                    select="             dvf:deprecated(string(./@ism:nonICmarkings), $depTerms, $ISM_RESOURCE_CREATE_DATE, $isError)             "/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count($reportErr)=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count($reportErr)=0">
               <xsl:attribute name="id">ISM-00193</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00193][Error] For attribute nonICmarkings, value(s) <xsl:text/>
                  <xsl:value-of select="$reportErr"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M131"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M131"/>
   <xsl:template match="@*|node()" priority="-2" mode="M131">
      <xsl:apply-templates select="*" mode="M131"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00194-->


	<!--RULE -->
<xsl:template match="*[@ism:noticeType]" priority="1000" mode="M132">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:noticeType]"/>
      <xsl:variable name="depTerms"
                    select="document('../../CVE/ISM/CVEnumISMNotice.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated]"/>
      <xsl:variable name="isError" select="false()"/>
      <xsl:variable name="reportWarn"
                    select="             dvf:deprecated(string(./@ism:noticeType), $depTerms, $ISM_RESOURCE_CREATE_DATE, $isError)             "/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count($reportWarn)=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count($reportWarn)=0">
               <xsl:attribute name="id">ISM-00194</xsl:attribute>
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00194][Warning] For attribute notice, value(s) <xsl:text/>
                  <xsl:value-of select="$reportWarn"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M132"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M132"/>
   <xsl:template match="@*|node()" priority="-2" mode="M132">
      <xsl:apply-templates select="*" mode="M132"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00195-->


	<!--RULE -->
<xsl:template match="*[@ism:noticeType]" priority="1000" mode="M133">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:noticeType]"/>
      <xsl:variable name="depTerms"
                    select="document('../../CVE/ISM/CVEnumISMNotice.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated]"/>
      <xsl:variable name="isError" select="true()"/>
      <xsl:variable name="reportErr"
                    select="             dvf:deprecated(string(./@ism:noticeType), $depTerms, $ISM_RESOURCE_CREATE_DATE, $isError)             "/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count($reportErr)=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count($reportErr)=0">
               <xsl:attribute name="id">ISM-00195</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00195][Error] For attribute notice, value(s) <xsl:text/>
                  <xsl:value-of select="$reportErr"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M133"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M133"/>
   <xsl:template match="@*|node()" priority="-2" mode="M133">
      <xsl:apply-templates select="*" mode="M133"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00196-->


	<!--RULE -->
<xsl:template match="*[@ism:ownerProducer]" priority="1000" mode="M134">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:ownerProducer]"/>
      <xsl:variable name="depTerms"
                    select="document('../../CVE/ISM/CVEnumISMOwnerProducer.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated]"/>
      <xsl:variable name="isError" select="false()"/>
      <xsl:variable name="reportWarn"
                    select="             dvf:deprecated(string(./@ism:ownerProducer), $depTerms, $ISM_RESOURCE_CREATE_DATE, $isError)             "/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count($reportWarn)=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count($reportWarn)=0">
               <xsl:attribute name="id">ISM-00196</xsl:attribute>
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00196][Warning] For attribute ownerProducer, value(s) <xsl:text/>
                  <xsl:value-of select="$reportWarn"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M134"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M134"/>
   <xsl:template match="@*|node()" priority="-2" mode="M134">
      <xsl:apply-templates select="*" mode="M134"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00197-->


	<!--RULE -->
<xsl:template match="*[@ism:ownerProducer]" priority="1000" mode="M135">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:ownerProducer]"/>
      <xsl:variable name="depTerms"
                    select="document('../../CVE/ISM/CVEnumISMOwnerProducer.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated]"/>
      <xsl:variable name="isError" select="true()"/>
      <xsl:variable name="reportErr"
                    select="             dvf:deprecated(string(./@ism:ownerProducer), $depTerms, $ISM_RESOURCE_CREATE_DATE, $isError)             "/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count($reportErr)=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count($reportErr)=0">
               <xsl:attribute name="id">ISM-00197</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00197][Error] For attribute ownerProducer, value(s) <xsl:text/>
                  <xsl:value-of select="$reportErr"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M135"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M135"/>
   <xsl:template match="@*|node()" priority="-2" mode="M135">
      <xsl:apply-templates select="*" mode="M135"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00198-->


	<!--RULE -->
<xsl:template match="*[@ism:releasableTo]" priority="1000" mode="M136">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:releasableTo]"/>
      <xsl:variable name="depTerms"
                    select="document('../../CVE/ISM/CVEnumISMRelTo.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated]"/>
      <xsl:variable name="isError" select="false()"/>
      <xsl:variable name="reportWarn"
                    select="             dvf:deprecated(string(./@ism:releasableTo), $depTerms, $ISM_RESOURCE_CREATE_DATE, $isError)             "/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count($reportWarn)=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count($reportWarn)=0">
               <xsl:attribute name="id">ISM-00198</xsl:attribute>
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00198][Warning] For attribute releasableTo, value(s) <xsl:text/>
                  <xsl:value-of select="$reportWarn"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M136"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M136"/>
   <xsl:template match="@*|node()" priority="-2" mode="M136">
      <xsl:apply-templates select="*" mode="M136"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00199-->


	<!--RULE -->
<xsl:template match="*[@ism:releasableTo]" priority="1000" mode="M137">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:releasableTo]"/>
      <xsl:variable name="depTerms"
                    select="document('../../CVE/ISM/CVEnumISMRelTo.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated]"/>
      <xsl:variable name="isError" select="true()"/>
      <xsl:variable name="reportErr"
                    select="             dvf:deprecated(string(./@ism:releasableTo), $depTerms, $ISM_RESOURCE_CREATE_DATE, $isError)             "/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count($reportErr)=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count($reportErr)=0">
               <xsl:attribute name="id">ISM-00199</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00199][Error] For attribute releasableTo, value(s) <xsl:text/>
                  <xsl:value-of select="$reportErr"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M137"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M137"/>
   <xsl:template match="@*|node()" priority="-2" mode="M137">
      <xsl:apply-templates select="*" mode="M137"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00200-->


	<!--RULE -->
<xsl:template match="*[@ism:displayOnlyTo]" priority="1000" mode="M138">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:displayOnlyTo]"/>
      <xsl:variable name="depTerms"
                    select="document('../../CVE/ISM/CVEnumISMRelTo.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated]"/>
      <xsl:variable name="isError" select="false()"/>
      <xsl:variable name="reportWarn"
                    select="             dvf:deprecated(string(./@ism:displayOnlyTo), $depTerms, $ISM_RESOURCE_CREATE_DATE, $isError)             "/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count($reportWarn)=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count($reportWarn)=0">
               <xsl:attribute name="id">ISM-00200</xsl:attribute>
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00200][Warning] For attribute displayOnlyTo, value(s) <xsl:text/>
                  <xsl:value-of select="$reportWarn"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M138"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M138"/>
   <xsl:template match="@*|node()" priority="-2" mode="M138">
      <xsl:apply-templates select="*" mode="M138"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00201-->


	<!--RULE -->
<xsl:template match="*[@ism:displayOnlyTo]" priority="1000" mode="M139">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:displayOnlyTo]"/>
      <xsl:variable name="depTerms"
                    select="document('../../CVE/ISM/CVEnumISMRelTo.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated]"/>
      <xsl:variable name="isError" select="true()"/>
      <xsl:variable name="reportErr"
                    select="             dvf:deprecated(string(./@ism:displayOnlyTo), $depTerms, $ISM_RESOURCE_CREATE_DATE, $isError)             "/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count($reportErr)=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count($reportErr)=0">
               <xsl:attribute name="id">ISM-00201</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00201][Error] For attribute displayOnlyTo, value(s) <xsl:text/>
                  <xsl:value-of select="$reportErr"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M139"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M139"/>
   <xsl:template match="@*|node()" priority="-2" mode="M139">
      <xsl:apply-templates select="*" mode="M139"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00202-->


	<!--RULE -->
<xsl:template match="*[@ism:SARIdentifier]" priority="1000" mode="M140">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:SARIdentifier]"/>
      <xsl:variable name="depTerms"
                    select="document('../../CVE/ISM/CVEnumISMSAR.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated]"/>
      <xsl:variable name="isError" select="false()"/>
      <xsl:variable name="reportWarn"
                    select="             dvf:deprecated(string(./@ism:SARIdentifier), $depTerms, $ISM_RESOURCE_CREATE_DATE, $isError)             "/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count($reportWarn)=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count($reportWarn)=0">
               <xsl:attribute name="id">ISM-00202</xsl:attribute>
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00202][Warning] For attribute SARIdentifier, value(s) <xsl:text/>
                  <xsl:value-of select="$reportWarn"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M140"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M140"/>
   <xsl:template match="@*|node()" priority="-2" mode="M140">
      <xsl:apply-templates select="*" mode="M140"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00203-->


	<!--RULE -->
<xsl:template match="*[@ism:SARIdentifier]" priority="1000" mode="M141">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:SARIdentifier]"/>
      <xsl:variable name="depTerms"
                    select="document('../../CVE/ISM/CVEnumISMSAR.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated]"/>
      <xsl:variable name="isError" select="true()"/>
      <xsl:variable name="reportErr"
                    select="             dvf:deprecated(string(./@ism:SARIdentifier), $depTerms, $ISM_RESOURCE_CREATE_DATE, $isError)             "/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count($reportErr)=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count($reportErr)=0">
               <xsl:attribute name="id">ISM-00203</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00203][Error] For attribute SARIdentifier, value(s) <xsl:text/>
                  <xsl:value-of select="$reportErr"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M141"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M141"/>
   <xsl:template match="@*|node()" priority="-2" mode="M141">
      <xsl:apply-templates select="*" mode="M141"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00204-->


	<!--RULE -->
<xsl:template match="*[@ism:SCIcontrols]" priority="1000" mode="M142">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:SCIcontrols]"/>
      <xsl:variable name="depTerms"
                    select="document('../../CVE/ISM/CVEnumISMSCIControls.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated]"/>
      <xsl:variable name="isError" select="false()"/>
      <xsl:variable name="reportWarn"
                    select="             dvf:deprecated(string(./@ism:SCIcontrols), $depTerms, $ISM_RESOURCE_CREATE_DATE, $isError)             "/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count($reportWarn)=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count($reportWarn)=0">
               <xsl:attribute name="id">ISM-00204</xsl:attribute>
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00204][Warning] For attribute SCIControls, value(s) <xsl:text/>
                  <xsl:value-of select="$reportWarn"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M142"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M142"/>
   <xsl:template match="@*|node()" priority="-2" mode="M142">
      <xsl:apply-templates select="*" mode="M142"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00205-->


	<!--RULE -->
<xsl:template match="*[@ism:SCIcontrols]" priority="1000" mode="M143">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:SCIcontrols]"/>
      <xsl:variable name="depTerms"
                    select="document('../../CVE/ISM/CVEnumISMSCIControls.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated]"/>
      <xsl:variable name="isError" select="true()"/>
      <xsl:variable name="reportErr"
                    select="             dvf:deprecated(string(./@ism:SCIcontrols), $depTerms, $ISM_RESOURCE_CREATE_DATE, $isError)             "/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count($reportErr)=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count($reportErr)=0">
               <xsl:attribute name="id">ISM-00205</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00205][Error] For attribute SCIcontrols, value(s) <xsl:text/>
                  <xsl:value-of select="$reportErr"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M143"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M143"/>
   <xsl:template match="@*|node()" priority="-2" mode="M143">
      <xsl:apply-templates select="*" mode="M143"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00206-->


	<!--RULE -->
<xsl:template match="*[@ism:declassException]" priority="1000" mode="M144">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:declassException]"/>
      <xsl:variable name="depTerms"
                    select="document('../../CVE/ISM/CVEnumISM25X.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated]"/>
      <xsl:variable name="isError" select="false()"/>
      <xsl:variable name="reportWarn"
                    select="             dvf:deprecated(string(./@ism:declassException), $depTerms,$ISM_RESOURCE_CREATE_DATE, $isError)             "/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count($reportWarn)=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count($reportWarn)=0">
               <xsl:attribute name="id">ISM-00206</xsl:attribute>
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00206][Warning] For attribute declassException, value(s) <xsl:text/>
                  <xsl:value-of select="$reportWarn"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M144"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M144"/>
   <xsl:template match="@*|node()" priority="-2" mode="M144">
      <xsl:apply-templates select="*" mode="M144"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00207-->


	<!--RULE -->
<xsl:template match="*[@ism:declassException]" priority="1000" mode="M145">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:declassException]"/>
      <xsl:variable name="depTerms"
                    select="document('../../CVE/ISM/CVEnumISM25X.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated]"/>
      <xsl:variable name="isError" select="true()"/>
      <xsl:variable name="reportErr"
                    select="             dvf:deprecated(string(./@ism:declassException), $depTerms, $ISM_RESOURCE_CREATE_DATE, $isError)             "/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count($reportErr)=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count($reportErr)=0">
               <xsl:attribute name="id">ISM-00207</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00207][Error] For attribute declassException, value(s) <xsl:text/>
                  <xsl:value-of select="$reportErr"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M145"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M145"/>
   <xsl:template match="@*|node()" priority="-2" mode="M145">
      <xsl:apply-templates select="*" mode="M145"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00208-->


	<!--RULE -->
<xsl:template match="*[@ism:atomicEnergyMarkings]" priority="1000" mode="M146">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:atomicEnergyMarkings]"/>
      <xsl:variable name="depTerms"
                    select="document('../../CVE/ISM/CVEnumISMAtomicEnergyMarkings.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated]"/>
      <xsl:variable name="isError" select="false()"/>
      <xsl:variable name="reportWarn"
                    select="             dvf:deprecated(string(./@ism:atomicEnergyMarkings), $depTerms, $ISM_RESOURCE_CREATE_DATE, $isError)             "/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count($reportWarn)=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count($reportWarn)=0">
               <xsl:attribute name="id">ISM-00208</xsl:attribute>
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00208][Warning] For attribute atomicEnergyMarkings, value(s) <xsl:text/>
                  <xsl:value-of select="$reportWarn"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M146"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M146"/>
   <xsl:template match="@*|node()" priority="-2" mode="M146">
      <xsl:apply-templates select="*" mode="M146"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00209-->


	<!--RULE -->
<xsl:template match="*[@ism:atomicEnergyMarkings]" priority="1000" mode="M147">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:atomicEnergyMarkings]"/>
      <xsl:variable name="depTerms"
                    select="document('../../CVE/ISM/CVEnumISMAtomicEnergyMarkings.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated]"/>
      <xsl:variable name="isError" select="true()"/>
      <xsl:variable name="reportErr"
                    select="             dvf:deprecated(string(./@ism:atomicEnergyMarkings), $depTerms, $ISM_RESOURCE_CREATE_DATE, $isError)             "/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count($reportErr)=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count($reportErr)=0">
               <xsl:attribute name="id">ISM-00209</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00209][Error] For attribute atomicEnergyMarkings, value(s) <xsl:text/>
                  <xsl:value-of select="$reportErr"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M147"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M147"/>
   <xsl:template match="@*|node()" priority="-2" mode="M147">
      <xsl:apply-templates select="*" mode="M147"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00210-->


	<!--RULE -->
<xsl:template match="*[@ism:nonUSControls]" priority="1000" mode="M148">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:nonUSControls]"/>
      <xsl:variable name="depTerms"
                    select="document('../../CVE/ISM/CVEnumISMNonUSControls.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated]"/>
      <xsl:variable name="isError" select="false()"/>
      <xsl:variable name="reportWarn"
                    select="             dvf:deprecated(string(./@ism:nonUSControls), $depTerms, $ISM_RESOURCE_CREATE_DATE, $isError)             "/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count($reportWarn)=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count($reportWarn)=0">
               <xsl:attribute name="id">ISM-00210</xsl:attribute>
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00210][Warning] For attribute nonUSControls, value(s) <xsl:text/>
                  <xsl:value-of select="$reportWarn"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M148"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M148"/>
   <xsl:template match="@*|node()" priority="-2" mode="M148">
      <xsl:apply-templates select="*" mode="M148"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00211-->


	<!--RULE -->
<xsl:template match="*[@ism:nonUSControls]" priority="1000" mode="M149">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:nonUSControls]"/>
      <xsl:variable name="depTerms"
                    select="document('../../CVE/ISM/CVEnumISMNonUSControls.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated]"/>
      <xsl:variable name="isError" select="true()"/>
      <xsl:variable name="reportErr"
                    select="             dvf:deprecated(string(./@ism:nonUSControls), $depTerms, $ISM_RESOURCE_CREATE_DATE, $isError)             "/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count($reportErr)=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count($reportErr)=0">
               <xsl:attribute name="id">ISM-00211</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00211][Error] For attribute nonUSControls, value(s) <xsl:text/>
                  <xsl:value-of select="$reportErr"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M149"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M149"/>
   <xsl:template match="@*|node()" priority="-2" mode="M149">
      <xsl:apply-templates select="*" mode="M149"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00223-->


	<!--RULE -->
<xsl:template match="ism:*[$ISM_CAPCO_RESOURCE]" priority="1000" mode="M150">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="ism:*[$ISM_CAPCO_RESOURCE]"/>
      <xsl:variable name="errMsg_ValueNotFound"
                    select="'             [ISM-ID-00223][Error] If any elements in namespace              urn:us:gov:ic:ism exist, the local name must exist in CVEnumISMElements.xml.         '"/>
      <xsl:variable name="localName" select="local-name()"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="exists($validElementList[text() = $localName])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="exists($validElementList[text() = $localName])">
               <xsl:attribute name="id">ISM-00223</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="normalize-space(string($errMsg_ValueNotFound))"/>
                  <xsl:text/>
            Invalid value of [<xsl:text/>
                  <xsl:value-of select="name()"/>
                  <xsl:text/>]</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M150"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M150"/>
   <xsl:template match="@*|node()" priority="-2" mode="M150">
      <xsl:apply-templates select="*" mode="M150"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00226-->


	<!--RULE -->
<xsl:template match="*[@ism:noticeType|@ism:unregisteredNoticeType]" priority="1000"
                 mode="M151">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:noticeType|@ism:unregisteredNoticeType]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(@ism:noticeType|@ism:unregisteredNoticeType)=1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(@ism:noticeType|@ism:unregisteredNoticeType)=1">
               <xsl:attribute name="id">ISM-00226</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00226][Error]
            @ism:noticeType and @ism:unregisteredNoticeType may not both be applied to the same element.
            
            Human Readable: The ISM attributes noticeType and unregisteredNoticeType 
            are mutually exclusive and cannot both be applied to the same element. 
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M151"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M151"/>
   <xsl:template match="@*|node()" priority="-2" mode="M151">
      <xsl:apply-templates select="*" mode="M151"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00035-->


	<!--RULE -->
<xsl:template match="*[@ism:nonICmarkings]" priority="1000" mode="M152">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:nonICmarkings]"/>
      <xsl:variable name="errMsg_AlphabeticalOrder"
                    select="'             [ISM-ID-00035][Error] If ISM_CAPCO_RESOURCE and attribute nonICmarkings is              specified, then each of its values must be ordered in accordance with CVEnumISMNonIC.xml.             '"/>
      <xsl:variable name="dataFileElems" select="$nonICmarkingsList"/>
      <xsl:variable name="attrValues" select="./@ism:nonICmarkings"/>
      <xsl:variable name="attrValueTokens" select="tokenize(string($attrValues),' ')"/>
      <xsl:variable name="convertStrToNum"
                    select="             for $token in $attrValueTokens return                 number(string-join(                     for $index in 1 to string-length($token) return                         for $char in substring($token, $index, 1) return                             if (contains(string('0123456789'), $char)) then                                 $char                             else if (contains(string('ABCDEFGHI'), $char)) then                                 translate(string($char), 'ABCDEFGHI', '123456789')                             else if (contains(string('JKLMNOPQRS'), $char)) then                                 concat('1', translate(string($char), 'JKLMNOPQRS', '0123456789'))                             else if (contains(string('TUVWXYZ'), $char)) then                                 concat('2', translate(string($char), 'TUVWXYZ', '0123456'))                             else '0'                 , ''))             "/>
      <xsl:variable name="orderNums"
                    select="             for $token in $attrValueTokens return                  if ($dataFileElems[matches($token,concat('^',text(),'$'))]) then                      count(($dataFileElems[matches($token,concat('^',text(),'$'))])/preceding::*) + 1                 else -1"/>
      <xsl:variable name="sortedOrderNums"
                    select="             for $index in distinct-values(for $token in $orderNums return index-of($orderNums,$token)) return                  if($index = 1 or $orderNums[$index] &gt; $orderNums[$index - 1]) then 1                 else if ($orderNums[$index] &lt; $orderNums[$index - 1]) then 0                 else                     if (matches($attrValueTokens[$index], '[0-9]') or matches($attrValueTokens[$index - 1], '[0-9]')) then                         if ($convertStrToNum[$index - 1] &gt; $convertStrToNum[$index]) then 0                         else 2                     else                           if (compare($attrValueTokens[$index - 1],$attrValueTokens[$index])=1) then 0                         else 2             "/>
      <xsl:variable name="hasUnsorted" select="count(index-of($sortedOrderNums,0)) &gt; 0"/>
      <xsl:variable name="unsortedValues"
                    select="             if ($hasUnsorted) then                 distinct-values(                     for $token in index-of($sortedOrderNums,0) return                         $attrValueTokens[$token]                  )             else null             "/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not($hasUnsorted)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($hasUnsorted)">
               <xsl:attribute name="id">ISM-00035</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="$errMsg_AlphabeticalOrder"/>
                  <xsl:text/>
            The following values are out of order [<xsl:text/>
                  <xsl:value-of select="$unsortedValues"/>
                  <xsl:text/>] for [<xsl:text/>
                  <xsl:value-of select="$attrValueTokens"/>
                  <xsl:text/>] </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M152"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M152"/>
   <xsl:template match="@*|node()" priority="-2" mode="M152">
      <xsl:apply-templates select="*" mode="M152"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00036-->


	<!--RULE -->
<xsl:template match="*[@ism:nonICmarkings]" priority="1000" mode="M153">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:nonICmarkings]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else              if(index-of(tokenize(string(./@ism:nonICmarkings), ' '),'SC')&gt;0)                 then matches(./@ism:classification,'^(TS|S|C)$')                 else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if(index-of(tokenize(string(./@ism:nonICmarkings), ' '),'SC')&gt;0) then matches(./@ism:classification,'^(TS|S|C)$') else true()">
               <xsl:attribute name="id">ISM-00036</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00036][Error] If ISM_CAPCO_RESOURCE and attribute nonICmarkings 
            contains the name token [SC], then attribute classification must have a 
            value of [TS], [S], or [C].        
            
            Human Readable: SC data must be marked CONFIDENTIAL, SECRET or TOP SECRET in USA documents.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M153"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M153"/>
   <xsl:template match="@*|node()" priority="-2" mode="M153">
      <xsl:apply-templates select="*" mode="M153"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00037-->


	<!--RULE -->
<xsl:template match="*[@ism:nonICmarkings]" priority="1000" mode="M154">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:nonICmarkings]"/>
      <xsl:variable name="nonICtok" select="tokenize(string(./@ism:nonICmarkings),' ')"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else             if(index-of($nonICtok, 'SINFO')&gt;0               or index-of($nonICtok, 'SBU')&gt;0               or index-of($nonICtok, 'SBU-NF')&gt;0)                 then ./@ism:classification='U'                 else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if(index-of($nonICtok, 'SINFO')&gt;0 or index-of($nonICtok, 'SBU')&gt;0 or index-of($nonICtok, 'SBU-NF')&gt;0) then ./@ism:classification='U' else true()">
               <xsl:attribute name="id">ISM-00037</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00037][Error] If ISM_CAPCO_RESOURCE and attribute nonICmarkings contains 
            the name token [SINFO], [SBU], or [SBU-NF], then attribute classification must have a value of [U].   
            
            Human Readable: SINFO, SBU, and SBU-NF data must be marked UNCLASSIFIED in USA documents.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M154"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M154"/>
   <xsl:template match="@*|node()" priority="-2" mode="M154">
      <xsl:apply-templates select="*" mode="M154"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00038-->


	<!--RULE -->
<xsl:template match="*[@ism:nonICmarkings]" priority="1000" mode="M155">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:nonICmarkings]"/>
      <xsl:variable name="nicmTok" select="tokenize(string(./@ism:nonICmarkings),' ')"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else             not(index-of($nicmTok,'XD')&gt;0 and index-of($nicmTok,'ND')&gt;0)             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else not(index-of($nicmTok,'XD')&gt;0 and index-of($nicmTok,'ND')&gt;0)">
               <xsl:attribute name="id">ISM-00038</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00038][Error] If ISM_CAPCO_RESOURCE, then Name tokens [XD] and [ND] are mutually 
            exclusive for attribute nonICmarkings.
            
            Human Readable: USA documents must not specify both XD and ND on a single element.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M155"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M155"/>
   <xsl:template match="@*|node()" priority="-2" mode="M155">
      <xsl:apply-templates select="*" mode="M155"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00148-->


	<!--RULE -->
<xsl:template match="*[@ism:nonICmarkings]" priority="1000" mode="M156">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:nonICmarkings]"/>
      <xsl:variable name="nicmTok" select="tokenize(string(./@ism:nonICmarkings), ' ')"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else             not(index-of($nicmTok,'LES')&gt;0 and index-of($nicmTok,'LES-NF')&gt;0)             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else not(index-of($nicmTok,'LES')&gt;0 and index-of($nicmTok,'LES-NF')&gt;0)">
               <xsl:attribute name="id">ISM-00148</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00148][Error] If ISM_CAPCO_RESOURCE, then tokens [LES] and [LES-NF] are mutually
            exclusive for attribute nonICmarkings.
            
            Human Readable: USA documents must not specify both LES and LES-NF on a single element.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M156"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M156"/>
   <xsl:template match="@*|node()" priority="-2" mode="M156">
      <xsl:apply-templates select="*" mode="M156"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00225-->


	<!--RULE -->
<xsl:template match="*[@ism:nonICmarkings]" priority="1000" mode="M157">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:nonICmarkings]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if($ISM_ICDOCUMENT_APPLIES)             then not(some $token in tokenize(normalize-space(string(@ism:nonICmarkings)), ' ') satisfies                  starts-with($token, 'ACCM'))       else true()                           "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if($ISM_ICDOCUMENT_APPLIES) then not(some $token in tokenize(normalize-space(string(@ism:nonICmarkings)), ' ') satisfies starts-with($token, 'ACCM')) else true()">
               <xsl:attribute name="id">ISM-00225</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
        	[ISM-ID-00225][Error] If ISM-ICDOCUMENT-APPLIES, then attribute ism:nonICmarkings must not 
        	be specified with a value containing any name token starting with [ACCM]. 
        	
        	Human Readable: ACCM tokens are not valid for documents that claim compliance with IC rules.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M157"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M157"/>
   <xsl:template match="@*|node()" priority="-2" mode="M157">
      <xsl:apply-templates select="*" mode="M157"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00163-->


	<!--RULE -->
<xsl:template match="*[@ism:nonUSControls]" priority="1000" mode="M158">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:nonUSControls]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="./@ism:ownerProducer='NATO'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="./@ism:ownerProducer='NATO'">
               <xsl:attribute name="id">ISM-00163</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00163][Error] NATO is the only owner of classification markings for which nonUSControls are currently authorized.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M158"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M158"/>
   <xsl:template match="@*|node()" priority="-2" mode="M158">
      <xsl:apply-templates select="*" mode="M158"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00127-->


	<!--RULE -->
<xsl:template match="*[@ism:atomicEnergyMarkings]" priority="1000" mode="M159">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:atomicEnergyMarkings]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)or ./@ism:excludeFromRollup=true()) then true() else              if(index-of(tokenize(string(./@ism:atomicEnergyMarkings), ' '), 'RD')&gt;0)                  then index-of($partNotice_tok, 'RD')&gt;0                 else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)or ./@ism:excludeFromRollup=true()) then true() else if(index-of(tokenize(string(./@ism:atomicEnergyMarkings), ' '), 'RD')&gt;0) then index-of($partNotice_tok, 'RD')&gt;0 else true()">
               <xsl:attribute name="id">ISM-00127</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00127][Error] If ISM_CAPCO_RESOURCE and:
            1. Any element meeting ISM_CONTRIBUTES in the document has the attribute atomicEnergyMarkings containing [RD]
            AND
            2. No element meeting ISM_CONTRIBUTES in the document has notice containing [RD].
            
            Human Readable: USA documents containing RD data must also have an RD notice.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M159"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M159"/>
   <xsl:template match="@*|node()" priority="-2" mode="M159">
      <xsl:apply-templates select="*" mode="M159"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00128-->


	<!--RULE -->
<xsl:template match="*[@ism:atomicEnergyMarkings]" priority="1000" mode="M160">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:atomicEnergyMarkings]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE) or ./@ism:excludeFromRollup=true()) then true() else              if(index-of(tokenize(string(./@ism:atomicEnergyMarkings), ' '), 'FRD')&gt;0)                  then index-of($partNotice_tok, 'FRD')&gt;0                 else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE) or ./@ism:excludeFromRollup=true()) then true() else if(index-of(tokenize(string(./@ism:atomicEnergyMarkings), ' '), 'FRD')&gt;0) then index-of($partNotice_tok, 'FRD')&gt;0 else true()">
               <xsl:attribute name="id">ISM-00128</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00128][Error] If ISM_CAPCO_RESOURCE and:
            1. Any element meeting ISM_CONTRIBUTES in the document has the attribute atomicEnergyMarkings containing [FRD]
            AND
            2. No element meeting ISM_CONTRIBUTES in the document has notice containing [FRD]
            
            Human Readable: USA documents containing FRD data must also have an FRD notice.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M160"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M160"/>
   <xsl:template match="@*|node()" priority="-2" mode="M160">
      <xsl:apply-templates select="*" mode="M160"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00129-->


	<!--RULE -->
<xsl:template match="*[@ism:disseminationControls]" priority="1000" mode="M161">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:disseminationControls]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE) or ./@ism:excludeFromRollup=true()) then true() else              if(index-of(tokenize(string(./@ism:disseminationControls), ' '), 'IMC')&gt;0)                  then index-of($partNotice_tok, 'IMC')&gt;0                 else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE) or ./@ism:excludeFromRollup=true()) then true() else if(index-of(tokenize(string(./@ism:disseminationControls), ' '), 'IMC')&gt;0) then index-of($partNotice_tok, 'IMC')&gt;0 else true()">
               <xsl:attribute name="id">ISM-00129</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00129][Error] If ISM_CAPCO_RESOURCE and:
            1. Any element meeting ISM_CONTRIBUTES in the document has the attribute disseminationControls containing [IMC]
            AND
            2. No element meeting ISM_CONTRIBUTES in the document has notice containing [IMC]
            
            Human Readable: USA documents containing IMC data must also have an IMC notice.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M161"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M161"/>
   <xsl:template match="@*|node()" priority="-2" mode="M161">
      <xsl:apply-templates select="*" mode="M161"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00130-->


	<!--RULE -->
<xsl:template match="*[@ism:disseminationControls]" priority="1000" mode="M162">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:disseminationControls]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE) or ./@ism:excludeFromRollup=true()) then true() else              if(index-of(tokenize(string(./@ism:disseminationControls), ' '), 'FISA')&gt;0)                  then index-of($partNotice_tok, 'FISA')&gt;0                 else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE) or ./@ism:excludeFromRollup=true()) then true() else if(index-of(tokenize(string(./@ism:disseminationControls), ' '), 'FISA')&gt;0) then index-of($partNotice_tok, 'FISA')&gt;0 else true()">
               <xsl:attribute name="id">ISM-00130</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00130][Error] If ISM_CAPCO_RESOURCE and:
            1. Any element meeting ISM_CONTRIBUTES in the document has the attribute disseminationControls containing [FISA]
            AND
            2. No element meeting ISM_CONTRIBUTES in the document has notice containing [FISA]
            
            Human Readable: USA documents containing FISA data must also have an FISA notice.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M162"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M162"/>
   <xsl:template match="@*|node()" priority="-2" mode="M162">
      <xsl:apply-templates select="*" mode="M162"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00134-->


	<!--RULE -->
<xsl:template match="*[@ism:nonICmarkings]" priority="1000" mode="M163">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:nonICmarkings]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE) or ./@ism:excludeFromRollup=true()) then true() else              if(index-of(tokenize(string(./@ism:nonICmarkings), ' '), 'DS')&gt;0)                  then index-of($partNotice_tok, 'DS')&gt;0                 else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE) or ./@ism:excludeFromRollup=true()) then true() else if(index-of(tokenize(string(./@ism:nonICmarkings), ' '), 'DS')&gt;0) then index-of($partNotice_tok, 'DS')&gt;0 else true()">
               <xsl:attribute name="id">ISM-00134</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00134][Error] If ISM_CAPCO_RESOURCE and:
            1. Any element meeting ISM_CONTRIBUTES in the document has the attribute nonICmarkings containing [DS]
            AND
            2. No element meeting ISM_CONTRIBUTES in the document has the attribute notice containing [DS]
            
            Human Readable: USA documents containing DS data must also have a DS notice.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M163"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M163"/>
   <xsl:template match="@*|node()" priority="-2" mode="M163">
      <xsl:apply-templates select="*" mode="M163"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00135-->


	<!--RULE -->
<xsl:template match="*[@ism:noticeType]" priority="1000" mode="M164">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:noticeType]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE) or ./@ism:excludeFromRollup=true()) then true() else              if(generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)) then true() else             if(index-of(tokenize(string(./@ism:noticeType), ' '), 'RD')&gt;0 and not(./@ism:excludeFromRollup=true()))             then index-of($partAtomicEnergyMarkings_tok, 'RD')&gt;0                  else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE) or ./@ism:excludeFromRollup=true()) then true() else if(generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)) then true() else if(index-of(tokenize(string(./@ism:noticeType), ' '), 'RD')&gt;0 and not(./@ism:excludeFromRollup=true())) then index-of($partAtomicEnergyMarkings_tok, 'RD')&gt;0 else true()">
               <xsl:attribute name="id">ISM-00135</xsl:attribute>
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00135][Warning] If ISM_CAPCO_RESOURCE and:
            1. No element meeting ISM_CONTRIBUTES in the document has the attribute atomicEnergyMarkings containing [RD]
            AND
            2. Any element meeting ISM_CONTRIBUTES in the document has the attribute notice containing [RD]
            
            Human Readable: USA documents containing RD data must also have an RD notice.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M164"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M164"/>
   <xsl:template match="@*|node()" priority="-2" mode="M164">
      <xsl:apply-templates select="*" mode="M164"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00136-->


	<!--RULE -->
<xsl:template match="*[@ism:noticeType]" priority="1000" mode="M165">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:noticeType]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE) or ./@ism:excludeFromRollup=true()) then true() else              if(index-of(tokenize(string(./@ism:noticeType), ' '), 'FRD')&gt;0 and not(./@ism:excludeFromRollup=true()))                 then index-of($partAtomicEnergyMarkings_tok, 'FRD')&gt;0                  else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE) or ./@ism:excludeFromRollup=true()) then true() else if(index-of(tokenize(string(./@ism:noticeType), ' '), 'FRD')&gt;0 and not(./@ism:excludeFromRollup=true())) then index-of($partAtomicEnergyMarkings_tok, 'FRD')&gt;0 else true()">
               <xsl:attribute name="id">ISM-00136</xsl:attribute>
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> 
            [ISM-ID-00136][Warning] If ISM_CAPCO_RESOURCE and:
            1. No element without ism:excludeFromRollup=true() in the document has the attribute atomicEnergyMarkings containing [FRD]
            AND
            2. Any element without ism:excludeFromRollup=true() in the document has the attribute notice containing [FRD]
            
            Human Readable: USA documents containing FRD data must also have an FRD notice.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M165"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M165"/>
   <xsl:template match="@*|node()" priority="-2" mode="M165">
      <xsl:apply-templates select="*" mode="M165"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00137-->


	<!--RULE -->
<xsl:template match="*[@ism:noticeType]" priority="1000" mode="M166">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:noticeType]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE) or ./@ism:excludeFromRollup=true()) then true() else                      if(index-of(tokenize(string(./@ism:noticeType), ' '), 'IMC')&gt;0 and not(./@ism:excludeFromRollup=true()))                         then index-of($partDisseminationControls_tok, 'IMC')&gt;0                         else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE) or ./@ism:excludeFromRollup=true()) then true() else if(index-of(tokenize(string(./@ism:noticeType), ' '), 'IMC')&gt;0 and not(./@ism:excludeFromRollup=true())) then index-of($partDisseminationControls_tok, 'IMC')&gt;0 else true()">
               <xsl:attribute name="id">ISM-00137</xsl:attribute>
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> 
            [ISM-ID-00137][Warning] If ISM_CAPCO_RESOURCE and:
            1. No element without ism:excludeFromRollup=true() in the document has the attribute disseminationControls containing [IMC]
            AND
            2. Any element without ism:excludeFromRollup=true() in the document has the attribute notice containing [IMC]
            
            Human Readable: USA documents containing IMC data must also have an IMC notice.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M166"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M166"/>
   <xsl:template match="@*|node()" priority="-2" mode="M166">
      <xsl:apply-templates select="*" mode="M166"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00138-->


	<!--RULE -->
<xsl:template match="*[@ism:noticeType]" priority="1000" mode="M167">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:noticeType]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE) or ./@ism:excludeFromRollup=true()) then true() else              if(index-of(tokenize(string(./@ism:noticeType), ' '), 'DS')&gt;0 and not(./@ism:excludeFromRollup=true()))                 then index-of($partNonICmarkings_tok, 'DS')&gt;0                 else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE) or ./@ism:excludeFromRollup=true()) then true() else if(index-of(tokenize(string(./@ism:noticeType), ' '), 'DS')&gt;0 and not(./@ism:excludeFromRollup=true())) then index-of($partNonICmarkings_tok, 'DS')&gt;0 else true()">
               <xsl:attribute name="id">ISM-00138</xsl:attribute>
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> 
            [ISM-ID-00138][Warning] If ISM_CAPCO_RESOURCE and:
            1. No element without ism:excludeFromRollup=true() in the document has the attribute nonICmarkings containing [DS]
            AND
            2. Any element without ism:excludeFromRollup=true() in the document has the attribute notice containing [DS]
            
            Human Readable: USA documents containing DS data must also have a DS notice.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M167"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M167"/>
   <xsl:template match="@*|node()" priority="-2" mode="M167">
      <xsl:apply-templates select="*" mode="M167"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00139-->


	<!--RULE -->
<xsl:template match="*[@ism:noticeType]" priority="1000" mode="M168">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:noticeType]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE) or ./@ism:excludeFromRollup=true()) then true() else              if(index-of(tokenize(string(./@ism:noticeType), ' '), 'FISA')&gt;0 and not(./@ism:excludeFromRollup=true()))                 then index-of($partDisseminationControls_tok, 'FISA')&gt;0                 else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE) or ./@ism:excludeFromRollup=true()) then true() else if(index-of(tokenize(string(./@ism:noticeType), ' '), 'FISA')&gt;0 and not(./@ism:excludeFromRollup=true())) then index-of($partDisseminationControls_tok, 'FISA')&gt;0 else true()">
               <xsl:attribute name="id">ISM-00139</xsl:attribute>
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> 
            [ISM-ID-00139][Warning] If ISM_CAPCO_RESOURCE and:
            1. No element without ism:excludeFromRollup=true() in the document has the attribute disseminationControls containing [FISA]
            AND
            2. Any element without ism:excludeFromRollup=true() in the document has the attribute notice containing [FISA]
            
            Human Readable: USA documents containing FISA data must also have an FISA notice.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M168"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M168"/>
   <xsl:template match="@*|node()" priority="-2" mode="M168">
      <xsl:apply-templates select="*" mode="M168"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00150-->


	<!--RULE -->
<xsl:template match="*[@ism:nonICmarkings]" priority="1000" mode="M169">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:nonICmarkings]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE) or ./@ism:excludeFromRollup=true()) then true() else              if(generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)) then true() else             if(index-of(tokenize(string(./@ism:nonICmarkings), ' '), 'LES')&gt;0)              then index-of($partNotice_tok, 'LES')&gt;0             else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE) or ./@ism:excludeFromRollup=true()) then true() else if(generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)) then true() else if(index-of(tokenize(string(./@ism:nonICmarkings), ' '), 'LES')&gt;0) then index-of($partNotice_tok, 'LES')&gt;0 else true()">
               <xsl:attribute name="id">ISM-00150</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00150][Error] If ISM_CAPCO_RESOURCE and:
            1. Any element meeting ISM_CONTRIBUTES in the document has the attribute nonICmarkings containing [LES]
            AND
            2. No element meeting ISM_CONTRIBUTES in the document has notice containing [LES]
            
            Human Readable: USA documents containing LES data must also have an LES notice. 
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M169"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M169"/>
   <xsl:template match="@*|node()" priority="-2" mode="M169">
      <xsl:apply-templates select="*" mode="M169"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00151-->


	<!--RULE -->
<xsl:template match="*[@ism:noticeType]" priority="1000" mode="M170">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:noticeType]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE) or ./@ism:excludeFromRollup=true()) then true() else             if(index-of(tokenize(string(./@ism:noticeType), ' '), 'LES')&gt;0 and not(./@ism:excludeFromRollup=true()))                 then index-of($partNonICmarkings_tok, 'LES')&gt;0                 else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE) or ./@ism:excludeFromRollup=true()) then true() else if(index-of(tokenize(string(./@ism:noticeType), ' '), 'LES')&gt;0 and not(./@ism:excludeFromRollup=true())) then index-of($partNonICmarkings_tok, 'LES')&gt;0 else true()">
               <xsl:attribute name="id">ISM-00151</xsl:attribute>
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> 
            [ISM-ID-00151][Warning] If ISM_CAPCO_RESOURCE and:
            1. No element without ism:excludeFromRollup=true() in the document has the attribute nonICmarkings containing [LES]
            AND
            2. Any element without ism:excludeFromRollup=true() in the document has the attribute notice containing [LES]
            
            Human Readable: USA documents containing LES data must also have an LES notice. 
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M170"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M170"/>
   <xsl:template match="@*|node()" priority="-2" mode="M170">
      <xsl:apply-templates select="*" mode="M170"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00152-->


	<!--RULE -->
<xsl:template match="*[@ism:nonICmarkings]" priority="1000" mode="M171">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:nonICmarkings]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE) or ./@ism:excludeFromRollup=true()) then true() else              if(generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)) then true() else             if(index-of(tokenize(string(./@ism:nonICmarkings), ' '), 'LES-NF')&gt;0)              then index-of($partNotice_tok, 'LES-NF')&gt;0             else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE) or ./@ism:excludeFromRollup=true()) then true() else if(generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)) then true() else if(index-of(tokenize(string(./@ism:nonICmarkings), ' '), 'LES-NF')&gt;0) then index-of($partNotice_tok, 'LES-NF')&gt;0 else true()">
               <xsl:attribute name="id">ISM-00152</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00152][Error] If ISM_CAPCO_RESOURCE and:
            1. Any element meeting ISM_CONTRIBUTES in the document has the attribute nonICmarkings containing [LES-NF]
            AND
            2. No element meeting ISM_CONTRIBUTES in the document has notice containing [LES-NF]
            
            Human Readable: USA documents containing LES-NF data must also have an LES-NF notice. 
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M171"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M171"/>
   <xsl:template match="@*|node()" priority="-2" mode="M171">
      <xsl:apply-templates select="*" mode="M171"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00153-->


	<!--RULE -->
<xsl:template match="*[@ism:noticeType]" priority="1000" mode="M172">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:noticeType]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE) or ./@ism:excludeFromRollup=true()) then true() else              if(index-of(tokenize(string(./@ism:noticeType), ' '), 'LES-NF')&gt;0 and not(./@ism:excludeFromRollup=true()))             then index-of($partNonICmarkings_tok, 'LES-NF')&gt;0             else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE) or ./@ism:excludeFromRollup=true()) then true() else if(index-of(tokenize(string(./@ism:noticeType), ' '), 'LES-NF')&gt;0 and not(./@ism:excludeFromRollup=true())) then index-of($partNonICmarkings_tok, 'LES-NF')&gt;0 else true()">
               <xsl:attribute name="id">ISM-00153</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> 
            [ISM-ID-00153][Error] If ISM_CAPCO_RESOURCE and:
            1. No element without ism:excludeFromRollup=true() in the document has the attribute nonICmarkings containing [LES-NF]
            AND
            2. Any element without ism:excludeFromRollup=true() in the document has the attribute notice containing [LES-NF]
            
            Human Readable: USA documents containing LES-NF data must also have an LES-NF notice.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M172"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M172"/>
   <xsl:template match="@*|node()" priority="-2" mode="M172">
      <xsl:apply-templates select="*" mode="M172"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00156-->


	<!--RULE -->
<xsl:template match="*[@ism:noticeType and $ISM_CAPCO_RESOURCE]" priority="1000" mode="M173">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:noticeType and $ISM_CAPCO_RESOURCE]"/>
      <xsl:variable name="noticeTok" select="normalize-space(string(./@ism:noticeType))"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(index-of($noticeTok, 'DoD-Dist-B')&gt;0 or             index-of($noticeTok, 'DoD-Dist-C')&gt;0 or             index-of($noticeTok, 'DoD-Dist-D')&gt;0 or             index-of($noticeTok, 'DoD-Dist-E')&gt;0 or             index-of($noticeTok, 'DoD-Dist-F')&gt;0 or             index-of($noticeTok, 'DoD-Dist-X')&gt;0)              then (./@ism:noticeDate and index-of($partPocType_tok,$noticeTok)&gt;0)             else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(index-of($noticeTok, 'DoD-Dist-B')&gt;0 or index-of($noticeTok, 'DoD-Dist-C')&gt;0 or index-of($noticeTok, 'DoD-Dist-D')&gt;0 or index-of($noticeTok, 'DoD-Dist-E')&gt;0 or index-of($noticeTok, 'DoD-Dist-F')&gt;0 or index-of($noticeTok, 'DoD-Dist-X')&gt;0) then (./@ism:noticeDate and index-of($partPocType_tok,$noticeTok)&gt;0) else true()">
               <xsl:attribute name="id">ISM-00156</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> 
            [ISM-ID-00156][Error] DoD distribution statements B, C, D ,E ,F, and X all require a Date and a POC.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M173"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M173"/>
   <xsl:template match="@*|node()" priority="-2" mode="M173">
      <xsl:apply-templates select="*" mode="M173"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00157-->


	<!--RULE -->
<xsl:template match="*[@ism:noticeType]" priority="1000" mode="M174">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:noticeType]"/>
      <xsl:variable name="noticeTok" select="tokenize(string(./@ism:noticeType), ' ')"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else              if(                 count(                     (if(index-of($noticeTok, 'DoD-Dist-B')&gt;0) then 1 else null,                      if(index-of($noticeTok, 'DoD-Dist-C')&gt;0) then 1 else null,                      if(index-of($noticeTok, 'DoD-Dist-D')&gt;0) then 1 else null,                      if(index-of($noticeTok, 'DoD-Dist-E')&gt;0) then 1 else null)                 )=0             )                  then true()                  else ./@ism:noticeReason             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if( count( (if(index-of($noticeTok, 'DoD-Dist-B')&gt;0) then 1 else null, if(index-of($noticeTok, 'DoD-Dist-C')&gt;0) then 1 else null, if(index-of($noticeTok, 'DoD-Dist-D')&gt;0) then 1 else null, if(index-of($noticeTok, 'DoD-Dist-E')&gt;0) then 1 else null) )=0 ) then true() else ./@ism:noticeReason">
               <xsl:attribute name="id">ISM-00157</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> 
            [ISM-ID-00157][Error] DoD distribution statements B, C, D , or E  all require a reason.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M174"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M174"/>
   <xsl:template match="@*|node()" priority="-2" mode="M174">
      <xsl:apply-templates select="*" mode="M174"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00158-->


	<!--RULE -->
<xsl:template match="*[@ism:resourceElement=true()]" priority="1000" mode="M175">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:resourceElement=true()]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else              if(not($ISM_DOD5230_24_APPLIES)) then true() else             if(./@ism:classification='U') then true() else             if(                count(                    (if(index-of($bannerNotice_tok, 'DoD-Dist-B')&gt;0) then 1 else null,                     if(index-of($bannerNotice_tok, 'DoD-Dist-C')&gt;0) then 1 else null,                     if(index-of($bannerNotice_tok, 'DoD-Dist-D')&gt;0) then 1 else null,                     if(index-of($bannerNotice_tok, 'DoD-Dist-E')&gt;0) then 1 else null,                     if(index-of($bannerNotice_tok, 'DoD-Dist-F')&gt;0) then 1 else null)                )=0             ) then false()                else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if(not($ISM_DOD5230_24_APPLIES)) then true() else if(./@ism:classification='U') then true() else if( count( (if(index-of($bannerNotice_tok, 'DoD-Dist-B')&gt;0) then 1 else null, if(index-of($bannerNotice_tok, 'DoD-Dist-C')&gt;0) then 1 else null, if(index-of($bannerNotice_tok, 'DoD-Dist-D')&gt;0) then 1 else null, if(index-of($bannerNotice_tok, 'DoD-Dist-E')&gt;0) then 1 else null, if(index-of($bannerNotice_tok, 'DoD-Dist-F')&gt;0) then 1 else null) )=0 ) then false() else true()">
               <xsl:attribute name="id">ISM-00158</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> 
            [ISM-ID-00158][Error] All classified documents that claim compliance with DoD5230.24 must use one of DoD 
            distribution statements B, C, D, E, or F.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M175"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M175"/>
   <xsl:template match="@*|node()" priority="-2" mode="M175">
      <xsl:apply-templates select="*" mode="M175"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00159-->


	<!--RULE -->
<xsl:template match="*[@ism:noticeType]" priority="1000" mode="M176">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:noticeType]"/>
      <xsl:variable name="noticeTok" select="tokenize(string(./@ism:noticeType), ' ')"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else              if($bannerClassification='U') then true() else             not(index-of($noticeTok, 'DoD-Dist-A')&gt;0)             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if($bannerClassification='U') then true() else not(index-of($noticeTok, 'DoD-Dist-A')&gt;0)">
               <xsl:attribute name="id">ISM-00159</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> 
            [ISM-ID-00159][Error] Distribution statement A (Public Release) is forbidden on classified documents.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M176"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M176"/>
   <xsl:template match="@*|node()" priority="-2" mode="M176">
      <xsl:apply-templates select="*" mode="M176"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00160-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]" priority="1000"
                 mode="M177">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else              if(index-of($bannerNotice_tok, 'DoD-Dist-A')&gt;0) then             count(                 (if(index-of($bannerDisseminationControls_tok, 'FOUO')&gt;0) then 1 else null,                  if(index-of($bannerDisseminationControls_tok, 'PR')&gt;0) then 1 else null,                  if(index-of($bannerAtomicEnergyMarkings_tok, 'DCNI')&gt;0) then 1 else null,                  if(index-of($bannerAtomicEnergyMarkings_tok, 'UCNI')&gt;0) then 1 else null,                  if(index-of($bannerDisseminationControls_tok, 'DSEN')&gt;0) then 1 else null,                  if(index-of($bannerDisseminationControls_tok, 'FISA')&gt;0) then 1 else null)             )=0 else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if(index-of($bannerNotice_tok, 'DoD-Dist-A')&gt;0) then count( (if(index-of($bannerDisseminationControls_tok, 'FOUO')&gt;0) then 1 else null, if(index-of($bannerDisseminationControls_tok, 'PR')&gt;0) then 1 else null, if(index-of($bannerAtomicEnergyMarkings_tok, 'DCNI')&gt;0) then 1 else null, if(index-of($bannerAtomicEnergyMarkings_tok, 'UCNI')&gt;0) then 1 else null, if(index-of($bannerDisseminationControls_tok, 'DSEN')&gt;0) then 1 else null, if(index-of($bannerDisseminationControls_tok, 'FISA')&gt;0) then 1 else null) )=0 else true()">
               <xsl:attribute name="id">ISM-00160</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> 
            [ISM-ID-00160][Error] Distribution statement A (Public Release) is 
            incompatible with [FOUO], [PR], [DCNI], [UCNI], [DSEN], OR [FISA].
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M177"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M177"/>
   <xsl:template match="@*|node()" priority="-2" mode="M177">
      <xsl:apply-templates select="*" mode="M177"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00161-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]" priority="1000"
                 mode="M178">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else              if(index-of($bannerNotice_tok, 'DoD-Dist-A')&gt;0) then             count(                (if(index-of($bannerNonICmarkings_tok, 'SINFO')&gt;0) then 1 else null,                 if(index-of($bannerNonICmarkings_tok, 'XD')&gt;0) then 1 else null,                 if(index-of($bannerNonICmarkings_tok, 'ND')&gt;0) then 1 else null,                 if(index-of($bannerNonICmarkings_tok, 'SBU')&gt;0) then 1 else null,                 if(index-of($bannerNonICmarkings_tok, 'SBU-NF')&gt;0) then 1 else null,                 if(index-of($bannerNonICmarkings_tok, 'LES')&gt;0) then 1 else null,                 if(index-of($bannerNonICmarkings_tok, 'LES-NF')&gt;0) then 1 else null)             )=0 else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if(index-of($bannerNotice_tok, 'DoD-Dist-A')&gt;0) then count( (if(index-of($bannerNonICmarkings_tok, 'SINFO')&gt;0) then 1 else null, if(index-of($bannerNonICmarkings_tok, 'XD')&gt;0) then 1 else null, if(index-of($bannerNonICmarkings_tok, 'ND')&gt;0) then 1 else null, if(index-of($bannerNonICmarkings_tok, 'SBU')&gt;0) then 1 else null, if(index-of($bannerNonICmarkings_tok, 'SBU-NF')&gt;0) then 1 else null, if(index-of($bannerNonICmarkings_tok, 'LES')&gt;0) then 1 else null, if(index-of($bannerNonICmarkings_tok, 'LES-NF')&gt;0) then 1 else null) )=0 else true()">
               <xsl:attribute name="id">ISM-00161</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> 
            [ISM-ID-00161][Error] Distribution statement A (Public Release) is incompatible with [SINFO], [XD], [ND], [SBU], [SBU-NF], [LES], OR [LES-NF].
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M178"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M178"/>
   <xsl:template match="@*|node()" priority="-2" mode="M178">
      <xsl:apply-templates select="*" mode="M178"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00001-->


	<!--RULE -->
<xsl:template match="*[@ism:ownerProducer]" priority="1000" mode="M179">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:ownerProducer]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="normalize-space(string(./@ism:ownerProducer))!=''"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="normalize-space(string(./@ism:ownerProducer))!=''">
               <xsl:attribute name="id">ISM-00001</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00001][Error] The attribute ownerProducer, when it exists, must have
            a non-null value.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M179"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M179"/>
   <xsl:template match="@*|node()" priority="-2" mode="M179">
      <xsl:apply-templates select="*" mode="M179"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00099-->


	<!--RULE -->
<xsl:template match="*[@ism:ownerProducer]" priority="1000" mode="M180">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:ownerProducer]"/>
      <xsl:variable name="opTok" select="tokenize(string(./@ism:ownerProducer),' ')"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else             not(index-of($opTok,'FGI')&gt;0 and count($opTok)&gt;1)             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else not(index-of($opTok,'FGI')&gt;0 and count($opTok)&gt;1)">
               <xsl:attribute name="id">ISM-00099</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00099][Error] If ISM_CAPCO_RESOURCE attribute ownerProducer contains [FGI], 
            it must be the only value.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M180"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M180"/>
   <xsl:template match="@*|node()" priority="-2" mode="M180">
      <xsl:apply-templates select="*" mode="M180"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00100-->


	<!--RULE -->
<xsl:template match="*[@ism:ownerProducer]" priority="1000" mode="M181">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:ownerProducer]"/>
      <xsl:variable name="errMsg_AlphabeticalOrder"
                    select="'              [ISM-ID-00100][Error] If ISM_CAPCO_RESOURCE and attribute ownerProducer is specified,               then each of its values must be ordered in accordance with CVEnumISMOwnerProducer.xml.              '"/>
      <xsl:variable name="dataFileElems" select="$ownerProducerList"/>
      <xsl:variable name="attrValues" select="./@ism:ownerProducer"/>
      <xsl:variable name="attrValueTokens" select="tokenize(string($attrValues),' ')"/>
      <xsl:variable name="convertStrToNum"
                    select="              for $token in $attrValueTokens return                 number(string-join(                    for $index in 1 to string-length($token) return                       for $char in substring($token, $index, 1) return                          if (contains(string('0123456789'), $char)) then                             $char                          else if (contains(string('ABCDEFGHI'), $char)) then                             translate(string($char), 'ABCDEFGHI', '123456789')                          else if (contains(string('JKLMNOPQRS'), $char)) then                             concat('1', translate(string($char), 'JKLMNOPQRS', '0123456789'))                          else if (contains(string('TUVWXYZ'), $char)) then                             concat('2', translate(string($char), 'TUVWXYZ', '0123456'))                          else '0'                 , ''))              "/>
      <xsl:variable name="orderNums"
                    select="              for $token in $attrValueTokens return                  if ($dataFileElems[matches($token,concat('^',text(),'$'))]) then                     count(($dataFileElems[matches($token,concat('^',text(),'$'))])/preceding::*) + 1                 else -1"/>
      <xsl:variable name="sortedOrderNums"
                    select="              for $index in distinct-values(for $token in $orderNums return index-of($orderNums,$token)) return                  if($index = 1 or $orderNums[$index] &gt; $orderNums[$index - 1]) then 1                 else if ($orderNums[$index] &lt; $orderNums[$index - 1]) then 0                 else                    if (matches($attrValueTokens[$index], '[0-9]') or matches($attrValueTokens[$index - 1], '[0-9]')) then                       if ($convertStrToNum[$index - 1] &gt; $convertStrToNum[$index]) then 0                       else 2                    else                         if (compare($attrValueTokens[$index - 1],$attrValueTokens[$index])=1) then 0                       else 2              "/>
      <xsl:variable name="hasUnsorted" select="count(index-of($sortedOrderNums,0)) &gt; 0"/>
      <xsl:variable name="unsortedValues"
                    select="              if ($hasUnsorted) then                 distinct-values(                    for $token in index-of($sortedOrderNums,0) return                       $attrValueTokens[$token]                  )              else null              "/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not($hasUnsorted)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($hasUnsorted)">
               <xsl:attribute name="id">ISM-00100</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="$errMsg_AlphabeticalOrder"/>
                  <xsl:text/>
             The following values are out of order [<xsl:text/>
                  <xsl:value-of select="$unsortedValues"/>
                  <xsl:text/>] for [<xsl:text/>
                  <xsl:value-of select="$attrValueTokens"/>
                  <xsl:text/>] </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M181"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M181"/>
   <xsl:template match="@*|node()" priority="-2" mode="M181">
      <xsl:apply-templates select="*" mode="M181"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00219-->


	<!--RULE -->
<xsl:template match="*[@ism:ownerProducer and not(generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)) and not(@ism:excludeFromRollup=true())]"
                 priority="1000"
                 mode="M182">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:ownerProducer and not(generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)) and not(@ism:excludeFromRollup=true())]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(index-of(./@ism:ownerProducer,'FGI')&gt;0)             then index-of(./@ism:FGIsourceProtected,'FGI')&gt;0             else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(index-of(./@ism:ownerProducer,'FGI')&gt;0) then index-of(./@ism:FGIsourceProtected,'FGI')&gt;0 else true()">
               <xsl:attribute name="id">ISM-00219</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00219][Error] If element meets ISM_CONTRIBUTES and attribute ownerProducer contains [FGI], 
            then FGIsourceProtected must have a value of [FGI].
            
            Human Readable: Any non-resource element that contributes to the document's banner roll-up and has
            FOREIGN GOVERNMENT INFORMATION (FGI) must also specify attribute FGIsourceProtected with token FGI.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M182"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M182"/>
   <xsl:template match="@*|node()" priority="-2" mode="M182">
      <xsl:apply-templates select="*" mode="M182"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00224-->


	<!--RULE -->
<xsl:template match="*[generate-id(.)=generate-id($ISM_RESOURCE_ELEMENT)         and $ISM_CAPCO_RESOURCE          and $ISM_RESOURCE_CREATE_DATE         and $ISM_RESOURCE_CREATE_DATE &gt; $ISM_ORCON_POC_DATE         and $bannerDisseminationControls_tok='OC'         ]"
                 priority="1000"
                 mode="M183">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.)=generate-id($ISM_RESOURCE_ELEMENT)         and $ISM_CAPCO_RESOURCE          and $ISM_RESOURCE_CREATE_DATE         and $ISM_RESOURCE_CREATE_DATE &gt; $ISM_ORCON_POC_DATE         and $bannerDisseminationControls_tok='OC'         ]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="                 $partPocType_tok='ORCON'             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$partPocType_tok='ORCON'">
               <xsl:attribute name="id">ISM-00224</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00224][Error] If ISM_CAPCO_RESOURCE and any element meeting ISM_CONTRIBUTES 
            in the document has the attribute disseminationControls containing [OC], then the 
            attribute @ism:pocType with value [ORCON] must be specified on some element in the document. 
            
            Human Readable: After March 11, 2011, USA documents containing ORIGINATOR CONTROLLED 
            data must specify a point-of-contact to whom adjudication decisions about 
            those data can be directed. 
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M183"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M183"/>
   <xsl:template match="@*|node()" priority="-2" mode="M183">
      <xsl:apply-templates select="*" mode="M183"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00032-->


	<!--RULE -->
<xsl:template match="*[@ism:releasableTo and $ISM_CAPCO_RESOURCE]" priority="1000"
                 mode="M184">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:releasableTo and $ISM_CAPCO_RESOURCE]"/>
      <xsl:variable name="dissemTok" select="tokenize(string(./@ism:disseminationControls),' ')"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             index-of($dissemTok,'EYES')&gt;0 or index-of($dissemTok,'REL')&gt;0             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="index-of($dissemTok,'EYES')&gt;0 or index-of($dissemTok,'REL')&gt;0">
               <xsl:attribute name="id">ISM-00032</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00032][Error] If ISM_CAPCO_RESOURCE and attribute 
            disseminationControls is not specified, or is specified and does not contain the name token 
            [REL] or [EYES], then attribute releasableTo must not be specified.
            
            Human Readable: USA documents must only specify to which countries it is 
            authorized for release if dissemination information contains REL TO or EYES ONLY data. 
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M184"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M184"/>
   <xsl:template match="@*|node()" priority="-2" mode="M184">
      <xsl:apply-templates select="*" mode="M184"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00041-->


	<!--RULE -->
<xsl:template match="*[@ism:releasableTo]" priority="1000" mode="M185">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:releasableTo]"/>
      <xsl:variable name="errMsg_AlphabeticalOrder"
                    select="'             [ISM-ID-00041][Error] If ISM_CAPCO_RESOURCE and attribute releasableTo is specified,              then each of its values must be ordered in accordance with CVEnumISMRelTo.xml.         '"/>
      <xsl:variable name="dataFileElems" select="$releasableToList"/>
      <xsl:variable name="attrValues" select="./@ism:releasableTo"/>
      <xsl:variable name="attrValueTokens" select="tokenize(string($attrValues),' ')"/>
      <xsl:variable name="convertStrToNum"
                    select="             for $token in $attrValueTokens return                 number(string-join(                     for $index in 1 to string-length($token) return                         for $char in substring($token, $index, 1) return                             if (contains(string('0123456789'), $char)) then                                 $char                             else if (contains(string('ABCDEFGHI'), $char)) then                                 translate(string($char), 'ABCDEFGHI', '123456789')                             else if (contains(string('JKLMNOPQRS'), $char)) then                                 concat('1', translate(string($char), 'JKLMNOPQRS', '0123456789'))                             else if (contains(string('TUVWXYZ'), $char)) then                                 concat('2', translate(string($char), 'TUVWXYZ', '0123456'))                             else '0'                 , ''))             "/>
      <xsl:variable name="orderNums"
                    select="             for $token in $attrValueTokens return                  if ($dataFileElems[matches($token,concat('^',text(),'$'))]) then                      count(($dataFileElems[matches($token,concat('^',text(),'$'))])/preceding::*) + 1                 else -1"/>
      <xsl:variable name="sortedOrderNums"
                    select="             for $index in distinct-values(for $token in $orderNums return index-of($orderNums,$token)) return                  if($index = 1 or $orderNums[$index] &gt; $orderNums[$index - 1]) then 1                 else if ($orderNums[$index] &lt; $orderNums[$index - 1]) then 0                 else                     if (matches($attrValueTokens[$index], '[0-9]') or matches($attrValueTokens[$index - 1], '[0-9]')) then                         if ($convertStrToNum[$index - 1] &gt; $convertStrToNum[$index]) then 0                         else 2                     else                           if (compare($attrValueTokens[$index - 1],$attrValueTokens[$index])=1) then 0                         else 2             "/>
      <xsl:variable name="hasUnsorted" select="count(index-of($sortedOrderNums,0)) &gt; 0"/>
      <xsl:variable name="unsortedValues"
                    select="             if ($hasUnsorted) then                 distinct-values(                     for $token in index-of($sortedOrderNums,0) return                         $attrValueTokens[$token]                  )             else null             "/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not($hasUnsorted)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($hasUnsorted)">
               <xsl:attribute name="id">ISM-00041</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="$errMsg_AlphabeticalOrder"/>
                  <xsl:text/>
            The following values are out of order [<xsl:text/>
                  <xsl:value-of select="$unsortedValues"/>
                  <xsl:text/>] for [<xsl:text/>
                  <xsl:value-of select="$attrValueTokens"/>
                  <xsl:text/>] </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M185"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M185"/>
   <xsl:template match="@*|node()" priority="-2" mode="M185">
      <xsl:apply-templates select="*" mode="M185"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00214-->


	<!--RULE -->
<xsl:template match="*[@ism:releasableTo]" priority="1000" mode="M186">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:releasableTo]"/>
      <xsl:variable name="dissemTok" select="tokenize(string(./@ism:disseminationControls),' ')"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else             index-of(tokenize(string(./@ism:releasableTo),' '),'USA')=1             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else index-of(tokenize(string(./@ism:releasableTo),' '),'USA')=1">
               <xsl:attribute name="id">ISM-00032</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00214][Error] If ISM_CAPCO_RESOURCE then attribute 
            releasableTo must start with [USA].
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M186"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M186"/>
   <xsl:template match="@*|node()" priority="-2" mode="M186">
      <xsl:apply-templates select="*" mode="M186"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00013-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]" priority="1000"
                 mode="M187">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_NSI_EO_APPLIES)) then true()              else if(./@ism:classifiedBy or ./@ism:derivedFrom) then true()              else false()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_NSI_EO_APPLIES)) then true() else if(./@ism:classifiedBy or ./@ism:derivedFrom) then true() else false()">
               <xsl:attribute name="id">ISM-00013</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00013][Error] Documents under E.O. 13526 must have classification authority block information.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M187"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M187"/>
   <xsl:template match="@*|node()" priority="-2" mode="M187">
      <xsl:apply-templates select="*" mode="M187"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00014-->


	<!--RULE -->
<xsl:template match="//*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"
                 priority="1000"
                 mode="M188">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_NSI_EO_APPLIES)) then true() else             if(./@ism:declassDate or ./@ism:declassEvent or ./@ism:declassException)                 then true()              else false()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_NSI_EO_APPLIES)) then true() else if(./@ism:declassDate or ./@ism:declassEvent or ./@ism:declassException) then true() else false()">
               <xsl:attribute name="id">ISM-00014</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00014][Error] If ISM_NSI_EO_APPLIES then one or more of the following 
            attributes: declassDate, declassEvent, or declassException must be specified on the ISM_RESOURCE_ELEMENT.
            
            Human Readable: Documents under E.O. 13526 must have declassification instructions included in the 
            classification authority block information.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M188"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M188"/>
   <xsl:template match="@*|node()" priority="-2" mode="M188">
      <xsl:apply-templates select="*" mode="M188"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00056-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]" priority="1000"
                 mode="M189">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else             if(not(./@ism:classification='U')) then true() else              count(                 for $each in $partTags return                     if(contains(string($each/@ism:ownerProducer), 'USA') and                         not($each/@ism:classification='U'))                           then $each                           else null             )=0             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if(not(./@ism:classification='U')) then true() else count( for $each in $partTags return if(contains(string($each/@ism:ownerProducer), 'USA') and not($each/@ism:classification='U')) then $each else null )=0">
               <xsl:attribute name="id">ISM-00056</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00056][Error] USA UNCLASSIFIED documents can't have TOP SECRET, SECRET, or CONFIDENTIAL data.    
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M189"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M189"/>
   <xsl:template match="@*|node()" priority="-2" mode="M189">
      <xsl:apply-templates select="*" mode="M189"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00057-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]" priority="1000"
                 mode="M190">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else             if(not(./@ism:classification='U')) then true() else             not(index-of($partClassification_tok, 'R')&gt;0)             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if(not(./@ism:classification='U')) then true() else not(index-of($partClassification_tok, 'R')&gt;0)">
               <xsl:attribute name="id">ISM-00057</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00057][Error] USA UNCLASSIFIED documents cannot have RESTRICTED data. 
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M190"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M190"/>
   <xsl:template match="@*|node()" priority="-2" mode="M190">
      <xsl:apply-templates select="*" mode="M190"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00058-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]" priority="1000"
                 mode="M191">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else             if(not(./@ism:classification='C')) then true() else              count(                 for $each in $partTags return                     if(contains(string($each/@ism:ownerProducer), 'USA') and                         not($each/@ism:classification='U' or $each/@ism:classification='C') )                         then $each                         else null             )=0             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if(not(./@ism:classification='C')) then true() else count( for $each in $partTags return if(contains(string($each/@ism:ownerProducer), 'USA') and not($each/@ism:classification='U' or $each/@ism:classification='C') ) then $each else null )=0">
               <xsl:attribute name="id">ISM-00058</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00058][Error] USA CONFIDENTIAL documents can't have TOP SECRET or SECRET data.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M191"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M191"/>
   <xsl:template match="@*|node()" priority="-2" mode="M191">
      <xsl:apply-templates select="*" mode="M191"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00059-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]" priority="1000"
                 mode="M192">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else             if(not(./@ism:classification='S')) then true() else              count(                 for $each in $partTags return                     if(contains(string($each/@ism:ownerProducer), 'USA') and                         not($each/@ism:classification='U' or $each/@ism:classification='C'                            or $each/@ism:classification='S'))                         then $each                         else null             )=0             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if(not(./@ism:classification='S')) then true() else count( for $each in $partTags return if(contains(string($each/@ism:ownerProducer), 'USA') and not($each/@ism:classification='U' or $each/@ism:classification='C' or $each/@ism:classification='S')) then $each else null )=0">
               <xsl:attribute name="id">ISM-00059</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00059][Error] USA SECRET documents can't have TOP SECRET data.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M192"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M192"/>
   <xsl:template match="@*|node()" priority="-2" mode="M192">
      <xsl:apply-templates select="*" mode="M192"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00060-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]" priority="1000"
                 mode="M193">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else             if(index-of($partSCIcontrols_tok, 'SI') &gt; 0)                 then index-of($bannerSCIcontrols_tok, 'SI') &gt; 0                 else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if(index-of($partSCIcontrols_tok, 'SI') &gt; 0) then index-of($bannerSCIcontrols_tok, 'SI') &gt; 0 else true()">
               <xsl:attribute name="id">ISM-00060</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00060][Error] USA documents having SI data must have SI at the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M193"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M193"/>
   <xsl:template match="@*|node()" priority="-2" mode="M193">
      <xsl:apply-templates select="*" mode="M193"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00061-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]" priority="1000"
                 mode="M194">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else             if(index-of($partSCIcontrols_tok, 'SI-G') &gt; 0)                 then index-of($bannerSCIcontrols_tok, 'SI-G') &gt; 0                 else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if(index-of($partSCIcontrols_tok, 'SI-G') &gt; 0) then index-of($bannerSCIcontrols_tok, 'SI-G') &gt; 0 else true()">
               <xsl:attribute name="id">ISM-00061</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00061][Error] USA documents having SI-G data must have SI-G at the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M194"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M194"/>
   <xsl:template match="@*|node()" priority="-2" mode="M194">
      <xsl:apply-templates select="*" mode="M194"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00062-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]" priority="1000"
                 mode="M195">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else             if(index-of($partSCIcontrols_tok, 'TK') &gt; 0)                 then index-of($bannerSCIcontrols_tok, 'TK') &gt; 0                 else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if(index-of($partSCIcontrols_tok, 'TK') &gt; 0) then index-of($bannerSCIcontrols_tok, 'TK') &gt; 0 else true()">
               <xsl:attribute name="id">ISM-00062</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00062][Error] USA documents having TK data must have TK at the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M195"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M195"/>
   <xsl:template match="@*|node()" priority="-2" mode="M195">
      <xsl:apply-templates select="*" mode="M195"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00063-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]" priority="1000"
                 mode="M196">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else             if(index-of($partSCIcontrols_tok, 'HCS') &gt; 0)             then index-of($bannerSCIcontrols_tok, 'HCS') &gt; 0             else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if(index-of($partSCIcontrols_tok, 'HCS') &gt; 0) then index-of($bannerSCIcontrols_tok, 'HCS') &gt; 0 else true()">
               <xsl:attribute name="id">ISM-00063</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00063][Error] USA documents having HCS data must have HCS at the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M196"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M196"/>
   <xsl:template match="@*|node()" priority="-2" mode="M196">
      <xsl:apply-templates select="*" mode="M196"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00064-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]" priority="1000"
                 mode="M197">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else             if(not(empty($partFGIsourceOpen)))                  then ($bannerFGIsourceOpen                        or $bannerFGIsourceProtected)                  else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if(not(empty($partFGIsourceOpen))) then ($bannerFGIsourceOpen or $bannerFGIsourceProtected) else true()">
               <xsl:attribute name="id">ISM-00064</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00064][Error] USA documents having FGI Open data must have FGI Open or FGI Protected at the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M197"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M197"/>
   <xsl:template match="@*|node()" priority="-2" mode="M197">
      <xsl:apply-templates select="*" mode="M197"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00065-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]" priority="1000"
                 mode="M198">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else             if(not(empty($partFGIsourceProtected))) then $bannerFGIsourceProtected else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if(not(empty($partFGIsourceProtected))) then $bannerFGIsourceProtected else true()">
               <xsl:attribute name="id">ISM-00065</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00065][Error] USA documents having FGI Protected data must have FGI Protected at the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M198"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M198"/>
   <xsl:template match="@*|node()" priority="-2" mode="M198">
      <xsl:apply-templates select="*" mode="M198"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00066-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]" priority="1000"
                 mode="M199">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else             if(not($bannerClassification='U')) then true() else                 if(not(index-of($dcTagsFound,'FOUO')&gt;0)) then true() else                     index-of($partNonICmarkings_tok,'SBU')&gt;0                      or index-of($partNonICmarkings_tok,'SBU-NF')&gt;0                     or index-of($partNonICmarkings_tok,'LES')&gt;0                      or index-of($partNonICmarkings_tok,'LES-NF')&gt;0             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if(not($bannerClassification='U')) then true() else if(not(index-of($dcTagsFound,'FOUO')&gt;0)) then true() else index-of($partNonICmarkings_tok,'SBU')&gt;0 or index-of($partNonICmarkings_tok,'SBU-NF')&gt;0 or index-of($partNonICmarkings_tok,'LES')&gt;0 or index-of($partNonICmarkings_tok,'LES-NF')&gt;0">
               <xsl:attribute name="id">ISM-00066</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00066][Error] USA Unclassified documents having FOUO data and not having SBU, SBU-NF, LES, or LES-NF must have 
            FOUO at the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M199"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M199"/>
   <xsl:template match="@*|node()" priority="-2" mode="M199">
      <xsl:apply-templates select="*" mode="M199"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00067-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]" priority="1000"
                 mode="M200">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else             not(index-of($dcTagsFound,'OC') &gt; 0)             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else not(index-of($dcTagsFound,'OC') &gt; 0)">
               <xsl:attribute name="id">ISM-00067</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00067][Error] USA documents having ORCON data must have ORCON at the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M200"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M200"/>
   <xsl:template match="@*|node()" priority="-2" mode="M200">
      <xsl:apply-templates select="*" mode="M200"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00068-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]" priority="1000"
                 mode="M201">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else             not(index-of($dcTagsFound,'IMC') &gt; 0)             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else not(index-of($dcTagsFound,'IMC') &gt; 0)">
               <xsl:attribute name="id">ISM-00068</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00068][Error] USA documents having IMCON data must have IMCON at the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M201"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M201"/>
   <xsl:template match="@*|node()" priority="-2" mode="M201">
      <xsl:apply-templates select="*" mode="M201"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00070-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]" priority="1000"
                 mode="M202">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else             not(index-of($dcTagsFound,'NF') &gt; 0)             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else not(index-of($dcTagsFound,'NF') &gt; 0)">
               <xsl:attribute name="id">ISM-00070</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00070][Error] USA documents having NF data must have NF at the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M202"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M202"/>
   <xsl:template match="@*|node()" priority="-2" mode="M202">
      <xsl:apply-templates select="*" mode="M202"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00071-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]" priority="1000"
                 mode="M203">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else             not(index-of($dcTagsFound,'PR') &gt; 0)             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else not(index-of($dcTagsFound,'PR') &gt; 0)">
               <xsl:attribute name="id">ISM-00071</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00071][Error] USA documents having PROPIN data must have PROPIN at the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M203"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M203"/>
   <xsl:template match="@*|node()" priority="-2" mode="M203">
      <xsl:apply-templates select="*" mode="M203"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00072-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]" priority="1000"
                 mode="M204">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else             not(index-of($aeaTagsFound,'RD') &gt; 0)             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else not(index-of($aeaTagsFound,'RD') &gt; 0)">
               <xsl:attribute name="id">ISM-00072</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00072][Error] USA documents having Restricted Data (RD) must have RD at the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M204"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M204"/>
   <xsl:template match="@*|node()" priority="-2" mode="M204">
      <xsl:apply-templates select="*" mode="M204"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00073-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]" priority="1000"
                 mode="M205">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else             not(index-of($aeaTagsFound,'RD-CNWDI') &gt; 0)             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else not(index-of($aeaTagsFound,'RD-CNWDI') &gt; 0)">
               <xsl:attribute name="id">ISM-00073</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00073][Error] USA documents having Restricted CNWDI Data must have Restricted CNWDI Data at the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M205"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M205"/>
   <xsl:template match="@*|node()" priority="-2" mode="M205">
      <xsl:apply-templates select="*" mode="M205"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00074-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]" priority="1000"
                 mode="M206">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else             sum(               for $item in                  for $token in $partAtomicEnergyMarkings_tok return                   if(matches($token,'^RD-SG-[1-9][0-9]?$')) then $token else null                 return if(index-of($bannerAtomicEnergyMarkings_tok, $item)&gt;0) then 0 else 1             )=0             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else sum( for $item in for $token in $partAtomicEnergyMarkings_tok return if(matches($token,'^RD-SG-[1-9][0-9]?$')) then $token else null return if(index-of($bannerAtomicEnergyMarkings_tok, $item)&gt;0) then 0 else 1 )=0">
               <xsl:attribute name="id">ISM-00074</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00074][Error] USA documents having Restricted SIGMA-## Data must have the same Restricted SIGMA-## Data at the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M206"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M206"/>
   <xsl:template match="@*|node()" priority="-2" mode="M206">
      <xsl:apply-templates select="*" mode="M206"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00075-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]" priority="1000"
                 mode="M207">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else             not(index-of($aeaTagsFound,'FRD') &gt; 0)             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else not(index-of($aeaTagsFound,'FRD') &gt; 0)">
               <xsl:attribute name="id">ISM-00075</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00075][Error] USA documents having Formerly Restricted Data (FRD) must have FRD at the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M207"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M207"/>
   <xsl:template match="@*|node()" priority="-2" mode="M207">
      <xsl:apply-templates select="*" mode="M207"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00077-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]" priority="1000"
                 mode="M208">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else             sum(                 for $item in                      for $token in $partAtomicEnergyMarkings_tok return                         if(matches($token,'^FRD-SG-[1-9][0-9]?$')) then $token else null                 return if(index-of($bannerAtomicEnergyMarkings_tok, $item)&gt;0) then 0 else 1             )=0             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else sum( for $item in for $token in $partAtomicEnergyMarkings_tok return if(matches($token,'^FRD-SG-[1-9][0-9]?$')) then $token else null return if(index-of($bannerAtomicEnergyMarkings_tok, $item)&gt;0) then 0 else 1 )=0">
               <xsl:attribute name="id">ISM-00077</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00077][Error] USA documents having Formerly Restricted SIGMA-## Data must have the same Formerly Restricted SIGMA-## Data at 
            the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M208"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M208"/>
   <xsl:template match="@*|node()" priority="-2" mode="M208">
      <xsl:apply-templates select="*" mode="M208"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00078-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]" priority="1000"
                 mode="M209">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else             if(not($bannerClassification='U')) then true()                  else not(index-of($aeaTagsFound,'DCNI') &gt; 0)             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if(not($bannerClassification='U')) then true() else not(index-of($aeaTagsFound,'DCNI') &gt; 0)">
               <xsl:attribute name="id">ISM-00078</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00078][Error] Unclassified USA documents having DCNI Data must have DCNI at the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M209"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M209"/>
   <xsl:template match="@*|node()" priority="-2" mode="M209">
      <xsl:apply-templates select="*" mode="M209"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00079-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]" priority="1000"
                 mode="M210">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else             if(not($bannerClassification='U')) then true()                  else not(index-of($aeaTagsFound,'UCNI') &gt; 0)             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if(not($bannerClassification='U')) then true() else not(index-of($aeaTagsFound,'UCNI') &gt; 0)">
               <xsl:attribute name="id">ISM-00079</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00079][Error] Unclassified USA documents having UCNI Data must have UCNI at the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M210"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M210"/>
   <xsl:template match="@*|node()" priority="-2" mode="M210">
      <xsl:apply-templates select="*" mode="M210"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00080-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]" priority="1000"
                 mode="M211">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else             not(index-of($dcTagsFound,'DSEN') &gt; 0)             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else not(index-of($dcTagsFound,'DSEN') &gt; 0)">
               <xsl:attribute name="id">ISM-00080</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00080][Error] USA documents having DSEN Data must have DSEN at the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M211"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M211"/>
   <xsl:template match="@*|node()" priority="-2" mode="M211">
      <xsl:apply-templates select="*" mode="M211"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00081-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]" priority="1000"
                 mode="M212">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else             not(index-of($dcTagsFound,'FISA') &gt; 0)             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else not(index-of($dcTagsFound,'FISA') &gt; 0)">
               <xsl:attribute name="id">ISM-00081</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00081][Error] USA documents having FISA Data must have FISA at the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M212"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M212"/>
   <xsl:template match="@*|node()" priority="-2" mode="M212">
      <xsl:apply-templates select="*" mode="M212"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00082-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]" priority="1000"
                 mode="M213">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else             if(index-of($partNonICmarkings_tok, 'SC') &gt; 0)             then (index-of($bannerNonICmarkings_tok, 'SC') &gt; 0)             else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if(index-of($partNonICmarkings_tok, 'SC') &gt; 0) then (index-of($bannerNonICmarkings_tok, 'SC') &gt; 0) else true()">
               <xsl:attribute name="id">ISM-00082</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00082][Error] USA documents having SC Data must have SC at the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M213"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M213"/>
   <xsl:template match="@*|node()" priority="-2" mode="M213">
      <xsl:apply-templates select="*" mode="M213"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00083-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]" priority="1000"
                 mode="M214">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE) or not(matches(./@ism:classification,'^U$'))) then true() else             if(index-of($partNonICmarkings_tok, 'SINFO') &gt; 0)             then (index-of($bannerNonICmarkings_tok, 'SINFO') &gt; 0)             else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE) or not(matches(./@ism:classification,'^U$'))) then true() else if(index-of($partNonICmarkings_tok, 'SINFO') &gt; 0) then (index-of($bannerNonICmarkings_tok, 'SINFO') &gt; 0) else true()">
               <xsl:attribute name="id">ISM-00083</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00083][Error] USA documents having SINFO Data must have SINFO at the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M214"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M214"/>
   <xsl:template match="@*|node()" priority="-2" mode="M214">
      <xsl:apply-templates select="*" mode="M214"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00084-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]" priority="1000"
                 mode="M215">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else             if(index-of($partNonICmarkings_tok, 'DS') &gt; 0)             then (index-of($bannerNonICmarkings_tok, 'DS') &gt; 0)             else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if(index-of($partNonICmarkings_tok, 'DS') &gt; 0) then (index-of($bannerNonICmarkings_tok, 'DS') &gt; 0) else true()">
               <xsl:attribute name="id">ISM-00084</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00084][Error] USA documents having DS Data must have DS at the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M215"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M215"/>
   <xsl:template match="@*|node()" priority="-2" mode="M215">
      <xsl:apply-templates select="*" mode="M215"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00085-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]" priority="1000"
                 mode="M216">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else             if(index-of($partNonICmarkings_tok, 'XD') &gt; 0 and not(index-of($partNonICmarkings_tok, 'ND')&gt;0))             then index-of($bannerNonICmarkings_tok, 'XD') &gt; 0             else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if(index-of($partNonICmarkings_tok, 'XD') &gt; 0 and not(index-of($partNonICmarkings_tok, 'ND')&gt;0)) then index-of($bannerNonICmarkings_tok, 'XD') &gt; 0 else true()">
               <xsl:attribute name="id">ISM-00085</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00085][Error] USA documents having XD Data and not having ND must have XD at the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M216"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M216"/>
   <xsl:template match="@*|node()" priority="-2" mode="M216">
      <xsl:apply-templates select="*" mode="M216"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00086-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]" priority="1000"
                 mode="M217">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else             if(index-of($partNonICmarkings_tok, 'ND')&gt;0)             then index-of($bannerNonICmarkings_tok, 'ND') &gt; 0             else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if(index-of($partNonICmarkings_tok, 'ND')&gt;0) then index-of($bannerNonICmarkings_tok, 'ND') &gt; 0 else true()">
               <xsl:attribute name="id">ISM-00086</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00086][Error] USA documents having ND Data must have ND at the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M217"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M217"/>
   <xsl:template match="@*|node()" priority="-2" mode="M217">
      <xsl:apply-templates select="*" mode="M217"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00087-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]" priority="1000"
                 mode="M218">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else                 if(index-of($partNonICmarkings_tok, 'SBU-NF') &gt; 0 and not($bannerClassification='U'))                      then (index-of($bannerDisseminationControls_tok, 'NF') &gt; 0)                     else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if(index-of($partNonICmarkings_tok, 'SBU-NF') &gt; 0 and not($bannerClassification='U')) then (index-of($bannerDisseminationControls_tok, 'NF') &gt; 0) else true()">
               <xsl:attribute name="id">ISM-00087</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00087][Error] Classified USA documents having SBU-NF Data must have NF at the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M218"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M218"/>
   <xsl:template match="@*|node()" priority="-2" mode="M218">
      <xsl:apply-templates select="*" mode="M218"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00088-->


	<!--RULE -->
<xsl:template match="*[$ISM_CAPCO_RESOURCE                              and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                              and @ism:releasableTo]"
                 priority="1000"
                 mode="M219">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_CAPCO_RESOURCE                              and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                              and @ism:releasableTo]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="every $portion in $partTags                      satisfies ($portion/@ism:classification='U'                                  or $portion/@ism:releasableTo[normalize-space()])             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $portion in $partTags satisfies ($portion/@ism:classification='U' or $portion/@ism:releasableTo[normalize-space()])">
               <xsl:attribute name="id">ISM-00088</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00088][Error] USA documents having any classified portion that is not 
            Releasable cannot be REL at the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M219"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M219"/>
   <xsl:template match="@*|node()" priority="-2" mode="M219">
      <xsl:apply-templates select="*" mode="M219"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00090-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]" priority="1000"
                 mode="M220">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else                 if(sum(for $token in $partTags return                          if(contains(string($token/@ism:disseminationControls), 'REL'))                         then 1 else 0)                 ) then not(index-of($bannerDisseminationControls_tok, 'EYES')&gt;0)                 else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if(sum(for $token in $partTags return if(contains(string($token/@ism:disseminationControls), 'REL')) then 1 else 0) ) then not(index-of($bannerDisseminationControls_tok, 'EYES')&gt;0) else true()">
               <xsl:attribute name="id">ISM-00090</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00090][Error] USA documents with any portion that is REL must not be EYES at the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M220"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M220"/>
   <xsl:template match="@*|node()" priority="-2" mode="M220">
      <xsl:apply-templates select="*" mode="M220"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00104-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]" priority="1000"
                 mode="M221">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else                 if(index-of($partNonICmarkings_tok, 'SBU-NF') &gt; 0 and $bannerClassification='U')                  then (index-of($bannerNonICmarkings_tok, 'SBU-NF') &gt; 0)                 else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if(index-of($partNonICmarkings_tok, 'SBU-NF') &gt; 0 and $bannerClassification='U') then (index-of($bannerNonICmarkings_tok, 'SBU-NF') &gt; 0) else true()">
               <xsl:attribute name="id">ISM-00104</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00104][Error] Unclassified USA documents having SBU-NF must have SBU-NF at the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M221"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M221"/>
   <xsl:template match="@*|node()" priority="-2" mode="M221">
      <xsl:apply-templates select="*" mode="M221"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00105-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]" priority="1000"
                 mode="M222">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else                 if(index-of($partNonICmarkings_tok, 'SBU') &gt; 0 and $bannerClassification='U')                     then index-of($bannerNonICmarkings_tok, 'SBU') &gt; 0                     else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if(index-of($partNonICmarkings_tok, 'SBU') &gt; 0 and $bannerClassification='U') then index-of($bannerNonICmarkings_tok, 'SBU') &gt; 0 else true()">
               <xsl:attribute name="id">ISM-00105</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00105][Error] Unclassified USA documents having SBU must have SBU at the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M222"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M222"/>
   <xsl:template match="@*|node()" priority="-2" mode="M222">
      <xsl:apply-templates select="*" mode="M222"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00108-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]" priority="1000"
                 mode="M223">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else             if ($bannerClassification='TS' and not(string-length(normalize-space(string(./@ism:compilationReason)))&gt;0)) then                     index-of($partClassification_tok,'TS')&gt;0                     else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if ($bannerClassification='TS' and not(string-length(normalize-space(string(./@ism:compilationReason)))&gt;0)) then index-of($partClassification_tok,'TS')&gt;0 else true()">
               <xsl:attribute name="id">ISM-00108</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00108][Error] USA TS documents not using compilation must have TS data.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M223"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M223"/>
   <xsl:template match="@*|node()" priority="-2" mode="M223">
      <xsl:apply-templates select="*" mode="M223"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00109-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]" priority="1000"
                 mode="M224">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else             if ($bannerClassification='S' and not(string-length(normalize-space(string(./@ism:compilationReason)))&gt;0)) then                 index-of($partClassification_tok,'S')&gt;0                 else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if ($bannerClassification='S' and not(string-length(normalize-space(string(./@ism:compilationReason)))&gt;0)) then index-of($partClassification_tok,'S')&gt;0 else true()">
               <xsl:attribute name="id">ISM-00109</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00109][Error] USA S documents not using compilation must have S data.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M224"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M224"/>
   <xsl:template match="@*|node()" priority="-2" mode="M224">
      <xsl:apply-templates select="*" mode="M224"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00110-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]" priority="1000"
                 mode="M225">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else             if ($bannerClassification='C' and not(string-length(normalize-space(string(./@ism:compilationReason)))&gt;0)) then             index-of($partClassification_tok,'C')&gt;0             else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if ($bannerClassification='C' and not(string-length(normalize-space(string(./@ism:compilationReason)))&gt;0)) then index-of($partClassification_tok,'C')&gt;0 else true()">
               <xsl:attribute name="id">ISM-00110</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00110][Error] USA C documents not using compilation must have C data.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M225"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M225"/>
   <xsl:template match="@*|node()" priority="-2" mode="M225">
      <xsl:apply-templates select="*" mode="M225"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00111-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]" priority="1000"
                 mode="M226">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else                 if (index-of($bannerSCIcontrols_tok, 'SI')&gt;0 and not(string-length(normalize-space(string(./@ism:compilationReason)))&gt;0)) then                 index-of($partSCIcontrols_tok,'SI')&gt;0                 else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if (index-of($bannerSCIcontrols_tok, 'SI')&gt;0 and not(string-length(normalize-space(string(./@ism:compilationReason)))&gt;0)) then index-of($partSCIcontrols_tok,'SI')&gt;0 else true()">
               <xsl:attribute name="id">ISM-00111</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00111][Error] USA SI documents not using compilation must have SI data.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M226"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M226"/>
   <xsl:template match="@*|node()" priority="-2" mode="M226">
      <xsl:apply-templates select="*" mode="M226"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00112-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]" priority="1000"
                 mode="M227">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else             if (contains(string($bannerSCIcontrols), 'SI-G') and not(string-length(normalize-space(string(./@ism:compilationReason)))&gt;0)) then             index-of($partSCIcontrols_tok,'SI-G')&gt;0             else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if (contains(string($bannerSCIcontrols), 'SI-G') and not(string-length(normalize-space(string(./@ism:compilationReason)))&gt;0)) then index-of($partSCIcontrols_tok,'SI-G')&gt;0 else true()">
               <xsl:attribute name="id">ISM-00112</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00112][Error] USA SI-G documents not using compilation must have SI-G data.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M227"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M227"/>
   <xsl:template match="@*|node()" priority="-2" mode="M227">
      <xsl:apply-templates select="*" mode="M227"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00113-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]" priority="1000"
                 mode="M228">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else             if (index-of($bannerSCIcontrols_tok, 'TK')&gt;0 and not(string-length(normalize-space(string(./@ism:compilationReason)))&gt;0)) then             index-of($partSCIcontrols_tok,'TK')&gt;0             else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if (index-of($bannerSCIcontrols_tok, 'TK')&gt;0 and not(string-length(normalize-space(string(./@ism:compilationReason)))&gt;0)) then index-of($partSCIcontrols_tok,'TK')&gt;0 else true()">
               <xsl:attribute name="id">ISM-00113</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00113][Error] USA TK documents not using compilation must have TK data.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M228"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M228"/>
   <xsl:template match="@*|node()" priority="-2" mode="M228">
      <xsl:apply-templates select="*" mode="M228"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00116-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]" priority="1000"
                 mode="M229">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else                 if (index-of($bannerSCIcontrols_tok, 'HCS')&gt;0 and not(string-length(normalize-space(string(./@ism:compilationReason)))&gt;0)) then                 index-of($partSCIcontrols_tok,'HCS')&gt;0                 else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if (index-of($bannerSCIcontrols_tok, 'HCS')&gt;0 and not(string-length(normalize-space(string(./@ism:compilationReason)))&gt;0)) then index-of($partSCIcontrols_tok,'HCS')&gt;0 else true()">
               <xsl:attribute name="id">ISM-00116</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00116][Error] USA HCS documents not using compilation must have HCS data.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M229"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M229"/>
   <xsl:template match="@*|node()" priority="-2" mode="M229">
      <xsl:apply-templates select="*" mode="M229"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00118-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)][1]"
                 priority="1000"
                 mode="M230">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)][1]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(./@ism:createDate) then true() else false()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(./@ism:createDate) then true() else false()">
               <xsl:attribute name="id">ISM-00118</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00118][Error] The first element in document order having 
            resourceElement true must have createDate specified.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M230"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M230"/>
   <xsl:template match="@*|node()" priority="-2" mode="M230">
      <xsl:apply-templates select="*" mode="M230"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00132-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]" priority="1000"
                 mode="M231">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else                  if(index-of($bannerDisseminationControls_tok, 'RELIDO')&gt;0)                 then sum(for $token in $partTags return                             if(not($token/@ism:classification='U') and index-of(tokenize(string($token/@ism:disseminationControls),' '), 'RELIDO')&gt;0)                             then 1 else 0                      ) = count(for $tag in $partTags return if($tag/@ism:classification='U') then null else 1)                 else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if(index-of($bannerDisseminationControls_tok, 'RELIDO')&gt;0) then sum(for $token in $partTags return if(not($token/@ism:classification='U') and index-of(tokenize(string($token/@ism:disseminationControls),' '), 'RELIDO')&gt;0) then 1 else 0 ) = count(for $tag in $partTags return if($tag/@ism:classification='U') then null else 1) else true()">
               <xsl:attribute name="id">ISM-00132</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00132][Error] USA documents having RELIDO at the resource level must have every classified portion having RELIDO.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M231"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M231"/>
   <xsl:template match="@*|node()" priority="-2" mode="M231">
      <xsl:apply-templates select="*" mode="M231"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00141-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]" priority="1000"
                 mode="M232">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>
      <xsl:variable name="paddedDeclassEx"
                    select="concat(' ', normalize-space(string(./@ism:declassException)), ' ')"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_NSI_EO_APPLIES)) then true() else              if(matches($paddedDeclassEx, ' (25X1-human|50X1-HUM|50X2-WMD) ')) then true() else                     if(                         sum(                             for $each in tokenize(string(./@ism:atomicEnergyMarkings), ' ') return                                 if(matches($each, '^F?RD-?.*$'))                                     then 1                                     else 0                         )&gt;0                     ) then true()                     else (./@ism:declassDate or ./@ism:declassEvent)             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_NSI_EO_APPLIES)) then true() else if(matches($paddedDeclassEx, ' (25X1-human|50X1-HUM|50X2-WMD) ')) then true() else if( sum( for $each in tokenize(string(./@ism:atomicEnergyMarkings), ' ') return if(matches($each, '^F?RD-?.*$')) then 1 else 0 )&gt;0 ) then true() else (./@ism:declassDate or ./@ism:declassEvent)">
               <xsl:attribute name="id">ISM-00141</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00141][Error] Documents under E.O. 13526 require declassDate or declassEvent unless 25X1-human, 
            50X1-HUM, 50X2-WMD, RD, or FRD is specified.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M232"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M232"/>
   <xsl:template match="@*|node()" priority="-2" mode="M232">
      <xsl:apply-templates select="*" mode="M232"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00145-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]" priority="1000"
                 mode="M233">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="                 if(not($ISM_CAPCO_RESOURCE)) then true() else                     if(index-of($partNonICmarkings_tok, 'LES') &gt; 0 and not(index-of($partNonICmarkings_tok, 'LES-NF') &gt; 0))                     then (index-of($bannerNonICmarkings_tok, 'LES') &gt; 0)                     else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if(index-of($partNonICmarkings_tok, 'LES') &gt; 0 and not(index-of($partNonICmarkings_tok, 'LES-NF') &gt; 0)) then (index-of($bannerNonICmarkings_tok, 'LES') &gt; 0) else true()">
               <xsl:attribute name="id">ISM-00145</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00145][Error] USA documents having LES and not having LES-NF must have LES at the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M233"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M233"/>
   <xsl:template match="@*|node()" priority="-2" mode="M233">
      <xsl:apply-templates select="*" mode="M233"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00146-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]" priority="1000"
                 mode="M234">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else                 if(index-of($partNonICmarkings_tok, 'LES-NF') &gt; 0 and not($bannerClassification='U'))                  then (index-of($bannerDisseminationControls_tok, 'NF') &gt; 0)                 else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if(index-of($partNonICmarkings_tok, 'LES-NF') &gt; 0 and not($bannerClassification='U')) then (index-of($bannerDisseminationControls_tok, 'NF') &gt; 0) else true()">
               <xsl:attribute name="id">ISM-00146</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00146][Error] Classified USA documents having LES-NF Data must have NF at the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M234"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M234"/>
   <xsl:template match="@*|node()" priority="-2" mode="M234">
      <xsl:apply-templates select="*" mode="M234"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00147-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]" priority="1000"
                 mode="M235">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else                 if(index-of($partNonICmarkings_tok, 'LES-NF') &gt; 0 and not($bannerClassification='U'))                  then (index-of($bannerNonICmarkings_tok, 'LES') &gt; 0)                 else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if(index-of($partNonICmarkings_tok, 'LES-NF') &gt; 0 and not($bannerClassification='U')) then (index-of($bannerNonICmarkings_tok, 'LES') &gt; 0) else true()">
               <xsl:attribute name="id">ISM-00147</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00147][Error] Classified USA documents having LES-NF Data must have LES at the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M235"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M235"/>
   <xsl:template match="@*|node()" priority="-2" mode="M235">
      <xsl:apply-templates select="*" mode="M235"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00149-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]" priority="1000"
                 mode="M236">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="                 if(not($ISM_CAPCO_RESOURCE)) then true() else                     if(index-of($partNonICmarkings_tok, 'LES-NF') &gt; 0 and $bannerClassification='U')                     then (index-of($bannerNonICmarkings_tok, 'LES-NF') &gt; 0)                     else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if(index-of($partNonICmarkings_tok, 'LES-NF') &gt; 0 and $bannerClassification='U') then (index-of($bannerNonICmarkings_tok, 'LES-NF') &gt; 0) else true()">
               <xsl:attribute name="id">ISM-00149</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00149][Error] Unclassified USA documents having LES-NF data must have LES-NF at the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M236"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M236"/>
   <xsl:template match="@*|node()" priority="-2" mode="M236">
      <xsl:apply-templates select="*" mode="M236"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00154-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]" priority="1000"
                 mode="M237">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else                 if (index-of($bannerDisseminationControls_tok, 'FOUO')&gt;0 and not(string-length(normalize-space(string(./@ism:compilationReason)))&gt;0)) then                 index-of($partDisseminationControls_tok,'FOUO')&gt;0                 else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if (index-of($bannerDisseminationControls_tok, 'FOUO')&gt;0 and not(string-length(normalize-space(string(./@ism:compilationReason)))&gt;0)) then index-of($partDisseminationControls_tok,'FOUO')&gt;0 else true()">
               <xsl:attribute name="id">ISM-00154</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00154][Error] USA FOUO documents not using compilation must have FOUO data.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M237"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M237"/>
   <xsl:template match="@*|node()" priority="-2" mode="M237">
      <xsl:apply-templates select="*" mode="M237"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00155-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]" priority="1000"
                 mode="M238">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else                  if(not($ISM_DOD5230_24_APPLIES)) then true() else                 count(                     (if(index-of($bannerNotice_tok, 'DoD-Dist-A')&gt;0) then 1 else null,                      if(index-of($bannerNotice_tok, 'DoD-Dist-B')&gt;0) then 1 else null,                     if(index-of($bannerNotice_tok, 'DoD-Dist-C')&gt;0) then 1 else null,                     if(index-of($bannerNotice_tok, 'DoD-Dist-D')&gt;0) then 1 else null,                     if(index-of($bannerNotice_tok, 'DoD-Dist-E')&gt;0) then 1 else null,                     if(index-of($bannerNotice_tok, 'DoD-Dist-F')&gt;0) then 1 else null,                     if(index-of($bannerNotice_tok, 'DoD-Dist-X')&gt;0) then 1 else null)                      )&gt;0             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if(not($ISM_DOD5230_24_APPLIES)) then true() else count( (if(index-of($bannerNotice_tok, 'DoD-Dist-A')&gt;0) then 1 else null, if(index-of($bannerNotice_tok, 'DoD-Dist-B')&gt;0) then 1 else null, if(index-of($bannerNotice_tok, 'DoD-Dist-C')&gt;0) then 1 else null, if(index-of($bannerNotice_tok, 'DoD-Dist-D')&gt;0) then 1 else null, if(index-of($bannerNotice_tok, 'DoD-Dist-E')&gt;0) then 1 else null, if(index-of($bannerNotice_tok, 'DoD-Dist-F')&gt;0) then 1 else null, if(index-of($bannerNotice_tok, 'DoD-Dist-X')&gt;0) then 1 else null) )&gt;0">
               <xsl:attribute name="id">ISM-00155</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00155][Error] All USA documents that claim compliance with DoD5230.24 must have a distribution statement
            for the entire document.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M238"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M238"/>
   <xsl:template match="@*|node()" priority="-2" mode="M238">
      <xsl:apply-templates select="*" mode="M238"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00162-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]" priority="1000"
                 mode="M239">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else              if(not($ISM_DOD5230_24_APPLIES)) then true() else             not(count(                 (   if(index-of($bannerNotice_tok, 'DoD-Dist-A')&gt;0) then 1 else null,                      if(index-of($bannerNotice_tok, 'DoD-Dist-B')&gt;0) then 1 else null,                     if(index-of($bannerNotice_tok, 'DoD-Dist-C')&gt;0) then 1 else null,                     if(index-of($bannerNotice_tok, 'DoD-Dist-D')&gt;0) then 1 else null,                     if(index-of($bannerNotice_tok, 'DoD-Dist-E')&gt;0) then 1 else null,                     if(index-of($bannerNotice_tok, 'DoD-Dist-F')&gt;0) then 1 else null,                     if(index-of($bannerNotice_tok, 'DoD-Dist-X')&gt;0) then 1 else null)                  )&gt;1)             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if(not($ISM_DOD5230_24_APPLIES)) then true() else not(count( ( if(index-of($bannerNotice_tok, 'DoD-Dist-A')&gt;0) then 1 else null, if(index-of($bannerNotice_tok, 'DoD-Dist-B')&gt;0) then 1 else null, if(index-of($bannerNotice_tok, 'DoD-Dist-C')&gt;0) then 1 else null, if(index-of($bannerNotice_tok, 'DoD-Dist-D')&gt;0) then 1 else null, if(index-of($bannerNotice_tok, 'DoD-Dist-E')&gt;0) then 1 else null, if(index-of($bannerNotice_tok, 'DoD-Dist-F')&gt;0) then 1 else null, if(index-of($bannerNotice_tok, 'DoD-Dist-X')&gt;0) then 1 else null) )&gt;1)">
               <xsl:attribute name="id">ISM-00155</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00162][Error] All USA documents that claim compliance with DoD5230.24 must have only 1 distribution statement
            for the entire document.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M239"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M239"/>
   <xsl:template match="@*|node()" priority="-2" mode="M239">
      <xsl:apply-templates select="*" mode="M239"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00165-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]" priority="1000"
                 mode="M240">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else                 if(index-of($partDisseminationControls_tok, 'RS')&gt;0)                     then index-of($bannerDisseminationControls_tok, 'RS') &gt; 0                     else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if(index-of($partDisseminationControls_tok, 'RS')&gt;0) then index-of($bannerDisseminationControls_tok, 'RS') &gt; 0 else true()">
               <xsl:attribute name="id">ISM-00165</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00165][Error] USA documents having RS Data must have RS at the resource level.
            
            Human Readable: USA documents having RISK SENSITIVE (RS) data must have RS at the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M240"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M240"/>
   <xsl:template match="@*|node()" priority="-2" mode="M240">
      <xsl:apply-templates select="*" mode="M240"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00171-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)    and @ism:displayOnlyTo]"
                 priority="1000"
                 mode="M241">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)    and @ism:displayOnlyTo]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE))                  then true()              else                 sum(                     for $token in $partTags return                          if(matches($token/@ism:classification, '^U$')                            or exists($token/@ism:displayOnlyTo))                              then 0                         else 1                 ) = 0             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else sum( for $token in $partTags return if(matches($token/@ism:classification, '^U$') or exists($token/@ism:displayOnlyTo)) then 0 else 1 ) = 0">
               <xsl:attribute name="id">ISM-00171</xsl:attribute>
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00171][Warning] If ISM_CAPCO_RESOURCE and displayOnlyTo is specified on 
            the resource element then all classified portions must specify displayOnlyTo.
            
            Human Readable: USA documents having DISPLAYONLY data at the resource level
            must have all classified portions authorized for DISPLAYONLY.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M241"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M241"/>
   <xsl:template match="@*|node()" priority="-2" mode="M241">
      <xsl:apply-templates select="*" mode="M241"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00227-->


	<!--RULE -->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)    and @ism:noticeType]"
                 priority="1000"
                 mode="M242">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)    and @ism:noticeType]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             starts-with(normalize-space(string(@ism:noticeType)), 'DoD-Dist-')             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="starts-with(normalize-space(string(@ism:noticeType)), 'DoD-Dist-')">
               <xsl:attribute name="id">ISM-00227</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00227][Error] Attribute @noticeType may only appear on the 
            resource node when it contains the values [DoD-Dist-A], [DoD-Dist-B], 
            [DoD-Dist-C], [DoD-Dist-D], [DoD-Dist-E], [DoD-Dist-F], or [DoD-Dist-X].
            
            Human Readable: Documents may only specify a document-level notice if
            it pertains to DoD Distribution.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M242"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M242"/>
   <xsl:template match="@*|node()" priority="-2" mode="M242">
      <xsl:apply-templates select="*" mode="M242"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00121-->


	<!--RULE -->
<xsl:template match="*[@ism:SARIdentifier]" priority="1000" mode="M243">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:SARIdentifier]"/>
      <xsl:variable name="errMsg_AlphabeticalOrder"
                    select="'             [ISM-ID-00121][Error] If ISM_CAPCO_RESOURCE and attribute SARIdentifier              is specified, then each of its values must be ordered in accordance              with CVEnumISMSAR.xml.'"/>
      <xsl:variable name="dataFileElems" select="$SARIdentifierList"/>
      <xsl:variable name="attrValues" select="./@ism:SARIdentifier"/>
      <xsl:variable name="attrValueTokens" select="tokenize(string($attrValues),' ')"/>
      <xsl:variable name="convertStrToNum"
                    select="             for $token in $attrValueTokens return                 number(string-join(                     for $index in 1 to string-length($token) return                         for $char in substring($token, $index, 1) return                             if (contains(string('0123456789'), $char)) then                                 $char                             else if (contains(string('ABCDEFGHI'), $char)) then                                 translate(string($char), 'ABCDEFGHI', '123456789')                             else if (contains(string('JKLMNOPQRS'), $char)) then                                 concat('1', translate(string($char), 'JKLMNOPQRS', '0123456789'))                             else if (contains(string('TUVWXYZ'), $char)) then                                 concat('2', translate(string($char), 'TUVWXYZ', '0123456'))                             else '0'                 , ''))             "/>
      <xsl:variable name="orderNums"
                    select="             for $token in $attrValueTokens return                  if ($dataFileElems[matches($token,concat('^',text(),'$'))]) then                      count(($dataFileElems[matches($token,concat('^',text(),'$'))])/preceding::*) + 1                 else -1"/>
      <xsl:variable name="sortedOrderNums"
                    select="             for $index in distinct-values(for $token in $orderNums return index-of($orderNums,$token)) return                  if($index = 1 or $orderNums[$index] &gt; $orderNums[$index - 1]) then 1                 else if ($orderNums[$index] &lt; $orderNums[$index - 1]) then 0                 else                     if (matches($attrValueTokens[$index], '[0-9]') or matches($attrValueTokens[$index - 1], '[0-9]')) then                         if ($convertStrToNum[$index - 1] &gt; $convertStrToNum[$index]) then 0                         else 2                     else                           if (compare($attrValueTokens[$index - 1],$attrValueTokens[$index])=1) then 0                         else 2             "/>
      <xsl:variable name="hasUnsorted" select="count(index-of($sortedOrderNums,0)) &gt; 0"/>
      <xsl:variable name="unsortedValues"
                    select="             if ($hasUnsorted) then                 distinct-values(                     for $token in index-of($sortedOrderNums,0) return                         $attrValueTokens[$token]                  )             else null             "/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not($hasUnsorted)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($hasUnsorted)">
               <xsl:attribute name="id">ISM-00121</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="$errMsg_AlphabeticalOrder"/>
                  <xsl:text/>
            The following values are out of order [<xsl:text/>
                  <xsl:value-of select="$unsortedValues"/>
                  <xsl:text/>] for [<xsl:text/>
                  <xsl:value-of select="$attrValueTokens"/>
                  <xsl:text/>] </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M243"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M243"/>
   <xsl:template match="@*|node()" priority="-2" mode="M243">
      <xsl:apply-templates select="*" mode="M243"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00042-->


	<!--RULE -->
<xsl:template match="*[@ism:SCIcontrols]" priority="1000" mode="M244">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:SCIcontrols]"/>
      <xsl:variable name="errMsg_AlphabeticalOrder"
                    select="'             [ISM-ID-00042][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols is specified, each of its values must be              ordered in accordance with CVEnumISMSCIControls.xml.             '"/>
      <xsl:variable name="dataFileElems" select="$SCIcontrolsList"/>
      <xsl:variable name="attrValues" select="./@ism:SCIcontrols"/>
      <xsl:variable name="attrValueTokens" select="tokenize(string($attrValues),' ')"/>
      <xsl:variable name="convertStrToNum"
                    select="             for $token in $attrValueTokens return                 number(string-join(                     for $index in 1 to string-length($token) return                         for $char in substring($token, $index, 1) return                             if (contains(string('0123456789'), $char)) then                                 $char                             else if (contains(string('ABCDEFGHI'), $char)) then                                 translate(string($char), 'ABCDEFGHI', '123456789')                             else if (contains(string('JKLMNOPQRS'), $char)) then                                 concat('1', translate(string($char), 'JKLMNOPQRS', '0123456789'))                             else if (contains(string('TUVWXYZ'), $char)) then                                 concat('2', translate(string($char), 'TUVWXYZ', '0123456'))                             else '0'                 , ''))             "/>
      <xsl:variable name="orderNums"
                    select="             for $token in $attrValueTokens return                  if ($dataFileElems[matches($token,concat('^',text(),'$'))]) then                      count(($dataFileElems[matches($token,concat('^',text(),'$'))])/preceding::*) + 1                 else -1"/>
      <xsl:variable name="sortedOrderNums"
                    select="             for $index in distinct-values(for $token in $orderNums return index-of($orderNums,$token)) return                  if($index = 1 or $orderNums[$index] &gt; $orderNums[$index - 1]) then 1                 else if ($orderNums[$index] &lt; $orderNums[$index - 1]) then 0                 else                     if (matches($attrValueTokens[$index], '[0-9]') or matches($attrValueTokens[$index - 1], '[0-9]')) then                         if ($convertStrToNum[$index - 1] &gt; $convertStrToNum[$index]) then 0                         else 2                     else                           if (compare($attrValueTokens[$index - 1],$attrValueTokens[$index])=1) then 0                         else 2             "/>
      <xsl:variable name="hasUnsorted" select="count(index-of($sortedOrderNums,0)) &gt; 0"/>
      <xsl:variable name="unsortedValues"
                    select="             if ($hasUnsorted) then                 distinct-values(                     for $token in index-of($sortedOrderNums,0) return                         $attrValueTokens[$token]                  )             else null             "/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not($hasUnsorted)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($hasUnsorted)">
               <xsl:attribute name="id">ISM-00042</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="$errMsg_AlphabeticalOrder"/>
                  <xsl:text/>
            The following values are out of order [<xsl:text/>
                  <xsl:value-of select="$unsortedValues"/>
                  <xsl:text/>] for [<xsl:text/>
                  <xsl:value-of select="$attrValueTokens"/>
                  <xsl:text/>] </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M244"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M244"/>
   <xsl:template match="@*|node()" priority="-2" mode="M244">
      <xsl:apply-templates select="*" mode="M244"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00043-->


	<!--RULE -->
<xsl:template match="*[@ism:SCIcontrols]" priority="1000" mode="M245">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:SCIcontrols]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="if(not($ISM_CAPCO_RESOURCE)) then true() else               if ( index-of(tokenize(string(./@ism:SCIcontrols), ' '),'SI')&gt;0                  and not( matches(./@ism:classification,'^(TS|S|C)$'))             ) then false() else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if ( index-of(tokenize(string(./@ism:SCIcontrols), ' '),'SI')&gt;0 and not( matches(./@ism:classification,'^(TS|S|C)$')) ) then false() else true()">
               <xsl:attribute name="id">ISM-00043</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00043][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [SI], then attribute 
            classification must have a value of [TS], [S], or [C].
            
            Human Readable: A USA document containing Special Intelligence (SI) data must be 
            classified CONFIDENTIAL, SECRET, or TOP SECRET.  
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M245"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M245"/>
   <xsl:template match="@*|node()" priority="-2" mode="M245">
      <xsl:apply-templates select="*" mode="M245"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00044-->


	<!--RULE -->
<xsl:template match="*[@ism:SCIcontrols]" priority="1000" mode="M246">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:SCIcontrols]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="if(not($ISM_CAPCO_RESOURCE)) then true() else             if(index-of(tokenize(string(./@ism:SCIcontrols),' '),'SI-G')&gt;0                  and not(matches(./@ism:classification,'^TS$'))             ) then false() else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if(index-of(tokenize(string(./@ism:SCIcontrols),' '),'SI-G')&gt;0 and not(matches(./@ism:classification,'^TS$')) ) then false() else true()">
               <xsl:attribute name="id">ISM-00045</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00044][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [SI-G], then attribute 
            classification must have a value of [TS].
            
            Human Readable: A USA document containing Special Intelligence (SI) GAMMA compartment data 
            must be classified TOP SECRET.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M246"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M246"/>
   <xsl:template match="@*|node()" priority="-2" mode="M246">
      <xsl:apply-templates select="*" mode="M246"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00045-->


	<!--RULE -->
<xsl:template match="*[@ism:SCIcontrols]" priority="1000" mode="M247">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:SCIcontrols]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else             if(index-of(tokenize(string(./@ism:SCIcontrols),' '),'SI-G')&gt;0)                 then index-of(tokenize(string(./@ism:disseminationControls),' '), 'OC')&gt;0                 else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if(index-of(tokenize(string(./@ism:SCIcontrols),' '),'SI-G')&gt;0) then index-of(tokenize(string(./@ism:disseminationControls),' '), 'OC')&gt;0 else true()">
               <xsl:attribute name="id">ISM-00045</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00045][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [SI-G], then attribute 
            disseminationControls must contain the name token [OC].
            
            Human Readable: A USA document containing Special Intelligence (SI) GAMMA compartment data must 
            be marked for ORIGINATOR CONTROLLED dissemination.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M247"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M247"/>
   <xsl:template match="@*|node()" priority="-2" mode="M247">
      <xsl:apply-templates select="*" mode="M247"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00046-->


	<!--RULE -->
<xsl:template match="*[@ism:SCIcontrols]" priority="1000" mode="M248">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:SCIcontrols]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else             if(matches(./@ism:classification,'^TS$')) then true() else             count(                 for $token in tokenize(string(./@ism:SCIcontrols),' ') return                      if(matches($token,'^SI-ECI')) then 1 else null             )=0             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if(matches(./@ism:classification,'^TS$')) then true() else count( for $token in tokenize(string(./@ism:SCIcontrols),' ') return if(matches($token,'^SI-ECI')) then 1 else null )=0">
               <xsl:attribute name="id">ISM-00046</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00046][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains 
            a name token starting with [SI-ECI], then attribute classification must have a 
            value of [TS].
            
            Human Readable: A USA document containing Special Intelligence (SI) ECI compartment
            data must be classified TOP SECRET.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M248"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M248"/>
   <xsl:template match="@*|node()" priority="-2" mode="M248">
      <xsl:apply-templates select="*" mode="M248"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00047-->


	<!--RULE -->
<xsl:template match="*[@ism:SCIcontrols]" priority="1000" mode="M249">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:SCIcontrols]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else             if(index-of(tokenize(string(./@ism:SCIcontrols), ' '),'TK')&gt;0                  and not( matches(./@ism:classification,'^(TS|S)$'))             ) then false() else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if(index-of(tokenize(string(./@ism:SCIcontrols), ' '),'TK')&gt;0 and not( matches(./@ism:classification,'^(TS|S)$')) ) then false() else true()">
               <xsl:attribute name="id">ISM-00047</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00047][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains 
            the name token [TK], then attribute classification must have a value of [TS] or [S].
            
            Human Readable: A USA document containing TALENT KEYHOLE data must be classified
            SECRET or TOP SECRET.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M249"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M249"/>
   <xsl:template match="@*|node()" priority="-2" mode="M249">
      <xsl:apply-templates select="*" mode="M249"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00048-->


	<!--RULE -->
<xsl:template match="*[@ism:SCIcontrols]" priority="1000" mode="M250">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:SCIcontrols]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else             if(                 index-of(tokenize(string(./@ism:SCIcontrols), ' '),'HCS')&gt;0 and                  not(matches(./@ism:classification,'^(TS|S|C)$'))             ) then false() else true()                   "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if( index-of(tokenize(string(./@ism:SCIcontrols), ' '),'HCS')&gt;0 and not(matches(./@ism:classification,'^(TS|S|C)$')) ) then false() else true()">
               <xsl:attribute name="id">ISM-00048</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00048][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [HCS], then attribute 
            classification must have a value of [TS], [S], or [C].
            
            Human Readable: A USA document containing HCS data must be classified CONFIDENTIAL, SECRET, or TOP SECRET.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M250"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M250"/>
   <xsl:template match="@*|node()" priority="-2" mode="M250">
      <xsl:apply-templates select="*" mode="M250"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00049-->


	<!--RULE -->
<xsl:template match="*[@ism:SCIcontrols]" priority="1000" mode="M251">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:SCIcontrols]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else             not(                 index-of(tokenize(string(./@ism:SCIcontrols), ' '),'HCS')&gt;0 and                  not(index-of(tokenize(string(./@ism:disseminationControls),' '),'NF'))             )             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else not( index-of(tokenize(string(./@ism:SCIcontrols), ' '),'HCS')&gt;0 and not(index-of(tokenize(string(./@ism:disseminationControls),' '),'NF')) )">
               <xsl:attribute name="id">ISM-00048</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00049][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [HCS], then attribute 
            disseminationControls must contain the name token [NF].
            
            Human Readable: A USA document containing HCS data must be marked for NO FOREIGN dissemination.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M251"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M251"/>
   <xsl:template match="@*|node()" priority="-2" mode="M251">
      <xsl:apply-templates select="*" mode="M251"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00122-->


	<!--RULE -->
<xsl:template match="*[@ism:SCIcontrols]" priority="1000" mode="M252">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:SCIcontrols]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else                not(index-of(tokenize(string(./@ism:SCIcontrols), ' '),'KDK')&gt;0                  and not(matches(./@ism:classification,'^(TS|S)$'))             )             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else not(index-of(tokenize(string(./@ism:SCIcontrols), ' '),'KDK')&gt;0 and not(matches(./@ism:classification,'^(TS|S)$')) )">
               <xsl:attribute name="id">ISM-00122</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00122][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [KDK], then attribute 
            classification must have a value of [TS] or [S].
            
            Human Readable: A USA document with KLONDIKE data must be classified SECRET or TOP SECRET.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M252"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M252"/>
   <xsl:template match="@*|node()" priority="-2" mode="M252">
      <xsl:apply-templates select="*" mode="M252"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00123-->


	<!--RULE -->
<xsl:template match="*[@ism:SCIcontrols]" priority="1000" mode="M253">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:SCIcontrols]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else                if(index-of(tokenize(string(./@ism:SCIcontrols), ' '),'KDK')&gt;0                  and not( index-of(tokenize(string(./@ism:disseminationControls), ' '),'NF'))             ) then false() else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if(index-of(tokenize(string(./@ism:SCIcontrols), ' '),'KDK')&gt;0 and not( index-of(tokenize(string(./@ism:disseminationControls), ' '),'NF')) ) then false() else true()">
               <xsl:attribute name="id">ISM-00123</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00123][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [KDK], then attribute 
            disseminationControls must contain the name token [NF].
            
            Human Readable: A USA document containing KLONDIKE data must also be marked for NO FOREIGN dissemination.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M253"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M253"/>
   <xsl:template match="@*|node()" priority="-2" mode="M253">
      <xsl:apply-templates select="*" mode="M253"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00177-->


	<!--RULE -->
<xsl:template match="*[@ism:SCIcontrols]" priority="1000" mode="M254">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:SCIcontrols]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else             if(                count(                    for $each in tokenize(string(./@ism:SCIcontrols),' ') return                        if(matches($each,'^SI-ECI')) then 1 else null                )&gt;0             )                 then index-of(tokenize(string(./@ism:SCIcontrols),' '), 'SI')&gt;0                 else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if( count( for $each in tokenize(string(./@ism:SCIcontrols),' ') return if(matches($each,'^SI-ECI')) then 1 else null )&gt;0 ) then index-of(tokenize(string(./@ism:SCIcontrols),' '), 'SI')&gt;0 else true()">
               <xsl:attribute name="id">ISM-00177</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00177][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [SI-ECI],
            then it must also contain the name token [SI].
            
            Human Readable: A USA document containing Special Intelligence (SI) ECI compartment data must also
            specify that it contains SI data.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M254"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M254"/>
   <xsl:template match="@*|node()" priority="-2" mode="M254">
      <xsl:apply-templates select="*" mode="M254"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00186-->


	<!--RULE -->
<xsl:template match="*[@ism:SCIcontrols]" priority="1000" mode="M255">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:SCIcontrols]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else             if(                count(                    for $each in tokenize(string(./@ism:SCIcontrols),' ') return                        if(matches($each,'^SI-G-[A-Z][A-Z][A-Z][A-Z]')) then 1 else null                )&gt;0             )                 then index-of(tokenize(string(./@ism:SCIcontrols),' '), 'SI-G')&gt;0                 else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if( count( for $each in tokenize(string(./@ism:SCIcontrols),' ') return if(matches($each,'^SI-G-[A-Z][A-Z][A-Z][A-Z]')) then 1 else null )&gt;0 ) then index-of(tokenize(string(./@ism:SCIcontrols),' '), 'SI-G')&gt;0 else true()">
               <xsl:attribute name="id">ISM-00186</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00186][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [SI-G-XXXX],
            then it must also contain the name token [SI-G].
            
            Human Readable: A USA document that contains Special Intelligence (SI) GAMMA sub-compartments must
            also specify that it contains SI-GAMMA compartment data.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M255"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M255"/>
   <xsl:template match="@*|node()" priority="-2" mode="M255">
      <xsl:apply-templates select="*" mode="M255"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00187-->


	<!--RULE -->
<xsl:template match="*[@ism:SCIcontrols]" priority="1000" mode="M256">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@ism:SCIcontrols]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="             if(not($ISM_CAPCO_RESOURCE)) then true() else             if(                count(                    for $each in tokenize(string(./@ism:SCIcontrols),' ') return                        if(matches($each,'^SI-G')) then 1 else null                )&gt;0             )                 then index-of(tokenize(string(./@ism:SCIcontrols),' '), 'SI')&gt;0                 else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_CAPCO_RESOURCE)) then true() else if( count( for $each in tokenize(string(./@ism:SCIcontrols),' ') return if(matches($each,'^SI-G')) then 1 else null )&gt;0 ) then index-of(tokenize(string(./@ism:SCIcontrols),' '), 'SI')&gt;0 else true()">
               <xsl:attribute name="id">ISM-00187</xsl:attribute>
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00187][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [SI-G],
            then it must also contain the name token [SI].
            
            Human Readable: A USA document that contains Special Intelligence (SI) -GAMMA compartment data must also specify that 
            it contains SI data. 
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M256"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M256"/>
   <xsl:template match="@*|node()" priority="-2" mode="M256">
      <xsl:apply-templates select="*" mode="M256"/>
   </xsl:template>
</xsl:stylesheet>