Include QCMasterLibDefines

Class QCMasterLib.Services.REST.UIRESTBase Extends QCMasterLib.Utils.REST.Adapter [ Abstract ]
{

/// Allowable SQL operators to prevent sql injection
Parameter AllowedFilterOperators = "=,>=,>,<=,<,like,not like,in,is null,is not null";

/// Returns a dynamic object from the JSON data stream.<br>
/// pData - The data stream that contains the dynamic object.<br>
ClassMethod GetObjectFromJSONData(pData As %GlobalCharacterStream) As %Library.DynamicObject [ Private ]
{
	do pData.Rewind()
	quit ##class(%Library.DynamicObject).%FromJSON(pData.Read())
}

/// Converts a JSON stream to a generic message and returns the request object.<br>
/// pJSONContent - The JSON stream to be converted.<br>
ClassMethod FromJSONStreamToGeneric(pJSONContent As %CSP.Stream, Output pRequest As QCMasterLib.Messages.Req.GenericUIReq) As %Status
{
	set sc = $$$OK
	#dim tObject As %Library.DynamicObject
	set tObject = ##class(%Library.DynamicObject).%FromJSON(pJSONContent)
	set tJSONStream = ##class(%GlobalCharacterStream).%New()
	do tJSONStream.Write(tObject.Data.%ToJSON())
	do tObject.%Remove("Data")
	
	set pRequest = ##class(QCMasterLib.Messages.Req.GenericUIReq).%New()
	set sc = pRequest.FromDynamicObj(tObject)
	do pRequest.Data.CopyFrom(tJSONStream)
	quit sc
}

/// Converts a generic message to a JSON stream and returns the JSON stream.<br>
/// pGenericMessage - The generic message to be converted.<br>
ClassMethod ToJSONStreamFromGeneric(pGenericMessage As %Library.DynamicObject) As %String
{
	if (pGenericMessage.%IsDefined("Data")) {
		set tDataObject = ##class(%Library.DynamicObject).%FromJSON(pGenericMessage.Data)
		do pGenericMessage.%Remove("Data")
		set pGenericMessage.Data = tDataObject
	}
	quit pGenericMessage.%ToJSON()
}

/// Get the ccc header information from the request and built the SQL array with it
/// to be used with %SQL.Statement to retrieve a list of %Id values<br>
/// The AllowedFilterOperators parameter will be used to prevent SQL injection.
ClassMethod BuildGetSQLStatement(pHTTPRequest As %CSP.Request, pClassName As %String, Output pSQLStatement As %String, Output pSQLArgs As %String, Output pPageSize As %Integer) As %Status
{
	set sc = $$$OK
	try
	{
		set pSQLArgs = 0
		set pPageSize = 0
		set tFilterableProps = ""
		set tSortableProps = ""
		set tPageNo = 1
		set pPageSize = 0
		set tAllowedFilterOps = $listfromstring(..#AllowedFilterOperators, ",")
		set tSQLTableName = $$$FormatText("%1.%2", $translate($piece(pClassName, ".", 1, *-1), ".", "_"), $piece(pClassName, ".", *))
		
		// Get the class and filter and sort options
		set tUIQueryObj = ##class(QCMasterLib.Tables.UIQueryCriteria).ClassNameIndexOpen(pClassName,0)
		if (tUIQueryObj '= "") {
			set tFilterableProps = $listfromstring(tUIQueryObj.FilterableProperties, ",")
			set tSortableProps = $listfromstring(tUIQueryObj.SortableProperties, ",")
		}
		
		// Get the header and load the parameters
		set tFilterCriteria = $listfromstring(pHTTPRequest.GetCgiEnv("HTTP_X_UI_FILTER"), ";")
		set tSortCriteria = $listfromstring(pHTTPRequest.GetCgiEnv("HTTP_X_UI_SORT"), ";")
		set tPageCriteria = pHTTPRequest.GetCgiEnv("HTTP_X_UI_PAGE")
		if ($length(tPageCriteria, ";") = 2) {
			set pPageSize = $piece(tPageCriteria, ";", 2)
			set tPageNo = $piece(tPageCriteria, ";", 1)
		}
		set tBottomRange = 0
		set tTopRange = 0
		if (pPageSize '= 0) {
			set tBottomRange = ((tPageNo - 1) * pPageSize) + 1
			set tTopRange = tPageNo * pPageSize
		}
		set tTOPString = "ALL"
		if (pPageSize '= 0) {
			set tTOPString = tTopRange
		}
		// Build the sql
		set pSQLStatement($increment(pSQLStatement)) = $$$FormatText("SELECT * FROM (")
		set pSQLStatement($increment(pSQLStatement)) = $$$FormatText("SELECT TOP %1 COUNT(*), * FROM %2 %3", tTOPString, "%PARALLEL", tSQLTableName)
		// - Build the sql filters
		set tCtr = 0
		for i=1:1:$listlength(tFilterCriteria) {
			// some validations
			set tPropertyFilter = $listfromstring($list(tFilterCriteria, i), ":")
			if ($listlength(tPropertyFilter) '= 4) {
				continue
			}
			if ($listfind(tFilterableProps, $zstrip($list(tPropertyFilter, 1),"<","(")) = 0) {
				// invalid property
				continue
			}
			if ($listfind(tAllowedFilterOps, $list(tPropertyFilter, 2)) = 0) {
				// invalid comparison operator
				continue
			}
			
			// Add to the sql. first normalise values and operands
			// - Property
			set tProperty = $list(tPropertyFilter, 1)
			set tTmpLen = $length(tProperty)
			set tProperty = $zstrip(tProperty,"<","(")
			set tNumberOfOpens = tTmpLen - $length(tProperty)
			// - Operand
			set tOperand = $list(tPropertyFilter, 2)
			set:(tOperand="in") tOperand = "%INLIST"
			// - Value
			set tValue = $list(tPropertyFilter, 3)
			set:(tOperand="%INLIST") tValue = $listfromstring(tValue, ",")
			// - and/or
			set tCondition = $list(tPropertyFilter, 4)
			set tTmpLen = $length(tCondition)
			set tCondition = $zstrip(tCondition,">",")")
			set tNumberOfCloses = tTmpLen - $length(tCondition)
			set tCondition = $case(tCondition, 1:"OR", :"AND")
			
			set tIgnoreVal = 0
			if ((tOperand = "is null") || (tOperand = "is not null")) {
				set tIgnoreVal = 1
			}
			
			set tCtr = tCtr + 1
			if (tCtr = 1) {
				set pSQLStatement($increment(pSQLStatement)) = $$$FormatText("WHERE %1 %2 %3 %4 %5", $$$LeftPad("",tNumberOfOpens,"("), tProperty, tOperand, $select(tIgnoreVal=0:"?",1:""), $$$LeftPad("",tNumberOfCloses,")"))
			} else {
				set pSQLStatement($increment(pSQLStatement)) = $$$FormatText("%1 %2 %3 %4 %5 %6", tCondition, $$$LeftPad("",tNumberOfOpens,"("), tProperty, tOperand, $select(tIgnoreVal=0:"?",1:""), $$$LeftPad("",tNumberOfCloses,")"))
			}
			if (tIgnoreVal = 0) {
				set pSQLArgs($increment(pSQLArgs)) = tValue
			}
		} // end for
		
		// Build the sql sorting
		set tCtr = 0
		for i=1:1:$listlength(tSortCriteria) {
			// some validations
			set tPropertySort = $listfromstring($list(tSortCriteria, i), ":")
			if ($listlength(tPropertySort) '= 2) {
				continue
			}
			if ($listfind(tSortableProps, $list(tPropertySort, 1)) = 0) {
				// invalid property
				continue
			}
			// add to the sql. first normalise values and operands
			set tAscDesc = $case($list(tPropertySort, 2), 1:"DESC", :"ASC")
			set tCtr = tCtr + 1
			if (tCtr = 1) {
				set pSQLStatement($increment(pSQLStatement)) = $$$FormatText("ORDER BY %1 %2", $list(tPropertySort, 1), tAscDesc)
			} else {
				set pSQLStatement($increment(pSQLStatement)) = $$$FormatText(", %1 %2",$list(tPropertySort, 1), tAscDesc)
			}
		} // end for
		
		// Close pagination query
		set pSQLStatement($increment(pSQLStatement)) = ")"

		// Apply the pagination
		if (pPageSize '= 0) {
			set pSQLStatement($increment(pSQLStatement)) = $$$FormatText("WHERE %1 >= %2", "%VID", tBottomRange)
		}
				
	} catch tEx {
		if (sc = $$$OK) {
			set sc = $$$ERROR($$$GeneralError, tEx.DisplayString())
		}
	}
	quit sc
}

XData HdrMap
{
<Headers>
	<Header Name="X-UI-FILTER" 	Description="field:operand:value:or;"/>
	<Header Name="X-UI-SORT" 	Description="field:descending;"/>
	<Header Name="X-UI-PAGE"	Description="pagenumber;pagesize"/>
	<Header Name="X-UI-UID"	Description="user identifier"/>
	<Header Name="X-UI-UIDSOURCE"	Description="user identifier source system"/>
</Headers>
}

}
