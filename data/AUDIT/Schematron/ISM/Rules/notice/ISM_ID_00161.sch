<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00161" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00161][Error] If ISM_CAPCO_RESOURCE and:
        1. The attribute notice of ISM_RESOURCE_ELEMENT does contains [DoD-Dist-A]
        AND
        2. attribute nonICmarkings contains any of [SINFO], [XD], [ND], [SBU], [SBU-NF], [LES], OR [LES-NF].
        
        Human Readable: Distribution statement A (Public Release) is incompatible with [SINFO], [XD], [ND], [SBU], [SBU-NF], [LES], OR [LES-NF].
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If it is a CAPCO resource and the resourceElement has 
        attribute notice specified with a value containing [DoD-Dist-A], then we make sure that
        the resourceElement's attribute nonICmarkings does not contain values 
        [SINFO], [XD], [ND], [SBU], [SBU-NF], [LES], or [LES-NF].
    </sch:p>
    <sch:rule context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]">
        <sch:assert id="ISM-00161"
            test="
            if(not($ISM_CAPCO_RESOURCE)) then true() else 
            if(index-of($bannerNotice_tok, 'DoD-Dist-A')>0) then
            count(
               (if(index-of($bannerNonICmarkings_tok, 'SINFO')>0) then 1 else null,
                if(index-of($bannerNonICmarkings_tok, 'XD')>0) then 1 else null,
                if(index-of($bannerNonICmarkings_tok, 'ND')>0) then 1 else null,
                if(index-of($bannerNonICmarkings_tok, 'SBU')>0) then 1 else null,
                if(index-of($bannerNonICmarkings_tok, 'SBU-NF')>0) then 1 else null,
                if(index-of($bannerNonICmarkings_tok, 'LES')>0) then 1 else null,
                if(index-of($bannerNonICmarkings_tok, 'LES-NF')>0) then 1 else null)
            )=0 else true()
            "
            flag="error"> 
            [ISM-ID-00161][Error] Distribution statement A (Public Release) is incompatible with [SINFO], [XD], [ND], [SBU], [SBU-NF], [LES], OR [LES-NF].
        </sch:assert>
    </sch:rule>
</sch:pattern>
