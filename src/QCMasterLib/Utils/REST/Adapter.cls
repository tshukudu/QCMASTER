Include ErrorCodes

/// Adapter class for UI REST services.<br>
Class QCMasterLib.Utils.REST.Adapter [ Abstract ]
{

/// Returns the JSON content stream from the incoming CSP request.<br>
/// pRequest - The CSP request received by the REST service.<br>
/// pErrCode - The error code for any exceptions that occur.<br>
/// pErrReason - The error reason  for any exceptions that occur.<br>
ClassMethod GetJSONFromCSPRequest(pRequest As %CSP.Request, ByRef pErrCode As %String, ByRef pErrReason As %String) As %CSP.BinaryStream
{
	if (pRequest.ContentType '= "application/json") {
		set pErrCode = $$$RcRESTInvalidContentType
		set pErrReason = "Invalid content type. Expected application/json"
		throw ##class(%Exception.General).%New("RcRESTInvalidContentType",pErrCode,,pErrReason)
	}
	if (pRequest.Content = "") {
		set pErrCode = $$$RcRESTEmptyPOST
		set pErrReason = "Input data is empty."
		throw ##class(%Exception.General).%New("RcRESTEmptyPOST",pErrCode,,pErrReason)
	}
	quit pRequest.Content
}

/// Writes out a dynamic to JSON.<br>
/// pResponse - The dynamic object to be displayed as output.<br>
ClassMethod OutputToJSON(pResponse As %Library.DynamicObject)
{
 	set tStream = ##Class(%Stream.GlobalCharacter).%New()
 	do pResponse.%ToJSON(tStream)
	do tStream.OutputToDevice()
	quit
}

/// Get the root tag name from an XML stream to be used for parsing later
ClassMethod GetRootTagFromStream(pInput As %Stream.Object) As %String
{
	do pInput.Rewind()
	set tStartStr = pInput.Read(500)
	set tTag = $Piece($Piece(tStartStr, ">",1), "<", 2)
	return tTag
}

/// Create a RESP Method Error Response Object
ClassMethod CreateRESTMethodError(pReturnCode As MasterLib.Messages.FieldTypes.ReturnCode, pReturnReason As MasterLib.Messages.FieldTypes.ReturnReason) As MasterLib.Messages.Rsp.RESTMethodErrorRsp
{
	set tRsp = ##class(MasterLib.Messages.Rsp.RESTMethodErrorRsp).%New()
	set tRsp.ReturnCode = pReturnCode
	set tRsp.ReturnReason = pReturnReason
	return tRsp
}

ClassMethod OutputXMLObj(pObject As %XML.Adaptor) As %Status
{
	set sc = pObject.XMLExportToStream(.tStream)
	if $$$ISERR(sc) { return sc }
	set sc = tStream.OutputToDevice()
	quit sc
}

/// Parses a JSON CSP Request into the passed message class
ClassMethod GetMessageFromCSPRequest(pRequest As %CSP.Request,pMessageClass As %String, ByRef pErrCode As %String, ByRef pErrReason As %String, Output pMessage As %RegisteredObject) As %Status
{
	set sc = $$$OK
	set tJSONStream = ..GetJSONFromCSPRequest(pRequest, .pErrCode, .pErrReason)
	set pMessage = $classmethod(pMessageClass, "%New")
    set tDynObj = ##class(%DynamicObject).%New()
	set tDynObj = ##class(%DynamicAbstractObject).%FromJSON(tJSONStream)
	set sc = pMessage.FromDynamicObj(tDynObj)	
	quit sc
}

}