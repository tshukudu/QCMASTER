Include QCMasterLibDefines

/// Basic CRUD methods for the UI. Each table CRUD REST Service can use the methods in this class, unless they have specific requirements
Class QCMasterLib.Services.REST.UIBaseTables.CRUDBase Extends QCMasterLib.Services.REST.UIRESTBase [ Abstract ]
{

/// Get a list of records from a table
ClassMethod GetTableListList(pCSPRequest As %CSP.Request, pCSPSession As %CSP.Session, pClassName As %String) As %Status
{
	
	set sc = $$$OK
	set tErrorCode = ""
	set tErrorReason = ""
	set tResponse = ##class(QCMasterLib.Messages.Rsp.GenericUIRsp).%New()
	set tDynamicResponse = $$$NULLOREF
	try {
		set %gUser(pCSPSession.SessionId,"UID") = pCSPRequest.GetCgiEnv("HTTP_X_UI_UID")
		set %gUser(pCSPSession.SessionId,"Source") = pCSPRequest.GetCgiEnv("HTTP_X_UI_UIDSOURCE")
		
		#dim %response As %CSP.Response
		set %response.ContentType = "application/json"
		set tRowCount = 0 
		
		set tTable = $piece(pClassName, ".", *)
		do ##class(QCMasterLib.Tables.UIFilterLog).InsertRecordLow("CST: "_pCSPSession.SessionId, tTable)
		
		// Create the sql and execute the count and resultset statemetns
		$$$ThrowOnError(..BuildGetSQLStatement(pCSPRequest, pClassName, .tSQLText, .tSQLArgs, .tPageSize))
		// - resultset processing. set pagination as well
		set tStatement = ##class(%SQL.Statement).%New(1)
		$$$ThrowOnError(tStatement.%Prepare(.tSQLText))
		set tResultset = tStatement.%Execute(tSQLArgs...)
		if ((tResultset.%SQLCODE '= 100) && (tResultset.%SQLCODE '= 0)) {
			set tErrorCode = $$$RcRESTMethodError
			set tErrorReason = "Invalid query criteria"
			throw
		}
		// - Load the resultset
		set tRecordListArray = ##class(%Library.DynamicArray).%New()
		while(tResultset.%Next()) {
			set tRowCount = tResultset.%GetData(1)
			// Open the record and parse
			set tRecord = $classmethod(pClassName, "%OpenId", tResultset.%Get("ID"))
			if (tRecord = "") {
			set tErrorCode = $$$RcRESTObjNotFound
				set tErrorReason = $$$FormatText("Unable to find %1 on ID %2", $piece(pClassName, ".", *), tResultset.%Get("ID"))
				throw
			}
			$$$ThrowOnError(tRecord.ToDynamicObj(.tDynamicObject))
			do tRecordListArray.%Push(tDynamicObject)
		}
		// Setup Response
		if (tPageSize = 0) {
			set tResponse.TotalPages = 1
		} else {
			set tResponse.TotalPages = tRowCount \ tPageSize
			set:((tRowCount # tPageSize) '= 0) tResponse.TotalPages = tResponse.TotalPages + 1
		}
		set tResponse.Model = $piece(pClassName, ".", *)
		set tResponse.ReturnCode = $$$RcOk
		set tResponse.ReturnReason = $$$RcOkDescr
		set tResponse.TotalResults = tRowCount
		$$$ThrowOnError(tResponse.ToDynamicObj(.tDynamicResponse))
		set tDynamicResponse.Data = tRecordListArray
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
	kill %gUser(pCSPSession.SessionId)	
	quit sc
}

ClassMethod GetTableEntry(pCSPRequest As %CSP.Request, pCSPSession As %CSP.Session, pClassName As %String, pID As %Integer) As %Status
{
	set sc = $$$OK
	set tErrorCode = ""
	set tErrorReason = ""
	set tResponse = ##class(QCMasterLib.Messages.Rsp.GenericUIRsp).%New()
	set tDynamicResponse = $$$NULLOREF
	try {
		set %gUser(pCSPSession.SessionId,"UID") = pCSPRequest.GetCgiEnv("HTTP_X_UI_UID")
		set %gUser(pCSPSession.SessionId,"Source") = pCSPRequest.GetCgiEnv("HTTP_X_UI_UIDSOURCE")
		
		#dim %response As %CSP.Response
		set %response.ContentType = "application/json"
		set tRowCount = 0 
		
		set tTable = $piece(pClassName, ".", *)
		do ##class(MasterLib.Tables.UIFilterLog).InsertRecordLow("CST: "_pCSPSession.SessionId_" - RowId: "_pID, tTable)
    	
		set tRecord = $classmethod(pClassName, "%OpenId", pID)
		if (tRecord = "") {
			set tErrorCode = $$$RcRESTObjNotFound
			set tErrorReason = $$$FormatText("Unable to find %1 on ID %2", $piece(pClassName, ".", *), pID)
			throw
		}
		$$$ThrowOnError(tRecord.ToDynamicObj(.tDynamicObject))
		
		set tResponse.Model = $piece(pClassName, ".", *)
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
	kill %gUser(pCSPSession.SessionId)
	quit sc
}

ClassMethod CreateTableEntry(pCSPRequest As %CSP.Request, pCSPSession As %CSP.Session, pClassName As %String) As %Status
{
	set sc = $$$OK
	set tErrorCode = ""
	set tErrorReason = ""
	set tResponse = ##class(MasterLib.Messages.Rsp.GenericUIRsp).%New()
	set tDynamicResponse = $$$NULLOREF
	set tErrorList = 0
	try {
		set %gUser(pCSPSession.SessionId,"UID") = pCSPRequest.GetCgiEnv("HTTP_X_UI_UID")
		set %gUser(pCSPSession.SessionId,"Source") = pCSPRequest.GetCgiEnv("HTTP_X_UI_UIDSOURCE")
		#dim %response As %CSP.Response
    	set %response.ContentType = pCSPRequest.ContentType
    	set tTable = $piece(pClassName, ".", *)
		
		// Parse the JSON request and save it
		set tJSON = ..GetJSONFromCSPRequest(pCSPRequest,.tErrorCode, .tErrorReason)
		#dim tRequest As MasterLib.Messages.Req.GenericUIReq
		$$$ThrowOnError(..FromJSONStreamToGeneric(tJSON, .tRequest))
		set tRequest.Table = tTable
		$$$ThrowOnError(tRequest.%Save(0))
		
		// Parse the Data section of the JSON to the relevant class
		set tDynamicObject = ##class(%Library.DynamicObject).%New()
    	set tDynamicObject = ..GetObjectFromJSONData(tRequest.Data)
		set tRecord = $classmethod(pClassName, "%New")
		$$$ThrowOnError(tRecord.FromDynamicObj(tDynamicObject))
		
		// Validate and add to field errors. duplicate errors will be handled in the carch
		set sc = tRecord.%ValidateObject()
		if $$$ISERR(sc) {
			$$$ThrowOnError(##class(MasterLib.Utils.Error).DecomposeValidationStatusToFieldErrorList(sc, 0, .tErrorList))
			$$$ThrowOnError(tResponse.SetErrorsFromErrorList(tErrorList))
			throw
		}
		
		// Save and toDO it again for the response
		$$$ThrowOnError(tRecord.%Save(0))
		$$$ThrowOnError(tRecord.ToDynamicObj(.tDynamicTableRecord))
		
		set tResponse.Model = tTable
		set tResponse.ReturnCode = $$$RcOk
		set tResponse.ReturnReason = $$$RcOkDescr
		$$$ThrowOnError(tResponse.ToDynamicObj(.tDynamicResponse))
    	set tDynamicResponse.Data = tDynamicTableRecord
	} catch ex {
		set:sc=$$$OK sc=ex.AsStatus()
		if (tErrorCode = "") {
			set tResponse.ReturnCode = $$$RcRESTMethodError
		} else {
			set tResponse.ReturnCode = tErrorCode
		}
		if (tResponse.ReturnReason="") {
			if (tErrorReason '= "") {
				set tResponse.ReturnReason = tErrorReason
			} elseif (sc = $$$OK) {
				set tResponse.ReturnReason = $$$StripCacheErrCode(ex.DisplayString())
			} else {
				set tResponse.ReturnReason = $$$StripCacheErrCode($SYSTEM.Status.GetErrorText(sc))
			}
		}
		$$$ThrowOnError(tResponse.ToDynamicObj(.tDynamicResponse))
	}
	do ..OutputToJSON(tDynamicResponse)
	kill %gUser(pCSPSession.SessionId)
	quit sc
}

ClassMethod UpdateTableEntry(pCSPRequest As %CSP.Request, pCSPSession As %CSP.Session, pClassName As %String, pId As %Integer) As %Status
{
	set sc = $$$OK
	set tErrorCode = ""
	set tErrorReason = ""
	set tResponse = ##class(QCMasterLib.Messages.Rsp.GenericUIRsp).%New()
	set tDynamicResponse = $$$NULLOREF
	set tErrorList = 0
	try {
		set %gUser(pCSPSession.SessionId,"UID") = pCSPRequest.GetCgiEnv("HTTP_X_UI_UID")
		set %gUser(pCSPSession.SessionId,"Source") = pCSPRequest.GetCgiEnv("HTTP_X_UI_UIDSOURCE")
		#dim %response As %CSP.Response
    	set %response.ContentType = pCSPRequest.ContentType
    	set tTable = $piece(pClassName, ".", *)
		// Parse the JSON request and save it
		set tJSON = ..GetJSONFromCSPRequest(pCSPRequest,.tErrorCode, .tErrorReason)
		#dim tRequest As QCMasterLib.Messages.Req.GenericUIReq
		$$$ThrowOnError(..FromJSONStreamToGeneric(tJSON, .tRequest))
		set tRequest.Table = tTable
		$$$ThrowOnError(tRequest.%Save(0))
		
		// Parse the Data section of the JSON to the relevant class
		set tDynamicObject = ##class(%Library.DynamicObject).%New()
    	set tDynamicObject = ..GetObjectFromJSONData(tRequest.Data)
		set tRecord = $classmethod(pClassName, "%OpenId", pId)
		if (tRecord = "") {
			set tErrorCode = $$$RcRESTObjNotFound
			set tErrorReason = $$$FormatText("Unable to find %1 on ID %2", tTable, pId)
			throw
		}
		$$$ThrowOnError(tRecord.FromDynamicObj(tDynamicObject))
		
		// Validate and add to field errors. duplicate errirs will be handled in the carch
		set sc = tRecord.%ValidateObject()
		if $$$ISERR(sc) {
			$$$ThrowOnError(##class(QCMasterLib.Utils.Error).DecomposeValidationStatusToFieldErrorList(sc, 0, .tErrorList))
			$$$ThrowOnError(tResponse.SetErrorsFromErrorList(tErrorList))
			throw
		}
		// Save and toDO it again for the response
		$$$ThrowOnError(tRecord.%Save(0))
		$$$ThrowOnError(tRecord.ToDynamicObj(.tDynamicTableRecord))
		
		set tResponse.Model = tTable
		set tResponse.ReturnCode = $$$RcOk
		set tResponse.ReturnReason = $$$RcOkDescr
		$$$ThrowOnError(tResponse.ToDynamicObj(.tDynamicResponse))
    	set tDynamicResponse.Data = tDynamicTableRecord
	} catch ex {
		set:sc=$$$OK sc=ex.AsStatus()
		if (tErrorCode = "") {
			set tResponse.ReturnCode = $$$RcRESTMethodError
		} else {
			set tResponse.ReturnCode = tErrorCode
		}
		if (tResponse.ReturnReason="") {
			if (tErrorReason '= "") {
				set tResponse.ReturnReason = tErrorReason
			} elseif (sc = $$$OK) {
				set tResponse.ReturnReason = $$$StripCacheErrCode(ex.DisplayString())
			} else {
				set tResponse.ReturnReason = $$$StripCacheErrCode($SYSTEM.Status.GetErrorText(sc))
			}
		}
		$$$ThrowOnError(tResponse.ToDynamicObj(.tDynamicResponse))
	}
	do ..OutputToJSON(tDynamicResponse)
	kill %gUser(pCSPSession.SessionId)
	quit sc
}

ClassMethod DeleteTableEntry(pCSPRequest As %CSP.Request, pCSPSession As %CSP.Session, pClassName As %String, pId As %Integer) As %Status
{
	set sc = $$$OK
	set tErrorCode = ""
	set tErrorReason = ""
	set tResponse = ##class(MasterLib.Messages.Rsp.GenericUIRsp).%New()
	set tDynamicResponse = $$$NULLOREF
	try {
		set %gUser(pCSPSession.SessionId,"UID") = pCSPRequest.GetCgiEnv("HTTP_X_UI_UID")
		set %gUser(pCSPSession.SessionId,"Source") = pCSPRequest.GetCgiEnv("HTTP_X_UI_UIDSOURCE")
		#dim %response As %CSP.Response
    	set %response.ContentType = "application/json"
    	set tRowCount = 0 
    	
		set tRecord = $classmethod(pClassName, "%OpenId", pId)
		if (tRecord = "") {
			set tErrorCode = $$$RcRESTObjNotFound
			set tErrorReason = $$$FormatText("Unable to find %1 on ID %2", $piece(pClassName, ".", *), pId)
			throw
		}
		$$$ThrowOnError($classmethod(pClassName,"%DeleteId",pId))
		
		set tResponse.Model = $piece(pClassName, ".", *)
		set tResponse.ReturnCode = $$$RcOk
		set tResponse.ReturnReason = $$$RcOkDescr
		$$$ThrowOnError(tResponse.ToDynamicObj(.tDynamicResponse))		
		
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
	kill %gUser(pCSPSession.SessionId)
	quit sc
}

}
