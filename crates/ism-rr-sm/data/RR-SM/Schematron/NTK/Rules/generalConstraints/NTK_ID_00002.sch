<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="NTK-ID-00002" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [MAT-ID-00002][Error]
        ntk:ExternalAccess and ntk:Access must contain at least one of 
        ntk:AccessIndividualList, ntk:AccessGroupList, ntk:AccessProfileList.
    </sch:p>
    
    <sch:p id="codeDesc">
        We make sure that either ntk:AccessIndividualList, ntk:AccessGroupList,
        or ntk:AccessProfileList exist as child elements of ntk:Access and 
        ntk:ExternalAccess.
    </sch:p>
    
    <sch:rule context="ntk:Access|ntk:ExternalAccess">
        <sch:assert 
            test="ntk:AccessIndividualList 
            or ntk:AccessGroupList
            or ntk:AccessProfileList"
            flag="error">
            [NTK-ID-00002][Error]
            ntk:ExternalAccess and ntk:Access must contain at least one of 
            ntk:AccessIndividualList, ntk:AccessGroupList, ntk:AccessProfileList.
        </sch:assert>
    </sch:rule>
</sch:pattern>
