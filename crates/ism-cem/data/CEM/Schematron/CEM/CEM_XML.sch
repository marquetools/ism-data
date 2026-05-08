<?xml version="1.0" encoding="UTF-8"?>
<!--UNCLASSIFIED--><?ICEA master?>
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<!-- WARNING: 
    Once compiled into an XSLT the result will 
    be the aggregate classification of all the CVES 
    and included .sch files
-->
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron"
            xmlns:ism="urn:us:gov:ic:ism"
            queryBinding="xslt2">
    <sch:ns uri="urn:us:gov:ic:cem" prefix="cem"/>
    <sch:ns uri="urn:us:gov:ic:virt" prefix="virt"/>
    <sch:ns uri="http://www.w3.org/1999/xlink" prefix="xlink"/>
    <sch:ns uri="date:time:function" prefix="dtf"/>
    <sch:p ism:classification="U" ism:ownerProducer="USA" class="codeDesc">This is the root file for the CEM Schematron rule set. It loads all of
      the required CVEs declares some variables and includes all of the Rule .sch files. </sch:p>

   <!-- **************************** -->
   <!-- * General Global Variables * -->
   <!-- **************************** -->
   <sch:let name="timeZoneRegEx" value="'Z|[\+-]\d{2}:\d{2}'"/>
   <sch:let name="defaultTimeZone" value="'Z'"/>
   <sch:let name="startDateTimeTemplate" value="'0001-01-01T00:00:00.000'"/>
   <sch:let name="endDateTimeTemplate" value="'9999-12-01T23:59:59.999'"/>
   
   <!-- ************************************* -->
   <!-- * Custom XSLT2 Function Definitions * -->
   <!-- ************************************* -->
   <!--
		Returns a string representation of the year portion of the date
		represented by the provided string.
		@param {xs:string} dateString String representation of a date in one
		    of the allowable formats.
		@returns {xs:string} String representation of the year portion of the 
		    date represented by the provided string.
	-->
   <xsl:function xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                 name="dtf:getYear"
                 as="xs:string">
      <xsl:param name="dateString" as="xs:string"/>
      <xsl:value-of select="substring(dtf:removeTimeZone($dateString), 1, 4)"/>
   </xsl:function>
   <!--
		Returns a string representation of the month portion of the date
		represented by the provided string.
		@param {xs:string} dateString String representation of a date in one
		    of the allowable formats.
		@returns {xs:string} String representation of the month portion of the 
		date represented by the provided string.
	-->
   <xsl:function xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                 name="dtf:getMonth"
                 as="xs:string">
      <xsl:param name="dateString" as="xs:string"/>
      <xsl:value-of select="substring(dtf:removeTimeZone($dateString), 6, 2)"/>
   </xsl:function>
   <!--
		@param {xs:date} date String representation of a date
		@returns {xs:boolean} Returns true if the date provided occurs in a 
		    leap year; otherwise returns false.
	-->
   <xsl:function xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
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
   <!--
		Returns the maximum day of the month for an xs:dateTime as an xs:string.
		@param {xs:dateTime} date The date time from which to get the month
		@returns {xs:string} String representation of the maximum day of the month
	-->
   <xsl:function xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
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
   <!--
		Replaces the day portion of the provided dateTime with the new day provided.
		@param {xs:dateTime} dateTime An xs:dateTime to be updated with new day.
		@param {xs:string} newDayString String representation of day portion of a date.
		@returns {xs:dateTime} Returns new xs:dateTime with updated day portion. 
		leap year; otherwise returns false.
	-->
   <xsl:function xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                 name="dtf:replaceDateTimeDay"
                 as="xs:dateTime">
      <xsl:param name="dateTime" as="xs:dateTime"/>
      <xsl:param name="newDayString" as="xs:string"/>
      <xsl:variable name="beforeDay" select="substring(string($dateTime), 1, 8)"/>
      <xsl:variable name="afterDay" select="substring(string($dateTime), 11)"/>
      <xsl:value-of select="concat($beforeDay, $newDayString, $afterDay)"/>
   </xsl:function>
   <!--
		Returns a string representation of the day portion of the date
		represented by the provided string.
		@param {xs:string} dateString String representation of a date in one
		    of the allowable formats.
		@returns {xs:string} String representation of the day portion of the 
		date represented by the provided string.
	-->
   <xsl:function xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                 name="dtf:getDay"
                 as="xs:string">
      <xsl:param name="dateString" as="xs:string"/>
      <xsl:value-of select="substring(dtf:removeTimeZone($dateString), 9, 2)"/>
   </xsl:function>
   <!--
		Removes the timezone portion of the date represented by the provided
		string and returns all remaining portions.
		@param {xs:string} dateString String representation of a date in one
		    of the allowable formats.
		@returns {xs:string} String representation of a date without a timezone
		    portion.
	-->
   <xsl:function xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                 name="dtf:removeTimeZone"
                 as="xs:string">
      <xsl:param name="dateString" as="xs:string"/>
      <xsl:value-of select="replace($dateString, $timeZoneRegEx, '')"/>
   </xsl:function>
   <!--
		Uses the template provided to fill in missing portions of the string
		representation of a dateTime provided and returns a full xs:dateTime.
		The dateString provided must not contain a timezone.
		@param {xs:string} dateString String representation of a date in one
		    of the allowable formats.
		@param {xs:string} dateTemplateString String template of a default date
		    from which to pad missing portions of the dateString parameter.
		@returns {xs:dateTime} An xs:dateTime represented by the string date provided.
	-->
   <xsl:function xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                 name="dtf:padDateTimeWithTemplate"
                 as="xs:dateTime">
      <xsl:param name="dateString" as="xs:string"/>
      <xsl:param name="dateTemplateString" as="xs:string"/>
      <xsl:value-of select="concat($dateString, substring($dateTemplateString, string-length(normalize-space($dateString)) + 1))"/>
   </xsl:function>
   <!--
		Returns a string representation of the timezone portion of the date
		represented by the provided string.
		@param {xs:string} dateString String representation of a date in one
		    of the allowable formats.
		@returns {xs:string} String representation of the timezone portion of
		    the date represented by the provided string.
	-->
   <xsl:function xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
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
   <!--
		Calculates the date range implied for both primary and secondary and 
		determines if there is any overlap between the two ranges. Overlap is
		defined as the start of primary date range less than or equal to the 
		end of secondary date range, inclusive, and the start of the secondary
		date range less than or equal to the end of the primary date range.
		Returns true if there is any overlap; otherwise, returns false.
		@param {xs:string} primary String representation of a date in one
		    of the allowable formats.
		@param {xs:string} secondary String representation of a date in one
		    of the allowable formats.
		@returns {xs:boolean} Returns true if the date ranges implied by primary 
		    and secondary overlap at all; otherwise, returns false.
	-->
   <xsl:function xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
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
   <!--
		Determines if the date range implied by the string representation in 
		primary is strictly before the date range implied by the string
		representation in secondary. Returns true if the end of the date
		range implied by primary is less than the start of the date range
		implied by secondary; otherwise, returns false.
		@param {xs:string} primary String representation of a date in one
		    of the allowable formats.
		@param {xs:string} secondary String representation of a date in one
		    of the allowable formats.
		@returns {xs:boolean} Returns true if the date range implied by primary 
		    is stricly earlier than the date range implied by secondary; otherwise,
		    returns false.
	-->
   <xsl:function xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
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
   <!--
		Determines if the date range implied by the string representation in 
		primary is strictly after the date range implied by the string
		representation in secondary. Returns true if the end of the date
		range implied by primary is less than the start of the date range
		implied by secondary; otherwise, returns false.
		@param {xs:string} primary String representation of a date in one
		    of the allowable formats.
		@param {xs:string} secondary String representation of a date in one
		    of the allowable formats.
		@returns {xs:boolean} Returns true if the date range implied by primary 
		    is stricly later than the date range implied by secondary; otherwise,
		    returns false.
	-->
   <xsl:function xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
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
   <!--
		Returns the earlist xs:dateTime possible for the provided string
		representation of a dateTime. Fills in missing portions of the 
		dateTime with the earliest possible values. Default values for missing
		portions:
		MM = 01
		DD = 01
		hh = 00
		mm = 00
		ss = 00
		s  = 000
		@param {xs:string} dateString String representation of a date in one
		    of the allowable formats.
		@returns {xs:dateTime} The earliest xs:dateTime possible for the 
		    provided string representation of a dateTime.
	-->
   <xsl:function xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                 name="dtf:startDate"
                 as="xs:dateTime">
      <xsl:param name="dateString" as="xs:string"/>
      <xsl:variable name="timeZonePortion" select="dtf:getTimeZone($dateString)"/>
      <xsl:variable name="dateTimePortion" select="dtf:removeTimeZone($dateString)"/>
      <xsl:variable name="outputDate"
                    select="dtf:padDateTimeWithTemplate($dateTimePortion, $startDateTimeTemplate)"/>
      <xsl:value-of select="concat($outputDate, $timeZonePortion)"/>
   </xsl:function>
   <!--
		Returns the latest xs:dateTime possible for the provided string
		representation of a dateTime. Fills in missing portions of the 
		dateTime with the latest possible values. Default values for missing
		portions:
		MM = 12
		DD = maximum day of the month
		hh = 23
		mm = 59
		ss = 59
		s  = 999
		@param {xs:string} dateString String representation of a date in one
		    of the allowable formats.
		@returns {xs:dateTime} The latest xs:dateTime possible for the 
		    provided string representation of a dateTime.
	-->
   <xsl:function xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
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
   <!--
		Returns true if the year portion of the date represented by the provided
		string contains four (4) digits; otherwise returns false.
		@param {xs:string} dateString String representation of a date in one
		    of the allowable formats.
		@returns {xs:string} true if the year portion of the date represented by
		    the provided string contains four (4) digits; otherwise returns false.
	-->
   <xsl:function xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
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
   <!--
		Determines if the date range implied by the string representation in 
		primary satisfies the comparison to the date range implied by secondary
		using the provided comparison operator; otherwise, returns false.
		
		Both primary and secondary must be in one of the allowable formats
		and represent dates with four digits in the year portion.
		@param {xs:string} primary String representation of a date in one
		    of the allowable formats.
		@param {xs:string} secondary String representation of a date in one
		    of the allowable formats.
		@returns {xs:boolean} Returns true if the date range implied by primary 
		    satisfies the comparison to the date range implied by secondary using
		    the provided comparison operator; otherwise, returns false.
	-->
   <xsl:function xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
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
               <!-- 'Less Than' Edge Case -->
               <!-- 2010-01-01T00:00:00.000Z < 2010 -->
               <xsl:when test="($operator = 'lt' or $operator = '&lt;') and (($primaryStart = $primaryEnd and $primaryStart = $secondaryStart) or ($primaryStart = $primaryEnd and $primaryStart = $secondaryEnd) or ($secondaryStart = $secondaryEnd and $primaryStart = $secondaryStart))">
                  <xsl:value-of select="false()"/>
               </xsl:when>
               <!-- 'Greater Than' Edge Case -->
               <!-- 2010-12-31T23:59:59.999Z > 2010 -->
               <xsl:when test="($operator = 'gt' or $operator = '&gt;') and (($primaryStart = $primaryEnd and $primaryEnd = $secondaryEnd) or ($primaryStart = $primaryEnd and $primaryEnd = $secondaryStart) or ($secondaryStart = $secondaryEnd and $primaryEnd = $secondaryEnd))">
                  <xsl:value-of select="false()"/>
               </xsl:when>
               <!-- 'Less Than' and 'Less Than or Equal' -->
               <xsl:when test="$operator = 'lt' or $operator = '&lt;' or $operator = '&lt;='">
                  <xsl:value-of select="dtf:isBefore($primary, $secondary) or dtf:overlaps($primary, $secondary)"/>
               </xsl:when>
               <!-- 'Greater Than' and 'Greater Than or Equal' -->
               <xsl:when test="$operator = 'gt' or $operator = '&gt;' or $operator = '&gt;='">
                  <xsl:value-of select="dtf:isAfter($primary, $secondary) or dtf:overlaps($primary, $secondary)"/>
               </xsl:when>
               <!-- Default to false() -->
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

   <!--****************************-->
<!-- (U) CEM ID Rules -->
<!--****************************-->

<!--(U) -->
   <sch:include href="./Rules/CEM_ID_00001.sch"/>
   <sch:include href="./Rules/CEM_ID_00002.sch"/>
   <sch:include href="./Rules/CEM_ID_00003.sch"/>
   <sch:include href="./Rules/CEM_ID_00004.sch"/>
   <sch:include href="./Rules/CEM_ID_00005.sch"/>

   <!--****************************-->
<!-- (U) CEM Phases -->
<!--****************************--></sch:schema>
<!--UNCLASSIFIED-->
