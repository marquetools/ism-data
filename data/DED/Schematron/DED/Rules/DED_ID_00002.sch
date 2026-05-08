<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern xmlns:sch="http://purl.oclc.org/dsdl/schematron" id="DED-ID-00002">
    <sch:p class="ruleText">
        [DED-ID-00002][Error] @icid:DESVersion must be declared.
    </sch:p>
    
    <sch:p class="codeDesc">
        Check to verify that there exists a declaration of version for IC-ID.
    </sch:p>
    
    <sch:rule context="/*" id="DED-ID-00002-R1">
        <sch:assert test="exists(//*[@icid:DESVersion])" flag="error" role="error">
            [DED-ID-00002][Error] @icid:DESVersion must be declared.
        </sch:assert>
    </sch:rule>
</sch:pattern>
