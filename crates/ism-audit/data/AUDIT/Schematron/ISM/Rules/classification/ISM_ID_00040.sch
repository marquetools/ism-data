<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00040" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00040][Error] If ISM_CAPCO_RESOURCE and attribute 
        ownerProducer contains [USA] then attribute classification must have a value in 
        CVEnumISMClassificationUS.xml.
    </sch:p>
    <sch:p id="codeDesc">
        To determine the valid values, this rule first retrieves the CVE 
        values for the attribute, which in this case is classification. Then, each attribute token
        is converted into a numerical value based on its characters. Next, each attribute token is 
        given an order number, which compares its position to that of its value in the CVE file. If
        the token is not found, its order number will be -1. If the document is a CAPCO resource and 
        the ownerProducer of this element is 'USA', then the rule will fail if tokens are 
        found with order numbers of -1. The rule will also fail if duplicate values are found for the 
        element, or when its count is greater than 1.
    </sch:p>

    <sch:rule context="*[@ism:classification and $ISM_CAPCO_RESOURCE]">
        <!-- Define variables -->      
        <sch:let name="errMsg_ValueNotFound" value="'
            [ISM-ID-00040][Error] If ISM_CAPCO_RESOURCE and attribute 
            ownerProducer contains [USA] then attribute classification must have a value in 
            CVEnumISMClassificationUS.xml.'
            "/>
        
        <sch:let name="dataFileElems" value="$classificationUSList"/>
        <sch:let name="attrValues" value="./@ism:classification"/>
        <sch:let name="attrValueTokens" value="tokenize(string($attrValues),' ')"/>
        <sch:let name="capco" value="contains(string(./@ism:ownerProducer), 'USA')"/>
        
        
        <!-- Get the position of each client node relative to its position in the master list.  If the node is not found, return a -1 -->
        <sch:let name="orderNums" value="
            for $token in $attrValueTokens return 
            if ($dataFileElems[matches($token,concat('^',text(),'$'))]) then 
            count(($dataFileElems[matches($token,concat('^',text(),'$'))])/preceding::*) + 1
            else -1"/>
        
        <!-- Determine if the list has invalid values. If and only if it does, figure out which ones are invalids -->
        <sch:let name="hasInvalids" value="count(index-of($orderNums,-1)) > 0"/>            
        <sch:let name="invalidValues" value="
            if ($hasInvalids) then
            distinct-values(
            for $token in index-of($orderNums,-1) return
            $attrValueTokens[$token] 
            )
            else null
            "/>
        
        <!-- Determine if the list has duplicate values. If and only if it does, figure out which ones are duplicates -->
        <sch:let name="hasDups" value="count(distinct-values($attrValueTokens)) != count($attrValueTokens)"/>            
        <sch:let name="dupValues" value="
            if ($hasDups) then
            distinct-values(
            for $token in $attrValueTokens return
            if (count(index-of($attrValueTokens,$token)) > 1) then $attrValueTokens[index-of($attrValueTokens,$token)[1]] 
            else null
            )   
            else null
            "/>
        
        <!-- Execute tests --> 
        <sch:assert id="ISM-00040" flag="error"
            test="if(not($capco)) then true() else not($hasInvalids)">
            <sch:value-of select="$errMsg_ValueNotFound"/>
            Invalid value of [<sch:value-of select="$invalidValues"/>]</sch:assert>
        <sch:assert test="not($hasDups)" flag="undefined">Duplicate values found [<sch:value-of select="$dupValues"
        />] for [<sch:value-of select="$attrValueTokens"/>] </sch:assert>
    </sch:rule>
</sch:pattern>