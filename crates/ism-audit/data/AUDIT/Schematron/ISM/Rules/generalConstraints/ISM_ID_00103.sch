<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00103" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00103][Error] At least one element must have resourceElement true.
    </sch:p>
    <sch:p id="codeDesc">
        The code loops over all elements which have ISM attributes present and counts the elements which 
        specify the attribute resourceElement. Then it makes sure that the total is greater than zero.
    </sch:p>
    <sch:rule context="/*">
        <sch:assert 
            id="ISM-00103" 
            test="
            count(
                for $token in //*[(@ism:*)] return 
                if($token/@ism:resourceElement=true()) then 1 else null
            ) > 0
            "
            flag="error">
            [ISM-ID-00103][Error] At least one element must have resourceElement true.
        </sch:assert>
    </sch:rule>
</sch:pattern>