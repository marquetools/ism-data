<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<sch:pattern xmlns:sch="http://purl.oclc.org/dsdl/schematron" 
  id="WLNtkAccessPolicy-ID-00001" 
  is-a="AllValuesExistInList">
  
  <sch:p class="ruleText">
    [WLAccessPolicy-ID-00001][Error] NTK AccessPolicy Whitelist Validation - 
                              each ntk:AccessPolicy value in document must exist in the whitelist.
    
    Human Readable: Whitelist Validation Error: each ntk:AccessPolicy value
    found in document must be specified in the whitelist.
  </sch:p>
  
  <sch:p class="codeDesc">
    All allowable NTK Profile URIs are defined in whitelist.  A list of the allowable values is created
    from the whitelist configuration xml file; this list is compared against a list each NTK AccessProfile value 
    found in xml document.  All document NTK values must exist in the list of valued defined in whitelist.
  </sch:p>
  
  <sch:param name="context"   
    value="//ntk:RequiresAllOf/ntk:AccessProfileList/ntk:AccessProfile/ntk:AccessPolicy"/>
  <sch:param name="list" value="$policyList"/>
  <sch:param name="errMsg"
             value="'   [WLAccessPolicy-ID-00001][Error] NTK AccessPolicy Whitelist Validation - each ntk:AccessPolicy value in document must exist in the whitelist.' "/>
  
</sch:pattern>