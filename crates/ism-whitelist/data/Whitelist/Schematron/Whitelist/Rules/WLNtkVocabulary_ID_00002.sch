<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<sch:pattern xmlns:sch="http://purl.oclc.org/dsdl/schematron" 
  id="WLNtkVocabulary-ID-00002" 
  is-a="SomeValuesExistInList">
  
  <sch:p class="ruleText">
    [WLNtkVocabulary-ID-00002][Error] NTK Vocabulary Type Whitelist Validation - for ntk:RequiresAnyOf, 
    each ntk:AccessProfileValue@vocabulary value in document must exist in the whitelist.
    
    Human Readable: Whitelist Validation Error: each ntk:AccessPolicy value
    found in document must be specified in the whitelist.
  </sch:p>
  
  <sch:p class="codeDesc">
    All allowable NTK Vocabulary URIs are defined in whitelist.  A list of the allowable values is created
    from the whitelist configuration xml file; this list is compared against a list each NTK AccessProfileValue@vocabulary 
    value found in xml document. All document NTK values must exist in the list of valued defined in whitelist.
    
    Pass one list to SomeValuesExistInList abstract rule - list of all NTK Vocabulary values defined in config file
  </sch:p>
  
  <sch:param name="context"   
    value="//ntk:RequiresAnyOf/ntk:AccessProfileList/ntk:AccessProfile/ntk:AccessProfileValue/@ntk:vocabulary"/>
  <sch:param name="list" value="$vocabList"/>
  <sch:param name="errMsg"
    value="'   [WLNtkVocabulary-ID-00002][Error] NTK Vocabulary Type Whitelist Validation - for ntk:RequiresAnyOf, 
                each ntk:AccessProfileValue@vocabulary value in document must exist in the whitelist.' "/>
  
</sch:pattern>