Include QCMasterLibDefines

/// Helper class for conversions between swagger objects and Cache objects
Class QCMasterLib.Utils.REST.Swagger.DefinitionHelperUtil Extends %RegisteredObject
{

/// Returns the swagger type and format of the type passed in.
ClassMethod MakePropertyTypeAndFormat(pXSDType As %String, pScale As %Integer, Output pType As %String = "", Output pFormat As %String = "", Output pMultipleOf As %String = "")
{
	if (pXSDType="date") {
		set pType="string"
		set pFormat="date"
	} elseif (pXSDType="dateTime") {
		set pType="string"
		set pFormat="date-time"
	} elseif (pXSDType="double") {
		set pType="number"
		set pFormat="double"
		set:(pScale > 0) pMultipleOf = "0." _ $$$LeftPad(1, pScale, 0)
	} elseif (pXSDType="long") {
		set pType="integer"
		set pFormat="int64"
	} elseif (pXSDType="decimal") {
		set pType="number"
		set:(pScale > 0) pMultipleOf = "0." _ $$$LeftPad(1, pScale, 0)
	} else {
		set pType="string"
		set pFormat=""
	}
}

}
