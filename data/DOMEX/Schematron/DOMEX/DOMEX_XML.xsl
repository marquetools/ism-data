<?xml version="1.0" encoding="UTF-8"?>
<!--UNCLASSIFIED--><xsl:stylesheet xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:saxon="http://saxon.sf.net/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:schold="http://www.ascc.net/xml/schematron"
                xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:ism="urn:us:gov:ic:ism"
                xmlns:irm="urn:us:gov:ic:irm"
                xmlns:arh="urn:us:gov:ic:arh"
                xmlns:tdf="urn:us:gov:ic:tdf"
                xmlns:domex="urn:us:mil:ces:metadata:domex"
                xmlns:Identity="urn:us:mil:ces:metadata:domex_identity"
                xmlns:cr="urn:CellexReport"
                xmlns:cve="urn:us:gov:ic:cve"
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
<xsl:output xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
               method="xml"
               omit-xml-declaration="no"
               standalone="yes"
               indent="yes"/>

   <!--XSD TYPES FOR XSLT2-->


<!--KEYS AND FUNCTIONS-->


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
         <svrl:text>
        This is the root file for the specifications Schematron ruleset. It loads all of the required CVEs, 
        and includes all of the Rule .sch files.
    </svrl:text>
         <svrl:ns-prefix-in-attribute-values uri="http://www.w3.org/1999/xlink" prefix="xlink"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.w3.org/2001/XMLSchema" prefix="xs"/>
         <svrl:ns-prefix-in-attribute-values uri="urn:us:gov:ic:ism" prefix="ism"/>
         <svrl:ns-prefix-in-attribute-values uri="urn:us:gov:ic:irm" prefix="irm"/>
         <svrl:ns-prefix-in-attribute-values uri="urn:us:gov:ic:arh" prefix="arh"/>
         <svrl:ns-prefix-in-attribute-values uri="urn:us:gov:ic:tdf" prefix="tdf"/>
         <svrl:ns-prefix-in-attribute-values uri="urn:us:mil:ces:metadata:domex" prefix="domex"/>
         <svrl:ns-prefix-in-attribute-values uri="urn:us:mil:ces:metadata:domex_identity" prefix="Identity"/>
         <svrl:ns-prefix-in-attribute-values uri="urn:CellexReport" prefix="cr"/>
         <svrl:ns-prefix-in-attribute-values uri="urn:us:gov:ic:irm" prefix="irm"/>
         <svrl:ns-prefix-in-attribute-values uri="urn:us:gov:ic:cve" prefix="cve"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">DOMEX-ID-00001</xsl:attribute>
            <xsl:attribute name="name">DOMEX-ID-00001</xsl:attribute>
            <svrl:text>
        This abstract pattern checks to see if the validation environment has at least the version / revision of the
        CVE as of the writing of this specification. 
        The calling rule must pass in '202111', 'ISM', '../../CVE/ISM/CVEnumISMClassificationAll.xml', 'DOMEX-ID-00001'.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M12"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">DOMEX-ID-00003</xsl:attribute>
            <xsl:attribute name="name">DOMEX-ID-00003</xsl:attribute>
            <svrl:text>
        [DOMEX_ID_00003][Error] String length constraint violation - (element) 
        
        Human Readable: String length constraint violation - (element).
    </svrl:text>
            <svrl:text>
        Checks string lengths for selected DOMEX elements in the IRM assertion.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M13"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">DOMEX-ID-00004</xsl:attribute>
            <xsl:attribute name="name">DOMEX-ID-00004</xsl:attribute>
            <svrl:text>
        [DOMEX_ID_00004][Error] If a TrustedDataObject element contains a DOMEX assertion, 
        it must also contain an assertion with an IRM structured statement. 
        
        Human Readable: If a Trusted Data Object contains a DOMEX assertion, it must also contain an IRM assertion.  
    </svrl:text>
            <svrl:text>
        If a TDO has a DOMEX assertion, verify that it also contains an IRM assertion.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M14"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">DOMEX-ID-00005</xsl:attribute>
            <xsl:attribute name="name">DOMEX-ID-00005</xsl:attribute>
            <svrl:text>
        [DOMEX_ID_00005][Error]
        Invalid GENC code. 
        
        Human Readable: Invalid GENC code.  
    </svrl:text>
            <svrl:text>
        Invokes GENC AllowableGencValues abstract pattern to validate GENC country code.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M15"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">DOMEX-ID-00006</xsl:attribute>
            <xsl:attribute name="name">DOMEX-ID-00006</xsl:attribute>
            <svrl:text>
        [DOMEX_ID_00006][Error]
        Invalid sub-agency code. 
        
        Human Readable: Invalid sub-agency code.  
    </svrl:text>
            <svrl:text>
        Given a primary agency, validate the sub-agency.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M16"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">DOMEX-ID-00007</xsl:attribute>
            <xsl:attribute name="name">DOMEX-ID-00007</xsl:attribute>
            <svrl:text>
        [DOMEX_ID_00007][Error]
        Invalid sub-activiy specified. 
        
        Human Readable: Invalid sub-activiy specified.  
    </svrl:text>
            <svrl:text>
        Given a primary activity, validate the sub-activity.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M17"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">DOMEX-ID-00008</xsl:attribute>
            <xsl:attribute name="name">DOMEX-ID-00008</xsl:attribute>
            <svrl:text>
        [DOMEX_ID_00008][Error] The root element of a DOMEX assertion must contain a DESVersion attribute. 
        
        Human Readable: The root element of a DOMEX assertion must contain a DESVersion attribute. 
    </svrl:text>
            <svrl:text>
        Check the root element of a DOMEX assertion to ensure that it contains a DESVersion attribute.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M18"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">DOMEX-ID-00009</xsl:attribute>
            <xsl:attribute name="name">DOMEX-ID-00009</xsl:attribute>
            <svrl:text>
        [DOMEX_ID_00009][Error] The DOMEX assertion must have a scope of either TDO or TDC. 
        
        Human Readable: The DOMEX assertion must have a scope of either TDO or TDC. 
    </svrl:text>
            <svrl:text>
        Ensure that the DOMEX assertion has a scope of either TDO or TDC. 
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M19"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">DOMEX-ID-00010</xsl:attribute>
            <xsl:attribute name="name">DOMEX-ID-00010</xsl:attribute>
            <svrl:text>
        This abstract pattern checks to see if the validation environment has at least the version / revision of the
        Schema as of the writing of this specification. 
        The calling rule must pass in '202111', 'IRM', '../../Schema/IRM/IC-IRM.xsd', 'DOMEX-ID-00010'.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M20"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">DOMEX-ID-00011</xsl:attribute>
            <xsl:attribute name="name">DOMEX-ID-00011</xsl:attribute>
            <svrl:text>
        This abstract pattern checks to see if the validation environment has at least the version / revision of the
        Schema as of the writing of this specification. 
        The calling rule must pass in '201903', 'IC-EDH', '../../Schema/IC-EDH/IC-EDH.xsd', 'DOMEX-ID-00011'.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M21"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">DOMEX-ID-00012</xsl:attribute>
            <xsl:attribute name="name">DOMEX-ID-00012</xsl:attribute>
            <svrl:text>
        [DOMEX_ID_00012][Warning] DESVersion attribute SHOULD be specified as version 202111
        (Version:2021-NOV) with an optional extension. 
    </svrl:text>
            <svrl:text> This rule checks the root element of a DOMEX assertion to ensure it has
        the appropriate DESVersion and supports extending the version identifier with an optional
        trailing hyphen and up to 23 additional characters. The version must match the regular
        expression “^202111(-.{1,23})?$".
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M22"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">DOMEX-ID-00013</xsl:attribute>
            <xsl:attribute name="name">DOMEX-ID-00013</xsl:attribute>
            <svrl:text>
        This abstract pattern checks to see if the validation environment has at least the version / revision of the
        CVE as of the writing of this specification. 
        The calling rule must pass in '201703.201802', 'USAgency', '../../CVE/USAgency/CVEnumUSAgencyAcronym.xml', 'DOMEX-ID-00013'.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M23"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">DOMEX-ID-00014</xsl:attribute>
            <xsl:attribute name="name">DOMEX-ID-00014</xsl:attribute>
            <svrl:text>
        This abstract pattern checks to see if the validation environment has at least the version / revision of the
        CVE as of the writing of this specification. 
        The calling rule must pass in '202010', 'MIME', '../../CVE/MIME/CVEnumMIMEType.xml', 'DOMEX-ID-00014'.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M24"/>
      </svrl:schematron-output>
   </xsl:template>

   <!--SCHEMATRON PATTERNS-->


<!--PATTERN DOMEX-ID-00001-->


	<!--RULE ValidateValidationEnvCVE-R1-->
<xsl:template match="/" priority="1000" mode="M12">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/"
                       id="ValidateValidationEnvCVE-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="document('../../CVE/ISM/CVEnumISMClassificationAll.xml')//cve:CVE//@specVersion castable as xs:double              and document('../../CVE/ISM/CVEnumISMClassificationAll.xml')//cve:CVE//@specVersion &gt;= '202111'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="document('../../CVE/ISM/CVEnumISMClassificationAll.xml')//cve:CVE//@specVersion castable as xs:double and document('../../CVE/ISM/CVEnumISMClassificationAll.xml')//cve:CVE//@specVersion &gt;= '202111'">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> 
            [<xsl:text/>
                  <xsl:value-of select="'DOMEX-ID-00001'"/>
                  <xsl:text/>][Error] Version [ <xsl:text/>
                  <xsl:value-of select="document('../../CVE/ISM/CVEnumISMClassificationAll.xml')//cve:CVE//@specVersion"/>
                  <xsl:text/> ] of <xsl:text/>
                  <xsl:value-of select="'ISM'"/>
                  <xsl:text/> found; 
            Version [<xsl:text/>
                  <xsl:value-of select="'202111'"/>
                  <xsl:text/>] or later is required. The latest version of <xsl:text/>
                  <xsl:value-of select="'ISM'"/>
                  <xsl:text/> 
            is not being used in the validation infrastructure. Regardless of the version indicated on the instance document, 
            the validation infrastructure needs to use a version of <xsl:text/>
                  <xsl:value-of select="'ISM'"/>
                  <xsl:text/> that is
            version [<xsl:text/>
                  <xsl:value-of select="'202111'"/>
                  <xsl:text/>] or later. NOTE: This is not an error of the instance
            document but of the validation environment itself. The incorrect value was found in <xsl:text/>
                  <xsl:value-of select="document-uri(document('../../CVE/ISM/CVEnumISMClassificationAll.xml'))"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M12"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M12"/>
   <xsl:template match="@*|node()" priority="-2" mode="M12">
      <xsl:apply-templates select="*" mode="M12"/>
   </xsl:template>

   <!--PATTERN DOMEX-ID-00003-->


	<!--RULE DOMEX-ID-00003-R1-->
<xsl:template match="irm:description" priority="1000" mode="M13">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="irm:description"
                       id="DOMEX-ID-00003-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="string-length(text()) &lt;= 4000"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="string-length(text()) &lt;= 4000">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [DOMEX_ID_00003][Error] String length constraint violation - (irm:description)
            
            Human Readable: String length constraint violation - (irm:description)
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M13"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M13"/>
   <xsl:template match="@*|node()" priority="-2" mode="M13">
      <xsl:apply-templates select="*" mode="M13"/>
   </xsl:template>

   <!--PATTERN DOMEX-ID-00004-->


	<!--RULE DOMEX-ID-00004-R1-->
<xsl:template match="tdf:StructuredStatement/*[namespace-uri() = 'urn:us:mil:ces:metadata:domex']"
                 priority="1002"
                 mode="M14">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="tdf:StructuredStatement/*[namespace-uri() = 'urn:us:mil:ces:metadata:domex']"
                       id="DOMEX-ID-00004-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="//tdf:Assertion/tdf:StructuredStatement/irm:ICResourceMetadataPackage"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="//tdf:Assertion/tdf:StructuredStatement/irm:ICResourceMetadataPackage">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[DOMEX_ID_00004][Error] If a TrustedDataObject element contains a DOMEX assertion, 
            it must also contain an assertion with an IRM structured statement. 
            
            Human Readable: If a Trusted Data Object contains a DOMEX assertion, it must also contain an IRM assertion.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M14"/>
   </xsl:template>

	  <!--RULE DOMEX-ID-00004-R2-->
<xsl:template match="tdf:StructuredStatement/*[namespace-uri() = 'urn:CellexReport']"
                 priority="1001"
                 mode="M14">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="tdf:StructuredStatement/*[namespace-uri() = 'urn:CellexReport']"
                       id="DOMEX-ID-00004-R2"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="//tdf:Assertion/tdf:StructuredStatement/irm:ICResourceMetadataPackage"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="//tdf:Assertion/tdf:StructuredStatement/irm:ICResourceMetadataPackage">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[DOMEX_ID_00004][Error] If a TrustedDataObject element contains a DOMEX assertion, 
            it must also contain an assertion with an IRM structured statement. 
            
            Human Readable: If a Trusted Data Object contains a DOMEX assertion, it must also contain an IRM assertion.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M14"/>
   </xsl:template>

	  <!--RULE DOMEX-ID-00004-R3-->
<xsl:template match="tdf:StructuredStatement/*[namespace-uri() = 'urn:us:mil:ces:metadata:domex_identity']"
                 priority="1000"
                 mode="M14">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="tdf:StructuredStatement/*[namespace-uri() = 'urn:us:mil:ces:metadata:domex_identity']"
                       id="DOMEX-ID-00004-R3"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="//tdf:Assertion/tdf:StructuredStatement/irm:ICResourceMetadataPackage"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="//tdf:Assertion/tdf:StructuredStatement/irm:ICResourceMetadataPackage">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[DOMEX_ID_00004][Error] If a TrustedDataObject element contains a DOMEX assertion, 
            it must also contain an assertion with an IRM structured statement. 
            
            Human Readable: If a Trusted Data Object contains a DOMEX assertion, it must also contain an IRM assertion.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M14"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M14"/>
   <xsl:template match="@*|node()" priority="-2" mode="M14">
      <xsl:apply-templates select="*" mode="M14"/>
   </xsl:template>

   <!--PATTERN DOMEX-ID-00005-->


	<!--RULE DOMEX-ID-00005-R1-->
<xsl:template match="*[@irm:codespace]" priority="1000" mode="M15">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@irm:codespace]"
                       id="DOMEX-ID-00005-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="some $term in document(concat('../../CVE/IC-GENC/CVEnum',upper-case(substring(./@irm:codespace,1,1)),translate(substring(./@irm:codespace,2),':',''),'.xml'))//cve:CVE/cve:Enumeration/cve:Term/cve:Value              satisfies $term=./@irm:code"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="some $term in document(concat('../../CVE/IC-GENC/CVEnum',upper-case(substring(./@irm:codespace,1,1)),translate(substring(./@irm:codespace,2),':',''),'.xml'))//cve:CVE/cve:Enumeration/cve:Term/cve:Value satisfies $term=./@irm:code">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [DOMEX_ID_00005] [Error] Invalid GENC code.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M15"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M15"/>
   <xsl:template match="@*|node()" priority="-2" mode="M15">
      <xsl:apply-templates select="*" mode="M15"/>
   </xsl:template>

   <!--PATTERN DOMEX-ID-00006-->


	<!--RULE DOMEX-ID-00006-R1-->
<xsl:template match="*[./domex:subAgency]" priority="1000" mode="M16">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[./domex:subAgency]"
                       id="DOMEX-ID-00006-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="some $term in document(concat('../../CVE/DOMEX/CVEnumDOMEXAgency',substring-after(./domex:primaryAgency,'USA.'),'.xml'))//cve:CVE/cve:Enumeration/cve:Term/cve:Value              satisfies $term=./domex:subAgency"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="some $term in document(concat('../../CVE/DOMEX/CVEnumDOMEXAgency',substring-after(./domex:primaryAgency,'USA.'),'.xml'))//cve:CVE/cve:Enumeration/cve:Term/cve:Value satisfies $term=./domex:subAgency">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [DOMEX_ID_00006] [Error] Invalid sub-agency code.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M16"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M16"/>
   <xsl:template match="@*|node()" priority="-2" mode="M16">
      <xsl:apply-templates select="*" mode="M16"/>
   </xsl:template>

   <!--PATTERN DOMEX-ID-00007-->


	<!--RULE DOMEX-ID-00007-R1-->
<xsl:template match="domex:subActivity" priority="1000" mode="M17">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="domex:subActivity"
                       id="DOMEX-ID-00007-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="some $term in document(concat('../../CVE/DOMEX/CVEnumDOMEXActivity',translate(../domex:primaryActivity,' ,',''),'.xml'))//cve:CVE/cve:Enumeration/cve:Term/cve:Value satisfies $term=."/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="some $term in document(concat('../../CVE/DOMEX/CVEnumDOMEXActivity',translate(../domex:primaryActivity,' ,',''),'.xml'))//cve:CVE/cve:Enumeration/cve:Term/cve:Value satisfies $term=.">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [DOMEX_ID_00007] [Error] Invalid sub-activity specified.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M17"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M17"/>
   <xsl:template match="@*|node()" priority="-2" mode="M17">
      <xsl:apply-templates select="*" mode="M17"/>
   </xsl:template>

   <!--PATTERN DOMEX-ID-00008-->


	<!--RULE DOMEX-ID-00008-R1-->
<xsl:template match="tdf:StructuredStatement/*[namespace-uri() = 'urn:us:mil:ces:metadata:domex']"
                 priority="1002"
                 mode="M18">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="tdf:StructuredStatement/*[namespace-uri() = 'urn:us:mil:ces:metadata:domex']"
                       id="DOMEX-ID-00008-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="@domex:DESVersion"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@domex:DESVersion">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> 
            [DOMEX_ID_00008][Error] The root element of a DOMEX assertion must contain a DESVersion attribute. 
            
            Human Readable: The root element of a DOMEX assertion must contain a DESVersion attribute. 
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M18"/>
   </xsl:template>

	  <!--RULE DOMEX-ID-00008-R2-->
<xsl:template match="tdf:StructuredStatement/*[namespace-uri() = 'urn:CellexReport']"
                 priority="1001"
                 mode="M18">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="tdf:StructuredStatement/*[namespace-uri() = 'urn:CellexReport']"
                       id="DOMEX-ID-00008-R2"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="@cr:DESVersion"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@cr:DESVersion">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [DOMEX_ID_00008][Error] The root element of a DOMEX assertion must contain a DESVersion attribute. 
            
            Human Readable: The root element of a DOMEX assertion must contain a DESVersion attribute. 
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M18"/>
   </xsl:template>

	  <!--RULE DOMEX-ID-00008-R3-->
<xsl:template match="tdf:StructuredStatement/*[namespace-uri() = 'urn:us:mil:ces:metadata:domex_identity']"
                 priority="1000"
                 mode="M18">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="tdf:StructuredStatement/*[namespace-uri() = 'urn:us:mil:ces:metadata:domex_identity']"
                       id="DOMEX-ID-00008-R3"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="@Identity:DESVersion"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@Identity:DESVersion">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [DOMEX_ID_00008][Error] The root element of a DOMEX assertion must contain a DESVersion attribute. 
            
            Human Readable: The root element of a DOMEX assertion must contain a DESVersion attribute. </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M18"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M18"/>
   <xsl:template match="@*|node()" priority="-2" mode="M18">
      <xsl:apply-templates select="*" mode="M18"/>
   </xsl:template>

   <!--PATTERN DOMEX-ID-00009-->


	<!--RULE DOMEX-ID-00009-R1-->
<xsl:template match="tdf:StructuredStatement/*[namespace-uri() = 'urn:us:mil:ces:metadata:domex']"
                 priority="1002"
                 mode="M19">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="tdf:StructuredStatement/*[namespace-uri() = 'urn:us:mil:ces:metadata:domex']"
                       id="DOMEX-ID-00009-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="../../@tdf:scope='TDO' or ../../@tdf:scope='TDC'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="../../@tdf:scope='TDO' or ../../@tdf:scope='TDC'">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> 
            [DOMEX_ID_00009][Error] The DOMEX assertion must have a scope of either TDO or TDC.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M19"/>
   </xsl:template>

	  <!--RULE DOMEX-ID-00009-R2-->
<xsl:template match="tdf:StructuredStatement/*[namespace-uri() = 'urn:CellexReport']"
                 priority="1001"
                 mode="M19">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="tdf:StructuredStatement/*[namespace-uri() = 'urn:CellexReport']"
                       id="DOMEX-ID-00009-R2"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="../../@tdf:scope='TDO' or ../../@tdf:scope='TDC'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="../../@tdf:scope='TDO' or ../../@tdf:scope='TDC'">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [DOMEX_ID_00009][Error] The DOMEX assertion must have a scope of either TDO or TDC.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M19"/>
   </xsl:template>

	  <!--RULE DOMEX-ID-00009-R3-->
<xsl:template match="tdf:StructuredStatement/*[namespace-uri() = 'urn:us:mil:ces:metadata:domex_identity']"
                 priority="1000"
                 mode="M19">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="tdf:StructuredStatement/*[namespace-uri() = 'urn:us:mil:ces:metadata:domex_identity']"
                       id="DOMEX-ID-00009-R3"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="../../@tdf:scope='TDO' or ../../@tdf:scope='TDC'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="../../@tdf:scope='TDO' or ../../@tdf:scope='TDC'">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [DOMEX_ID_00009][Error The DOMEX assertion must have a scope of either TDO or TDC.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M19"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M19"/>
   <xsl:template match="@*|node()" priority="-2" mode="M19">
      <xsl:apply-templates select="*" mode="M19"/>
   </xsl:template>

   <!--PATTERN DOMEX-ID-00010-->


	<!--RULE ValidateValidationEnvSchema-R1-->
<xsl:template match="/" priority="1000" mode="M20">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/"
                       id="ValidateValidationEnvSchema-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="document('../../Schema/IRM/IC-IRM.xsd')//xsd:schema//@version castable as xs:double              and document('../../Schema/IRM/IC-IRM.xsd')//xsd:schema//@version &gt;= '202111'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="document('../../Schema/IRM/IC-IRM.xsd')//xsd:schema//@version castable as xs:double and document('../../Schema/IRM/IC-IRM.xsd')//xsd:schema//@version &gt;= '202111'">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> 
            [<xsl:text/>
                  <xsl:value-of select="'DOMEX-ID-00010'"/>
                  <xsl:text/>][Error] Version [ <xsl:text/>
                  <xsl:value-of select="document('../../Schema/IRM/IC-IRM.xsd')//xsd:schema//@version"/>
                  <xsl:text/> ] of <xsl:text/>
                  <xsl:value-of select="'IRM'"/>
                  <xsl:text/> found; 
            Version [<xsl:text/>
                  <xsl:value-of select="'202111'"/>
                  <xsl:text/>] or later is required. The latest version of <xsl:text/>
                  <xsl:value-of select="'IRM'"/>
                  <xsl:text/> 
            is not being used in the validation infrastructure. Regardless of the version indicated on the instance document, 
            the validation infrastructure needs to use a version of <xsl:text/>
                  <xsl:value-of select="'IRM'"/>
                  <xsl:text/> that is
            version [<xsl:text/>
                  <xsl:value-of select="'202111'"/>
                  <xsl:text/>] or later. NOTE: This is not an error of the instance
            document but of the validation environment itself. The incorrect value was found in <xsl:text/>
                  <xsl:value-of select="document-uri(document('../../Schema/IRM/IC-IRM.xsd'))"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M20"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M20"/>
   <xsl:template match="@*|node()" priority="-2" mode="M20">
      <xsl:apply-templates select="*" mode="M20"/>
   </xsl:template>

   <!--PATTERN DOMEX-ID-00011-->


	<!--RULE ValidateValidationEnvSchema-R1-->
<xsl:template match="/" priority="1000" mode="M21">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/"
                       id="ValidateValidationEnvSchema-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="document('../../Schema/IC-EDH/IC-EDH.xsd')//xsd:schema//@version castable as xs:double              and document('../../Schema/IC-EDH/IC-EDH.xsd')//xsd:schema//@version &gt;= '201903'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="document('../../Schema/IC-EDH/IC-EDH.xsd')//xsd:schema//@version castable as xs:double and document('../../Schema/IC-EDH/IC-EDH.xsd')//xsd:schema//@version &gt;= '201903'">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> 
            [<xsl:text/>
                  <xsl:value-of select="'DOMEX-ID-00011'"/>
                  <xsl:text/>][Error] Version [ <xsl:text/>
                  <xsl:value-of select="document('../../Schema/IC-EDH/IC-EDH.xsd')//xsd:schema//@version"/>
                  <xsl:text/> ] of <xsl:text/>
                  <xsl:value-of select="'IC-EDH'"/>
                  <xsl:text/> found; 
            Version [<xsl:text/>
                  <xsl:value-of select="'201903'"/>
                  <xsl:text/>] or later is required. The latest version of <xsl:text/>
                  <xsl:value-of select="'IC-EDH'"/>
                  <xsl:text/> 
            is not being used in the validation infrastructure. Regardless of the version indicated on the instance document, 
            the validation infrastructure needs to use a version of <xsl:text/>
                  <xsl:value-of select="'IC-EDH'"/>
                  <xsl:text/> that is
            version [<xsl:text/>
                  <xsl:value-of select="'201903'"/>
                  <xsl:text/>] or later. NOTE: This is not an error of the instance
            document but of the validation environment itself. The incorrect value was found in <xsl:text/>
                  <xsl:value-of select="document-uri(document('../../Schema/IC-EDH/IC-EDH.xsd'))"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M21"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M21"/>
   <xsl:template match="@*|node()" priority="-2" mode="M21">
      <xsl:apply-templates select="*" mode="M21"/>
   </xsl:template>

   <!--PATTERN DOMEX-ID-00012-->


	<!--RULE DOMEX-ID-00012-R1-->
<xsl:template match="tdf:StructuredStatement/*[namespace-uri() = 'urn:us:mil:ces:metadata:domex']"
                 priority="1002"
                 mode="M22">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="tdf:StructuredStatement/*[namespace-uri() = 'urn:us:mil:ces:metadata:domex']"
                       id="DOMEX-ID-00012-R1"/>

		    <!--ASSERT warning-->
<xsl:choose>
         <xsl:when test="matches(@domex:DESVersion, '^202111(\-.{1,23})?$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches(@domex:DESVersion, '^202111(\-.{1,23})?$')">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> [DOMEX_ID_00012][Warning] DESVersion attribute SHOULD be specified as
            version 202111 (Version:2021-NOV) with an optional extension. The value provided was:
            <xsl:text/>
                  <xsl:value-of select="@domex:DESVersion"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M22"/>
   </xsl:template>

	  <!--RULE DOMEX-ID-00012-R2-->
<xsl:template match="tdf:StructuredStatement/*[namespace-uri() = 'urn:CellexReport']"
                 priority="1001"
                 mode="M22">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="tdf:StructuredStatement/*[namespace-uri() = 'urn:CellexReport']"
                       id="DOMEX-ID-00012-R2"/>

		    <!--ASSERT Warning-->
<xsl:choose>
         <xsl:when test="matches(@cr:DESVersion, '^202111(\-.{1,23})?$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches(@cr:DESVersion, '^202111(\-.{1,23})?$')">
               <xsl:attribute name="flag">Warning</xsl:attribute>
               <xsl:attribute name="role">Warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> [DOMEX_ID_00012][Warning] DESVersion attribute SHOULD be specified as
            version 202111 (Version:2021-NOV) with an optional extension. The value provided was:
            <xsl:text/>
                  <xsl:value-of select="@cr:DESVersion"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M22"/>
   </xsl:template>

	  <!--RULE DOMEX-ID-00012-R3-->
<xsl:template match="tdf:StructuredStatement/*[namespace-uri() = 'urn:us:mil:ces:metadata:domex_identity']"
                 priority="1000"
                 mode="M22">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="tdf:StructuredStatement/*[namespace-uri() = 'urn:us:mil:ces:metadata:domex_identity']"
                       id="DOMEX-ID-00012-R3"/>

		    <!--ASSERT Warning-->
<xsl:choose>
         <xsl:when test="matches(@Identity:DESVersion, '^202111(\-.{1,23})?$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches(@Identity:DESVersion, '^202111(\-.{1,23})?$')">
               <xsl:attribute name="flag">Warning</xsl:attribute>
               <xsl:attribute name="role">Warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> [DOMEX_ID_00012][Warning] DESVersion attribute SHOULD be specified as
            version 202111 (Version:2021-NOV) with an optional extension. The value provided was:
            <xsl:text/>
                  <xsl:value-of select="@Identity:DESVersion"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M22"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M22"/>
   <xsl:template match="@*|node()" priority="-2" mode="M22">
      <xsl:apply-templates select="*" mode="M22"/>
   </xsl:template>

   <!--PATTERN DOMEX-ID-00013-->


	<!--RULE ValidateValidationEnvCVE-R1-->
<xsl:template match="/" priority="1000" mode="M23">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/"
                       id="ValidateValidationEnvCVE-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="document('../../CVE/USAgency/CVEnumUSAgencyAcronym.xml')//cve:CVE//@specVersion castable as xs:double              and document('../../CVE/USAgency/CVEnumUSAgencyAcronym.xml')//cve:CVE//@specVersion &gt;= '201703.201802'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="document('../../CVE/USAgency/CVEnumUSAgencyAcronym.xml')//cve:CVE//@specVersion castable as xs:double and document('../../CVE/USAgency/CVEnumUSAgencyAcronym.xml')//cve:CVE//@specVersion &gt;= '201703.201802'">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> 
            [<xsl:text/>
                  <xsl:value-of select="'DOMEX-ID-00013'"/>
                  <xsl:text/>][Error] Version [ <xsl:text/>
                  <xsl:value-of select="document('../../CVE/USAgency/CVEnumUSAgencyAcronym.xml')//cve:CVE//@specVersion"/>
                  <xsl:text/> ] of <xsl:text/>
                  <xsl:value-of select="'USAgency'"/>
                  <xsl:text/> found; 
            Version [<xsl:text/>
                  <xsl:value-of select="'201703.201802'"/>
                  <xsl:text/>] or later is required. The latest version of <xsl:text/>
                  <xsl:value-of select="'USAgency'"/>
                  <xsl:text/> 
            is not being used in the validation infrastructure. Regardless of the version indicated on the instance document, 
            the validation infrastructure needs to use a version of <xsl:text/>
                  <xsl:value-of select="'USAgency'"/>
                  <xsl:text/> that is
            version [<xsl:text/>
                  <xsl:value-of select="'201703.201802'"/>
                  <xsl:text/>] or later. NOTE: This is not an error of the instance
            document but of the validation environment itself. The incorrect value was found in <xsl:text/>
                  <xsl:value-of select="document-uri(document('../../CVE/USAgency/CVEnumUSAgencyAcronym.xml'))"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M23"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M23"/>
   <xsl:template match="@*|node()" priority="-2" mode="M23">
      <xsl:apply-templates select="*" mode="M23"/>
   </xsl:template>

   <!--PATTERN DOMEX-ID-00014-->


	<!--RULE ValidateValidationEnvCVE-R1-->
<xsl:template match="/" priority="1000" mode="M24">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/"
                       id="ValidateValidationEnvCVE-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="document('../../CVE/MIME/CVEnumMIMEType.xml')//cve:CVE//@specVersion castable as xs:double              and document('../../CVE/MIME/CVEnumMIMEType.xml')//cve:CVE//@specVersion &gt;= '202010'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="document('../../CVE/MIME/CVEnumMIMEType.xml')//cve:CVE//@specVersion castable as xs:double and document('../../CVE/MIME/CVEnumMIMEType.xml')//cve:CVE//@specVersion &gt;= '202010'">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> 
            [<xsl:text/>
                  <xsl:value-of select="'DOMEX-ID-00014'"/>
                  <xsl:text/>][Error] Version [ <xsl:text/>
                  <xsl:value-of select="document('../../CVE/MIME/CVEnumMIMEType.xml')//cve:CVE//@specVersion"/>
                  <xsl:text/> ] of <xsl:text/>
                  <xsl:value-of select="'MIME'"/>
                  <xsl:text/> found; 
            Version [<xsl:text/>
                  <xsl:value-of select="'202010'"/>
                  <xsl:text/>] or later is required. The latest version of <xsl:text/>
                  <xsl:value-of select="'MIME'"/>
                  <xsl:text/> 
            is not being used in the validation infrastructure. Regardless of the version indicated on the instance document, 
            the validation infrastructure needs to use a version of <xsl:text/>
                  <xsl:value-of select="'MIME'"/>
                  <xsl:text/> that is
            version [<xsl:text/>
                  <xsl:value-of select="'202010'"/>
                  <xsl:text/>] or later. NOTE: This is not an error of the instance
            document but of the validation environment itself. The incorrect value was found in <xsl:text/>
                  <xsl:value-of select="document-uri(document('../../CVE/MIME/CVEnumMIMEType.xml'))"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M24"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M24"/>
   <xsl:template match="@*|node()" priority="-2" mode="M24">
      <xsl:apply-templates select="*" mode="M24"/>
   </xsl:template>
</xsl:stylesheet>
<!--UNCLASSIFIED-->
