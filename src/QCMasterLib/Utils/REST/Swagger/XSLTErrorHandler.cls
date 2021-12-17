Class QCMasterLib.Utils.REST.Swagger.XSLTErrorHandler Extends %XML.XSLT.ErrorHandler
{

Method error(pMessage As %String)
{
	throw ##class(%Exception.General).%New("XSLTError",,,pMessage)
}

Method fatalError(pMessage As %String)
{
	throw ##class(%Exception.General).%New("XSLTFatalError",,,pMessage)
}

Method warning(pMessage As %String)
{
}

}
