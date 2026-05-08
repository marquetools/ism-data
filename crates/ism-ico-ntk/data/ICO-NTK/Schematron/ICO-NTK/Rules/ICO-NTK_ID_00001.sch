<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ICO-NTK-ID-00001" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ICO-NTK-ID-00001][Error] The ICO-NTK Profile DES must be [guide://2020/ico-ntk.des.v1]. 
    </sch:p>
    <sch:p id="codeDesc">
        For every ntk:ProfileDes element of an ntk:AccessProfile that has an 
        ntk:AccessPolicy of [guide://2020/ico-ntk.aces], the ntk:ProfileDes must be [guide://2020/ico-ntk.des.v1].
    </sch:p>
    <sch:rule context="ntk:AccessProfile[ntk:AccessPolicy='guide://2020/ico-ntk.aces']">
        <sch:assert test="ntk:ProfileDes='guide://2020/ico-ntk.des.v1'">
            [ICO-NTK-ID-00001][Error] The ICO-NTK Profile DES must be [guide://2020/ico-ntk.des.v1]. 
        </sch:assert>
    </sch:rule>
</sch:pattern>