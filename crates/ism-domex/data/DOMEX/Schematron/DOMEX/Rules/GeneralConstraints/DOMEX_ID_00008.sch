<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern xmlns:sch="http://purl.oclc.org/dsdl/schematron" id="DOMEX-ID-00008">
    <sch:p xmlns:ism="urn:us:gov:ic:ism" ism:ownerProducer="USA" ism:classification="U" class="ruleText">
        [DOMEX_ID_00008][Error] The root element of a DOMEX assertion must contain a DESVersion attribute. 
        
        Human Readable: The root element of a DOMEX assertion must contain a DESVersion attribute. 
    </sch:p>
    <sch:p xmlns:ism="urn:us:gov:ic:ism" ism:ownerProducer="USA" ism:classification="U" class="codeDesc">
        Check the root element of a DOMEX assertion to ensure that it contains a DESVersion attribute.
    </sch:p>
    <sch:rule id="DOMEX-ID-00008-R1" context="tdf:StructuredStatement/*[namespace-uri() = 'urn:us:mil:ces:metadata:domex']">
        <sch:assert test="@domex:DESVersion" flag="error" role="error"> 
            [DOMEX_ID_00008][Error] The root element of a DOMEX assertion must contain a DESVersion attribute. 
            
            Human Readable: The root element of a DOMEX assertion must contain a DESVersion attribute. 
        </sch:assert>
    </sch:rule>
    <sch:rule id="DOMEX-ID-00008-R2" context="tdf:StructuredStatement/*[namespace-uri() = 'urn:CellexReport']">
        <sch:assert test="@cr:DESVersion" flag="error" role="error">
            [DOMEX_ID_00008][Error] The root element of a DOMEX assertion must contain a DESVersion attribute. 
            
            Human Readable: The root element of a DOMEX assertion must contain a DESVersion attribute. 
        </sch:assert>
    </sch:rule>
    <sch:rule id="DOMEX-ID-00008-R3"
        context="tdf:StructuredStatement/*[namespace-uri() = 'urn:us:mil:ces:metadata:domex_identity']">
        <sch:assert test="@Identity:DESVersion" flag="error" role="error">
            [DOMEX_ID_00008][Error] The root element of a DOMEX assertion must contain a DESVersion attribute. 
            
            Human Readable: The root element of a DOMEX assertion must contain a DESVersion attribute. </sch:assert>
    </sch:rule>
</sch:pattern>
