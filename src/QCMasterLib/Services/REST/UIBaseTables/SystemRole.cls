/// CRUD UI REST Service methods for the SystemRole Table.
Class QCMasterLib.Services.REST.UIBaseTables.SystemRole Extends (%CSP.REST, QCMasterLib.Services.REST.UIBaseTables.CRUDBase, QCMasterLib.Utils.DynamicObject.Adapter)
{

ClassMethod GetSystemRole() As %Status
{

	set sc = ..GetTableListList(%request, %session, "QCMasterLib.Tables.SystemRole")		
	
	quit sc
}

/// Allows the use of System and description as an alternative to Id for getting a table entry
ClassMethod GetSystemRoleDetailOnSystemDescription(pSystem As %String, pDescription As %String) As %Status
{
	set sc = $$$OK
	set tCSPRequest = %request
	set tCSPSession = %session
	set tClassName = "QCMasterLib.Tables.SystemRole"
	set tErrorCode = ""
	set tErrorReason = ""
	set tResponse = ##class(QCMasterLib.Messages.Rsp.GenericUIRsp).%New()
	set tDynamicResponse = $$$NULLOREF
	try {
		set %gUser(tCSPSession.SessionId,"UID") = tCSPRequest.GetCgiEnv("HTTP_X_UI_UID")
		set %gUser(tCSPSession.SessionId,"Source") = tCSPRequest.GetCgiEnv("HTTP_X_UI_UIDSOURCE")
		#dim %response As %CSP.Response
    	set %response.ContentType = "application/json"
    	set tRowCount = 0 
    	
    	set tSystem = ##class(QCMasterLib.Tables.System).DescriptionIndexOpen(pSystem,0)
    	if (tSystem = "") {
			set tErrorCode = $$$RcRESTObjNotFound
			set tErrorReason = $$$FormatText("System '%2' does not exist.", $piece(tClassName, ".", *), pSystem)
			throw
		}
    	set tSystemId = tSystem.%Id()
    	
		set tRecord = $classmethod(tClassName, "DescriptionSystemIndexOpen",pDescription,tSystemId)
		if (tRecord = "") {
			set tErrorCode = $$$RcRESTObjNotFound
			set tErrorReason = $$$FormatText("Unable to find %1 on System '%2' and Description '%3'", $piece(tClassName, ".", *), pSystem,pDescription)
			throw
		}
		$$$ThrowOnError(tRecord.ToDynamicObj(.tDynamicObject))
		
		set tResponse.Model = $piece(tClassName, ".", *)
		set tResponse.ReturnCode = $$$RcOk
		set tResponse.ReturnReason = $$$RcOkDescr
		$$$ThrowOnError(tResponse.ToDynamicObj(.tDynamicResponse))
		set tDynamicResponse.Data = tDynamicObject
		
	} catch ex {
		set:sc=$$$OK sc=ex.AsStatus()
		if (tErrorCode = "") {
			set tResponse.ReturnCode = $$$RcRESTMethodError
		} else {
			set tResponse.ReturnCode = tErrorCode
		}
		if (tErrorReason '= "") {
			set tResponse.ReturnReason = tErrorReason
		} elseif (sc = $$$OK) {
			set tResponse.ReturnReason = $$$StripCacheErrCode(ex.DisplayString())
		} else {
			set tResponse.ReturnReason = $$$StripCacheErrCode($SYSTEM.Status.GetErrorText(sc))
		}
		$$$ThrowOnError(tResponse.ToDynamicObj(.tDynamicResponse))
	}
	do ..OutputToJSON(tDynamicResponse)
	kill %gUser(tCSPSession.SessionId)
	
	quit sc
}

ClassMethod GetSystemRoleDetail(pID As %Integer) As %Status
{
	set sc = ..GetTableEntry(%request, %session, "QCMasterLib.Tables.SystemRole", pID)		
	
	quit sc
}

ClassMethod CreateSystemRole() As %Status
{
	set sc = ..CreateTableEntry(%request, %session, "QCMasterLib.Tables.SystemRole")		
	
	quit sc
}

ClassMethod UpdateSystemRole(pId As %Integer) As %Status
{
	set sc = ..UpdateTableEntry(%request, %session, "QCMasterLib.Tables.SystemRole", pId)		
	
	quit sc
}

}
