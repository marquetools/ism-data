<?xml version="1.0" encoding="UTF-8"?>
<!--UNCLASSIFIED--><xsl:stylesheet xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:saxon="http://saxon.sf.net/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:schold="http://www.ascc.net/xml/schematron"
                xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:ded="urn:us:gov:ic:ded"
                xmlns:ism="urn:us:gov:ic:ism"
                xmlns:icid="urn:us:gov:ic:id"
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
        declares some variables, and includes all of the Rule .sch files.</svrl:text>
         <svrl:ns-prefix-in-attribute-values uri="urn:us:gov:ic:ded" prefix="ded"/>
         <svrl:ns-prefix-in-attribute-values uri="urn:us:gov:ic:ism" prefix="ism"/>
         <svrl:ns-prefix-in-attribute-values uri="urn:us:gov:ic:id" prefix="icid"/>
         <svrl:ns-prefix-in-attribute-values uri="urn:us:gov:ic:cve" prefix="cve"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">DED-ID-00001</xsl:attribute>
            <xsl:attribute name="name">DED-ID-00001</xsl:attribute>
            <svrl:text>
        [DED-ID-00001][warning] The ded:DESVersion attribute SHOULD be specified as version 201903 (Version:2019-MAR) with an optional extension.
    </svrl:text>
            <svrl:text>
        For each element with attribute DED:DESVersion specified, this rule ensures that the value
        matches the version of this rule set.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M5"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">DED-ID-00002</xsl:attribute>
            <xsl:attribute name="name">DED-ID-00002</xsl:attribute>
            <svrl:text>
        [DED-ID-00002][Error] @icid:DESVersion must be declared.
    </svrl:text>
            <svrl:text>
        Check to verify that there exists a declaration of version for IC-ID.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M6"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">DED-ID-00003</xsl:attribute>
            <xsl:attribute name="name">DED-ID-00003</xsl:attribute>
            <svrl:text>
        This abstract pattern checks to see if the validation environment has at least the version / revision of the
        Schema as of the writing of this specification. 
        The calling rule must pass in '1', 'IC-ID', '../../Schema/IC-ID/IC-ID.xsd', 'DED-ID-00003'.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M7"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">DED-ID-00004</xsl:attribute>
            <xsl:attribute name="name">DED-ID-00004</xsl:attribute>
            <svrl:text>
        This abstract pattern checks to see if the validation environment has at least the version / revision of the
        Schema as of the writing of this specification. 
        The calling rule must pass in '201903', 'IC-EDH', '../../Schema/IC-EDH/IC-EDH.xsd', 'DED-ID-00004'.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M8"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">DED-ID-00005</xsl:attribute>
            <xsl:attribute name="name">DED-ID-00005</xsl:attribute>
            <svrl:text>
        This abstract pattern checks to see if the validation environment has at least the version / revision of the
        CVE as of the writing of this specification. 
        The calling rule must pass in '201903', 'ISM', '../../CVE/ISM/CVEnumISMClassificationAll.xml', 'DED-ID-00005'.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M9"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">DED-ID-00006</xsl:attribute>
            <xsl:attribute name="name">DED-ID-00006</xsl:attribute>
            <svrl:text>
        [DED-ID-00006][Error] If ded:ElementObligation has the value of ‘Conditional” then ded:ElementRestrictions must exist.
    </svrl:text>
            <svrl:text>
        For ded:DataElements with ded:ElementObligation with the value of ‘Conditional”, ded:ElementRestrictions must exist.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M10"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">DED-ID-00007</xsl:attribute>
            <xsl:attribute name="name">DED-ID-00007</xsl:attribute>
            <svrl:text>
        [DED-ID-00007][Warning] For every optional element that exists in the 
        document and can have text content, the element should have non-null, 
        non-whitespace value.
    </svrl:text>
            <svrl:text>
        This pattern uses an abstract rule to consolidate logic. The abstract rule
        first concatenates the text values within the given element, separated by a single 
        space. The resultant string is then normalized with leading and trailing 
        whitespace removed, and the length of the string is determined to be greater 
        than zero, which indicates non-whitespace content. The abstract rule is extended 
        once for each optional element in the DED schema.  
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M11"/>
      </svrl:schematron-output>
   </xsl:template>

   <!--SCHEMATRON PATTERNS-->


<!--PATTERN DED-ID-00001-->


	<!--RULE DED-ID-00001-R1-->
<xsl:template match="*[@ded:DESVersion]" priority="1000" mode="M5">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ded:DESVersion]"
                       id="DED-ID-00001-R1"/>

		    <!--ASSERT warning-->
<xsl:choose>
         <xsl:when test="matches(@ded:DESVersion, '^201903(\-.{1,23})?$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches(@ded:DESVersion, '^201903(\-.{1,23})?$')">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [DED-ID-00001][warning] The ded:DESVersion attribute SHOULD be specified as version 201903 (Version:2019-MAR) with an optional extension. The value provided was: <xsl:text/>
                  <xsl:value-of select="@ded:DESVersion"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M5"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M5"/>
   <xsl:template match="@*|node()" priority="-2" mode="M5">
      <xsl:apply-templates select="*" mode="M5"/>
   </xsl:template>

   <!--PATTERN DED-ID-00002-->


	<!--RULE DED-ID-00002-R1-->
<xsl:template match="/*" priority="1000" mode="M6">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/*"
                       id="DED-ID-00002-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="exists(//*[@icid:DESVersion])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="exists(//*[@icid:DESVersion])">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [DED-ID-00002][Error] @icid:DESVersion must be declared.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M6"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M6"/>
   <xsl:template match="@*|node()" priority="-2" mode="M6">
      <xsl:apply-templates select="*" mode="M6"/>
   </xsl:template>

   <!--PATTERN DED-ID-00003-->


	<!--RULE ValidateValidationEnvSchema-R1-->
<xsl:template match="/" priority="1000" mode="M7">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/"
                       id="ValidateValidationEnvSchema-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="document('../../Schema/IC-ID/IC-ID.xsd')//xsd:schema//@version castable as xs:double              and document('../../Schema/IC-ID/IC-ID.xsd')//xsd:schema//@version &gt;= '1'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="document('../../Schema/IC-ID/IC-ID.xsd')//xsd:schema//@version castable as xs:double and document('../../Schema/IC-ID/IC-ID.xsd')//xsd:schema//@version &gt;= '1'">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> 
            Version [ <xsl:text/>
                  <xsl:value-of select="document('../../Schema/IC-ID/IC-ID.xsd')//xsd:schema//@version"/>
                  <xsl:text/> ] of <xsl:text/>
                  <xsl:value-of select="'IC-ID'"/>
                  <xsl:text/> found; 
            Version [<xsl:text/>
                  <xsl:value-of select="'1'"/>
                  <xsl:text/>] or later is required. The latest version of <xsl:text/>
                  <xsl:value-of select="'IC-ID'"/>
                  <xsl:text/> 
            is not being used in the validation infrastructure. Regardless of the version indicated on the instance document, 
            the validation infrastructure needs to use a version of <xsl:text/>
                  <xsl:value-of select="'IC-ID'"/>
                  <xsl:text/> that is
            version [<xsl:text/>
                  <xsl:value-of select="'1'"/>
                  <xsl:text/>] or later. NOTE: This is not an error of the instance
            document but of the validation environment itself. The incorrect value was found in <xsl:text/>
                  <xsl:value-of select="document-uri(document('../../Schema/IC-ID/IC-ID.xsd'))"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M7"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M7"/>
   <xsl:template match="@*|node()" priority="-2" mode="M7">
      <xsl:apply-templates select="*" mode="M7"/>
   </xsl:template>

   <!--PATTERN DED-ID-00004-->


	<!--RULE ValidateValidationEnvSchema-R1-->
<xsl:template match="/" priority="1000" mode="M8">
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
            Version [ <xsl:text/>
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
      <xsl:apply-templates select="*" mode="M8"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M8"/>
   <xsl:template match="@*|node()" priority="-2" mode="M8">
      <xsl:apply-templates select="*" mode="M8"/>
   </xsl:template>

   <!--PATTERN DED-ID-00005-->


	<!--RULE ValidateValidationEnvCVE-R1-->
<xsl:template match="/" priority="1000" mode="M9">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/"
                       id="ValidateValidationEnvCVE-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="document('../../CVE/ISM/CVEnumISMClassificationAll.xml')//cve:CVE//@specVersion castable as xs:double              and document('../../CVE/ISM/CVEnumISMClassificationAll.xml')//cve:CVE//@specVersion &gt;= '201903'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="document('../../CVE/ISM/CVEnumISMClassificationAll.xml')//cve:CVE//@specVersion castable as xs:double and document('../../CVE/ISM/CVEnumISMClassificationAll.xml')//cve:CVE//@specVersion &gt;= '201903'">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> 
            Version [ <xsl:text/>
                  <xsl:value-of select="document('../../CVE/ISM/CVEnumISMClassificationAll.xml')//cve:CVE//@specVersion"/>
                  <xsl:text/> ] of <xsl:text/>
                  <xsl:value-of select="'ISM'"/>
                  <xsl:text/> found; 
            Version [<xsl:text/>
                  <xsl:value-of select="'201903'"/>
                  <xsl:text/>] or later is required. The latest version of <xsl:text/>
                  <xsl:value-of select="'ISM'"/>
                  <xsl:text/> 
            is not being used in the validation infrastructure. Regardless of the version indicated on the instance document, 
            the validation infrastructure needs to use a version of <xsl:text/>
                  <xsl:value-of select="'ISM'"/>
                  <xsl:text/> that is
            version [<xsl:text/>
                  <xsl:value-of select="'201903'"/>
                  <xsl:text/>] or later. NOTE: This is not an error of the instance
            document but of the validation environment itself. The incorrect value was found in <xsl:text/>
                  <xsl:value-of select="document-uri(document('../../CVE/ISM/CVEnumISMClassificationAll.xml'))"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M9"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M9"/>
   <xsl:template match="@*|node()" priority="-2" mode="M9">
      <xsl:apply-templates select="*" mode="M9"/>
   </xsl:template>

   <!--PATTERN DED-ID-00006-->


	<!--RULE DED-ID-00006-R1-->
<xsl:template match="ded:DataElement[ded:ElementObligation/text()='Conditional']"
                 priority="1000"
                 mode="M10">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="ded:DataElement[ded:ElementObligation/text()='Conditional']"
                       id="DED-ID-00006-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="ded:ElementRestrictions"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="ded:ElementRestrictions">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [DED-ID-00006][Error] If ded:ElementObligation has the value of ‘Conditional” then ded:ElementRestrictions must exist.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M10"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M10"/>
   <xsl:template match="@*|node()" priority="-2" mode="M10">
      <xsl:apply-templates select="*" mode="M10"/>
   </xsl:template>

   <!--PATTERN DED-ID-00007-->


	<!--RULE DED-ID-00007-R1-->
<xsl:template match="ded:ElementRestriction" priority="1000" mode="M11">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="ded:ElementRestriction"
                       id="DED-ID-00007-R1"/>

		    <!--ASSERT warning-->
<xsl:choose>
         <xsl:when test="normalize-space(string())"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="normalize-space(string())">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [DED-ID-00007][Warning] For every optional element that exists in the 
            document and can have text content, the element should have non-null, 
            non-whitespace value.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M11"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M11"/>
   <xsl:template match="@*|node()" priority="-2" mode="M11">
      <xsl:apply-templates select="*" mode="M11"/>
   </xsl:template>
</xsl:stylesheet>
<!--UNCLASSIFIED-->
