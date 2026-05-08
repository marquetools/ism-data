<?xml version="1.0" encoding="utf-8"?>
<sch:pattern id="ISM-ID-00222" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00222][Error] If ISM_ICDOCUMENT_APPLIES, then the pocType attribute with value [ICD-710]
        must also be specified on some element in the document.
        
        Human Readable: A document claiming compliance with ICD-710 must specify a point-of-contact
        to whom questions about the document can be directed.
    </sch:p>
    <sch:p id="codeDesc">
        If ISM_ICDOCUMENT_APPLIES, then ensure that some element specifies attribute @pocType with
        value 'ICD-710'.
    </sch:p> 
    <sch:rule context="/*[$ISM_ICDOCUMENT_APPLIES]">       
        <sch:assert 
            id="ISM-00222" 
            test="index-of($partPocType_tok, 'ICD-710') > 0" 
            flag="error">
            [ISM-ID-00222][Error] If ISM_ICDOCUMENT_APPLIES, then the pocType attribute with value [ICD-710]
            must also be specified on some element in the document.
            
            Human Readable: A document claiming compliance with ICD-710 must specify a point-of-contact
            to whom questions about the document can be directed.
        </sch:assert>
    </sch:rule>
</sch:pattern>