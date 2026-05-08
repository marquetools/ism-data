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
                xmlns:tdf="urn:us:gov:ic:tdf"
                xmlns:cve="urn:us:gov:ic:cve"
                xmlns:dhzm="urn:us:gov:ic:digitalhazmat"
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
         <svrl:ns-prefix-in-attribute-values uri="http://www.w3.org/1999/xlink" prefix="xlink"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.w3.org/2001/XMLSchema" prefix="xs"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.w3.org/1999/XSL/Transform" prefix="xsl"/>
         <svrl:ns-prefix-in-attribute-values uri="urn:us:gov:ic:ism" prefix="ism"/>
         <svrl:ns-prefix-in-attribute-values uri="urn:us:gov:ic:tdf" prefix="tdf"/>
         <svrl:ns-prefix-in-attribute-values uri="urn:us:gov:ic:cve" prefix="cve"/>
         <svrl:ns-prefix-in-attribute-values uri="urn:us:gov:ic:digitalhazmat" prefix="dhzm"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">DHZMC-TDF-ID-00001</xsl:attribute>
            <xsl:attribute name="name">DHZMC-TDF-ID-00001</xsl:attribute>
            <svrl:text>
        [DHZMC-TDF-ID-00001][Warning] tdf:version attribute SHOULD be specified as version 202111-DHZMC-TDF.202111 
        with an optional extension.
    </svrl:text>
            <svrl:text>
        This rule supports extending the version identifier with an optional trailing hyphen
        and up to 23 additional characters. The version must match the regular expression
        “^202111-DHZMC-TDF.202111(-.{1,23})?$".
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M8"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">DHZMC-TDF-ID-00002</xsl:attribute>
            <xsl:attribute name="name">DHZMC-TDF-ID-00002</xsl:attribute>
            <svrl:text>
        This abstract pattern checks to see if the validation environment has at least the version / revision of the
        Schema as of the writing of this specification. 
        The calling rule must pass in '202111', 'IC-SF', '../../Schema/IC-SF/IC-SF.xsd', 'DHZMC-TDF-ID-00002'.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M9"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">DHZMC-TDF-ID-00003</xsl:attribute>
            <xsl:attribute name="name">DHZMC-TDF-ID-00003</xsl:attribute>
            <svrl:text>
        This abstract pattern checks to see if the validation environment has at least the version / revision of the
        Schema as of the writing of this specification. 
        The calling rule must pass in '202111', 'BASE-TDF', '../../Schema/BASE-TDF/BASE-TDF.xsd', 'DHZMC-TDF-ID-00003'.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M10"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">DHZMC-TDF-ID-00004</xsl:attribute>
            <xsl:attribute name="name">DHZMC-TDF-ID-00004</xsl:attribute>
            <svrl:text>
        This abstract pattern checks to see if the validation environment has at least the version / revision of the
        Schema as of the writing of this specification. 
        The calling rule must pass in '202111', 'DHZM', '../../Schema/DHZM/DHZM.xsd', 'DHZMC-TDF-ID-00004'.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M11"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">DHZMC-TDF-ID-00005</xsl:attribute>
            <xsl:attribute name="name">DHZMC-TDF-ID-00005</xsl:attribute>
            <svrl:text>
        This abstract pattern checks to see if the validation environment has at least the version / revision of the
        Schema as of the writing of this specification. 
        The calling rule must pass in '202111', 'ANLYS', '../../Schema/ANLYS/ANLYS.xsd', 'DHZMC-TDF-ID-00005'.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M12"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">DHZMC-TDF-ID-00006</xsl:attribute>
            <xsl:attribute name="name">DHZMC-TDF-ID-00006</xsl:attribute>
            <svrl:text> 
        [DHZMC-TDF-ID-00006][Error] In a DHZMC-TDF TDO, there must be a dhzm:DigitalHazMatAssertion and only 1 of them.
    </svrl:text>
            <svrl:text>
        In a DHZMC-TDF tdf:TrustedDataObject, there must be a dhzm:DigitalHazMatAssertion and only 1 of them.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M13"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">DHZMC-TDF-ID-00007</xsl:attribute>
            <xsl:attribute name="name">DHZMC-TDF-ID-00007</xsl:attribute>
            <svrl:text> 
        [DHZMC-TDF-ID-00007][Warning] In a DHZMC-TDF TDO, dhzm:DigitalHazMatAssertion must be the first tdf:Assertion.
    </svrl:text>
            <svrl:text>
        In a DHZMC-TDF tdf:TrustedDataObject, dhzm:DigitalHazMatAssertion must be the first tdf:Assertion.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M14"/>
      </svrl:schematron-output>
   </xsl:template>

   <!--SCHEMATRON PATTERNS-->


<!--PATTERN DHZMC-TDF-ID-00001-->


	<!--RULE DHZMC-TDF-ID-00001-R1-->
<xsl:template match="*[@tdf:version]" priority="1000" mode="M8">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@tdf:version]"
                       id="DHZMC-TDF-ID-00001-R1"/>

		    <!--ASSERT warning-->
<xsl:choose>
         <xsl:when test="matches(@tdf:version,'^202111-DHZMC-TDF.202111(\-.{1,23})?$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches(@tdf:version,'^202111-DHZMC-TDF.202111(\-.{1,23})?$')">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [DHZMC-TDF-ID-00001][Warning] tdf:version attribute SHOULD be specified as version 202111-DHZMC-TDF.202111 
            with an optional extension. 
            The value provided was: <xsl:text/>
                  <xsl:value-of select="./@tdf:version"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M8"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M8"/>
   <xsl:template match="@*|node()" priority="-2" mode="M8">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M8"/>
   </xsl:template>

   <!--PATTERN DHZMC-TDF-ID-00002-->


	<!--RULE ValidateValidationEnvSchema-R1-->
<xsl:template match="/" priority="1000" mode="M9">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/"
                       id="ValidateValidationEnvSchema-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="document('../../Schema/IC-SF/IC-SF.xsd')//xsd:schema//@version castable as xs:double              and document('../../Schema/IC-SF/IC-SF.xsd')//xsd:schema//@version &gt;= '202111'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="document('../../Schema/IC-SF/IC-SF.xsd')//xsd:schema//@version castable as xs:double and document('../../Schema/IC-SF/IC-SF.xsd')//xsd:schema//@version &gt;= '202111'">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> 
            [<xsl:text/>
                  <xsl:value-of select="'DHZMC-TDF-ID-00002'"/>
                  <xsl:text/>][Error] Version [ <xsl:text/>
                  <xsl:value-of select="document('../../Schema/IC-SF/IC-SF.xsd')//xsd:schema//@version"/>
                  <xsl:text/> ] of <xsl:text/>
                  <xsl:value-of select="'IC-SF'"/>
                  <xsl:text/> found; 
            Version [<xsl:text/>
                  <xsl:value-of select="'202111'"/>
                  <xsl:text/>] or later is required. The latest version of <xsl:text/>
                  <xsl:value-of select="'IC-SF'"/>
                  <xsl:text/> 
            is not being used in the validation infrastructure. Regardless of the version indicated on the instance document, 
            the validation infrastructure needs to use a version of <xsl:text/>
                  <xsl:value-of select="'IC-SF'"/>
                  <xsl:text/> that is
            version [<xsl:text/>
                  <xsl:value-of select="'202111'"/>
                  <xsl:text/>] or later. NOTE: This is not an error of the instance
            document but of the validation environment itself. The incorrect value was found in <xsl:text/>
                  <xsl:value-of select="document-uri(document('../../Schema/IC-SF/IC-SF.xsd'))"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M9"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M9"/>
   <xsl:template match="@*|node()" priority="-2" mode="M9">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M9"/>
   </xsl:template>

   <!--PATTERN DHZMC-TDF-ID-00003-->


	<!--RULE ValidateValidationEnvSchema-R1-->
<xsl:template match="/" priority="1000" mode="M10">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/"
                       id="ValidateValidationEnvSchema-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="document('../../Schema/BASE-TDF/BASE-TDF.xsd')//xsd:schema//@version castable as xs:double              and document('../../Schema/BASE-TDF/BASE-TDF.xsd')//xsd:schema//@version &gt;= '202111'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="document('../../Schema/BASE-TDF/BASE-TDF.xsd')//xsd:schema//@version castable as xs:double and document('../../Schema/BASE-TDF/BASE-TDF.xsd')//xsd:schema//@version &gt;= '202111'">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> 
            [<xsl:text/>
                  <xsl:value-of select="'DHZMC-TDF-ID-00003'"/>
                  <xsl:text/>][Error] Version [ <xsl:text/>
                  <xsl:value-of select="document('../../Schema/BASE-TDF/BASE-TDF.xsd')//xsd:schema//@version"/>
                  <xsl:text/> ] of <xsl:text/>
                  <xsl:value-of select="'BASE-TDF'"/>
                  <xsl:text/> found; 
            Version [<xsl:text/>
                  <xsl:value-of select="'202111'"/>
                  <xsl:text/>] or later is required. The latest version of <xsl:text/>
                  <xsl:value-of select="'BASE-TDF'"/>
                  <xsl:text/> 
            is not being used in the validation infrastructure. Regardless of the version indicated on the instance document, 
            the validation infrastructure needs to use a version of <xsl:text/>
                  <xsl:value-of select="'BASE-TDF'"/>
                  <xsl:text/> that is
            version [<xsl:text/>
                  <xsl:value-of select="'202111'"/>
                  <xsl:text/>] or later. NOTE: This is not an error of the instance
            document but of the validation environment itself. The incorrect value was found in <xsl:text/>
                  <xsl:value-of select="document-uri(document('../../Schema/BASE-TDF/BASE-TDF.xsd'))"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M10"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M10"/>
   <xsl:template match="@*|node()" priority="-2" mode="M10">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M10"/>
   </xsl:template>

   <!--PATTERN DHZMC-TDF-ID-00004-->


	<!--RULE ValidateValidationEnvSchema-R1-->
<xsl:template match="/" priority="1000" mode="M11">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/"
                       id="ValidateValidationEnvSchema-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="document('../../Schema/DHZM/DHZM.xsd')//xsd:schema//@version castable as xs:double              and document('../../Schema/DHZM/DHZM.xsd')//xsd:schema//@version &gt;= '202111'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="document('../../Schema/DHZM/DHZM.xsd')//xsd:schema//@version castable as xs:double and document('../../Schema/DHZM/DHZM.xsd')//xsd:schema//@version &gt;= '202111'">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> 
            [<xsl:text/>
                  <xsl:value-of select="'DHZMC-TDF-ID-00004'"/>
                  <xsl:text/>][Error] Version [ <xsl:text/>
                  <xsl:value-of select="document('../../Schema/DHZM/DHZM.xsd')//xsd:schema//@version"/>
                  <xsl:text/> ] of <xsl:text/>
                  <xsl:value-of select="'DHZM'"/>
                  <xsl:text/> found; 
            Version [<xsl:text/>
                  <xsl:value-of select="'202111'"/>
                  <xsl:text/>] or later is required. The latest version of <xsl:text/>
                  <xsl:value-of select="'DHZM'"/>
                  <xsl:text/> 
            is not being used in the validation infrastructure. Regardless of the version indicated on the instance document, 
            the validation infrastructure needs to use a version of <xsl:text/>
                  <xsl:value-of select="'DHZM'"/>
                  <xsl:text/> that is
            version [<xsl:text/>
                  <xsl:value-of select="'202111'"/>
                  <xsl:text/>] or later. NOTE: This is not an error of the instance
            document but of the validation environment itself. The incorrect value was found in <xsl:text/>
                  <xsl:value-of select="document-uri(document('../../Schema/DHZM/DHZM.xsd'))"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M11"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M11"/>
   <xsl:template match="@*|node()" priority="-2" mode="M11">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M11"/>
   </xsl:template>

   <!--PATTERN DHZMC-TDF-ID-00005-->


	<!--RULE ValidateValidationEnvSchema-R1-->
<xsl:template match="/" priority="1000" mode="M12">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/"
                       id="ValidateValidationEnvSchema-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="document('../../Schema/ANLYS/ANLYS.xsd')//xsd:schema//@version castable as xs:double              and document('../../Schema/ANLYS/ANLYS.xsd')//xsd:schema//@version &gt;= '202111'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="document('../../Schema/ANLYS/ANLYS.xsd')//xsd:schema//@version castable as xs:double and document('../../Schema/ANLYS/ANLYS.xsd')//xsd:schema//@version &gt;= '202111'">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> 
            [<xsl:text/>
                  <xsl:value-of select="'DHZMC-TDF-ID-00005'"/>
                  <xsl:text/>][Error] Version [ <xsl:text/>
                  <xsl:value-of select="document('../../Schema/ANLYS/ANLYS.xsd')//xsd:schema//@version"/>
                  <xsl:text/> ] of <xsl:text/>
                  <xsl:value-of select="'ANLYS'"/>
                  <xsl:text/> found; 
            Version [<xsl:text/>
                  <xsl:value-of select="'202111'"/>
                  <xsl:text/>] or later is required. The latest version of <xsl:text/>
                  <xsl:value-of select="'ANLYS'"/>
                  <xsl:text/> 
            is not being used in the validation infrastructure. Regardless of the version indicated on the instance document, 
            the validation infrastructure needs to use a version of <xsl:text/>
                  <xsl:value-of select="'ANLYS'"/>
                  <xsl:text/> that is
            version [<xsl:text/>
                  <xsl:value-of select="'202111'"/>
                  <xsl:text/>] or later. NOTE: This is not an error of the instance
            document but of the validation environment itself. The incorrect value was found in <xsl:text/>
                  <xsl:value-of select="document-uri(document('../../Schema/ANLYS/ANLYS.xsd'))"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M12"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M12"/>
   <xsl:template match="@*|node()" priority="-2" mode="M12">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M12"/>
   </xsl:template>

   <!--PATTERN DHZMC-TDF-ID-00006-->


	<!--RULE DHZMC-TDF-ID-00006-R1-->
<xsl:template match="tdf:TrustedDataObject" priority="1000" mode="M13">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="tdf:TrustedDataObject"
                       id="DHZMC-TDF-ID-00006-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test=".//dhzm:DigitalHazMatAssertion and count(.//dhzm:DigitalHazMatAssertion) = 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test=".//dhzm:DigitalHazMatAssertion and count(.//dhzm:DigitalHazMatAssertion) = 1">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> 
            [DHZMC-TDF-ID-00006][Error] In a DHZMC-TDF TDO, there must be a dhzm:DigitalHazMatAssertion and only 1 of them.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M13"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M13"/>
   <xsl:template match="@*|node()" priority="-2" mode="M13">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M13"/>
   </xsl:template>

   <!--PATTERN DHZMC-TDF-ID-00007-->


	<!--RULE DHZMC-TDF-ID-00007-R1-->
<xsl:template match="tdf:TrustedDataObject//tdf:Assertion[1]"
                 priority="1000"
                 mode="M14">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="tdf:TrustedDataObject//tdf:Assertion[1]"
                       id="DHZMC-TDF-ID-00007-R1"/>

		    <!--ASSERT warning-->
<xsl:choose>
         <xsl:when test=".//dhzm:DigitalHazMatAssertion"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test=".//dhzm:DigitalHazMatAssertion">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> 
            [DHZMC-TDF-ID-00007][Warning] In a DHZMC-TDF TDO, dhzm:DigitalHazMatAssertion must be the first tdf:Assertion.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M14"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M14"/>
   <xsl:template match="@*|node()" priority="-2" mode="M14">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M14"/>
   </xsl:template>
</xsl:stylesheet>
<!--UNCLASSIFIED-->
