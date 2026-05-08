<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ICO-NTK-ID-00003" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ICO-NTK-ID-00003][Error] The ICO-NTK Access Policy must be [guide://2020/ico-ntk.aces].
    </sch:p>
    <sch:p id="codeDesc">
        For every ntk:AccessPolicy element of an ntk:AccessProfile that has an 
        ntk:ProfileDes of [guide://2020/ico-ntk.des.v1], the ntk:AccessPolicy must be [guide://2020/ico-ntk.aces].
    </sch:p>
    <sch:rule context="ntk:AccessProfile[ntk:ProfileDes='guide://2020/ico-ntk.des.v1']">
        <sch:assert test="ntk:AccessPolicy='guide://2020/ico-ntk.aces'">
            [ICO-NTK-ID-00003][Error] The ICO-NTK Access Policy must be [guide://2020/ico-ntk.aces]. 
        </sch:assert>
    </sch:rule>
</sch:pattern>