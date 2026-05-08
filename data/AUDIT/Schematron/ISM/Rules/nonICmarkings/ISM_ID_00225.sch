<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00225" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00225][Error] If ISM-ICDOCUMENT-APPLIES, then attribute ism:nonICmarkings must not 
        be specified with a value containing any name token starting with [ACCM]. 
        
        Human Readable: ACCM tokens are not valid for documents that claim compliance with IC rules.
    </sch:p>
    <sch:p id="codeDesc">
        For each element which specifies attribute ism:nonICmarkings, if $ISM-ICDOCUMENT-APPLIES,
        then we make sure that attribute ism:nonICmarkings is not specified with a value containing
        a token which starts with [ACCM].
    </sch:p>
		<sch:rule context="*[@ism:nonICmarkings]">
        <sch:assert 
            id="ISM-00225" 
            test="
            if($ISM_ICDOCUMENT_APPLIES)
            then not(some $token in tokenize(normalize-space(string(@ism:nonICmarkings)), ' ') satisfies
            					starts-with($token, 'ACCM'))
						else true()            		
            " 
            flag="error">
        	[ISM-ID-00225][Error] If ISM-ICDOCUMENT-APPLIES, then attribute ism:nonICmarkings must not 
        	be specified with a value containing any name token starting with [ACCM]. 
        	
        	Human Readable: ACCM tokens are not valid for documents that claim compliance with IC rules.
        </sch:assert>
    </sch:rule>
</sch:pattern>