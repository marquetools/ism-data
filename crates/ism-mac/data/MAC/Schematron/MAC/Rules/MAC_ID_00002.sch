<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern xmlns:sch="http://purl.oclc.org/dsdl/schematron" id="MAC-ID-00002">
    <sch:p class="ruleText">
        [MAC-ID-00002][Error] The DESVersion of MAC must be 201609 for these rules to apply.
    </sch:p>
    
    <sch:p class="codeDesc">
        For each element with attribute mac:DESVersion specified, this rule ensures that the value
        matches the version of this rule set.
    </sch:p>
    
    <sch:rule context="*[@mac:DESVersion]">
        <sch:assert test="matches(@mac:DESVersion, '^201609')" flag="error">
            [MAC-ID-00002][Error] The DESVersion of MAC must be 201609 for these rules to apply.
        </sch:assert>
    </sch:rule>
</sch:pattern>
