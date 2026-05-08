<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="NTK-ID-00002" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [MAT-ID-00002][Error]
        ntk:Access must contain at least one of ntk:AccessIndividualList, 
        ntk:AccessGroupList, ntk:AccessProfileList.
    </sch:p>
    
    <sch:p id="codeDesc">
        We make sure that either ntk:AccessIndividualList, ntk:AccessGroupList,
        or ntk:AccessProfileList exist as child elements of ntk:Access.
    </sch:p>
    
    <sch:rule context="ntk:Access">
        <sch:assert id="NTK-00002"
            test="ntk:AccessIndividualList 
            or ntk:AccessGroupList
            or ntk:AccessProfileList"
            flag="error">
            [NTK-ID-00002][Error] All NTK.XML documents must have least one of ntk:AccessIndividualList, 
            ntk:AccessGroupList, ntk:AccessProfileList.
        </sch:assert>
    </sch:rule>
</sch:pattern>
