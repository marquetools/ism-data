<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00133" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00133][Error] If ISM_NSI_EO_APPLIES and attribute 
        declassException is specified and contains the tokens [25X1-human], 
        [50X1-HUM], or [50X2-WMD], then attribute declassDate or declassEvent must NOT be specified.
        
        Human Readable: Documents under E.O. 13526 must not specify declassDate or declassEvent if 
        a declassException of 25X1-human, 50X1-HUM, or 50X2-WMD is specified.
    </sch:p>
    <sch:p id="codeDesc">
        If current Classified National Security Information Executive Order does not
        apply to this resource then the rule does not apply and we return true. 
        Otherwise we ensure that any element with the attribute declassException
        specified with a value of [25X1-human], [50X1-HUM], or [50X1-WMD], 
        then we ensure that the attribute declassDate or attribute declassEvent 
        are not specified.      
    </sch:p>
    <sch:rule context="*[@ism:declassException and $ISM_NSI_EO_APPLIES]">
        <sch:let name="dd" value="exists(./@ism:declassDate)"/>
        <sch:let name="de" value="exists(./@ism:declassEvent)"/>
        <sch:let name="paddedDeclassEx" 
            value="concat(' ', normalize-space(string(./@ism:declassException)), ' ')"/>

        <sch:assert 
            id="ISM-00133" 
            test="
            if(not(matches($paddedDeclassEx, ' (25X1-human|50X1-HUM|50X2-WMD) ')))
                then true() 
            else not($dd or $de)
            " 
            flag="error">
            [ISM-ID-00133][Error] If ISM_NSI_EO_APPLIES and attribute 
            declassException is specified and contains the tokens [25X1-human], 
            [50X1-HUM], or [50X2-WMD], then attribute declassDate or 
            declassEvent must NOT be specified. Invalid presence of 
            <sch:value-of select="if($dd) then 'declassDate' else null"/>
            <sch:value-of select="if($dd and $de) then ' and ' else null"/>
            <sch:value-of select="if($de) then 'declassEvent' else null"/>.
        </sch:assert>
    </sch:rule>
</sch:pattern>