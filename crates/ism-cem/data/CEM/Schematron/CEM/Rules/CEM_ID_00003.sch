<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern xmlns:sch="http://purl.oclc.org/dsdl/schematron" id="CEM-ID-00003">
    <sch:p xmlns:ism="urn:us:gov:ic:ism" ism:classification="U" ism:ownerProducer="USA" class="ruleText">
        [CEM-ID-00003][Error]
        For attribute dateTimeRange, for each pair of date/time values, 
        the second value must be later than the first value.
        
        Human Readable: The second value of date/time value pair for attribute dateTimeRange has to be later than the first value.
    </sch:p>

    <sch:p xmlns:ism="urn:us:gov:ic:ism" ism:classification="U" ism:ownerProducer="USA" class="codeDesc"> 
        The value of the attribute dateTimeRange is tokenized into a list of dateTimes, 
        called $dateTimeList. If the number of dates in $dateTimeList
        is not even, then each date does not have a corresponding pair so this rule returns
        false. Otherwise, this rule verifies that the second date of each dateTime pair is 
        later than the first date in that pair. To do this, the rule loops over all dates in 
        $dateTimeList and identify dateTime pairs by pairing the date at an even index N with
        the date at index N-1. For each pair, this rule verifies that $dateList[N-1] is less than $dateList[N].
    </sch:p>
    
    <sch:rule context="cem:*[@cem:dateTimeRange]" id="CEM-ID-00003-R1">
        <sch:let name="dateTimeList" value="tokenize(string(@cem:dateTimeRange), ' ')"/>
        <sch:assert test="             if ((count($dateTimeList) mod 2) != 0)             then false()             else                 count(                     for $index in 1 to count($dateTimeList) return                         if($index mod 2 = 0) then                             if(dtf:compareDateTimeRanges($dateTimeList[$index - 1], '&lt;', $dateTimeList[$index]))                             then 1                             else null                         else null                 ) = count($dateTimeList) * .5             "
                  flag="error" role="error">
            [CEM-ID-00003][Error]
            For attribute dateTimeRange, for each pair of date/time values, 
            the second value must be later than the first value.
            
            Human Readable: The second value of date/time value pair for attribute dateTimeRange has to be later than the first value.
        </sch:assert>
    </sch:rule>
</sch:pattern>
