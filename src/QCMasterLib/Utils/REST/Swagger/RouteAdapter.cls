Include ErrorCodes

/// Adapter class for %CSP.REST REST services which makes the MakeSwagger Method available to them,<br>
/// so that swagger corresponding to their setup XDATA blocks/referenced data types can be generated.
Class QCMasterLib.Utils.REST.Swagger.RouteAdapter [ Abstract ]
{

/// Specifies the class holding the xdata block with descriptions for Headers.
Parameter DefaultHdrMapClassName = "QCMasterLib.Services.REST.UIRESTBase";

/// Makes a swagger object for the current class.<br>
/// pIsHTTPS - Boolean true/false which controls the scheme specified in the output swagger.<br>
/// pHost    - Host name with port of output swagger.<br>
/// pBasePath- basePath specified in output swagger.<br>
/// The three parameters above are considered input arguments for creating the swagger at runtime, as these values are<br>
/// unavailable at compile time.
ClassMethod MakeSwagger(pIsHTTPS As %Boolean, pHost As %String, pBasePath As %String, Output pOutputSwaggerObj As %Library.DynamicObject) As %Status [ CodeMode = objectgenerator ]
{
	set sc=$$$OK
	if '%compiledclass.Abstract {
		set tSwaggerTemplateGenerator=##class(QCMasterLib.Utils.REST.Swagger.MakeSwaggerTemplateGenerator).%New()
		set tSwaggerTemplateId=tSwaggerTemplateGenerator.Generate(%compiledclass,..#DefaultHdrMapClassName)
		do %code.WriteLine("	set sc=$$$OK")
		do %code.WriteLine("	set tTempSwagger={""swagger"":""2.0"", ""info"":{""title"":(..GetServiceTitle()),""version"":(..GetServiceVersion())}}")
	   	do %code.WriteLine("	try {")
	   	do %code.WriteLine("		set tHttpScheme=$CASE(pIsHTTPS,1:""https"",:""http"")")
		do %code.WriteLine("		do tTempSwagger.%Set(""schemes"",[(tHttpScheme)])")
		do %code.WriteLine("		do tTempSwagger.%Set(""host"",(pHost))")
		do %code.WriteLine("		do tTempSwagger.%Set(""basePath"",(pBasePath))")
		//copy values from template to real output - done this way to ensure correct property order.
		do %code.WriteLine("		set tSwaggerTemplate=##class(QCMasterLib.Tables.SwaggerTemplate).%OpenId("""_tSwaggerTemplateId_""",0,.sc)")
		do %code.WriteLine("		set tPaths=[].%FromJSON(tSwaggerTemplate.Paths)")
		do %code.WriteLine("		do tTempSwagger.%Set(""paths"",tPaths)")
		do %code.WriteLine("		set tDefintions=[].%FromJSON(tSwaggerTemplate.Definitions)")
		do %code.WriteLine("		do tTempSwagger.%Set(""definitions"",tDefintions)")
	   	do %code.WriteLine("		set pOutputSwaggerObj=tTempSwagger")
	   	do %code.WriteLine("	} catch(ex) {")
	   	do %code.WriteLine("		set sc=$SYSTEM.Status.AppendStatus(ex.AsStatus(),sc)")
	   	do %code.WriteLine("	}")
	   	do %code.WriteLine("	quit sc") //Ends Of code line*/
	}
   	quit sc
}

/// Service name swagger will report - can be overriden in sub classes
ClassMethod GetServiceTitle() As %String
{
	quit $PIECE($THIS,".",*)_ " REST Service"
}

/// Service Version Swagger defintion will report - can be overriden in sub classes
ClassMethod GetServiceVersion() As %String
{
	quit "1"
}

/// REST ROUTE Implementation for /swagger method called when client performs /swagger request.<br>
/// Referenced by routes in %CSP.REST classes which extends this function.
ClassMethod GetSwagger() As %Status
{
	set tSC = $$$OK
	try {
		// Attach Request to Response
		#dim %response As %CSP.Response
    	set %response.ContentType = %request.ContentType
    	
    	// Get Request's Details
    	set tRequestUrl 	= %request.URL
		set tRequestHost 	= %request.CgiEnvs("SERVER_NAME")
		set tRequestPort 	= %request.CgiEnvs("SERVER_PORT")
		set tRequestProtocol= %request.CgiEnvs("SERVER_PROTOCOL")
		
		// Clean url: 	/csp/qlink/app/swagger 		Becomes:  /csp/qlink/app/ 
		set tLastSlash = $LENGTH(tRequestUrl)+2-$FIND($REVERSE(tRequestUrl),$REVERSE("/"))
		set tRequestUrl = $EXTRACT(tRequestUrl, 0, tLastSlash-1)
		
		// Get boolean (true) if https (false) if http
		#dim tIsHTTPS As %Boolean
		if ($find(tRequestProtocol, "HTTPS")){
			set tIsHTTPS = 1
		}
		else{
			set tIsHTTPS = 0
		}
		
		// Procede to make swagger
		set tSwag = ""
		$$$ThrowOnError(..MakeSwagger(tIsHTTPS,tRequestHost_":"_tRequestPort,tRequestUrl,.tSwag))
		
		// Generate Dynamic Response
		set %response.ContentType="application/json"
		set tStream = ##Class(%Stream.GlobalCharacter).%New()
 		do tSwag.%ToJSON(tStream)
		do tStream.OutputToDevice()
	} catch (tException){
		set %response.ContentType="application/json"
		set tDynamicResponse = $$$NULLOREF
		set tResponse = ##class(MasterLib.Messages.Rsp.GenericUIRsp).%New()
		
		// Get Error Code
		if (tSC = $$$OK){
			set tSC = tException.AsStatus()
		}
		
		set tResponse.ReturnCode = $$$RcRESTMethodError

		// Get Error Reason
		set tResponse.ReturnReason = $$$StripCacheErrCode($SYSTEM.Status.GetErrorText(tSC))

		// Generate Dynamic Response From Code And Reason
		$$$ThrowOnError(tResponse.ToDynamicObj(.tDynamicResponse))
		// Output Response To JSON for client
		set tStream = ##Class(%Stream.GlobalCharacter).%New()
 		do tDynamicResponse.%ToJSON(tStream)
		do tStream.OutputToDevice()
		
		set tSC=$$$OK //Force back into a 200 OK error.
	}
		
	quit tSC
}

}
