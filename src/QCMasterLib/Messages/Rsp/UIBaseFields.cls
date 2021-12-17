Include ErrorCodes

/// Base Q LINK UI Response Message Fields
/// To be inherited on all Q LINK UI message definitions
Class QCMasterLib.Messages.Rsp.UIBaseFields Extends (%XML.Adaptor, QCMasterLib.Utils.DynamicObject.Adapter, QCMasterLib.Utils.REST.Swagger.MessageAdapter) [ Abstract ]
{

/// A general return code of the operation, indicates success, failure and/or when there are field errors.
Property ReturnCode As QCMasterLib.Messages.FieldTypes.ReturnCode [ Required ];

/// Descriptive reason of the return code.
Property ReturnReason As QCMasterLib.Messages.FieldTypes.ReturnReason [ Required ];

/// Repeating group of field errors.
Property FieldErrors As list Of QCMasterLib.Messages.FieldTypes.FieldError(XMLNAME = "field_errors");

/// Set the Field Errors, Return Code and Return reason from the list of FieldErrors
Method SetErrorsFromErrorList(pErrors As %ListOfObjects) As %Status
{
	set sc = $$$OK
	try {
		if (pErrors.Size = 0) {
			set ..ReturnCode = $$$RcOk
			set ..ReturnReason = $$$RcOkDescr
		}
		else {
			set ..ReturnCode = $$$RcFieldError
			set ..ReturnReason = $$$RcFieldErrorDescr
			for i=1:1:pErrors.Size {
				set sc = ..FieldErrors.Insert(pErrors.GetAt(i))
				if $$$ISERR(sc) { throw }
			}
		}
	} catch tEx {
		if (sc = $$$OK) {
			set sc = $$$ERROR($$$GeneralError, tEx.DisplayString())
		}
	}
	quit sc
}

/// Adds a field error to Field error array
Method AppendFieldError(pFieldError As QCMasterLib.Messages.FieldTypes.FieldError) As %Status
{
	set sc = $$$OK
	try {
		set tIndex = ..FieldErrors.Count() 
		do ..FieldErrors.SetAt(pFieldError,$i(tIndex))
	 } catch tEx {
	 	set sc = $$$ERROR($$$GeneralError, tEx.DisplayString())
	 }
	 quit sc
}

}
