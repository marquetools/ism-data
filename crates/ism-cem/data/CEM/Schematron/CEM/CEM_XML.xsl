<?xml version="1.0" encoding="UTF-8"?>
<!--UNCLASSIFIED--><xsl:stylesheet xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:saxon="http://saxon.sf.net/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:schold="http://www.ascc.net/xml/schematron"
                xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:cem="urn:us:gov:ic:cem"
                xmlns:virt="urn:us:gov:ic:virt"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:dtf="date:time:function"
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
                 xmlns:ism="urn:us:gov:ic:ism"
                 name="dtf:getYear"
                 as="xs:string">
      <xsl:param name="dateString" as="xs:string"/>
      <xsl:value-of select="substring(dtf:removeTimeZone($dateString), 1, 4)"/>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 xmlns:ism="urn:us:gov:ic:ism"
                 name="dtf:getMonth"
                 as="xs:string">
      <xsl:param name="dateString" as="xs:string"/>
      <xsl:value-of select="substring(dtf:removeTimeZone($dateString), 6, 2)"/>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 xmlns:ism="urn:us:gov:ic:ism"
                 name="dtf:isLeapYear"
                 as="xs:boolean">
      <xsl:param name="date" as="xs:string"/>
      <xsl:variable name="year" as="xs:integer" select="xs:integer(dtf:getYear($date))"/>
      <xsl:choose>
         <xsl:when test="$year mod 100 = 0">
            <xsl:choose>
               <xsl:when test="$year mod 400 = 0">
                  <xsl:value-of select="true()"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="false()"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
            <xsl:choose>
               <xsl:when test="$year mod 4 = 0">
                  <xsl:value-of select="true()"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="false()"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 xmlns:ism="urn:us:gov:ic:ism"
                 name="dtf:getMaxDay"
                 as="xs:string">
      <xsl:param name="date" as="xs:dateTime"/>
      <xsl:variable name="month" select="number(dtf:getMonth(string($date)))"/>
      <xsl:choose>
         <xsl:when test="$month = (1, 3, 5, 7, 8, 10, 12)">
            <xsl:value-of select="31"/>
         </xsl:when>
         <xsl:when test="$month = (4, 6, 9, 11)">
            <xsl:value-of select="30"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:choose>
               <xsl:when test="dtf:isLeapYear(string($date))">
                  <xsl:value-of select="29"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="28"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 xmlns:ism="urn:us:gov:ic:ism"
                 name="dtf:replaceDateTimeDay"
                 as="xs:dateTime">
      <xsl:param name="dateTime" as="xs:dateTime"/>
      <xsl:param name="newDayString" as="xs:string"/>
      <xsl:variable name="beforeDay" select="substring(string($dateTime), 1, 8)"/>
      <xsl:variable name="afterDay" select="substring(string($dateTime), 11)"/>
      <xsl:value-of select="concat($beforeDay, $newDayString, $afterDay)"/>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 xmlns:ism="urn:us:gov:ic:ism"
                 name="dtf:getDay"
                 as="xs:string">
      <xsl:param name="dateString" as="xs:string"/>
      <xsl:value-of select="substring(dtf:removeTimeZone($dateString), 9, 2)"/>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 xmlns:ism="urn:us:gov:ic:ism"
                 name="dtf:removeTimeZone"
                 as="xs:string">
      <xsl:param name="dateString" as="xs:string"/>
      <xsl:value-of select="replace($dateString, $timeZoneRegEx, '')"/>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 xmlns:ism="urn:us:gov:ic:ism"
                 name="dtf:padDateTimeWithTemplate"
                 as="xs:dateTime">
      <xsl:param name="dateString" as="xs:string"/>
      <xsl:param name="dateTemplateString" as="xs:string"/>
      <xsl:value-of select="concat($dateString, substring($dateTemplateString, string-length(normalize-space($dateString)) + 1))"/>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 xmlns:ism="urn:us:gov:ic:ism"
                 name="dtf:getTimeZone"
                 as="xs:string">
      <xsl:param name="dateString" as="xs:string"/>
      <xsl:variable name="dateTimeEndingWithTimezone"
                    as="xs:string"
                    select="concat('^.*(', $timeZoneRegEx, ')$')"/>
      <xsl:choose>
         <xsl:when test="matches($dateString, $dateTimeEndingWithTimezone)">
            <xsl:value-of select="replace($dateString, $dateTimeEndingWithTimezone, '$1')"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="$defaultTimeZone"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 xmlns:ism="urn:us:gov:ic:ism"
                 name="dtf:overlaps"
                 as="xs:boolean">
      <xsl:param name="primary" as="xs:string"/>
      <xsl:param name="secondary" as="xs:string"/>
      <xsl:variable name="primaryStart"
                    as="xs:dateTime"
                    select="dtf:startDate($primary)"/>
      <xsl:variable name="primaryEnd" as="xs:dateTime" select="dtf:endDate($primary)"/>
      <xsl:variable name="secondaryStart"
                    as="xs:dateTime"
                    select="dtf:startDate($secondary)"/>
      <xsl:variable name="secondaryEnd"
                    as="xs:dateTime"
                    select="dtf:endDate($secondary)"/>
      <xsl:value-of select="$primaryStart &lt;= $secondaryEnd and $secondaryStart &lt;= $primaryEnd"/>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 xmlns:ism="urn:us:gov:ic:ism"
                 name="dtf:isBefore"
                 as="xs:boolean">
      <xsl:param name="primary" as="xs:string"/>
      <xsl:param name="secondary" as="xs:string"/>
      <xsl:variable name="primaryEnd" as="xs:dateTime" select="dtf:endDate($primary)"/>
      <xsl:variable name="secondaryStart"
                    as="xs:dateTime"
                    select="dtf:startDate($secondary)"/>
      <xsl:value-of select="$primaryEnd &lt; $secondaryStart"/>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 xmlns:ism="urn:us:gov:ic:ism"
                 name="dtf:isAfter"
                 as="xs:boolean">
      <xsl:param name="primary" as="xs:string"/>
      <xsl:param name="secondary" as="xs:string"/>
      <xsl:variable name="primaryStart"
                    as="xs:dateTime"
                    select="dtf:startDate($primary)"/>
      <xsl:variable name="secondaryEnd"
                    as="xs:dateTime"
                    select="dtf:endDate($secondary)"/>
      <xsl:value-of select="$secondaryEnd &lt; $primaryStart"/>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 xmlns:ism="urn:us:gov:ic:ism"
                 name="dtf:startDate"
                 as="xs:dateTime">
      <xsl:param name="dateString" as="xs:string"/>
      <xsl:variable name="timeZonePortion" select="dtf:getTimeZone($dateString)"/>
      <xsl:variable name="dateTimePortion" select="dtf:removeTimeZone($dateString)"/>
      <xsl:variable name="outputDate"
                    select="dtf:padDateTimeWithTemplate($dateTimePortion, $startDateTimeTemplate)"/>
      <xsl:value-of select="concat($outputDate, $timeZonePortion)"/>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 xmlns:ism="urn:us:gov:ic:ism"
                 name="dtf:endDate"
                 as="xs:dateTime">
      <xsl:param name="input" as="xs:string"/>
      <xsl:variable name="timeZonePortion" select="dtf:getTimeZone($input)"/>
      <xsl:variable name="dateTimePortion" select="dtf:removeTimeZone($input)"/>
      <xsl:variable name="outputDate"
                    select="dtf:padDateTimeWithTemplate($dateTimePortion, $endDateTimeTemplate)"/>
      <xsl:variable name="outputWithCorrectedDay"
                    select="dtf:replaceDateTimeDay($outputDate, dtf:getMaxDay($outputDate))"/>
      <xsl:choose>
         <xsl:when test="dtf:getDay($input)">
            <xsl:value-of select="concat($outputDate, $timeZonePortion)"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="concat($outputWithCorrectedDay, $timeZonePortion)"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 xmlns:ism="urn:us:gov:ic:ism"
                 name="dtf:yearPortionHasFourDigits"
                 as="xs:boolean">
      <xsl:param name="dateString" as="xs:string"/>
      <xsl:variable name="dateWithOnlyFourDigitYearAndOptionalTimeZoneRegEx"
                    as="xs:string"
                    select="concat('^\d{4}(', $timeZoneRegEx, ')?$')"/>
      <xsl:variable name="dateStartingWithFourDigitYearRegEx"
                    as="xs:string"
                    select="'^\d{4}-.*$'"/>
      <xsl:value-of select="matches($dateString, $dateWithOnlyFourDigitYearAndOptionalTimeZoneRegEx) or matches($dateString, $dateStartingWithFourDigitYearRegEx)"/>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 xmlns:ism="urn:us:gov:ic:ism"
                 name="dtf:compareDateTimeRanges"
                 as="xs:boolean">
      <xsl:param name="primary" as="xs:string"/>
      <xsl:param name="operator" as="xs:string"/>
      <xsl:param name="secondary" as="xs:string"/>
      <xsl:variable name="primaryAndSecondayYearPortionsHaveFourDigits"
                    as="xs:boolean"
                    select="dtf:yearPortionHasFourDigits($primary) and dtf:yearPortionHasFourDigits($secondary)"/>
      <xsl:choose>
         <xsl:when test="$primaryAndSecondayYearPortionsHaveFourDigits">
            <xsl:variable name="primaryStart"
                          as="xs:dateTime"
                          select="dtf:startDate($primary)"/>
            <xsl:variable name="primaryEnd" as="xs:dateTime" select="dtf:endDate($primary)"/>
            <xsl:variable name="secondaryStart"
                          as="xs:dateTime"
                          select="dtf:startDate($secondary)"/>
            <xsl:variable name="secondaryEnd"
                          as="xs:dateTime"
                          select="dtf:endDate($secondary)"/>
            <xsl:choose>
               
               
               <xsl:when test="($operator = 'lt' or $operator = '&lt;') and (($primaryStart = $primaryEnd and $primaryStart = $secondaryStart) or ($primaryStart = $primaryEnd and $primaryStart = $secondaryEnd) or ($secondaryStart = $secondaryEnd and $primaryStart = $secondaryStart))">
                  <xsl:value-of select="false()"/>
               </xsl:when>
               
               
               <xsl:when test="($operator = 'gt' or $operator = '&gt;') and (($primaryStart = $primaryEnd and $primaryEnd = $secondaryEnd) or ($primaryStart = $primaryEnd and $primaryEnd = $secondaryStart) or ($secondaryStart = $secondaryEnd and $primaryEnd = $secondaryEnd))">
                  <xsl:value-of select="false()"/>
               </xsl:when>
               
               <xsl:when test="$operator = 'lt' or $operator = '&lt;' or $operator = '&lt;='">
                  <xsl:value-of select="dtf:isBefore($primary, $secondary) or dtf:overlaps($primary, $secondary)"/>
               </xsl:when>
               
               <xsl:when test="$operator = 'gt' or $operator = '&gt;' or $operator = '&gt;='">
                  <xsl:value-of select="dtf:isAfter($primary, $secondary) or dtf:overlaps($primary, $secondary)"/>
               </xsl:when>
               
               <xsl:otherwise>
                  <xsl:value-of select="false()"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="false()"/>
         </xsl:otherwise>
      </xsl:choose>
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
         <svrl:text>This is the root file for the CEM Schematron rule set. It loads all of
      the required CVEs declares some variables and includes all of the Rule .sch files. </svrl:text>
         <svrl:ns-prefix-in-attribute-values uri="urn:us:gov:ic:cem" prefix="cem"/>
         <svrl:ns-prefix-in-attribute-values uri="urn:us:gov:ic:virt" prefix="virt"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.w3.org/1999/xlink" prefix="xlink"/>
         <svrl:ns-prefix-in-attribute-values uri="date:time:function" prefix="dtf"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">CEM-ID-00001</xsl:attribute>
            <xsl:attribute name="name">CEM-ID-00001</xsl:attribute>
            <svrl:text>
        [CEM-ID-00001][Warning] DESVersion attributes SHOULD be specified as version 201804 with an optional extension.
    </svrl:text>
            <svrl:text>
        This rule supports extending the version identifier with an optional trailing hyphen
        and up to 23 additional characters. The version must match the regular expression
        “^201804(-.{1,23})?$".
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M25"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">CEM-ID-00002</xsl:attribute>
            <xsl:attribute name="name">CEM-ID-00002</xsl:attribute>
            <svrl:text>
        [CEM-ID-00002][Error]
        For elements Facility and Person, if attribute xlink:href exists, then the attribute must have a non-null value.
        
        Human Readable: If attribute xlink:href exists for elements Facility and Person, it must have a value.
    </svrl:text>
            <svrl:text>
        This pattern uses an abstract rule to consolidate logic. It normalizes the
        space of the value of attribute xlink:href and makes sure the length of the
        resulting string is greater than zero, which indicates non-whitespace content.
        The abstract rule is extended once for each required element.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M26"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">CEM-ID-00003</xsl:attribute>
            <xsl:attribute name="name">CEM-ID-00003</xsl:attribute>
            <svrl:text>
        [CEM-ID-00003][Error]
        For attribute dateTimeRange, for each pair of date/time values, 
        the second value must be later than the first value.
        
        Human Readable: The second value of date/time value pair for attribute dateTimeRange has to be later than the first value.
    </svrl:text>
            <svrl:text> 
        The value of the attribute dateTimeRange is tokenized into a list of dateTimes, 
        called $dateTimeList. If the number of dates in $dateTimeList
        is not even, then each date does not have a corresponding pair so this rule returns
        false. Otherwise, this rule verifies that the second date of each dateTime pair is 
        later than the first date in that pair. To do this, the rule loops over all dates in 
        $dateTimeList and identify dateTime pairs by pairing the date at an even index N with
        the date at index N-1. For each pair, this rule verifies that $dateList[N-1] is less than $dateList[N].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M27"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">CEM-ID-00004</xsl:attribute>
            <xsl:attribute name="name">CEM-ID-00004</xsl:attribute>
            <svrl:text>
        [CEM-ID-00004][Error] If VIRT attributes are used on any CEM elements, then @virt:DESVersion must be declared.
    </svrl:text>
            <svrl:text>
        For any CEM elements with attribute virt:network, attribute virt:DESVersion must exist.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M28"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">CEM-ID-00005</xsl:attribute>
            <xsl:attribute name="name">CEM-ID-00005</xsl:attribute>
            <svrl:text>
        [CEM-ID-00005][Warning] For every optional element that exists
        and can have text content, the element should have non-null, 
        non-whitespace value.
    </svrl:text>
            <svrl:text>
        This pattern uses an abstract rule to consolidate logic. The abstract rule
        first concatenates the text values within the given element, separated by a single 
        space. The resultant string is then normalized with leading and trailing 
        whitespace removed, and the length of the string is determined to be greater 
        than zero, which indicates non-whitespace content. The abstract rule is extended 
        once for each optional element in the CEM schema.  
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M29"/>
      </svrl:schematron-output>
   </xsl:template>

   <!--SCHEMATRON PATTERNS-->
<xsl:param name="timeZoneRegEx" select="'Z|[\+-]\d{2}:\d{2}'"/>
   <xsl:param name="defaultTimeZone" select="'Z'"/>
   <xsl:param name="startDateTimeTemplate" select="'0001-01-01T00:00:00.000'"/>
   <xsl:param name="endDateTimeTemplate" select="'9999-12-01T23:59:59.999'"/>

   <!--PATTERN CEM-ID-00001-->


	<!--RULE CEM-ID-00001-R1-->
<xsl:template match="*[@cem:DESVersion]" priority="1000" mode="M25">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@cem:DESVersion]"
                       id="CEM-ID-00001-R1"/>

		    <!--ASSERT warning-->
<xsl:choose>
         <xsl:when test="matches(@cem:DESVersion,'^201804(-.{1,23})?$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches(@cem:DESVersion,'^201804(-.{1,23})?$')">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [CEM-ID-00001][Warning] DESVersion attributes SHOULD be specified as version 201804 with an optional extension.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M25"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M25"/>
   <xsl:template match="@*|node()" priority="-2" mode="M25">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M25"/>
   </xsl:template>

   <!--PATTERN CEM-ID-00002-->


	<!--RULE CEM-ID-00002-R1-->
<xsl:template match="cem:Facility[@xlink:href]" priority="1001" mode="M26">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="cem:Facility[@xlink:href]"
                       id="CEM-ID-00002-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="normalize-space(string(@xlink:href))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="normalize-space(string(@xlink:href))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [CEM-ID-00002][Error]
            For element <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> if attribute xlink:href exists, then the attribute must have a non-null value.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M26"/>
   </xsl:template>

	  <!--RULE CEM-ID-00002-R2-->
<xsl:template match="cem:Person[@xlink:href]" priority="1000" mode="M26">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="cem:Person[@xlink:href]"
                       id="CEM-ID-00002-R2"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="normalize-space(string(@xlink:href))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="normalize-space(string(@xlink:href))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [CEM-ID-00002][Error]
            For element <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> if attribute xlink:href exists, then the attribute must have a non-null value.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M26"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M26"/>
   <xsl:template match="@*|node()" priority="-2" mode="M26">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M26"/>
   </xsl:template>

   <!--PATTERN CEM-ID-00003-->


	<!--RULE CEM-ID-00003-R1-->
<xsl:template match="cem:*[@cem:dateTimeRange]" priority="1000" mode="M27">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="cem:*[@cem:dateTimeRange]"
                       id="CEM-ID-00003-R1"/>
      <xsl:variable name="dateTimeList" select="tokenize(string(@cem:dateTimeRange), ' ')"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="             if ((count($dateTimeList) mod 2) != 0)             then false()             else                 count(                     for $index in 1 to count($dateTimeList) return                         if($index mod 2 = 0) then                             if(dtf:compareDateTimeRanges($dateTimeList[$index - 1], '&lt;', $dateTimeList[$index]))                             then 1                             else null                         else null                 ) = count($dateTimeList) * .5             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if ((count($dateTimeList) mod 2) != 0) then false() else count( for $index in 1 to count($dateTimeList) return if($index mod 2 = 0) then if(dtf:compareDateTimeRanges($dateTimeList[$index - 1], '&lt;', $dateTimeList[$index])) then 1 else null else null ) = count($dateTimeList) * .5">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [CEM-ID-00003][Error]
            For attribute dateTimeRange, for each pair of date/time values, 
            the second value must be later than the first value.
            
            Human Readable: The second value of date/time value pair for attribute dateTimeRange has to be later than the first value.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M27"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M27"/>
   <xsl:template match="@*|node()" priority="-2" mode="M27">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M27"/>
   </xsl:template>

   <!--PATTERN CEM-ID-00004-->


	<!--RULE CEM-ID-00004-R1-->
<xsl:template match="cem:*[@virt:*]" priority="1000" mode="M28">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="cem:*[@virt:*]"
                       id="CEM-ID-00004-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="@virt:DESVersion"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@virt:DESVersion">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [CEM-ID-00004][Error] [CEM-ID-00004][Error] If VIRT attributes are used on any CEM elements, then @virt:DESVersion must be declared.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M28"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M28"/>
   <xsl:template match="@*|node()" priority="-2" mode="M28">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M28"/>
   </xsl:template>

   <!--PATTERN CEM-ID-00005-->


	<!--RULE -->
<xsl:template match="cem:Drug" priority="1029" mode="M29">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cem:Drug"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="normalize-space(string())"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="normalize-space(string())">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [CEM-ID-00005][Warning] For every optional element that exists
            and can have text content, the element should have non-null, 
            non-whitespace value.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M29"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="cem:Account" priority="1028" mode="M29">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cem:Account"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="normalize-space(string())"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="normalize-space(string())">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [CEM-ID-00005][Warning] For every optional element that exists
            and can have text content, the element should have non-null, 
            non-whitespace value.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M29"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="cem:CommData" priority="1027" mode="M29">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cem:CommData"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="normalize-space(string())"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="normalize-space(string())">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [CEM-ID-00005][Warning] For every optional element that exists
            and can have text content, the element should have non-null, 
            non-whitespace value.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M29"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="cem:CityName" priority="1026" mode="M29">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cem:CityName"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="normalize-space(string())"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="normalize-space(string())">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [CEM-ID-00005][Warning] For every optional element that exists
            and can have text content, the element should have non-null, 
            non-whitespace value.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M29"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="cem:Commodity" priority="1025" mode="M29">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cem:Commodity"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="normalize-space(string())"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="normalize-space(string())">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [CEM-ID-00005][Warning] For every optional element that exists
            and can have text content, the element should have non-null, 
            non-whitespace value.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M29"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="cem:Concept" priority="1024" mode="M29">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cem:Concept"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="normalize-space(string())"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="normalize-space(string())">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [CEM-ID-00005][Warning] For every optional element that exists
            and can have text content, the element should have non-null, 
            non-whitespace value.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M29"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="cem:CountryName" priority="1023" mode="M29">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cem:CountryName"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="normalize-space(string())"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="normalize-space(string())">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [CEM-ID-00005][Warning] For every optional element that exists
            and can have text content, the element should have non-null, 
            non-whitespace value.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M29"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="cem:Date" priority="1022" mode="M29">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cem:Date"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="normalize-space(string())"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="normalize-space(string())">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [CEM-ID-00005][Warning] For every optional element that exists
            and can have text content, the element should have non-null, 
            non-whitespace value.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M29"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="cem:DateTime" priority="1021" mode="M29">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cem:DateTime"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="normalize-space(string())"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="normalize-space(string())">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [CEM-ID-00005][Warning] For every optional element that exists
            and can have text content, the element should have non-null, 
            non-whitespace value.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M29"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="cem:EntityUntyped" priority="1020" mode="M29">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cem:EntityUntyped"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="normalize-space(string())"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="normalize-space(string())">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [CEM-ID-00005][Warning] For every optional element that exists
            and can have text content, the element should have non-null, 
            non-whitespace value.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M29"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="cem:Equipment" priority="1019" mode="M29">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cem:Equipment"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="normalize-space(string())"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="normalize-space(string())">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [CEM-ID-00005][Warning] For every optional element that exists
            and can have text content, the element should have non-null, 
            non-whitespace value.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M29"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="cem:Event" priority="1018" mode="M29">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cem:Event"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="normalize-space(string())"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="normalize-space(string())">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [CEM-ID-00005][Warning] For every optional element that exists
            and can have text content, the element should have non-null, 
            non-whitespace value.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M29"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="cem:Facility" priority="1017" mode="M29">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cem:Facility"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="normalize-space(string())"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="normalize-space(string())">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [CEM-ID-00005][Warning] For every optional element that exists
            and can have text content, the element should have non-null, 
            non-whitespace value.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M29"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="cem:GeoFeature" priority="1016" mode="M29">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cem:GeoFeature"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="normalize-space(string())"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="normalize-space(string())">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [CEM-ID-00005][Warning] For every optional element that exists
            and can have text content, the element should have non-null, 
            non-whitespace value.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M29"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="cem:GeoRef" priority="1015" mode="M29">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cem:GeoRef"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="normalize-space(string())"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="normalize-space(string())">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [CEM-ID-00005][Warning] For every optional element that exists
            and can have text content, the element should have non-null, 
            non-whitespace value.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M29"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="cem:Identifier" priority="1014" mode="M29">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cem:Identifier"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="normalize-space(string())"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="normalize-space(string())">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [CEM-ID-00005][Warning] For every optional element that exists
            and can have text content, the element should have non-null, 
            non-whitespace value.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M29"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="cem:InfoBearer" priority="1013" mode="M29">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cem:InfoBearer"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="normalize-space(string())"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="normalize-space(string())">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [CEM-ID-00005][Warning] For every optional element that exists
            and can have text content, the element should have non-null, 
            non-whitespace value.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M29"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="cem:LocationOfInterest" priority="1012" mode="M29">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="cem:LocationOfInterest"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="normalize-space(string())"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="normalize-space(string())">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [CEM-ID-00005][Warning] For every optional element that exists
            and can have text content, the element should have non-null, 
            non-whitespace value.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M29"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="cem:MilitaryUnit" priority="1011" mode="M29">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cem:MilitaryUnit"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="normalize-space(string())"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="normalize-space(string())">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [CEM-ID-00005][Warning] For every optional element that exists
            and can have text content, the element should have non-null, 
            non-whitespace value.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M29"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="cem:Money" priority="1010" mode="M29">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cem:Money"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="normalize-space(string())"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="normalize-space(string())">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [CEM-ID-00005][Warning] For every optional element that exists
            and can have text content, the element should have non-null, 
            non-whitespace value.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M29"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="cem:Nomenclature" priority="1009" mode="M29">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cem:Nomenclature"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="normalize-space(string())"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="normalize-space(string())">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [CEM-ID-00005][Warning] For every optional element that exists
            and can have text content, the element should have non-null, 
            non-whitespace value.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M29"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="cem:Organization" priority="1008" mode="M29">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cem:Organization"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="normalize-space(string())"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="normalize-space(string())">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [CEM-ID-00005][Warning] For every optional element that exists
            and can have text content, the element should have non-null, 
            non-whitespace value.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M29"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="cem:Person" priority="1007" mode="M29">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cem:Person"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="normalize-space(string())"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="normalize-space(string())">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [CEM-ID-00005][Warning] For every optional element that exists
            and can have text content, the element should have non-null, 
            non-whitespace value.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M29"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="cem:QuantityReference" priority="1006" mode="M29">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cem:QuantityReference"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="normalize-space(string())"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="normalize-space(string())">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [CEM-ID-00005][Warning] For every optional element that exists
            and can have text content, the element should have non-null, 
            non-whitespace value.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M29"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="cem:SystemClass" priority="1005" mode="M29">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cem:SystemClass"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="normalize-space(string())"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="normalize-space(string())">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [CEM-ID-00005][Warning] For every optional element that exists
            and can have text content, the element should have non-null, 
            non-whitespace value.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M29"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="cem:Term" priority="1004" mode="M29">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cem:Term"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="normalize-space(string())"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="normalize-space(string())">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [CEM-ID-00005][Warning] For every optional element that exists
            and can have text content, the element should have non-null, 
            non-whitespace value.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M29"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="cem:Time" priority="1003" mode="M29">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cem:Time"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="normalize-space(string())"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="normalize-space(string())">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [CEM-ID-00005][Warning] For every optional element that exists
            and can have text content, the element should have non-null, 
            non-whitespace value.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M29"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="cem:TransportationNetwork" priority="1002" mode="M29">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="cem:TransportationNetwork"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="normalize-space(string())"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="normalize-space(string())">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [CEM-ID-00005][Warning] For every optional element that exists
            and can have text content, the element should have non-null, 
            non-whitespace value.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M29"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="cem:Vehicle" priority="1001" mode="M29">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cem:Vehicle"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="normalize-space(string())"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="normalize-space(string())">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [CEM-ID-00005][Warning] For every optional element that exists
            and can have text content, the element should have non-null, 
            non-whitespace value.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M29"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="cem:Weapon" priority="1000" mode="M29">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cem:Weapon"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="normalize-space(string())"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="normalize-space(string())">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [CEM-ID-00005][Warning] For every optional element that exists
            and can have text content, the element should have non-null, 
            non-whitespace value.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M29"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M29"/>
   <xsl:template match="@*|node()" priority="-2" mode="M29">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M29"/>
   </xsl:template>
</xsl:stylesheet>
<!--UNCLASSIFIED-->
