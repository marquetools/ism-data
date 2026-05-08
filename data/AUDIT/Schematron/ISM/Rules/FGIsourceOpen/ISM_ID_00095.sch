<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00095" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    
    <sch:p id="ruleText">
        [ISM-ID-00095][Error] If ISM_CAPCO_RESOURCE and attribute FGIsourceOpen is 
        specified then each of its values must be ordered in accordance with CVEnumISMFGIOpen.xml.
    </sch:p>
    <sch:p id="codeDesc">
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
    </sch:p>
    
    <sch:rule context="*[@ism:FGIsourceOpen and $ISM_CAPCO_RESOURCE]">
        <!-- Define variables -->             
        <sch:let name="errMsg_AlphabeticalOrder" value="'
            [ISM-ID-00095][Error] If ISM_CAPCO_RESOURCE and attribute FGIsourceOpen is 
            specified then each of its values must be ordered in accordance with CVEnumISMFGIOpen.xml.
            '"/>
        
        <sch:let name="dataFileElems" value="$FGIsourceOpenList"/>
        <sch:let name="attrValues" value="string(./@ism:FGIsourceOpen)"/>
        <sch:let name="attrValueTokens" value="tokenize(string($attrValues),' ')"/>
        
        <!-- Convert each character to a numerical value, then concatenate the results to form a number-string -->
        <sch:let name="convertStrToNum" value="
            for $token in $attrValueTokens return
                number(string-join(
                    for $index in 1 to string-length($token) return
                        for $char in substring($token, $index, 1) return
                            if (contains(string('0123456789'), $char)) then
                                $char
                            else if (contains(string('ABCDEFGHI'), $char)) then
                                translate(string($char), 'ABCDEFGHI', '123456789')
                            else if (contains(string('JKLMNOPQRS'), $char)) then
                                concat('1', translate(string($char), 'JKLMNOPQRS', '0123456789'))
                            else if (contains(string('TUVWXYZ'), $char)) then
                                concat('2', translate(string($char), 'TUVWXYZ', '0123456'))
                            else '0'
                , ''))
            "/>
        
        <!-- Get the position of each client node relative to its position in the master list.  If the node is not found, return a -1 -->
        <sch:let name="orderNums" value="
            for $token in $attrValueTokens return 
                if ($dataFileElems[matches($token,concat('^',text(),'$'))]) then 
                    count(($dataFileElems[matches($token,concat('^',text(),'$'))])/preceding::*) + 1
                else -1"/>
        
        <!-- Create a sequence that returns a 0 if the previous sibling has a higher order number, else return a 1 -->            
        <sch:let name="sortedOrderNums" value="
            for $index in distinct-values(for $token in $orderNums return index-of($orderNums,$token)) return 
                if($index = 1 or $orderNums[$index] &gt; $orderNums[$index - 1]) then 1
                else if ($orderNums[$index] &lt; $orderNums[$index - 1]) then 0
                else
                    if (matches($attrValueTokens[$index], '[0-9]') or matches($attrValueTokens[$index - 1], '[0-9]')) then
                        if ($convertStrToNum[$index - 1] &gt; $convertStrToNum[$index]) then 0
                        else 2
                    else  
                        if (compare($attrValueTokens[$index - 1],$attrValueTokens[$index])=1) then 0
                        else 2
            "/>         
        <sch:let name="hasUnsorted" value="count(index-of($sortedOrderNums,0)) > 0" />
        <sch:let name="unsortedValues" value="
            if ($hasUnsorted) then
                distinct-values(
                    for $token in index-of($sortedOrderNums,0) return
                        $attrValueTokens[$token] 
                )
            else null
            "/>   
        
        <sch:assert id="ISM-00095" test="not($hasUnsorted)" flag="error">
            <sch:value-of select="$errMsg_AlphabeticalOrder"/>
            The following values are out of order [<sch:value-of
                select="$unsortedValues"/>] for [<sch:value-of select="$attrValueTokens"/>] </sch:assert>
    </sch:rule>
</sch:pattern>