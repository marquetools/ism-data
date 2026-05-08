<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern xmlns:sch="http://purl.oclc.org/dsdl/schematron" id="CEM-ID-00004">
    <sch:p xmlns:ism="urn:us:gov:ic:ism" ism:classification="U" ism:ownerProducer="USA" class="ruleText">
        [CEM-ID-00004][Error] If VIRT attributes are used on any CEM elements, then @virt:DESVersion must be declared.
    </sch:p>

    <sch:p xmlns:ism="urn:us:gov:ic:ism" ism:classification="U" ism:ownerProducer="USA" class="codeDesc">
        For any CEM elements with attribute virt:network, attribute virt:DESVersion must exist.
    </sch:p>
    
    <sch:rule context="cem:*[@virt:*]" id="CEM-ID-00004-R1">
        <sch:assert test="@virt:DESVersion" flag="error" role="error">
            [CEM-ID-00004][Error] [CEM-ID-00004][Error] If VIRT attributes are used on any CEM elements, then @virt:DESVersion must be declared.
        </sch:assert>
    </sch:rule>
</sch:pattern>
