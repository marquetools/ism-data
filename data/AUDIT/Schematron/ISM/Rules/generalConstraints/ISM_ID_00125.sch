<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00125" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    
    <sch:p id="ruleText">
        [ISM-ID-00125][Error] If any attributes in namespace 
        urn:us:gov:ic:ism exist, the local name must exist in CVEnumISMAttributes.xml. 
        
        Human Readable: Ensure that attributes in the ISM namespace are defined by ISM.XML.
    </sch:p>
    <sch:p id="codeDesc">
        To determine the valid values, this rule first retrieves the list of 
        valid attribute names as defined in CVEnumISMAttributes.xml. 
        Next, each attribute token is given an order number, which compares its 
        position to that of its value in the CVE file. If the token is not found, 
        its order number will be -1 and it is considered invalid. If the document 
        is a CAPCO resource, then the rule will fail if invalid tokens are found. 
        The rule will also fail if duplicate values are found for an attribute name.
    </sch:p>

    <sch:rule context="*[@ism:* and $ISM_CAPCO_RESOURCE]">
        <!-- Define variables -->    
        <sch:let name="errMsg_ValueNotFound" value="'
            [ISM-ID-00125][Error] If any attributes in namespace 
            urn:us:gov:ic:ism exist, the local name must exist in CVEnumISMAttributes.xml.
        '"/>
        
        <sch:let name="dataFileElems" value="$validAttributeList"/>
        <sch:let name="attrValues" value="string-join(./@ism:*/local-name(),' ')"/>
        <sch:let name="attrValueTokens" value="tokenize(string($attrValues),' ')"/>
        
        
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
                        if (count(index-of($attrValueTokens,$token)) > 1) then 
                            $attrValueTokens[index-of($attrValueTokens,$token)[1]] 
                        else null
                )   
            else null
            "/>
        
        <!-- Execute tests --> 
        <sch:assert id="ISM-00125" flag="error"
            test="not($hasInvalids)">
            <sch:value-of select="$errMsg_ValueNotFound"/>
            Invalid value of [<sch:value-of select="$invalidValues"/>]</sch:assert>
        <sch:assert test="not($hasDups)" flag="undefined">Duplicate values found [<sch:value-of select="$dupValues"
        />] for [<sch:value-of select="$attrValueTokens"/>] </sch:assert>
    </sch:rule>
</sch:pattern>