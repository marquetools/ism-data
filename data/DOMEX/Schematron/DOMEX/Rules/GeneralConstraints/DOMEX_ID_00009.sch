<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern xmlns:sch="http://purl.oclc.org/dsdl/schematron" id="DOMEX-ID-00009">
    <sch:p xmlns:ism="urn:us:gov:ic:ism" ism:ownerProducer="USA" ism:classification="U" class="ruleText">
        [DOMEX_ID_00009][Error] The DOMEX assertion must have a scope of either TDO or TDC. 
        
        Human Readable: The DOMEX assertion must have a scope of either TDO or TDC. 
    </sch:p>
    <sch:p xmlns:ism="urn:us:gov:ic:ism" ism:ownerProducer="USA" ism:classification="U" class="codeDesc">
        Ensure that the DOMEX assertion has a scope of either TDO or TDC. 
    </sch:p>
    <sch:rule id="DOMEX-ID-00009-R1" context="tdf:StructuredStatement/*[namespace-uri() = 'urn:us:mil:ces:metadata:domex']">
        <sch:assert test="../../@tdf:scope='TDO' or ../../@tdf:scope='TDC'" flag="error" role="error"> 
            [DOMEX_ID_00009][Error] The DOMEX assertion must have a scope of either TDO or TDC.
        </sch:assert>
    </sch:rule>
    <sch:rule id="DOMEX-ID-00009-R2" context="tdf:StructuredStatement/*[namespace-uri() = 'urn:CellexReport']">
        <sch:assert test="../../@tdf:scope='TDO' or ../../@tdf:scope='TDC'" flag="error" role="error">
            [DOMEX_ID_00009][Error] The DOMEX assertion must have a scope of either TDO or TDC.
        </sch:assert>
    </sch:rule>
    <sch:rule id="DOMEX-ID-00009-R3"
        context="tdf:StructuredStatement/*[namespace-uri() = 'urn:us:mil:ces:metadata:domex_identity']">
        <sch:assert test="../../@tdf:scope='TDO' or ../../@tdf:scope='TDC'" flag="error" role="error">
            [DOMEX_ID_00009][Error The DOMEX assertion must have a scope of either TDO or TDC.
        </sch:assert>
    </sch:rule>
</sch:pattern>
