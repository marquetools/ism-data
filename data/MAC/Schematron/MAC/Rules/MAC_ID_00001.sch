<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern xmlns:sch="http://purl.oclc.org/dsdl/schematron" id="MAC-ID-00001">
    <sch:p class="ruleText">
        [MAC-ID-00001][Error] Every attribute in the document must be specified with a non-whitespace value.
    </sch:p>
    
    <sch:p class="codeDesc">
        For each element with at least one attribute specified, this rule normalizes the space of 
        the value of each attribute and make sure that the resulting string has a length 
        greater than zero, which indicates non-whitespace content.
    </sch:p>
    
    <sch:rule context="*">
        <sch:assert test="every $attribute in ./@mac:* satisfies             string-length(normalize-space(string($attribute))) &gt; 0"
                  flag="error">
            [MAC-ID-00001][Error] Every attribute in the document must be specified with a non-whitespace value.
        </sch:assert>
    </sch:rule>
</sch:pattern>
