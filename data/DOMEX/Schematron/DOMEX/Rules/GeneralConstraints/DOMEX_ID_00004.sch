<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern xmlns:sch="http://purl.oclc.org/dsdl/schematron" id="DOMEX-ID-00004">
    <sch:p xmlns:ism="urn:us:gov:ic:ism" ism:ownerProducer="USA" ism:classification="U" class="ruleText">
        [DOMEX_ID_00004][Error] If a TrustedDataObject element contains a DOMEX assertion, 
        it must also contain an assertion with an IRM structured statement. 
        
        Human Readable: If a Trusted Data Object contains a DOMEX assertion, it must also contain an IRM assertion.  
    </sch:p>
    <sch:p xmlns:ism="urn:us:gov:ic:ism" ism:ownerProducer="USA" ism:classification="U" class="codeDesc">
        If a TDO has a DOMEX assertion, verify that it also contains an IRM assertion.
    </sch:p>
    <sch:rule id="DOMEX-ID-00004-R1" context="tdf:StructuredStatement/*[namespace-uri() = 'urn:us:mil:ces:metadata:domex']">
        <sch:assert test="//tdf:Assertion/tdf:StructuredStatement/irm:ICResourceMetadataPackage"
            flag="error" role="error">[DOMEX_ID_00004][Error] If a TrustedDataObject element contains a DOMEX assertion, 
            it must also contain an assertion with an IRM structured statement. 
            
            Human Readable: If a Trusted Data Object contains a DOMEX assertion, it must also contain an IRM assertion.
        </sch:assert>
    </sch:rule>
    <sch:rule id="DOMEX-ID-00004-R2" context="tdf:StructuredStatement/*[namespace-uri() = 'urn:CellexReport']">
        <sch:assert test="//tdf:Assertion/tdf:StructuredStatement/irm:ICResourceMetadataPackage"
            flag="error" role="error">[DOMEX_ID_00004][Error] If a TrustedDataObject element contains a DOMEX assertion, 
            it must also contain an assertion with an IRM structured statement. 
            
            Human Readable: If a Trusted Data Object contains a DOMEX assertion, it must also contain an IRM assertion.
        </sch:assert>
    </sch:rule>
    <sch:rule id="DOMEX-ID-00004-R3"
        context="tdf:StructuredStatement/*[namespace-uri() = 'urn:us:mil:ces:metadata:domex_identity']">
        <sch:assert test="//tdf:Assertion/tdf:StructuredStatement/irm:ICResourceMetadataPackage"
            flag="error" role="error">[DOMEX_ID_00004][Error] If a TrustedDataObject element contains a DOMEX assertion, 
            it must also contain an assertion with an IRM structured statement. 
            
            Human Readable: If a Trusted Data Object contains a DOMEX assertion, it must also contain an IRM assertion.
        </sch:assert>
    </sch:rule>   
</sch:pattern>
