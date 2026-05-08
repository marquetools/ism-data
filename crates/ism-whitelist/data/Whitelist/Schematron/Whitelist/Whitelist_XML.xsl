<?xml version="1.0" encoding="UTF-8"?>
<!--UNCLASSIFIED--><xsl:stylesheet xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:saxon="http://saxon.sf.net/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:schold="http://www.ascc.net/xml/schematron"
                xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:ism="urn:us:gov:ic:ism"
                xmlns:ntk="urn:us:gov:ic:ntk"
                xmlns:catt="urn:us:gov:ic:taxonomy:catt:tetragraph"
                xmlns:cve="urn:us:gov:ic:cve"
                xmlns:dvf="deprecated:value:function"
                xmlns:util="urn:us:gov:ic:ism:xsl:util"
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
<xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:containsOnlyTheTokens"
                 as="xs:boolean">
        <xsl:param name="attribute"/>
        <xsl:param name="tokenList" as="xs:string*"/>
        <xsl:value-of select="every $attrToken in tokenize(normalize-space(string($attribute)), ' ')                               satisfies $attrToken = $tokenList"/>
    </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:getFirstItemFromSequence"
                 as="xs:string">
        <xsl:param name="listValues"/>
        <xsl:variable name="StringValue">
            <xsl:for-each select="$listValues">
                <xsl:value-of select="current()"/>
                <xsl:if test="position() = 1">
                    <xsl:value-of select="current()"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="normalize-space(string($StringValue))"/>
    </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:getSpaceSeparatedStringFromSequence"
                 as="xs:string">
        <xsl:param name="attrValues"/>
        <xsl:variable name="StringValues">
            <xsl:for-each select="$attrValues">
                <xsl:value-of select="current()"/>
                <xsl:if test="position() != last()">
                    <xsl:value-of select="' '"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="normalize-space(string($StringValues))"/>
    </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:getCommaSeparatedStringFromSequence"
                 as="xs:string">
        <xsl:param name="attrValues"/>
        <xsl:variable name="StringValues">
            <xsl:for-each select="$attrValues">
                <xsl:value-of select="current()"/>
                <xsl:if test="position() != last()">
                    <xsl:value-of select="', '"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="normalize-space(string($StringValues))"/>
    </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:getCountriesForTetra"
                 as="xs:string*">
        <xsl:param name="tetra" as="xs:string"/>

        <xsl:sequence select="$decomposableTetraElems[catt:TetraToken/text() = $tetra]/catt:Membership/catt:Country/text()"/>
    </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:contributesToRollup"
                 as="xs:boolean">
        <xsl:param name="context"/>
        <xsl:value-of select="not(string($context/@ism:excludeFromRollup) = 'true')"/>
    </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:padValue"
                 as="xs:string">
        <xsl:param name="value" as="xs:string?"/>

        <xsl:value-of select="concat(' ', normalize-space($value), ' ')"/>
    </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:tokenize"
                 as="xs:string*">
        <xsl:param name="value" as="xs:string?"/>

        <xsl:sequence select="tokenize(normalize-space($value), ' ')"/>
    </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:join"
                 as="xs:string">
        <xsl:param name="values" as="xs:string*"/>

        <xsl:sequence select="normalize-space(string-join($values, ' '))"/>
    </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:containsAnyOfTheTokens"
                 as="xs:boolean">
        <xsl:param name="attribute"/>
        <xsl:param name="tokenList" as="xs:string*"/>
        <xsl:value-of select="                 some $attrToken in tokenize(normalize-space(string($attribute)), ' ')                     satisfies $attrToken = $tokenList"/>
    </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:containsDecomposableTetra"
                 as="xs:boolean">
        <xsl:param name="relTo" as="xs:string?"/>

        <xsl:sequence select="normalize-space($relTo) and util:containsAnyOfTheTokens($relTo, $decomposableTetras)"/>
    </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:expandAllTetras"
                 as="xs:string*">
        <xsl:param name="relToStrings" as="xs:string*"/>

        <xsl:variable name="allTokens" as="xs:string*">
            <xsl:for-each select="$relToStrings">
                <xsl:variable name="expandedCountryTokens" select="util:expandDecomposableTetras(.)"/>
                <xsl:value-of select="util:padValue(util:join($expandedCountryTokens))"/>
            </xsl:for-each>
        </xsl:variable>

        <xsl:sequence select="$allTokens"/>
    </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:expandDecomposableTetras"
                 as="xs:string*">
        <xsl:param name="relTo" as="xs:string"/>

        <xsl:variable name="expandedTetras">
            <xsl:choose>
                <xsl:when test="util:containsDecomposableTetra($relTo)">
                    <xsl:variable name="currTetra"
                             select="util:tokenize($relTo)[. = $decomposableTetras][1]"/>
                    <xsl:variable name="currTetraCountries"
                             select="util:join(util:getCountriesForTetra($currTetra))"/>
                    <xsl:variable name="expandCurrTetra"
                             select="replace(util:padValue($relTo), util:padValue($currTetra), util:padValue($currTetraCountries))"/>

                    <xsl:value-of select="util:expandDecomposableTetras($expandCurrTetra)"/>
                </xsl:when>

                <xsl:otherwise>
                    <xsl:value-of select="normalize-space($relTo)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:sequence select="distinct-values(util:tokenize($expandedTetras))"/>
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
         <svrl:text>This is the root file for the Whitelist Schematron rule set. It loads
        all of the required CVEs, declares some variables and includes all of the Rule .sch files. </svrl:text>
         <svrl:ns-prefix-in-attribute-values uri="urn:us:gov:ic:ism" prefix="ism"/>
         <svrl:ns-prefix-in-attribute-values uri="urn:us:gov:ic:ntk" prefix="ntk"/>
         <svrl:ns-prefix-in-attribute-values uri="urn:us:gov:ic:taxonomy:catt:tetragraph" prefix="catt"/>
         <svrl:ns-prefix-in-attribute-values uri="urn:us:gov:ic:cve" prefix="cve"/>
         <svrl:ns-prefix-in-attribute-values uri="deprecated:value:function" prefix="dvf"/>
         <svrl:ns-prefix-in-attribute-values uri="urn:us:gov:ic:ism:xsl:util" prefix="util"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">WLAtomicEnergyMarkings-ID-00001</xsl:attribute>
            <xsl:attribute name="name">WLAtomicEnergyMarkings-ID-00001</xsl:attribute>
            <svrl:text>This abstract pattern checks to see if an attribute of an element exists
        in a list or matches the pattern defined by the list. The calling rule must pass the
        context, search term list, attribute value to check, and an error message.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M65"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">WLClassification-ID-00001</xsl:attribute>
            <xsl:attribute name="name">WLClassification-ID-00001</xsl:attribute>
            <svrl:text>This abstract pattern checks to see if an attribute of an element exists
        in a list or matches the pattern defined by the list. The calling rule must pass the
        context, search term list, attribute value to check, and an error message.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M66"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">WLDisseminationControls-ID-00001</xsl:attribute>
            <xsl:attribute name="name">WLDisseminationControls-ID-00001</xsl:attribute>
            <svrl:text>This abstract pattern checks to see if an attribute of an element exists
        in a list or matches the pattern defined by the list. The calling rule must pass the
        context, search term list, attribute value to check, and an error message.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M67"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">WLFGIsourceOpen-ID-00001</xsl:attribute>
            <xsl:attribute name="name">WLFGIsourceOpen-ID-00001</xsl:attribute>
            <svrl:text>This abstract pattern checks to see if an attribute of an element exists
        in a list or matches the pattern defined by the list. The calling rule must pass the
        context, search term list, attribute value to check, and an error message.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M68"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">WLFGIsourceProtected-ID-00001</xsl:attribute>
            <xsl:attribute name="name">WLFGIsourceProtected-ID-00001</xsl:attribute>
            <svrl:text>This abstract pattern checks to see if an attribute of an element exists
        in a list or matches the pattern defined by the list. The calling rule must pass the
        context, search term list, attribute value to check, and an error message.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M69"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">WLISMAttribute-ID-00001</xsl:attribute>
            <xsl:attribute name="name">WLISMAttribute-ID-00001</xsl:attribute>
            <svrl:text>This abstract pattern checks to see if an attribute of an element exists
        in a list or matches the pattern defined by the list. The calling rule must pass the
        context, search term list, attribute value to check, and an error message.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M70"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">WLNtkAccessPolicy-ID-00001</xsl:attribute>
            <xsl:attribute name="name">WLNtkAccessPolicy-ID-00001</xsl:attribute>
            <svrl:text>This abstract pattern verifies that a value at a given context matches fome value in a list
      using regular expression matching. The calling rule must pass the context, search term list, attribute value to
      check, and an error message.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M71"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">WLNtkAccessProfileValue-ID-00001</xsl:attribute>
            <xsl:attribute name="name">WLNtkAccessProfileValue-ID-00001</xsl:attribute>
            <svrl:text>
    [WLNtkAccessProfileValue-ID-00001][Error] RequiresAnyOf NTK Whitelist Validation - For each profile within an NTK RequiresAnyOf element, 
    at least one AccessProfileValue must be specified in the whitelist.  For urn:us:gov:ic:aces:ntk:restrictive profiles, every AccessProfileValue 
    for that profile must be defined in the whitelist. For urn:us:gov:ic:aces:ntk:permissive profiles, at least one AccessProfileValue must be defined.
    
    Human Readable: Whitelist RequiresAnyOf Validation Error: for RequiresAnyOf profiles, at least one combination of AccessPolicy, AccessProfileValue@ntk:vocabulary 
    and ntk:AccessProfileValue from document must be specified for the profile in the whitelist.
  </svrl:text>
            <svrl:text>
    Utilizes the AnyAccessProfileInWhitelist abstract rule.  The abstract rule handles the variations in behavior with the restrictive / permissive profiles,
    the propin:1 profile with no AccessProfileValues and the ICO profile.  
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M72"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">WLNtkVocabulary-ID-00001</xsl:attribute>
            <xsl:attribute name="name">WLNtkVocabulary-ID-00001</xsl:attribute>
            <svrl:text>This abstract pattern verifies that a value at a given context matches fome value in a list
      using regular expression matching. The calling rule must pass the context, search term list, attribute value to
      check, and an error message.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M73"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">WLReleaseableTo-ID-00001</xsl:attribute>
            <xsl:attribute name="name">WLReleaseableTo-ID-00001</xsl:attribute>
            <svrl:text>This abstract pattern checks to see if an attribute of an element exists
        in a list or matches the pattern defined by the list. The calling rule must pass the
        context, search term list, attribute value to check, and an error message.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M74"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">WLSARIdentifier-ID-00001</xsl:attribute>
            <xsl:attribute name="name">WLSARIdentifier-ID-00001</xsl:attribute>
            <svrl:text>This abstract pattern checks to see if an attribute of an element exists
        in a list or matches the pattern defined by the list. The calling rule must pass the
        context, search term list, attribute value to check, and an error message.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M75"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">WLSCIcontrols-ID-00001</xsl:attribute>
            <xsl:attribute name="name">WLSCIcontrols-ID-00001</xsl:attribute>
            <svrl:text>This abstract pattern checks to see if an attribute of an element exists
        in a list or matches the pattern defined by the list. The calling rule must pass the
        context, search term list, attribute value to check, and an error message.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M76"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">WLdisplayOnlyTo-ID-00001</xsl:attribute>
            <xsl:attribute name="name">WLdisplayOnlyTo-ID-00001</xsl:attribute>
            <svrl:text>This abstract pattern checks to see if an attribute of an element exists
        in a list or matches the pattern defined by the list. The calling rule must pass the
        context, search term list, attribute value to check, and an error message.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M77"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">WLnonICmarkings-ID-00001</xsl:attribute>
            <xsl:attribute name="name">WLnonICmarkings-ID-00001</xsl:attribute>
            <svrl:text>This abstract pattern checks to see if an attribute of an element exists
        in a list or matches the pattern defined by the list. The calling rule must pass the
        context, search term list, attribute value to check, and an error message.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M78"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">WLnonUSControls-ID-00001</xsl:attribute>
            <xsl:attribute name="name">WLnonUSControls-ID-00001</xsl:attribute>
            <svrl:text>This abstract pattern checks to see if an attribute of an element exists
        in a list or matches the pattern defined by the list. The calling rule must pass the
        context, search term list, attribute value to check, and an error message.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M79"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">WLownerProducer-ID-00001</xsl:attribute>
            <xsl:attribute name="name">WLownerProducer-ID-00001</xsl:attribute>
            <svrl:text>This abstract pattern checks to see if an attribute of an element exists
        in a list or matches the pattern defined by the list. The calling rule must pass the
        context, search term list, attribute value to check, and an error message.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M80"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">WLNtkAccessPolicy-ID-00002</xsl:attribute>
            <xsl:attribute name="name">WLNtkAccessPolicy-ID-00002</xsl:attribute>
            <svrl:text>This abstract pattern verifies 
      that the values of child elements at a given context match some value in a list. The calling rule must pass the 
      context, child element name to build search term list, list of values from configuration file, and an error message.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M81"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">WLNtkAccessProfileValue-ID-00002</xsl:attribute>
            <xsl:attribute name="name">WLNtkAccessProfileValue-ID-00002</xsl:attribute>
            <svrl:text>
    [WLNtkAccessProfileValue-ID-00002][Error] RequiresAllOf NTK Whitelist Validation - For each profile within an NTK RequiresAllOf element, 
    at least one AccessProfileValue must be specified in the whitelist.  For urn:us:gov:ic:aces:ntk:restrictive profiles, every AccessProfileValue 
    must be defined in the whitelist. For urn:us:gov:ic:aces:ntk:permissive profiles, at least one AccessProfileValue must be defined.
    
    Human Readable: Whitelist RequiresAllOf Validation Error: all combinations of AccessPolicy, AccessProfileValue@ntk:vocabulary 
    and ntk:AccessProfileValue from document must be specified for the profile in the whitelist.
    
  </svrl:text>
            <svrl:text>
    Utilizes the AllAccessProfilesInWhitelist abstract rule.  The abstract rule handles the variations in behavior with the restrictive / permissive profiles,
    the propin:1 profile with no AccessProfileValues and the ICO profile.  
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M82"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">WLNtkVocabulary-ID-00002</xsl:attribute>
            <xsl:attribute name="name">WLNtkVocabulary-ID-00002</xsl:attribute>
            <svrl:text>This abstract pattern verifies 
      that the values of child elements at a given context match some value in a list. The calling rule must pass the 
      context, child element name to build search term list, list of values from configuration file, and an error message.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M83"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">WLReleaseableTo-ID-00002</xsl:attribute>
            <xsl:attribute name="name">WLReleaseableTo-ID-00002</xsl:attribute>
            <svrl:text>
    [WLReleaseableTo-ID-00002][Error]  Whitelist Validation - if minimumValues is defined for a minimum set of relTo values, then 
                                       ensure that @ism:releasableTo values include each member of minimum values.
  </svrl:text>
            <svrl:text>
    If config file ReleaseableTo element includes the minimumValues child,
    then each instance of ism:releaseableTo in the document must include each member listed
    in minimumValues.
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M84"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">WLownerProducer-ID-00002</xsl:attribute>
            <xsl:attribute name="name">WLownerProducer-ID-00002</xsl:attribute>
            <svrl:text>This abstract pattern checks to see if an attribute of an element exists
    in a list or matches the pattern defined by the list. The calling rule must pass the
    context, search term list, attribute value to check, and an error message.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M85"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">WLNtkAccessProfileValue-ID-00003</xsl:attribute>
            <xsl:attribute name="name">WLNtkAccessProfileValue-ID-00003</xsl:attribute>
            <svrl:text>
    [WLNtkAccessProfileValue-ID-00003][Error]  NTK Minimum Values Validation - at a minimum, each whitelist profile value, 
    defined by combination of AccessProfileValue@ntk:vocabulary and ntk:AccessProfileValue, must be found in document.
    
    Human Readable: At a minimum, each whitelist profile value, defined by combination of AccessProfileValue@ntk:vocabulary 
    and ntk:AccessProfileValue, must be found in document. Additional profile values can exist.
  </svrl:text>
            <svrl:text>
    Minimum set of NTK Profile values that must exist in document being evaluated. Minimum value entry is a combination of 
    required profile values as specified by a combination of AccessProfileValue@ntk:vocabulary and ntk:AccessProfileValue.
    A list of required values is created from the configuration xml file for the profile. 
    Each NTK profile value found in xml document must exist in this list along with any other profiles.
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M86"/>
      </svrl:schematron-output>
   </xsl:template>

   <!--SCHEMATRON PATTERNS-->
<xsl:param name="configXML" select="document('./whitelist_config.xml')"/>
   <xsl:param name="ismAttributesList"
              select="$configXML//Whitelist/ISMAttributes/values"/>
   <xsl:param name="ismAttributesListType"
              select="$configXML//Whitelist/ISMAttributes/values/@type"/>
   <xsl:param name="classificationList"
              select="$configXML//Whitelist/Classification/values"/>
   <xsl:param name="disseminationControlsList"
              select="$configXML//Whitelist/DisseminationControls/values"/>
   <xsl:param name="releasableToList"
              select="util:getSpaceSeparatedStringFromSequence(util:expandDecomposableTetras($configXML//Whitelist/ReleasableTo/values))"/>
   <xsl:param name="releasableToMinList"
              select="util:getSpaceSeparatedStringFromSequence(util:expandDecomposableTetras($configXML//Whitelist/ReleasableTo/minimumValues))"/>
   <xsl:param name="releasableToListType"
              select="$configXML//Whitelist/ReleasableTo/values/@type"/>
   <xsl:param name="ownerProducerList"
              select="$configXML//Whitelist/OwnerProducer/values"/>
   <xsl:param name="ownerProducerListType"
              select="$configXML//Whitelist/OwnerProducer/values/@type"/>
   <xsl:param name="atomicEnergyMarkingsList"
              select="$configXML//Whitelist/AtomicEnergyMarkings/values"/>
   <xsl:param name="nonICmarkingsList"
              select="$configXML//Whitelist/NonICmarkings/values"/>
   <xsl:param name="SCIControlsList"
              select="$configXML//Whitelist/SCIControls/values"/>
   <xsl:param name="displayOnlyToList"
              select="util:getSpaceSeparatedStringFromSequence(util:expandDecomposableTetras($configXML//Whitelist/DisplayOnlyTo/values))"/>
   <xsl:param name="displayOnlyToListType"
              select="$configXML//Whitelist/DisplayOnlyTo/values/@type"/>
   <xsl:param name="FGIsourceOpenList"
              select="$configXML//Whitelist/FGIsourceOpen/values"/>
   <xsl:param name="FGIsourceOpenListType"
              select="$configXML//Whitelist/FGIsourceOpen/values/@type"/>
   <xsl:param name="FGIsourceProtectedList"
              select="$configXML//Whitelist/FGIsourceProtected/values"/>
   <xsl:param name="FGIsourceProtectedListType"
              select="$configXML//Whitelist/FGIsourceProtected/values/@type"/>
   <xsl:param name="nonUSControlsList"
              select="$configXML//Whitelist/NonUSControls/values"/>
   <xsl:param name="SARIdentifierList"
              select="$configXML//Whitelist/SARIdentifier/values"/>
   <xsl:param name="policyList" select="$configXML//Whitelist/NtkPolicy/value"/>
   <xsl:param name="vocabList" select="$configXML//Whitelist/NtkVocabulary/value"/>
   <xsl:param name="accessProfileValueList"
              select="for $value in $configXML//Whitelist/NtkAccessProfile[@accessPolicy != 'urn:us:gov:ic:aces:ntk:permissive']/profile                     return normalize-space(concat($value/../@accessPolicy, ' ', $value/@vocabulary, ' ', $value/@profileValue))"/>
   <xsl:param name="accessProfileValueListPermissive"
              select="for $value in $configXML//Whitelist/NtkAccessProfile[@accessPolicy = 'urn:us:gov:ic:aces:ntk:permissive']/profile                      return normalize-space(concat($value/../@accessPolicy, ' ', $value/@vocabulary, ' ', $value/@profileValue))"/>
   <xsl:param name="profilesWithMinValues"
              select="$configXML//Whitelist/NtkAccessProfile[count(./minimumValues/profile/@profileValue) &gt; 0]/@accessPolicy"/>
   <xsl:param name="accessProfileMinValueList"
              select="for $value in $configXML//Whitelist/NtkAccessProfile[(@accessPolicy != 'urn:us:gov:ic:aces:ntk:restrictive')]/minimumValues/profile return normalize-space(concat($value/../../@accessPolicy, ' ', $value/@vocabulary, ' ', $value/@profileValue))"/>
   <xsl:param name="ismAttributesList_tok"
              select="tokenize(normalize-space(string($ismAttributesList)), ' ')"/>
   <xsl:param name="classificationList_tok"
              select="tokenize(normalize-space(string($classificationList)), ' ')"/>
   <xsl:param name="disseminationControlsList_tok"
              select="tokenize(normalize-space(string($disseminationControlsList)), ' ')"/>
   <xsl:param name="releasableToList_tok"
              select="for $value in $releasableToList return   normalize-space(concat($value, ' '))"/>
   <xsl:param name="releasableToMinList_tok"
              select="for $value in $releasableToMinList   return   normalize-space(concat($value, ' '))"/>
   <xsl:param name="ownerProducerList_tok"
              select="tokenize(normalize-space(string($ownerProducerList)), ' ')"/>
   <xsl:param name="atomicEnergyMarkingsList_tok"
              select="tokenize(normalize-space(string($atomicEnergyMarkingsList)), ' ')"/>
   <xsl:param name="SCIControlsList_tok"
              select="tokenize(normalize-space(string($SCIControlsList)), ' ')"/>
   <xsl:param name="nonICmarkingsList_tok"
              select="tokenize(normalize-space(string($nonICmarkingsList)), ' ')"/>
   <xsl:param name="displayOnlyToList_tok"
              select="for $value in $displayOnlyToList     return   normalize-space(concat($value, ' '))"/>
   <xsl:param name="FGIsourceOpenList_tok"
              select="tokenize(normalize-space(string($FGIsourceOpenList)), ' ')"/>
   <xsl:param name="FGIsourceProtectedList_tok"
              select="tokenize(normalize-space(string($FGIsourceProtectedList)), ' ')"/>
   <xsl:param name="nonUSControlsList_tok"
              select="tokenize(normalize-space(string($nonUSControlsList)), ' ')"/>
   <xsl:param name="SARIdentifierList_tok"
              select="tokenize(normalize-space(string($SARIdentifierList)), ' ')"/>
   <xsl:param name="catt"
              select="document('../../Taxonomy/ISMCAT/TetragraphTaxonomy.xml')"/>
   <xsl:param name="cattMappings" select="$catt//catt:Tetragraph"/>
   <xsl:param name="decomposableTetraElems"
              select="$cattMappings[@decomposable[. = 'Yes']]"/>
   <xsl:param name="decomposableTetras"
              select="$decomposableTetraElems/catt:TetraToken/text()"/>

   <!--PATTERN WLAtomicEnergyMarkings-ID-00001-->


	<!--RULE ValidateTokensExistInWhitelist-R1-->
<xsl:template match="*[@ism:atomicEnergyMarkings]" priority="1000" mode="M65">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:atomicEnergyMarkings]"
                       id="ValidateTokensExistInWhitelist-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="(matches(util:getFirstItemFromSequence($atomicEnergyMarkingsList_tok),'\*'))  or ( ( matches(util:getFirstItemFromSequence($atomicEnergyMarkingsList_tok),'\*') ) or (every $searchTerm in tokenize(util:getSpaceSeparatedStringFromSequence(@ism:atomicEnergyMarkings), ' ') satisfies             some $Term in $atomicEnergyMarkingsList_tok satisfies (matches (normalize-space($searchTerm), concat('^', $Term ,'$'))) )   )   "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="(matches(util:getFirstItemFromSequence($atomicEnergyMarkingsList_tok),'\*')) or ( ( matches(util:getFirstItemFromSequence($atomicEnergyMarkingsList_tok),'\*') ) or (every $searchTerm in tokenize(util:getSpaceSeparatedStringFromSequence(@ism:atomicEnergyMarkings), ' ') satisfies some $Term in $atomicEnergyMarkingsList_tok satisfies (matches (normalize-space($searchTerm), concat('^', $Term ,'$'))) ) )">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'   [WLAtomicEnergyMarkings-ID-00001][Error]  Whitelist Validation - @ism:atomicEnergyMarkings combination must be specified in the whitelist.'"/>
                  <xsl:text/>  Document Value(s): [<xsl:text/>
                  <xsl:value-of select="util:getCommaSeparatedStringFromSequence(@ism:atomicEnergyMarkings)"/>
                  <xsl:text/>]   Whitelist Value(s): [<xsl:text/>
                  <xsl:value-of select="util:getCommaSeparatedStringFromSequence($atomicEnergyMarkingsList_tok)"/>
                  <xsl:text/>]
            
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M65"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M65"/>
   <xsl:template match="@*|node()" priority="-2" mode="M65">
      <xsl:apply-templates select="*" mode="M65"/>
   </xsl:template>

   <!--PATTERN WLClassification-ID-00001-->


	<!--RULE ValidateTokensExistInWhitelist-R1-->
<xsl:template match="*[@ism:classification]" priority="1000" mode="M66">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:classification]"
                       id="ValidateTokensExistInWhitelist-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="(matches(util:getFirstItemFromSequence($classificationList_tok),'\*'))  or ( ( matches(util:getFirstItemFromSequence($classificationList_tok),'\*') ) or (every $searchTerm in tokenize(util:getSpaceSeparatedStringFromSequence(@ism:classification), ' ') satisfies             some $Term in $classificationList_tok satisfies (matches (normalize-space($searchTerm), concat('^', $Term ,'$'))) )   )   "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="(matches(util:getFirstItemFromSequence($classificationList_tok),'\*')) or ( ( matches(util:getFirstItemFromSequence($classificationList_tok),'\*') ) or (every $searchTerm in tokenize(util:getSpaceSeparatedStringFromSequence(@ism:classification), ' ') satisfies some $Term in $classificationList_tok satisfies (matches (normalize-space($searchTerm), concat('^', $Term ,'$'))) ) )">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'   [WLClassification-ID-00001][Error] Whitelist Validation - @ism:classification value in document must exist in the whitelist.'"/>
                  <xsl:text/>  Document Value(s): [<xsl:text/>
                  <xsl:value-of select="util:getCommaSeparatedStringFromSequence(@ism:classification)"/>
                  <xsl:text/>]   Whitelist Value(s): [<xsl:text/>
                  <xsl:value-of select="util:getCommaSeparatedStringFromSequence($classificationList_tok)"/>
                  <xsl:text/>]
            
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M66"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M66"/>
   <xsl:template match="@*|node()" priority="-2" mode="M66">
      <xsl:apply-templates select="*" mode="M66"/>
   </xsl:template>

   <!--PATTERN WLDisseminationControls-ID-00001-->


	<!--RULE ValidateTokensExistInWhitelist-R1-->
<xsl:template match="*[@ism:disseminationControls]" priority="1000" mode="M67">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:disseminationControls]"
                       id="ValidateTokensExistInWhitelist-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="(matches(util:getFirstItemFromSequence($disseminationControlsList_tok),'\*'))  or ( ( matches(util:getFirstItemFromSequence($disseminationControlsList_tok),'\*') ) or (every $searchTerm in tokenize(util:getSpaceSeparatedStringFromSequence(@ism:disseminationControls), ' ') satisfies             some $Term in $disseminationControlsList_tok satisfies (matches (normalize-space($searchTerm), concat('^', $Term ,'$'))) )   )   "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="(matches(util:getFirstItemFromSequence($disseminationControlsList_tok),'\*')) or ( ( matches(util:getFirstItemFromSequence($disseminationControlsList_tok),'\*') ) or (every $searchTerm in tokenize(util:getSpaceSeparatedStringFromSequence(@ism:disseminationControls), ' ') satisfies some $Term in $disseminationControlsList_tok satisfies (matches (normalize-space($searchTerm), concat('^', $Term ,'$'))) ) )">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'   [WLDisseminationControls-ID-00001][Error] Whitelist Validation - each @ism:disseminationControls value in document must exist in the whitelist.'"/>
                  <xsl:text/>  Document Value(s): [<xsl:text/>
                  <xsl:value-of select="util:getCommaSeparatedStringFromSequence(@ism:disseminationControls)"/>
                  <xsl:text/>]   Whitelist Value(s): [<xsl:text/>
                  <xsl:value-of select="util:getCommaSeparatedStringFromSequence($disseminationControlsList_tok)"/>
                  <xsl:text/>]
            
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M67"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M67"/>
   <xsl:template match="@*|node()" priority="-2" mode="M67">
      <xsl:apply-templates select="*" mode="M67"/>
   </xsl:template>

   <!--PATTERN WLFGIsourceOpen-ID-00001-->


	<!--RULE ValidateTokensExistInWhitelist-R1-->
<xsl:template match="*[@ism:FGIsourceOpen]" priority="1000" mode="M68">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:FGIsourceOpen]"
                       id="ValidateTokensExistInWhitelist-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="(matches(util:getFirstItemFromSequence($FGIsourceOpenList_tok),'\*'))  or ( ( matches(util:getFirstItemFromSequence($FGIsourceOpenList_tok),'\*') ) or (every $searchTerm in tokenize(util:getSpaceSeparatedStringFromSequence(@ism:FGIsourceOpen), ' ') satisfies             some $Term in $FGIsourceOpenList_tok satisfies (matches (normalize-space($searchTerm), concat('^', $Term ,'$'))) )   )   "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="(matches(util:getFirstItemFromSequence($FGIsourceOpenList_tok),'\*')) or ( ( matches(util:getFirstItemFromSequence($FGIsourceOpenList_tok),'\*') ) or (every $searchTerm in tokenize(util:getSpaceSeparatedStringFromSequence(@ism:FGIsourceOpen), ' ') satisfies some $Term in $FGIsourceOpenList_tok satisfies (matches (normalize-space($searchTerm), concat('^', $Term ,'$'))) ) )">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'   [WLFGIsourceOpen-ID-00001][Error] Whitelist Validation - each @ism:FGIsourceOpen values in document must exist in whitelist.'"/>
                  <xsl:text/>  Document Value(s): [<xsl:text/>
                  <xsl:value-of select="util:getCommaSeparatedStringFromSequence(@ism:FGIsourceOpen)"/>
                  <xsl:text/>]   Whitelist Value(s): [<xsl:text/>
                  <xsl:value-of select="util:getCommaSeparatedStringFromSequence($FGIsourceOpenList_tok)"/>
                  <xsl:text/>]
            
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M68"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M68"/>
   <xsl:template match="@*|node()" priority="-2" mode="M68">
      <xsl:apply-templates select="*" mode="M68"/>
   </xsl:template>

   <!--PATTERN WLFGIsourceProtected-ID-00001-->


	<!--RULE ValidateTokensExistInWhitelist-R1-->
<xsl:template match="*[@ism:FGIsourceProtected]" priority="1000" mode="M69">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:FGIsourceProtected]"
                       id="ValidateTokensExistInWhitelist-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="(matches(util:getFirstItemFromSequence($FGIsourceProtectedList_tok),'\*'))  or ( ( matches(util:getFirstItemFromSequence($FGIsourceProtectedList_tok),'\*') ) or (every $searchTerm in tokenize(util:getSpaceSeparatedStringFromSequence(@ism:FGIsourceProtected), ' ') satisfies             some $Term in $FGIsourceProtectedList_tok satisfies (matches (normalize-space($searchTerm), concat('^', $Term ,'$'))) )   )   "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="(matches(util:getFirstItemFromSequence($FGIsourceProtectedList_tok),'\*')) or ( ( matches(util:getFirstItemFromSequence($FGIsourceProtectedList_tok),'\*') ) or (every $searchTerm in tokenize(util:getSpaceSeparatedStringFromSequence(@ism:FGIsourceProtected), ' ') satisfies some $Term in $FGIsourceProtectedList_tok satisfies (matches (normalize-space($searchTerm), concat('^', $Term ,'$'))) ) )">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'   [WLFGIsourceProtected-ID-00001][Error] Whitelist Validation - each @ism:FGIsourceProtected value in document must exist in whitelist.'"/>
                  <xsl:text/>  Document Value(s): [<xsl:text/>
                  <xsl:value-of select="util:getCommaSeparatedStringFromSequence(@ism:FGIsourceProtected)"/>
                  <xsl:text/>]   Whitelist Value(s): [<xsl:text/>
                  <xsl:value-of select="util:getCommaSeparatedStringFromSequence($FGIsourceProtectedList_tok)"/>
                  <xsl:text/>]
            
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M69"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M69"/>
   <xsl:template match="@*|node()" priority="-2" mode="M69">
      <xsl:apply-templates select="*" mode="M69"/>
   </xsl:template>

   <!--PATTERN WLISMAttribute-ID-00001-->


	<!--RULE ValidateTokensExistInWhitelist-R1-->
<xsl:template match="*[//@*[namespace-uri()='urn:us:gov:ic:ism']]"
                 priority="1000"
                 mode="M70">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[//@*[namespace-uri()='urn:us:gov:ic:ism']]"
                       id="ValidateTokensExistInWhitelist-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="(matches(util:getFirstItemFromSequence($ismAttributesList_tok),'\*'))  or ( ( matches(util:getFirstItemFromSequence($ismAttributesList_tok),'\*') ) or (every $searchTerm in tokenize(util:getSpaceSeparatedStringFromSequence(util:getSpaceSeparatedStringFromSequence(@*[namespace-uri()='urn:us:gov:ic:ism']/local-name())), ' ') satisfies             some $Term in $ismAttributesList_tok satisfies (matches (normalize-space($searchTerm), concat('^', $Term ,'$'))) )   )   "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="(matches(util:getFirstItemFromSequence($ismAttributesList_tok),'\*')) or ( ( matches(util:getFirstItemFromSequence($ismAttributesList_tok),'\*') ) or (every $searchTerm in tokenize(util:getSpaceSeparatedStringFromSequence(util:getSpaceSeparatedStringFromSequence(@*[namespace-uri()='urn:us:gov:ic:ism']/local-name())), ' ') satisfies some $Term in $ismAttributesList_tok satisfies (matches (normalize-space($searchTerm), concat('^', $Term ,'$'))) ) )">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'   [WLISMAttribute-ID-00001][Error] Whitelist Validation - each @ism: attribute in document must exist in whitelist.'"/>
                  <xsl:text/>  Document Value(s): [<xsl:text/>
                  <xsl:value-of select="util:getCommaSeparatedStringFromSequence(util:getSpaceSeparatedStringFromSequence(@*[namespace-uri()='urn:us:gov:ic:ism']/local-name()))"/>
                  <xsl:text/>]   Whitelist Value(s): [<xsl:text/>
                  <xsl:value-of select="util:getCommaSeparatedStringFromSequence($ismAttributesList_tok)"/>
                  <xsl:text/>]
            
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M70"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M70"/>
   <xsl:template match="@*|node()" priority="-2" mode="M70">
      <xsl:apply-templates select="*" mode="M70"/>
   </xsl:template>

   <!--PATTERN WLNtkAccessPolicy-ID-00001-->


	<!--RULE AllValuesExistInList-R1-->
<xsl:template match="//ntk:RequiresAllOf/ntk:AccessProfileList/ntk:AccessProfile/ntk:AccessPolicy"
                 priority="1000"
                 mode="M71">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//ntk:RequiresAllOf/ntk:AccessProfileList/ntk:AccessProfile/ntk:AccessPolicy"
                       id="AllValuesExistInList-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="(                                               (matches(util:getFirstItemFromSequence($policyList),'\*'))                            or                                               ( every $searchTerm in //ntk:RequiresAllOf/ntk:AccessProfileList/ntk:AccessProfile/ntk:AccessPolicy satisfies some $term in $policyList satisfies (matches ($searchTerm , $term)) )                          )"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="( (matches(util:getFirstItemFromSequence($policyList),'\*')) or ( every $searchTerm in //ntk:RequiresAllOf/ntk:AccessProfileList/ntk:AccessProfile/ntk:AccessPolicy satisfies some $term in $policyList satisfies (matches ($searchTerm , $term)) ) )">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'   [WLAccessPolicy-ID-00001][Error] NTK AccessPolicy Whitelist Validation - each ntk:AccessPolicy value in document must exist in the whitelist.' "/>
                  <xsl:text/>
         
         Document Value(s): [<xsl:text/>
                  <xsl:value-of select="util:getCommaSeparatedStringFromSequence(//ntk:RequiresAllOf/ntk:AccessProfileList/ntk:AccessProfile/ntk:AccessPolicy)"/>
                  <xsl:text/>]
         
         Whitelist Value(s): [<xsl:text/>
                  <xsl:value-of select="util:getCommaSeparatedStringFromSequence($policyList)"/>
                  <xsl:text/>]
      </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M71"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M71"/>
   <xsl:template match="@*|node()" priority="-2" mode="M71">
      <xsl:apply-templates select="*" mode="M71"/>
   </xsl:template>

   <!--PATTERN WLNtkAccessProfileValue-ID-00001-->


	<!--RULE WLNtkAccessProfileValue-ID-00001-R1-->
<xsl:template match="//ntk:RequiresAnyOf/ntk:AccessProfileList"
                 priority="1000"
                 mode="M72">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//ntk:RequiresAnyOf/ntk:AccessProfileList"
                       id="WLNtkAccessProfileValue-ID-00001-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="some $docProfile in ./ntk:AccessProfile satisfies (                                      (  $docProfile/ntk:AccessPolicy = 'urn:us:gov:ic:aces:ntk:ico' )                    or                    (  $docProfile/ntk:AccessPolicy='urn:us:gov:ic:aces:ntk:propin:1'                        and                       not($docProfile[$docProfile/ntk:AccessPolicy='urn:us:gov:ic:aces:ntk:propin:1']/ntk:AccessProfileValue)                    )                    or                    (  if ($docProfile/ntk:AccessPolicy != 'urn:us:gov:ic:aces:ntk:permissive')                        then every $docTerm in for $value in $docProfile[./ntk:AccessPolicy != 'urn:us:gov:ic:aces:ntk:permissive']/ntk:AccessProfileValue return normalize-space(concat($value/../ntk:AccessPolicy, ' ',  $value/@ntk:vocabulary, ' ', $value))                            satisfies some $listTerm in $accessProfileValueList satisfies (matches ($docTerm, $listTerm))                         else some $docTerm in for $value in $docProfile[./ntk:AccessPolicy='urn:us:gov:ic:aces:ntk:permissive']/ntk:AccessProfileValue return normalize-space(concat($value/../ntk:AccessPolicy, ' ',  $value/@ntk:vocabulary, ' ', $value))                              satisfies some $listTerm in $accessProfileValueListPermissive satisfies (matches ($docTerm, $listTerm))                    )                            )"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="some $docProfile in ./ntk:AccessProfile satisfies ( ( $docProfile/ntk:AccessPolicy = 'urn:us:gov:ic:aces:ntk:ico' ) or ( $docProfile/ntk:AccessPolicy='urn:us:gov:ic:aces:ntk:propin:1' and not($docProfile[$docProfile/ntk:AccessPolicy='urn:us:gov:ic:aces:ntk:propin:1']/ntk:AccessProfileValue) ) or ( if ($docProfile/ntk:AccessPolicy != 'urn:us:gov:ic:aces:ntk:permissive') then every $docTerm in for $value in $docProfile[./ntk:AccessPolicy != 'urn:us:gov:ic:aces:ntk:permissive']/ntk:AccessProfileValue return normalize-space(concat($value/../ntk:AccessPolicy, ' ', $value/@ntk:vocabulary, ' ', $value)) satisfies some $listTerm in $accessProfileValueList satisfies (matches ($docTerm, $listTerm)) else some $docTerm in for $value in $docProfile[./ntk:AccessPolicy='urn:us:gov:ic:aces:ntk:permissive']/ntk:AccessProfileValue return normalize-space(concat($value/../ntk:AccessPolicy, ' ', $value/@ntk:vocabulary, ' ', $value)) satisfies some $listTerm in $accessProfileValueListPermissive satisfies (matches ($docTerm, $listTerm)) ) )">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>

      [WLNtkAccessProfileValue-ID-00001][Error] RequiresAnyOf NTK Whitelist Validation - For each profile within an NTK RequiresAnyOf element, 
      at least one AccessProfileValue must be specified in the whitelist.  For urn:us:gov:ic:aces:ntk:restrictive profiles, every AccessProfileValue 
      must be defined in the whitelist. For urn:us:gov:ic:aces:ntk:permissive profiles, at least one AccessProfileValue must be defined.
      
      Document Value(s): [<xsl:text/>
                  <xsl:value-of select="util:getCommaSeparatedStringFromSequence(for $value in ./ntk:AccessProfile/ntk:AccessProfileValue return normalize-space(concat($value/../ntk:AccessPolicy, ' ',$value/@ntk:vocabulary, ' ', $value)))"/>
                  <xsl:text/>]
      
      Whitelist Value(s): [<xsl:text/>
                  <xsl:value-of select="util:getCommaSeparatedStringFromSequence($accessProfileValueList)"/>
                  <xsl:text/>
                           <xsl:text/>
                  <xsl:value-of select="util:getCommaSeparatedStringFromSequence($accessProfileValueListPermissive)"/>
                  <xsl:text/>]     
    </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M72"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M72"/>
   <xsl:template match="@*|node()" priority="-2" mode="M72">
      <xsl:apply-templates select="*" mode="M72"/>
   </xsl:template>

   <!--PATTERN WLNtkVocabulary-ID-00001-->


	<!--RULE AllValuesExistInList-R1-->
<xsl:template match="//ntk:RequiresAllOf/ntk:AccessProfileList/ntk:AccessProfile/ntk:AccessProfileValue/@ntk:vocabulary"
                 priority="1000"
                 mode="M73">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//ntk:RequiresAllOf/ntk:AccessProfileList/ntk:AccessProfile/ntk:AccessProfileValue/@ntk:vocabulary"
                       id="AllValuesExistInList-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="(                                               (matches(util:getFirstItemFromSequence($vocabList),'\*'))                            or                                               ( every $searchTerm in //ntk:RequiresAllOf/ntk:AccessProfileList/ntk:AccessProfile/ntk:AccessProfileValue/@ntk:vocabulary satisfies some $term in $vocabList satisfies (matches ($searchTerm , $term)) )                          )"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="( (matches(util:getFirstItemFromSequence($vocabList),'\*')) or ( every $searchTerm in //ntk:RequiresAllOf/ntk:AccessProfileList/ntk:AccessProfile/ntk:AccessProfileValue/@ntk:vocabulary satisfies some $term in $vocabList satisfies (matches ($searchTerm , $term)) ) )">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'   [WLNtkVocabulary-ID-00001][Error] NTK Vocabulary Type Whitelist Validation - each ntk:AccessProfileValue@vocabulary value in document must exist in the whitelist.' "/>
                  <xsl:text/>
         
         Document Value(s): [<xsl:text/>
                  <xsl:value-of select="util:getCommaSeparatedStringFromSequence(//ntk:RequiresAllOf/ntk:AccessProfileList/ntk:AccessProfile/ntk:AccessProfileValue/@ntk:vocabulary)"/>
                  <xsl:text/>]
         
         Whitelist Value(s): [<xsl:text/>
                  <xsl:value-of select="util:getCommaSeparatedStringFromSequence($vocabList)"/>
                  <xsl:text/>]
      </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M73"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M73"/>
   <xsl:template match="@*|node()" priority="-2" mode="M73">
      <xsl:apply-templates select="*" mode="M73"/>
   </xsl:template>

   <!--PATTERN WLReleaseableTo-ID-00001-->


	<!--RULE ValidateDecomposableTokensExistInWhitelist-R1-->
<xsl:template match="*[@ism:releasableTo]" priority="1000" mode="M74">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:releasableTo]"
                       id="ValidateDecomposableTokensExistInWhitelist-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="( ( matches(util:getFirstItemFromSequence($releasableToList_tok),'\*') ) or (every $searchTerm in tokenize(util:getSpaceSeparatedStringFromSequence(util:expandDecomposableTetras(@ism:releasableTo)), ' ') satisfies             some $Term in tokenize(util:getSpaceSeparatedStringFromSequence(util:expandDecomposableTetras($releasableToList_tok)), ' ') satisfies (matches (normalize-space($searchTerm), normalize-space($Term))) )  )"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="( ( matches(util:getFirstItemFromSequence($releasableToList_tok),'\*') ) or (every $searchTerm in tokenize(util:getSpaceSeparatedStringFromSequence(util:expandDecomposableTetras(@ism:releasableTo)), ' ') satisfies some $Term in tokenize(util:getSpaceSeparatedStringFromSequence(util:expandDecomposableTetras($releasableToList_tok)), ' ') satisfies (matches (normalize-space($searchTerm), normalize-space($Term))) ) )">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'   [WLReleaseableTo-ID-00001][Error] Whitelist Validation - each @ism:releasableTo value in document must exist in whitelist.'"/>
                  <xsl:text/>  Document Value(s): [<xsl:text/>
                  <xsl:value-of select="util:getSpaceSeparatedStringFromSequence(util:expandDecomposableTetras(@ism:releasableTo))"/>
                  <xsl:text/>]   Whitelist Value(s): [<xsl:text/>
                  <xsl:value-of select="util:getCommaSeparatedStringFromSequence($releasableToList_tok)"/>
                  <xsl:text/>]
            
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M74"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M74"/>
   <xsl:template match="@*|node()" priority="-2" mode="M74">
      <xsl:apply-templates select="*" mode="M74"/>
   </xsl:template>

   <!--PATTERN WLSARIdentifier-ID-00001-->


	<!--RULE ValidateTokensExistInWhitelist-R1-->
<xsl:template match="*[@ism:SARIdentifier]" priority="1000" mode="M75">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:SARIdentifier]"
                       id="ValidateTokensExistInWhitelist-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="(matches(util:getFirstItemFromSequence($SARIdentifierList_tok),'\*'))  or ( ( matches(util:getFirstItemFromSequence($SARIdentifierList_tok),'\*') ) or (every $searchTerm in tokenize(util:getSpaceSeparatedStringFromSequence(@ism:SARIdentifier), ' ') satisfies             some $Term in $SARIdentifierList_tok satisfies (matches (normalize-space($searchTerm), concat('^', $Term ,'$'))) )   )   "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="(matches(util:getFirstItemFromSequence($SARIdentifierList_tok),'\*')) or ( ( matches(util:getFirstItemFromSequence($SARIdentifierList_tok),'\*') ) or (every $searchTerm in tokenize(util:getSpaceSeparatedStringFromSequence(@ism:SARIdentifier), ' ') satisfies some $Term in $SARIdentifierList_tok satisfies (matches (normalize-space($searchTerm), concat('^', $Term ,'$'))) ) )">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'   [WLSARIdentifier-ID-00001]  Whitelist Validation - each @ism:SARIdentifier attribute value in document must exist in the whitelist.'"/>
                  <xsl:text/>  Document Value(s): [<xsl:text/>
                  <xsl:value-of select="util:getCommaSeparatedStringFromSequence(@ism:SARIdentifier)"/>
                  <xsl:text/>]   Whitelist Value(s): [<xsl:text/>
                  <xsl:value-of select="util:getCommaSeparatedStringFromSequence($SARIdentifierList_tok)"/>
                  <xsl:text/>]
            
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M75"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M75"/>
   <xsl:template match="@*|node()" priority="-2" mode="M75">
      <xsl:apply-templates select="*" mode="M75"/>
   </xsl:template>

   <!--PATTERN WLSCIcontrols-ID-00001-->


	<!--RULE ValidateTokensExistInWhitelist-R1-->
<xsl:template match="*[@ism:SCIcontrols]" priority="1000" mode="M76">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:SCIcontrols]"
                       id="ValidateTokensExistInWhitelist-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="(matches(util:getFirstItemFromSequence($SCIControlsList_tok),'\*'))  or ( ( matches(util:getFirstItemFromSequence($SCIControlsList_tok),'\*') ) or (every $searchTerm in tokenize(util:getSpaceSeparatedStringFromSequence(@ism:SCIcontrols), ' ') satisfies             some $Term in $SCIControlsList_tok satisfies (matches (normalize-space($searchTerm), concat('^', $Term ,'$'))) )   )   "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="(matches(util:getFirstItemFromSequence($SCIControlsList_tok),'\*')) or ( ( matches(util:getFirstItemFromSequence($SCIControlsList_tok),'\*') ) or (every $searchTerm in tokenize(util:getSpaceSeparatedStringFromSequence(@ism:SCIcontrols), ' ') satisfies some $Term in $SCIControlsList_tok satisfies (matches (normalize-space($searchTerm), concat('^', $Term ,'$'))) ) )">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'   [WLSCIcontrols-ID-00001][Error] Whitelist Validation - each @ism:SCIcontrols each combination must be specified in the whitelist.'"/>
                  <xsl:text/>  Document Value(s): [<xsl:text/>
                  <xsl:value-of select="util:getCommaSeparatedStringFromSequence(@ism:SCIcontrols)"/>
                  <xsl:text/>]   Whitelist Value(s): [<xsl:text/>
                  <xsl:value-of select="util:getCommaSeparatedStringFromSequence($SCIControlsList_tok)"/>
                  <xsl:text/>]
            
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

   <!--PATTERN WLdisplayOnlyTo-ID-00001-->


	<!--RULE ValidateDecomposableTokensExistInWhitelist-R1-->
<xsl:template match="*[@ism:displayOnlyTo]" priority="1000" mode="M77">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:displayOnlyTo]"
                       id="ValidateDecomposableTokensExistInWhitelist-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="( ( matches(util:getFirstItemFromSequence($displayOnlyToList_tok),'\*') ) or (every $searchTerm in tokenize(util:getSpaceSeparatedStringFromSequence(util:expandDecomposableTetras(@ism:displayOnlyTo)), ' ') satisfies             some $Term in tokenize(util:getSpaceSeparatedStringFromSequence(util:expandDecomposableTetras($displayOnlyToList_tok)), ' ') satisfies (matches (normalize-space($searchTerm), normalize-space($Term))) )  )"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="( ( matches(util:getFirstItemFromSequence($displayOnlyToList_tok),'\*') ) or (every $searchTerm in tokenize(util:getSpaceSeparatedStringFromSequence(util:expandDecomposableTetras(@ism:displayOnlyTo)), ' ') satisfies some $Term in tokenize(util:getSpaceSeparatedStringFromSequence(util:expandDecomposableTetras($displayOnlyToList_tok)), ' ') satisfies (matches (normalize-space($searchTerm), normalize-space($Term))) ) )">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'   [WLdisplayOnlyTo-ID-00001][Error] Whitelist Validation - each @ism:displayOnlyTo value in document must exist in whitelist.'"/>
                  <xsl:text/>  Document Value(s): [<xsl:text/>
                  <xsl:value-of select="util:getSpaceSeparatedStringFromSequence(util:expandDecomposableTetras(@ism:displayOnlyTo))"/>
                  <xsl:text/>]   Whitelist Value(s): [<xsl:text/>
                  <xsl:value-of select="util:getCommaSeparatedStringFromSequence($displayOnlyToList_tok)"/>
                  <xsl:text/>]
            
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

   <!--PATTERN WLnonICmarkings-ID-00001-->


	<!--RULE ValidateTokensExistInWhitelist-R1-->
<xsl:template match="*[@ism:nonICmarkings]" priority="1000" mode="M78">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:nonICmarkings]"
                       id="ValidateTokensExistInWhitelist-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="(matches(util:getFirstItemFromSequence($nonICmarkingsList_tok),'\*'))  or ( ( matches(util:getFirstItemFromSequence($nonICmarkingsList_tok),'\*') ) or (every $searchTerm in tokenize(util:getSpaceSeparatedStringFromSequence(@ism:nonICmarkings), ' ') satisfies             some $Term in $nonICmarkingsList_tok satisfies (matches (normalize-space($searchTerm), concat('^', $Term ,'$'))) )   )   "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="(matches(util:getFirstItemFromSequence($nonICmarkingsList_tok),'\*')) or ( ( matches(util:getFirstItemFromSequence($nonICmarkingsList_tok),'\*') ) or (every $searchTerm in tokenize(util:getSpaceSeparatedStringFromSequence(@ism:nonICmarkings), ' ') satisfies some $Term in $nonICmarkingsList_tok satisfies (matches (normalize-space($searchTerm), concat('^', $Term ,'$'))) ) )">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'   [WLnonICmarkings-ID-00001][Error] Whitelist validation: each @ism:nonICmarkings value in document must exist in whitelist.'"/>
                  <xsl:text/>  Document Value(s): [<xsl:text/>
                  <xsl:value-of select="util:getCommaSeparatedStringFromSequence(@ism:nonICmarkings)"/>
                  <xsl:text/>]   Whitelist Value(s): [<xsl:text/>
                  <xsl:value-of select="util:getCommaSeparatedStringFromSequence($nonICmarkingsList_tok)"/>
                  <xsl:text/>]
            
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

   <!--PATTERN WLnonUSControls-ID-00001-->


	<!--RULE ValidateTokensExistInWhitelist-R1-->
<xsl:template match="*[@ism:nonUSControls]" priority="1000" mode="M79">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:nonUSControls]"
                       id="ValidateTokensExistInWhitelist-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="(matches(util:getFirstItemFromSequence($nonUSControlsList_tok),'\*'))  or ( ( matches(util:getFirstItemFromSequence($nonUSControlsList_tok),'\*') ) or (every $searchTerm in tokenize(util:getSpaceSeparatedStringFromSequence(@ism:nonUSControls), ' ') satisfies             some $Term in $nonUSControlsList_tok satisfies (matches (normalize-space($searchTerm), concat('^', $Term ,'$'))) )   )   "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="(matches(util:getFirstItemFromSequence($nonUSControlsList_tok),'\*')) or ( ( matches(util:getFirstItemFromSequence($nonUSControlsList_tok),'\*') ) or (every $searchTerm in tokenize(util:getSpaceSeparatedStringFromSequence(@ism:nonUSControls), ' ') satisfies some $Term in $nonUSControlsList_tok satisfies (matches (normalize-space($searchTerm), concat('^', $Term ,'$'))) ) )">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'   [WLnonUSControls-ID-00001]  Whitelist Validation - each @ism:nonUSControls attribute value in document must exist in the whitelist.'"/>
                  <xsl:text/>  Document Value(s): [<xsl:text/>
                  <xsl:value-of select="util:getCommaSeparatedStringFromSequence(@ism:nonUSControls)"/>
                  <xsl:text/>]   Whitelist Value(s): [<xsl:text/>
                  <xsl:value-of select="util:getCommaSeparatedStringFromSequence($nonUSControlsList_tok)"/>
                  <xsl:text/>]
            
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

   <!--PATTERN WLownerProducer-ID-00001-->


	<!--RULE ValidateTokensExistInWhitelist-R1-->
<xsl:template match="*[($ownerProducerListType = 'whitelist') and @ism:ownerProducer]"
                 priority="1000"
                 mode="M80">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[($ownerProducerListType = 'whitelist') and @ism:ownerProducer]"
                       id="ValidateTokensExistInWhitelist-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="(matches(util:getFirstItemFromSequence($ownerProducerList_tok),'\*'))  or ( ( matches(util:getFirstItemFromSequence($ownerProducerList_tok),'\*') ) or (every $searchTerm in tokenize(util:getSpaceSeparatedStringFromSequence(@ism:ownerProducer), ' ') satisfies             some $Term in $ownerProducerList_tok satisfies (matches (normalize-space($searchTerm), concat('^', $Term ,'$'))) )   )   "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="(matches(util:getFirstItemFromSequence($ownerProducerList_tok),'\*')) or ( ( matches(util:getFirstItemFromSequence($ownerProducerList_tok),'\*') ) or (every $searchTerm in tokenize(util:getSpaceSeparatedStringFromSequence(@ism:ownerProducer), ' ') satisfies some $Term in $ownerProducerList_tok satisfies (matches (normalize-space($searchTerm), concat('^', $Term ,'$'))) ) )">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'   [WLownerProducer-ID-00001][Error] Whitelist Validation - each @ism:ownerProducer value in document must exist in whitelist.'"/>
                  <xsl:text/>  Document Value(s): [<xsl:text/>
                  <xsl:value-of select="util:getCommaSeparatedStringFromSequence(@ism:ownerProducer)"/>
                  <xsl:text/>]   Whitelist Value(s): [<xsl:text/>
                  <xsl:value-of select="util:getCommaSeparatedStringFromSequence($ownerProducerList_tok)"/>
                  <xsl:text/>]
            
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M80"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M80"/>
   <xsl:template match="@*|node()" priority="-2" mode="M80">
      <xsl:apply-templates select="*" mode="M80"/>
   </xsl:template>

   <!--PATTERN WLNtkAccessPolicy-ID-00002-->


	<!--RULE SomeValuesExistInList-R1-->
<xsl:template match="//ntk:RequiresAnyOf/ntk:AccessProfileList/ntk:AccessProfile/ntk:AccessPolicy"
                 priority="1000"
                 mode="M81">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//ntk:RequiresAnyOf/ntk:AccessProfileList/ntk:AccessProfile/ntk:AccessPolicy"
                       id="SomeValuesExistInList-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="(                            (matches(util:getFirstItemFromSequence($policyList),'\*'))                              or                              (some $searchTerm in //ntk:RequiresAnyOf/ntk:AccessProfileList/ntk:AccessProfile/ntk:AccessPolicy satisfies some $term in $policyList satisfies (matches ($searchTerm , $term)))                          )"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="( (matches(util:getFirstItemFromSequence($policyList),'\*')) or (some $searchTerm in //ntk:RequiresAnyOf/ntk:AccessProfileList/ntk:AccessProfile/ntk:AccessPolicy satisfies some $term in $policyList satisfies (matches ($searchTerm , $term))) )">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'   [WLAccessPolicy-ID-00002][Error] NTK AccessPolicy Whitelist Validation - for ntk:RequiresAnyOf, each ntk:AccessPolicy value in document must exist in the whitelist.' "/>
                  <xsl:text/>
         
         Document Value(s): [<xsl:text/>
                  <xsl:value-of select="util:getCommaSeparatedStringFromSequence(//ntk:RequiresAnyOf/ntk:AccessProfileList/ntk:AccessProfile/ntk:AccessPolicy)"/>
                  <xsl:text/>]
         
         Whitelist Value(s): [<xsl:text/>
                  <xsl:value-of select="util:getCommaSeparatedStringFromSequence($policyList)"/>
                  <xsl:text/>]
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

   <!--PATTERN WLNtkAccessProfileValue-ID-00002-->


	<!--RULE WLNtkAccessProfileValue-ID-00002-R1-->
<xsl:template match="//ntk:RequiresAllOf/ntk:AccessProfileList"
                 priority="1000"
                 mode="M82">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//ntk:RequiresAllOf/ntk:AccessProfileList"
                       id="WLNtkAccessProfileValue-ID-00002-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="every $docProfile in ./ntk:AccessProfile satisfies (          (  $docProfile/ntk:AccessPolicy = 'urn:us:gov:ic:aces:ntk:ico' )          or          (  $docProfile/ntk:AccessPolicy='urn:us:gov:ic:aces:ntk:propin:1'              and             not($docProfile[$docProfile/ntk:AccessPolicy='urn:us:gov:ic:aces:ntk:propin:1']/ntk:AccessProfileValue)          )          or          (                      (if ($docProfile/ntk:AccessPolicy != 'urn:us:gov:ic:aces:ntk:permissive')              then every $docTerm in for $value in $docProfile[(./ntk:AccessPolicy != 'urn:us:gov:ic:aces:ntk:permissive')]/ntk:AccessProfileValue return normalize-space(concat($value/../ntk:AccessPolicy, ' ',  $value/@ntk:vocabulary, ' ', $value))                   satisfies some $listTerm in $accessProfileValueList satisfies (matches ($docTerm, $listTerm))              else some $docTerm in for $value in $docProfile[(./ntk:AccessPolicy = 'urn:us:gov:ic:aces:ntk:permissive')]/ntk:AccessProfileValue return normalize-space(concat($value/../ntk:AccessPolicy, ' ',  $value/@ntk:vocabulary, ' ', $value))                   satisfies some $listTerm in $accessProfileValueListPermissive satisfies (matches ($docTerm, $listTerm))             )           )                 )                         "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $docProfile in ./ntk:AccessProfile satisfies ( ( $docProfile/ntk:AccessPolicy = 'urn:us:gov:ic:aces:ntk:ico' ) or ( $docProfile/ntk:AccessPolicy='urn:us:gov:ic:aces:ntk:propin:1' and not($docProfile[$docProfile/ntk:AccessPolicy='urn:us:gov:ic:aces:ntk:propin:1']/ntk:AccessProfileValue) ) or ( (if ($docProfile/ntk:AccessPolicy != 'urn:us:gov:ic:aces:ntk:permissive') then every $docTerm in for $value in $docProfile[(./ntk:AccessPolicy != 'urn:us:gov:ic:aces:ntk:permissive')]/ntk:AccessProfileValue return normalize-space(concat($value/../ntk:AccessPolicy, ' ', $value/@ntk:vocabulary, ' ', $value)) satisfies some $listTerm in $accessProfileValueList satisfies (matches ($docTerm, $listTerm)) else some $docTerm in for $value in $docProfile[(./ntk:AccessPolicy = 'urn:us:gov:ic:aces:ntk:permissive')]/ntk:AccessProfileValue return normalize-space(concat($value/../ntk:AccessPolicy, ' ', $value/@ntk:vocabulary, ' ', $value)) satisfies some $listTerm in $accessProfileValueListPermissive satisfies (matches ($docTerm, $listTerm)) ) ) )">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
      
      [WLNtkAccessProfileValue-ID-00002][Error] RequiresAllOf NTK Whitelist Validation - For each profile within an NTK RequiresAllOf element, 
      at least one AccessProfileValue must be specified in the whitelist.  For urn:us:gov:ic:aces:ntk:restrictive profiles, every AccessProfileValue 
      must be defined in the whitelist. For urn:us:gov:ic:aces:ntk:permissive profiles, at least one AccessProfileValue must be defined.
      
      Document Value(s): [<xsl:text/>
                  <xsl:value-of select="util:getCommaSeparatedStringFromSequence(for $value in ./ntk:AccessProfile/ntk:AccessProfileValue return normalize-space(concat($value/@ntk:vocabulary, ' ', $value)))"/>
                  <xsl:text/>]
      
      Whitelist Value(s): [<xsl:text/>
                  <xsl:value-of select="util:getCommaSeparatedStringFromSequence($accessProfileValueList)"/>
                  <xsl:text/>
                           <xsl:text/>
                  <xsl:value-of select="util:getCommaSeparatedStringFromSequence($accessProfileValueListPermissive)"/>
                  <xsl:text/>] 
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

   <!--PATTERN WLNtkVocabulary-ID-00002-->


	<!--RULE SomeValuesExistInList-R1-->
<xsl:template match="//ntk:RequiresAnyOf/ntk:AccessProfileList/ntk:AccessProfile/ntk:AccessProfileValue/@ntk:vocabulary"
                 priority="1000"
                 mode="M83">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//ntk:RequiresAnyOf/ntk:AccessProfileList/ntk:AccessProfile/ntk:AccessProfileValue/@ntk:vocabulary"
                       id="SomeValuesExistInList-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="(                            (matches(util:getFirstItemFromSequence($vocabList),'\*'))                              or                              (some $searchTerm in //ntk:RequiresAnyOf/ntk:AccessProfileList/ntk:AccessProfile/ntk:AccessProfileValue/@ntk:vocabulary satisfies some $term in $vocabList satisfies (matches ($searchTerm , $term)))                          )"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="( (matches(util:getFirstItemFromSequence($vocabList),'\*')) or (some $searchTerm in //ntk:RequiresAnyOf/ntk:AccessProfileList/ntk:AccessProfile/ntk:AccessProfileValue/@ntk:vocabulary satisfies some $term in $vocabList satisfies (matches ($searchTerm , $term))) )">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'   [WLNtkVocabulary-ID-00002][Error] NTK Vocabulary Type Whitelist Validation - for ntk:RequiresAnyOf,                  each ntk:AccessProfileValue@vocabulary value in document must exist in the whitelist.' "/>
                  <xsl:text/>
         
         Document Value(s): [<xsl:text/>
                  <xsl:value-of select="util:getCommaSeparatedStringFromSequence(//ntk:RequiresAnyOf/ntk:AccessProfileList/ntk:AccessProfile/ntk:AccessProfileValue/@ntk:vocabulary)"/>
                  <xsl:text/>]
         
         Whitelist Value(s): [<xsl:text/>
                  <xsl:value-of select="util:getCommaSeparatedStringFromSequence($vocabList)"/>
                  <xsl:text/>]
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

   <!--PATTERN WLReleaseableTo-ID-00002-->


	<!--RULE WLReleaseableTo-ID-00002-R1-->
<xsl:template match="*[@ism:releasableTo]" priority="1000" mode="M84">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:releasableTo]"
                       id="WLReleaseableTo-ID-00002-R1"/>
      <xsl:variable name="searchTermList" select="@ism:releasableTo"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="every $Term in for $term in $releasableToMinList_tok return util:expandDecomposableTetras($term) satisfies                         some $searchTerm in for $term in $searchTermList return util:expandDecomposableTetras($term) satisfies                             (matches (normalize-space($Term), concat('^', $searchTerm, '$')))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $Term in for $term in $releasableToMinList_tok return util:expandDecomposableTetras($term) satisfies some $searchTerm in for $term in $searchTermList return util:expandDecomposableTetras($term) satisfies (matches (normalize-space($Term), concat('^', $searchTerm, '$')))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
      [WLReleaseableTo-ID-00002][Error] Whitelist Validation - if minimumValues is defined for a minimum set of relTo values, then 
      ensure that @ism:releasableTo values include each member of minimum values.
      
      Failed whitelist check. 
      Document releaseableTo value(s): [<xsl:text/>
                  <xsl:value-of select="util:getSpaceSeparatedStringFromSequence(util:expandDecomposableTetras($searchTermList))"/>
                  <xsl:text/>]   
      Minimum required releaseableTo value(s): [<xsl:text/>
                  <xsl:value-of select="util:getSpaceSeparatedStringFromSequence(util:expandDecomposableTetras(  $releasableToMinList_tok  ))"/>
                  <xsl:text/>]           
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

   <!--PATTERN WLownerProducer-ID-00002-->


	<!--RULE ValidateTokenValuesNotInBlacklist-R1-->
<xsl:template match="*[($ownerProducerListType = 'blacklist') and @ism:ownerProducer]"
                 priority="1000"
                 mode="M85">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[($ownerProducerListType = 'blacklist') and @ism:ownerProducer]"
                       id="ValidateTokenValuesNotInBlacklist-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="not(util:containsAnyOfTheTokens((normalize-space(string(util:getSpaceSeparatedStringFromSequence(@ism:ownerProducer)))), ($ownerProducerList_tok)))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(util:containsAnyOfTheTokens((normalize-space(string(util:getSpaceSeparatedStringFromSequence(@ism:ownerProducer)))), ($ownerProducerList_tok)))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'   [WLownerProducer-ID-00002][Error] Blacklist Validation - @sm:ownerProducer values in document must not exist in blacklist.'"/>
                  <xsl:text/>  Document Value(s): [<xsl:text/>
                  <xsl:value-of select="util:getSpaceSeparatedStringFromSequence(@ism:ownerProducer)"/>
                  <xsl:text/>]   
                                        Blacklist Value(s): [<xsl:text/>
                  <xsl:value-of select="util:getSpaceSeparatedStringFromSequence($ownerProducerList_tok)"/>
                  <xsl:text/>]
      
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

   <!--PATTERN WLNtkAccessProfileValue-ID-00003-->


	<!--RULE WLNtkAccessProfileValue-ID-00003-R1-->
<xsl:template match="//ntk:AccessProfileList/ntk:AccessProfile[some $policyTerm in ./ntk:AccessPolicy satisfies some $configPolicyTerm in $profilesWithMinValues satisfies matches($policyTerm, $configPolicyTerm) ]"
                 priority="1000"
                 mode="M86">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//ntk:AccessProfileList/ntk:AccessProfile[some $policyTerm in ./ntk:AccessPolicy satisfies some $configPolicyTerm in $profilesWithMinValues satisfies matches($policyTerm, $configPolicyTerm) ]"
                       id="WLNtkAccessProfileValue-ID-00003-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="(some $listTerm in $accessProfileMinValueList satisfies                 some $docTerm in for $value in .[(. != 'urn:us:gov:ic:aces:ntk:permissive')]/ntk:AccessProfileValue return normalize-space(concat($value/../ntk:AccessPolicy, ' ',  $value/@ntk:vocabulary, ' ', $value))                  satisfies (matches ($docTerm, $listTerm))               )"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="(some $listTerm in $accessProfileMinValueList satisfies some $docTerm in for $value in .[(. != 'urn:us:gov:ic:aces:ntk:permissive')]/ntk:AccessProfileValue return normalize-space(concat($value/../ntk:AccessPolicy, ' ', $value/@ntk:vocabulary, ' ', $value)) satisfies (matches ($docTerm, $listTerm)) )">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> 
        
        [WLNtkAccessProfileValue-ID-00003][Error] NTK Minimum Values Validation - at a minimum, each whitelist profile value, 
        defined by combination of AccessProfileValue@ntk:vocabulary and ntk:AccessProfileValue, must be found in document.
        
        Document NTK Profiles[<xsl:text/>
                  <xsl:value-of select="util:getCommaSeparatedStringFromSequence( ./ntk:AccessPolicy )"/>
                  <xsl:text/>]
        Profiles with Minimum Values Defined: [<xsl:text/>
                  <xsl:value-of select="util:getCommaSeparatedStringFromSequence($profilesWithMinValues)"/>
                  <xsl:text/>]
        Document Value(s): [<xsl:text/>
                  <xsl:value-of select="util:getCommaSeparatedStringFromSequence(for $value in ./ntk:AccessProfileValue return normalize-space(concat($value/../ntk:AccessPolicy, ' ',  $value/@ntk:vocabulary, ' ', $value)))"/>
                  <xsl:text/>]
        Minimum required value(s): [<xsl:text/>
                  <xsl:value-of select="util:getCommaSeparatedStringFromSequence($accessProfileMinValueList)"/>
                  <xsl:text/>] 
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
</xsl:stylesheet>
<!--UNCLASSIFIED-->
