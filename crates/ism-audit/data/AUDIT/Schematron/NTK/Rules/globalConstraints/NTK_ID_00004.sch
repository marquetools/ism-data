<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="NTK-ID-00004" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [NTK-ID-00004][Error] Every attribute in the document must be specified with a non-whitespace value.
    </sch:p>
    
    <sch:p id="codeDesc">
        For each element with at least one attribute specified, we normalize the space of 
        the value of each attribute and make sure that the resulting string has a length 
        greater than zero, which indicates non-whitespace content.
    </sch:p>
    
    <sch:rule context="//*[@*]">
        <sch:assert
            id="NTK-00004"
            test="every $attribute in ./@* satisfies
            string-length(normalize-space(string($attribute))) > 0"
            flag="error">
            [NTK-ID-00004][Error] Every attribute in the document must be specified with a non-whitespace value.
        </sch:assert>
    </sch:rule>
</sch:pattern>