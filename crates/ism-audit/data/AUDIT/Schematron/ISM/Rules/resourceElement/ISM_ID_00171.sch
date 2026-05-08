<?xml version="1.0" encoding="utf-8"?>
<sch:pattern id="ISM-ID-00171" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00171][Warning] If ISM_CAPCO_RESOURCE and displayOnlyTo is specified on 
        the resource element then all classified portions must specify displayOnlyTo.
        
        Human Readable: USA documents having DISPLAYONLY data at the resource level
        must have all classified portions authorized for DISPLAYONLY.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. Otherwise, we loop over all portions of the document and count 
        the number of elements which have attribute classification specified with a value 
        other than [U] and do not have attribute displayOnlyTo.
        
        The loop checks, if the current element has attribute classification specified with 
        a value other than [U], or has attribute displayOnlyTo, then the rule does not 
        apply to this element and we return 0. Otherwise, we return 1 to indicate the element 
        is classified but does not specify attribute displayOnlyTo.
        
        If the count of elements not meeting either of the two requirements stated above is 
        greater than zero, then the assertion fails since attribute displayOnly appears on 
        the banner but is not present on all classified portions.

    </sch:p> 
    <sch:rule context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT) 
		and @ism:displayOnlyTo]">       
        <sch:assert 
            id="ISM-00171" 
            test="
            if(not($ISM_CAPCO_RESOURCE)) 
                then true() 
            else
                sum(
                    for $token in $partTags return 
                        if(matches($token/@ism:classification, '^U$')
                           or exists($token/@ism:displayOnlyTo)) 
                            then 0
                        else 1
                ) = 0
            " 
            flag="warning">
            [ISM-ID-00171][Warning] If ISM_CAPCO_RESOURCE and displayOnlyTo is specified on 
            the resource element then all classified portions must specify displayOnlyTo.
            
            Human Readable: USA documents having DISPLAYONLY data at the resource level
            must have all classified portions authorized for DISPLAYONLY.
        </sch:assert>
    </sch:rule>
</sch:pattern>