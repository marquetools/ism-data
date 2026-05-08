<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ICO-NTK-ID-00002" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ICO-NTK-ID-00002][Error] The ICO-NTK Profile should not contain any  
        Access Profile Values. 
    </sch:p>
    <sch:p id="codeDesc">
        For every ntk:AccessProfile with an ntk:AccessPolicy of 'guide://2020/ico-ntk.des.v1',  
        ensure that there are no ntk:AccessProfileValue elements.  
    </sch:p>
    <sch:rule context="ntk:AccessProfile[ntk:ProfileDes='guide://2020/ico-ntk.des.v1']">
        <sch:assert test="not(ntk:AccessProfileValue)">
            [ICO-NTK-ID-00002][Error] The ICO-NTK Profile should not contain any  
            Access Profile Values. 
        </sch:assert>
    </sch:rule>
</sch:pattern>