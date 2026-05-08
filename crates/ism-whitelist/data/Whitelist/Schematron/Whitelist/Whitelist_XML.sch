<?xml version="1.0" encoding="UTF-8"?>
<!--UNCLASSIFIED-->
<!--        Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
    <sch:ns uri="urn:us:gov:ic:ism" prefix="ism"/>
    <sch:ns uri="urn:us:gov:ic:ntk" prefix="ntk"/>
    <sch:ns uri="urn:us:gov:ic:taxonomy:catt:tetragraph" prefix="catt"/>
    <sch:ns uri="urn:us:gov:ic:cve" prefix="cve"/>
    <sch:ns uri="deprecated:value:function" prefix="dvf"/>
    <sch:ns uri="urn:us:gov:ic:ism:xsl:util" prefix="util"/>
    
    <sch:p class="codeDesc">This is the root file for the Whitelist Schematron rule set. It loads
        all of the required CVEs, declares some variables and includes all of the Rule .sch files. </sch:p>

    <!-- (U) Abstract Patterns -->
    <sch:include href="./Lib/ValidateDecomposableTokensExistInWhitelist.sch"/>       
    <sch:include href="./Lib/ValidateTokensExistInWhitelist.sch"/>
    <sch:include href="./Lib/ValidateTokenValuesNotInBlacklist.sch"/>   
    <sch:include href="./Lib/AllValuesExistInList.sch"/> 
    <sch:include href="./Lib/SomeValuesExistInList.sch"/>

    <!-- (U) Whitelist Configuration File  -->
    <sch:let name="configXML" value="document('./whitelist_config.xml')"/>

    <!-- (U) Resources  -->
    <sch:let name="ismAttributesList"
            value="$configXML//Whitelist/ISMAttributes/values"/>
    <sch:let name="ismAttributesListType"
            value="$configXML//Whitelist/ISMAttributes/values/@type"/>
    <sch:let name="classificationList"
            value="$configXML//Whitelist/Classification/values"/>
    <sch:let name="disseminationControlsList"
            value="$configXML//Whitelist/DisseminationControls/values"/>
    <sch:let name="releasableToList"
            value="util:getSpaceSeparatedStringFromSequence(util:expandDecomposableTetras($configXML//Whitelist/ReleasableTo/values))"/>
    <sch:let name="releasableToMinList"
            value="util:getSpaceSeparatedStringFromSequence(util:expandDecomposableTetras($configXML//Whitelist/ReleasableTo/minimumValues))"/>
    <sch:let name="releasableToListType"
            value="$configXML//Whitelist/ReleasableTo/values/@type"/>
    <sch:let name="ownerProducerList"
            value="$configXML//Whitelist/OwnerProducer/values"/>
    <sch:let name="ownerProducerListType"
            value="$configXML//Whitelist/OwnerProducer/values/@type"/>
    <sch:let name="atomicEnergyMarkingsList"
            value="$configXML//Whitelist/AtomicEnergyMarkings/values"/>
    <sch:let name="nonICmarkingsList"
            value="$configXML//Whitelist/NonICmarkings/values"/>
    <sch:let name="SCIControlsList" value="$configXML//Whitelist/SCIControls/values"/>
    <sch:let name="displayOnlyToList"
            value="util:getSpaceSeparatedStringFromSequence(util:expandDecomposableTetras($configXML//Whitelist/DisplayOnlyTo/values))"/>
    <sch:let name="displayOnlyToListType"
            value="$configXML//Whitelist/DisplayOnlyTo/values/@type"/>
    <sch:let name="FGIsourceOpenList"
            value="$configXML//Whitelist/FGIsourceOpen/values"/>
    <sch:let name="FGIsourceOpenListType"
            value="$configXML//Whitelist/FGIsourceOpen/values/@type"/>
    <sch:let name="FGIsourceProtectedList"
            value="$configXML//Whitelist/FGIsourceProtected/values"/>
    <sch:let name="FGIsourceProtectedListType"
            value="$configXML//Whitelist/FGIsourceProtected/values/@type"/>
    <sch:let name="nonUSControlsList"
            value="$configXML//Whitelist/NonUSControls/values"/>
    <sch:let name="SARIdentifierList"
            value="$configXML//Whitelist/SARIdentifier/values"/>
    <sch:let name="policyList" value="$configXML//Whitelist/NtkPolicy/value"/>
    <sch:let name="vocabList" value="$configXML//Whitelist/NtkVocabulary/value"/>
    <sch:let name="accessProfileValueList"
            value="for $value in $configXML//Whitelist/NtkAccessProfile[@accessPolicy != 'urn:us:gov:ic:aces:ntk:permissive']/profile                     return normalize-space(concat($value/../@accessPolicy, ' ', $value/@vocabulary, ' ', $value/@profileValue))"/>
    <sch:let name="accessProfileValueListPermissive"
            value="for $value in $configXML//Whitelist/NtkAccessProfile[@accessPolicy = 'urn:us:gov:ic:aces:ntk:permissive']/profile                      return normalize-space(concat($value/../@accessPolicy, ' ', $value/@vocabulary, ' ', $value/@profileValue))"/>
    <sch:let name="profilesWithMinValues"
            value="$configXML//Whitelist/NtkAccessProfile[count(./minimumValues/profile/@profileValue) &gt; 0]/@accessPolicy"/>
    <sch:let name="accessProfileMinValueList"
            value="for $value in $configXML//Whitelist/NtkAccessProfile[(@accessPolicy != 'urn:us:gov:ic:aces:ntk:restrictive')]/minimumValues/profile return normalize-space(concat($value/../../@accessPolicy, ' ', $value/@vocabulary, ' ', $value/@profileValue))"/>

    <sch:let name="ismAttributesList_tok"
            value="tokenize(normalize-space(string($ismAttributesList)), ' ')"/>
    <sch:let name="classificationList_tok"
            value="tokenize(normalize-space(string($classificationList)), ' ')"/>
    <sch:let name="disseminationControlsList_tok"
            value="tokenize(normalize-space(string($disseminationControlsList)), ' ')"/>
    <sch:let name="releasableToList_tok"
            value="for $value in $releasableToList return   normalize-space(concat($value, ' '))"/>
    <sch:let name="releasableToMinList_tok"
            value="for $value in $releasableToMinList   return   normalize-space(concat($value, ' '))"/>
    <sch:let name="ownerProducerList_tok"
            value="tokenize(normalize-space(string($ownerProducerList)), ' ')"/>
    <sch:let name="atomicEnergyMarkingsList_tok"
            value="tokenize(normalize-space(string($atomicEnergyMarkingsList)), ' ')"/>
    <sch:let name="SCIControlsList_tok"
            value="tokenize(normalize-space(string($SCIControlsList)), ' ')"/>
    <sch:let name="nonICmarkingsList_tok"
            value="tokenize(normalize-space(string($nonICmarkingsList)), ' ')"/>
    <sch:let name="displayOnlyToList_tok"
            value="for $value in $displayOnlyToList     return   normalize-space(concat($value, ' '))"/>
    <sch:let name="FGIsourceOpenList_tok"
            value="tokenize(normalize-space(string($FGIsourceOpenList)), ' ')"/>
    <sch:let name="FGIsourceProtectedList_tok"
            value="tokenize(normalize-space(string($FGIsourceProtectedList)), ' ')"/>
    <sch:let name="nonUSControlsList_tok"
            value="tokenize(normalize-space(string($nonUSControlsList)), ' ')"/>
    <sch:let name="SARIdentifierList_tok"
            value="tokenize(normalize-space(string($SARIdentifierList)), ' ')"/>
        
    <!-- ISMCAT Dependencies for decomposition  -->
    <sch:let name="catt"
            value="document('../../Taxonomy/ISMCAT/TetragraphTaxonomy.xml')"/>
    <sch:let name="cattMappings" value="$catt//catt:Tetragraph"/>
    <sch:let name="decomposableTetraElems"
            value="$cattMappings[@decomposable[. = 'Yes']]"/>
    <sch:let name="decomposableTetras"
            value="$decomposableTetraElems/catt:TetraToken/text()"/>

    <!--****************************-->

    <!-- (U) Custom XSLT functions   -->

    <!--****************************-->

    <!-- Returns true if all token in the attribute value match at least one token in the provided list.-->
    <xsl:function xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                 name="util:containsOnlyTheTokens"
                 as="xs:boolean">
        <xsl:param name="attribute"/>
        <xsl:param name="tokenList" as="xs:string*"/>
        <xsl:value-of select="every $attrToken in tokenize(normalize-space(string($attribute)), ' ')                               satisfies $attrToken = $tokenList"/>
    </xsl:function>

    <!-- Return first item in a list of values -->
    <xsl:function xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
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
        
    <!--
        Return a list of values as a space delimited string from a sequence of tokens
   -->
    <xsl:function xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
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

    <!--
        Return a list of values as a comma delimited string from a sequence of tokens
    -->
    <xsl:function xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
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

    <!-- Returns the sequence of country codes that correspond to the given $tetra -->
    <xsl:function xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                 name="util:getCountriesForTetra"
                 as="xs:string*">
        <xsl:param name="tetra" as="xs:string"/>

        <xsl:sequence select="$decomposableTetraElems[catt:TetraToken/text() = $tetra]/catt:Membership/catt:Country/text()"/>
    </xsl:function>

    <!--
    Returns true if the attribute @ism:excludeFromRollup is present and evaluates to 'true'
      -->
    <xsl:function xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                 name="util:contributesToRollup"
                 as="xs:boolean">
        <xsl:param name="context"/>
        <xsl:value-of select="not(string($context/@ism:excludeFromRollup) = 'true')"/>
    </xsl:function>


    <!-- Returns normalized $value with a preceding and subsequent space (' ') character -->
    <xsl:function xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                 name="util:padValue"
                 as="xs:string">
        <xsl:param name="value" as="xs:string?"/>

        <xsl:value-of select="concat(' ', normalize-space($value), ' ')"/>
    </xsl:function>

    <!-- Returns the given $value with its values broken into tokens using whitespace as delimiters -->

    <xsl:function xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                 name="util:tokenize"
                 as="xs:string*">
        <xsl:param name="value" as="xs:string?"/>

        <xsl:sequence select="tokenize(normalize-space($value), ' ')"/>
    </xsl:function>

    <!-- Returns the given sequence of $values joined into a normalized single string  -->

    <xsl:function xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                 name="util:join"
                 as="xs:string">
        <xsl:param name="values" as="xs:string*"/>

        <xsl:sequence select="normalize-space(string-join($values, ' '))"/>
    </xsl:function>

    <!--
    Returns true if any token in the attribute value matches at least one token in the provided list.
    -->
    <xsl:function xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                 name="util:containsAnyOfTheTokens"
                 as="xs:boolean">
        <xsl:param name="attribute"/>
        <xsl:param name="tokenList" as="xs:string*"/>
        <xsl:value-of select="                 some $attrToken in tokenize(normalize-space(string($attribute)), ' ')                     satisfies $attrToken = $tokenList"/>
    </xsl:function>

    <!-- Returns true if the given $relTo string (e.g. 'USA CAN GBR') contains any 
        tetragraphs that can be decomposed into its constituent countries  -->
    <xsl:function xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                 name="util:containsDecomposableTetra"
                 as="xs:boolean">
        <xsl:param name="relTo" as="xs:string?"/>

        <xsl:sequence select="normalize-space($relTo) and util:containsAnyOfTheTokens($relTo, $decomposableTetras)"/>
    </xsl:function>

    <!-- Given a sequence of $relToStrings (e.g. ('USA CAN GBR', 'USA AUS SPAA')), returns a set of tokens 
        that are each of these $relToStrings decomposed using util:expandDecomposableTetras() -->
    <xsl:function xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
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

    <!-- Recursively remove all decomposable tetragraphs in the given $relTo string 
        and replace them with their constituent countries. Note: Does not include USA -->
    <xsl:function xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
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

   <!--****************************-->
<!-- (U) Whitelist ID Rules -->
<!--****************************-->

<!--(U) -->
   <sch:include href="./Rules/WLAtomicEnergyMarkings_ID_00001.sch"/>
   <sch:include href="./Rules/WLClassification_ID_00001.sch"/>
   <sch:include href="./Rules/WLDisseminationControls_ID_00001.sch"/>
   <sch:include href="./Rules/WLFGIsourceOpen_ID_00001.sch"/>
   <sch:include href="./Rules/WLFGIsourceProtected_ID_00001.sch"/>
   <sch:include href="./Rules/WLISMAttributes_ID_00001.sch"/>
   <sch:include href="./Rules/WLNtkAccessPolicy_ID_00001.sch"/>
   <sch:include href="./Rules/WLNtkAccessProfileValue_ID_00001.sch"/>
   <sch:include href="./Rules/WLNtkVocabulary_ID_00001.sch"/>
   <sch:include href="./Rules/WLReleaseableTo_ID_00001.sch"/>
   <sch:include href="./Rules/WLSARIdentifier_ID_00001.sch"/>
   <sch:include href="./Rules/WLSCIcontrols_ID_00001.sch"/>
   <sch:include href="./Rules/WLdisplayOnlyTo_ID_00001.sch"/>
   <sch:include href="./Rules/WLnonICmarkings_ID_00001.sch"/>
   <sch:include href="./Rules/WLnonUSControls_ID_00001.sch"/>
   <sch:include href="./Rules/WLownerProducer_ID_00001.sch"/>
   <sch:include href="./Rules/WLNtkAccessPolicy_ID_00002.sch"/>
   <sch:include href="./Rules/WLNtkAccessProfileValue_ID_00002.sch"/>
   <sch:include href="./Rules/WLNtkVocabulary_ID_00002.sch"/>
   <sch:include href="./Rules/WLReleaseableTo_ID_00002.sch"/>
   <sch:include href="./Rules/WLownerProducer_ID_00002.sch"/>
   <sch:include href="./Rules/WLNtkAccessProfileValue_ID_00003.sch"/>

   <!--****************************-->
<!-- (U) Whitelist Phases -->
<!--****************************--></sch:schema>
<!--UNCLASSIFIED-->
