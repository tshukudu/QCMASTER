Include QCMasterLib.Utils.REST.Swagger.Adapter

/// Generates and stores a template of swagger paths and defintions required to generate a swagger object
Class QCMasterLib.Utils.REST.Swagger.MakeSwaggerTemplateGenerator Extends %RegisteredObject
{

/// Parsed Header XDATA, holds lists of array elements containing Name/Description of headers.
Property HeaderDescriptionData As list Of %ArrayOfDataTypes [ Private, Transient ];

/// Holds a array of DynamicObjects representing swagger path entries.<br>
/// Used in final swagger object generation
Property Paths As array Of %DynamicObject [ Private, Transient ];

/// Holds a array of DynamicObjects representing swagger defintion schema entries created for the paths.<br>
/// Used in final swagger object generation
Property Definitions As array Of %DynamicObject [ Private, Transient ];

/// Holds a referenced to the current compiled class entry for a REST Service for which<br>
/// swagger paths are being generated.
Property CurrentCompiledClass As %Dictionary.CompiledClass [ Private, Transient ];

/// Holds a referenced to the current route for which a swagger path is being generated.
Property CurrentRouteURL As %String(MAXLEN = "") [ Private, Transient ];

/// Name of the class for which swagger is being generated.
Property SwaggerClassName As %String(MAXLEN = "") [ Private, Transient ];

/// Holds the class name of the swagger template table which stores defintions and path data.
Property SwaggerTemplateTableClassName As %String(MAXLEN = "") [ Private ];

/// Constructor
/// pSwaggerTemplateTableName - class name of class to which to write swagger templates.
Method %OnNew(pSwaggerTemplateTableClassName As %String = "QCMasterLib.Tables.SwaggerTemplate") As %Status [ Private, ServerOnly = 1 ]
{
	set ..SwaggerTemplateTableClassName=pSwaggerTemplateTableClassName
	Quit $$$OK
}

/// Generates and stores a template of swagger paths and defintions required to generate a swagger object <br>
/// for rest class pRESTServiceCompiledClass<br>
/// pHeaderMapClassName is the name of the class holding the descriptions XDATA block for the <br>
/// Header Parameters.<br>
/// Returns Id by which the swagger template can be opened, i.e. the class name of the pRESTServiceCompiledClass service.
Method Generate(pRESTServiceCompiledClass As %Dictionary.CompiledClass, pHeaderMapClassName As %String) As %String
{
	do ..Initialize(pHeaderMapClassName,pRESTServiceCompiledClass)
	do ..RetrievePathAndDefinitionData(pRESTServiceCompiledClass)
	do ..StoreSwaggerTemplates()

	quit ..SwaggerClassName
}

/// Initialization code for Generate<br>
/// pHeaderMapClassName 		- is the name of the class holding the descriptions XDATA block for the <br>
/// 								Header Parameters.<br>
/// pRESTServiceCompiledClass 	- is the class for which swagger is being generated.
Method Initialize(pHeaderMapClassName As %String, pRESTServiceCompiledClass As %Dictionary.CompiledClass) [ Internal, Private ]
{
	set ..SwaggerClassName=pRESTServiceCompiledClass.%Id()
	do ..InitializeHeaderDescriptionXDATAArray(pHeaderMapClassName)
}

/// Initializes Header XDATA into HeaderDescriptionData<br>
/// pHeaderMapClassName is the name of the class holding the descriptions XDATA block for the <br>
/// Header Parameters.
Method InitializeHeaderDescriptionXDATAArray(pHeaderMapClassName As %String) [ Internal, Private ]
{
	//Header
	set tHeaderXDATA=..GetXDATAStream(pHeaderMapClassName,$$$HdrMapXDATAName)
	set tHeaderAttributesList=..GetHdrMapHeaderElementAttributeList()
	set ..HeaderDescriptionData=..MakeXDataElementsAttributesDataList(
										tHeaderXDATA,
										$$$HdrMapXDATAElementsName,
										tHeaderAttributesList
									)
}

/// Retrieves the stream object of a XDATA block pXDATAName residing in pSourceClassName's class.<br>
/// The return is a stream object containing XML
Method GetXDATAStream(pSourceClassName As %String, pXDATAName As %String) As %Stream.Object [ Internal, Private ]
{
	set tXDATAObj=##class(%Dictionary.CompiledXData).%OpenId(pSourceClassName_"||"_pXDATAName,0,.sc)
	quit:$$$ISERR(sc) $$$NULLOREF
	quit tXDATAObj.Data
}

/// Returns a list of XDATA attributes applicable to the Header element of HdrMap
Method GetHdrMapHeaderElementAttributeList() As %List [ Internal, Private ]
{
	quit $LB("Name","Description")
}

/// Generic function 
/// Parses a XML stream pXMLStream, converting instances of the element pElementName into entries in the <br>
/// response %ListOfObjects. Each encountered element is inspected for attributes corresponding to the <br>
/// pXMLAttributesList of fields which are converted to a %ArrayOfDataTypes which then becomes the elements <br>
/// inserted into the %ListOfObjects response.
Method MakeXDataElementsAttributesDataList(pXMLStream As %Stream.Object, pXMLElementName As %String, pXMLAttributesList As %List) As %ListOfObjects [ Internal, Private ]
{
	set tElementsAttributesList=##class(%ListOfObjects).%New()
	#dim tReader As %XML.TextReader
	$$$ThrowOnError(##class(%XML.TextReader).ParseStream(pXMLStream,.tReader))
	while tReader.Read() {
		if ((tReader.NodeType="element") && (tReader.Name=pXMLElementName)) {
			set tAttributesDataArray=..GetXMLReaderAttributesDataArray(tReader,pXMLAttributesList)
			do tElementsAttributesList.Insert(tAttributesDataArray)
		}
	}
	quit tElementsAttributesList
}

/// Generic function
/// Parses the pReader's current element node for the attirbutes in the pXMLAttributesList, this is converted to<br>
/// a Array Of DataTypes and returned. The Key of the array forming the name of the attribute.
Method GetXMLReaderAttributesDataArray(pReader As %XML.TextReader, pXMLAttributesList As %List) As %ArrayOfDataTypes [ Internal, Private ]
{
	set tAttributeDataList=##class(%ArrayOfDataTypes).%New()
	for i=1:1:$LISTLENGTH(pXMLAttributesList) {
		set tName=$LISTGET(pXMLAttributesList,i)
		continue:'pReader.MoveToAttributeName(tName)
		do tAttributeDataList.SetAt(pReader.Value,tName)
	}
	quit tAttributeDataList
}

/// Populates ..Paths and ..Defintions arrays with Dynamic objects representing the path and schema definition objects <br>
/// to be used during swagger generation. <br>
/// Will walk down the REST Controller heirarchy by following forwarded routes.<br>
/// pRESTServiceCompiledClass the compiled class for which the swagger path's and schema defintions are to be generated<br>
/// pRoutePrefix is a optional parameter which gets set when this method is called recursively to walk the<br>
/// REST controller heirarchy to find qualifying routes. pRoutePrefix is attached to the front of any qualifying routes <br>
/// found further down the heirarchy, so that their swagger path represents their complete path, the value is also used in <br>
/// combinarion deeper down the execution structure to generate a prefix for schema defintion names to avoid collisions.
Method RetrievePathAndDefinitionData(pRESTServiceCompiledClass As %Dictionary.CompiledClass, pRoutePrefix As %String = "") [ Internal, Private ]
{
	//init
	set ..CurrentCompiledClass=pRESTServiceCompiledClass
	#dim tUrlRouteData As %ListOfObjects //Holds arrays of attribute properties from XDATA
	#dim tMsgMapData As %ListOfObjects //Holds arrays of attribute properties from XDATA
	#dim tForwardingUrlMapDa As %ListOfObjects //Holds arrays of attribute properties from XDATA
	
	//Get XDATA formated values from the service
	do ..RetrieveRESTServiceFormatedXDATA(..CurrentCompiledClass.%Id(),.tUrlRouteData,.tMsgMapData,.tForwardingUrlMapData)
	do ..ReformatCacheRouteURLSToSwaggerRouteURLS(tUrlRouteData)
	do ..ReformatCacheRouteURLSToSwaggerRouteURLS(tMsgMapData)
	
	//Validate any requirements applicable to the XDATA content of the MsgMap and UrlMap.
	do ..ValidateRetrievedXDATA(tMsgMapData)
	
	//Find applicable routes for which to generate swagger
	#dim tCommonRoutesIndices As %ListOfDataTypes
	set tCommonRoutesIndices=..FindCommonRouteIndices(tMsgMapData,tUrlRouteData)
	set tNormalizedCommonRoutes=..MakeNormalizedCommonRoutesWithMethods(tCommonRoutesIndices,tMsgMapData,tUrlRouteData,pRoutePrefix)
	
	//create supporting path/definition data for common normalized routes which will be used in swagger generation.
	do ..GeneratePaths(tNormalizedCommonRoutes)
	
	//Process paths forwarded to other REST controllers
	/*This instruction must be the last instruction in this method since it 
	may recurse over sub classes and change the value of ..CurrentCompiledClass*/
	do ..RetrievePathAndDefinitionDataForForwardMaps(tForwardingUrlMapData,pRoutePrefix)
}

/// Initializes UrlMap/MsgMap XDATA of the pRESTServiceClassName class into oOutputUrlRouteData, <br>
/// oOutputMsgMapData, and oOutputForwardingUrlMapData. Each of these output parameters holds a list<br>
/// of array elements where the array element key correspond to xml attribute names and their values <br>
/// to the attribute value.
Method RetrieveRESTServiceFormatedXDATA(pRESTServiceClassName As %String, Output oOutputUrlRouteData As %ListOfObjects, Output oOutputMsgMapData As %ListOfObjects, Output oOutputForwardingUrlMapData As %ListOfObjects) [ Internal, Private ]
{
	//UrlMap
	set tUrlMapXDATA=..GetXDATAStream(pRESTServiceClassName,$$$UrlMapXDATAName)
	
	//-Route
	set tUrlMapRouteElementAttributesList=..GetUrlMapRouteElementAttributeList()
	set oOutputUrlRouteData=..MakeXDataElementsAttributesDataList(
										tUrlMapXDATA,
										$$$UrlMapXDATARouteElementsName,
										tUrlMapRouteElementAttributesList
									)
	
	//-Map						
	set tUrlMapMapElementAttributesList=..GetUrlMapMapElementAttributeList()
	set oOutputForwardingUrlMapData=..MakeXDataElementsAttributesDataList(
										tUrlMapXDATA,
										$$$UrlMapXDATAMapElementsName,
										tUrlMapMapElementAttributesList
									)
	
	//MsgMap
	set tMsgMapXDATA=..GetXDATAStream(pRESTServiceClassName,$$$MsgMapXDATAName)
	if tMsgMapXDATA=$$$NULLOREF {
		set oOutputMsgMapData=##class(%ListOfObjects).%New() //Needed for when %CSP.REST extentions simply completely lack the MsgMap section entirely
	} else {
		set tMsgMapElementAttributesList=..GetMsgMapMapElementAttributeList()
		set oOutputMsgMapData=..MakeXDataElementsAttributesDataList(
											tMsgMapXDATA,
											$$$MsgMapXDATARouteElementsName,
											tMsgMapElementAttributesList
										)
	}
}

/// Returns a list of XDATA attributes applicable to the Route element of UrlMap
Method GetUrlMapRouteElementAttributeList() As %List [ Internal, Private ]
{
	quit $LB("Url","Method","Call","Cors")
}

/// Returns a list of XDATA attributes applicable to the Map element of UrlMap
Method GetUrlMapMapElementAttributeList() As %List [ Internal, Private ]
{
	quit $LB("Prefix","Forward")
}

/// Returns a list of XDATA attributes applicable to the Route element of MsgMap
Method GetMsgMapMapElementAttributeList() As %List [ Internal, Private ]
{
	quit $LB("Url","Method","ReqMsg","RspMsg","ReqFieldObjects","RspFieldObjects","Headers")
}

/// Format's the passed list of Array of Data Type elements's Url value into a swagger url
Method ReformatCacheRouteURLSToSwaggerRouteURLS(pRouteArray As %ListOfObjects) [ Internal, Private ]
{
	for i=1:1:pRouteArray.Count() {
		set tDataElement=pRouteArray.GetAt(i)
		set tURL=tDataElement.GetAt("Url")
		do tDataElement.SetAt(..FormatCacheURLToSwaggerURL(tURL),"Url")
	}
}

/// Formats a %CSP.REST route into a swagger route.
Method FormatCacheURLToSwaggerURL(pURL) As %String
{
	 for i=1:1:$LENGTH(pURL,"/") {
		 set tSection=$PIECE(pURL,"/",i)
		 If (($Extract(tSection)=":") && ($LENGTH(tSection)>1)) {
			 set tSwaggerSection="{"_$ZSTRIP($EXTRACT(tSection,2,*),"<>W")_"}"
			 set $PIECE(pURL,"/",i)=tSwaggerSection
		 }
	 }
	 quit pURL
}

/// Applies validation to each MsgMapData element attribute set found in pMsgMapData
Method ValidateRetrievedXDATA(pMsgMapData As %ListOfObjects) As %Status [ Internal, Private ]
{
	for i=1:1:pMsgMapData.Count() {
		set tElementData=pMsgMapData.GetAt(i)
		do ..ValidateOverridePropertyFields(tElementData)
	}
}

/// Apply Override property validations
Method ValidateOverridePropertyFields(pMsgMapElementData As %ArrayOfDataTypes) [ Internal, Private ]
{
	do ..ValidateNoDuplicateOverridePropertyFields(pMsgMapElementData)
	do ..ValidateOverridePropertyFieldsHaveTypes(pMsgMapElementData)
}

/// Validates the ReqFieldObjects and RspFieldObjects values that no single property cited for override, <br>
/// can have more than one entry. Throws exception if encountered. <br>
/// pMsgMapElementData - A entry from the formated MsgMap XDATA element, at this point it is a %ArrayOfDataTypes <br>
/// 						 with the keys making up the names of the attributes of the original xml element, and  <br>
/// 						the value the value of the xml attribute.
Method ValidateNoDuplicateOverridePropertyFields(pMsgMapElementData As %ArrayOfDataTypes) [ Internal, Private ]
{
	set tDuplicateFound=""
	set tRequestPropertyOverrides=pMsgMapElementData.GetAt("ReqFieldObjects")
	throw:..IsDuplicateOverridePropertyPresent(tRequestPropertyOverrides,
												.tDuplicateFound) ..MakeDuplicateOverridePropertyException(
																			"ReqFieldObjects",
																			pMsgMapElementData.GetAt("Url"),
																			tDuplicateFound)
	
	set tResponsePropertyOverrides=pMsgMapElementData.GetAt("RspFieldObjects")
	throw:..IsDuplicateOverridePropertyPresent(tResponsePropertyOverrides,
												.tDuplicateFound) ..MakeDuplicateOverridePropertyException(
																			"RspFieldObjects",
																			pMsgMapElementData.GetAt("Url"),
																			tDuplicateFound)
}

/// Searches through the override property string pPropertyOverrides for a duplicate property entry,<br>
/// which is captured to oDuplicateFound, and returns a true/false assertion on whether a duplicate<br>
/// was encountered.
Method IsDuplicateOverridePropertyPresent(pPropertyOverrides As %String, ByRef oDuplicateFound As %String) As %Boolean [ Internal, Private ]
{
	quit:pPropertyOverrides="" 0
	set tFoundDuplicate=0
	for i=1:1:$LENGTH(pPropertyOverrides,";") {
		set tElementUnderReviewName=$PIECE($PIECE(pPropertyOverrides,";",i),":",1)
		if tElementUnderReviewName="" continue //skipping blanks that can occur due to ; on end or start.
		for j=1:1:$LENGTH(pPropertyOverrides,";") {
			continue:i=j //We are not comparing it to itself.
			set tElementComparedToName=$PIECE($PIECE(pPropertyOverrides,";",j),":",1)
			if tElementComparedToName="" continue //skipping blanks that can occur due to ; on end or start.
			if tElementComparedToName=tElementUnderReviewName {
				set tFoundDuplicate=1
				set oDuplicateFound=tElementComparedToName
				quit //breaking j for
			}
		}
		quit:tFoundDuplicate //breaking i for
	}
	quit tFoundDuplicate
}

/// Creates and returns an exception for duplicate override property validation error event.
/// pSourceAttributeName - the source that raised the event i.e. ReqFieldObjects/RspFieldObjects
/// pRouteElementRouteUrl - Route URL attribute value that created the exception scenario.
/// pDuplicateFieldFound - name of duplicate property found.
Method MakeDuplicateOverridePropertyException(pSourceAttributeName As %String, pRouteElementRouteUrl As %String, pDuplicateFieldFound As %String) [ Internal, Private ]
{
	set tMessage="Duplicate override property '"_pDuplicateFieldFound_"' found in '"_pSourceAttributeName_"', "_
					" of route '"_pRouteElementRouteUrl_ "', in class '"_ ..CurrentCompiledClass.%Id() _
					"' XDATA block MsgMap. "

	quit ##class(%Exception.General).%New("DuplicateOverridePropertyException",,,tMessage)
}

/// Validate that override properties have a type specified.
Method ValidateOverridePropertyFieldsHaveTypes(pMsgMapElementData As %ArrayOfDataTypes) [ Internal, Private ]
{
	set tRequestPropertyOverrides=pMsgMapElementData.GetAt("ReqFieldObjects")
	throw:..IsTypelessOverridePropertyPresent(tRequestPropertyOverrides,
												.tFailingPropertyName) ..MakeTypelessPropertyException(
																			"ReqFieldObjects",
																			pMsgMapElementData.GetAt("Url"),
																			tFailingPropertyName)
																			
	set tResponsePropertyOverrides=pMsgMapElementData.GetAt("RspFieldObjects")
	throw:..IsTypelessOverridePropertyPresent(tResponsePropertyOverrides,
												.tFailingPropertyName) ..MakeTypelessPropertyException(
																			"RspFieldObjects",
																			pMsgMapElementData.GetAt("Url"),
																			tFailingPropertyName)
}

Method IsTypelessOverridePropertyPresent(pPropertyOverrides As %String, ByRef oProblemPropertyName As %String) As %Boolean [ Internal, Private ]
{
	quit:pPropertyOverrides="" 0 //Nothing to find.
	set tFoundTypelessProperty=0
	for i=1:1:$LENGTH(pPropertyOverrides,";") {
		set tPropertyName=$PIECE($PIECE(pPropertyOverrides,";",i),":",1)
		continue:tPropertyName="" //skip blanks that could occur due to list starting/ending with a ;
		set tType=$PIECE($PIECE(pPropertyOverrides,";",i),":",2)
		if tType="" {
			set tFoundTypelessProperty=1
			set oProblemPropertyName=tPropertyName
			quit 
		}
	}
	quit tFoundTypelessProperty
}

/// Creates and returns an exception for typeless override property validation error event.
/// pSourceAttributeName - the source that raised the event i.e. ReqFieldObjects/RspFieldObjects
/// pRouteElementRouteUrl - Route URL attribute value that created the exception scenario.
/// pProblemPropertyField - name of property that has no type.
Method MakeTypelessPropertyException(pSourceAttributeName As %String, pRouteElementRouteUrl As %String, pProblemPropertyField As %String) [ Internal, Private ]
{
	set tMessage="Typeless override property '"_pProblemPropertyField_"' found in '"_pSourceAttributeName_"', "_
					" of route '"_pRouteElementRouteUrl_ "', in class '"_ ..CurrentCompiledClass.%Id() _
					"' XDATA block MsgMap. "

	quit ##class(%Exception.General).%New("TypelessOverridePropertyException",,,tMessage)
}

/// Parses the pMsgMapData and pUrlData lists finding common routes adding indices to
/// their entries to a %ListOfDataTypes which is returned.
Method FindCommonRouteIndices(pMsgMapData As %ListOfObjects, pUrlData As %ListOfObjects) As %ListOfDataTypes [ Internal, Private ]
{
	set tCommonRouteIndices=##class(%ListOfDataTypes).%New()
	for i=1:1:pMsgMapData.Count() {
		set tMsgMapURL=pMsgMapData.GetAt(i)
		for j=1:1:pUrlData.Count() {
			set tURLRoute=pUrlData.GetAt(j)
			if ..IsCommonRoute(tMsgMapURL,tURLRoute) $$$ThrowOnError(tCommonRouteIndices.Insert($LB(i,j)))	
		}
}
	quit tCommonRouteIndices
}

/// Determines if a pMsgMapRouteDataElement and a pUrlMapRouteDataElement are refering to the same
/// REST route.
Method IsCommonRoute(pMsgMapRouteDataElement As %ArrayOfDataTypes, pUrlMapRouteDataElement As %ArrayOfDataTypes) [ Internal, Private ]
{
	quit (	(pMsgMapRouteDataElement.GetAt("Method")=pUrlMapRouteDataElement.GetAt("Method")) && 
			(pMsgMapRouteDataElement.GetAt("Url")=pUrlMapRouteDataElement.GetAt("Url"))	)
}

/// Creates a new normalized array structure of common routes normalizing the common route element<br>
/// and grouping their respective route method information below, i.e. one route path can have multiple<br>
/// HTTP Method routes(GET/PUT/POST) underneath it.<br>
/// <br>
/// pMsgRoutes and pUrlRoutes is the original lists of formated XDATA elements, however they have 1 entry <br>
/// per HTTP Method not grouped together under their comment routes. The normalization process groups them <br>
/// together.<br>
/// <br>
/// pRoutePrefix is a prefix appended to each route when populated in order to get the full route from the <br>
/// original base path.
Method MakeNormalizedCommonRoutesWithMethods(pCommonIndices As %ListOfDataTypes, pMsgRoutes As %ListOfObjects, pUrlRoutes As %ListOfObjects, pRoutePrefix As %String) As %ArrayOfObjects [ Internal, Private ]
{
	set tNormalizedRoutes=##class(%ArrayOfObjects).%New()
	for i=1:1:pCommonIndices.Count() {
		#dim tRouteDataMsg As %ArrayOfDataTypes
		set tRouteDataMsg=pMsgRoutes.GetAt($LG(pCommonIndices.GetAt(i),1))
		set tRouteDataUrl=pUrlRoutes.GetAt($LG(pCommonIndices.GetAt(i),2))
		set tURL=tRouteDataMsg.GetAt("Url")
		set tMethod=tRouteDataMsg.GetAt("Method")
		
		set tRouteObject=tNormalizedRoutes.GetAt(pRoutePrefix_tURL)
		if tRouteObject=$$$NULLOREF {
			set tRouteObject=##class(%ArrayOfObjects).%New()
			$$$ThrowOnError(tNormalizedRoutes.SetAt(tRouteObject,pRoutePrefix_tURL))
		}
		#dim tNormalizedRouteData As %ArrayOfDataTypes
		set tNormalizedRouteData=tRouteDataMsg.%ConstructClone(1)
		do tNormalizedRouteData.SetAt(tRouteDataUrl.GetAt("Call"),"Call") //Copying method it is going to call over - used later in execution.
		
		$$$ThrowOnError(tRouteObject.SetAt(tNormalizedRouteData,tMethod))
	}	
	quit tNormalizedRoutes
}

/// Generates path entries for the routes to be used during swagger creation, also generates <br>
/// and captures schema defintions during process for swagger creation.<br>
/// pNormalizedRoutesAndMethods - Array of routes (key=path route) used for path generation <br>
/// 									where the value is an array of methods that need a method <br>
/// 									operation generation for the path.
Method GeneratePaths(pNormalizedRoutesAndMethods As %ArrayOfObjects) [ Internal, Private ]
{
	set tRouteUrl=""
	for  { //For each normalized route with a method array.
		set tRouteUrl=pNormalizedRoutesAndMethods.Next(tRouteUrl)
		quit:tRouteUrl=""
		set ..CurrentRouteURL=tRouteUrl
		set tRouteMethods=pNormalizedRoutesAndMethods.GetAt(..CurrentRouteURL)
		#dim tDefinitionsArray As %ArrayOfObjects
		set tDefinitionsArray=##class(%ArrayOfObjects).%New()
		set tPathObj=..MakePath(tRouteMethods,tDefinitionsArray) 
		do ..Paths.SetAt(tPathObj,..CurrentRouteURL)
		//Add any defintions generated by the path to the ..Defintions array for later output.
		do ..CaptureGeneratedDefintions(tDefinitionsArray)
	}
}

/// Creates a populated swagger Path object along with http method operations. Also adds definitions created<br>
/// for operations to pDefintionsArray, which is an array of swagger defintions to be included in the swagger<br>
/// generation.<br>
/// pRouteMethods - full normalized route methods data for the path under generation.<br>
/// pDefintionsArray - array to which newly created swagger schema defintions are added.<br>
Method MakePath(pRouteMethods As %ArrayOfObjects, pDefintionsArray As %ArrayOfObjects) As %DynamicObject [ Internal, Private ]
{
	#dim tPath As %DynamicObject
	set tPath={}
	set tMethod=""
	for  { //For each http method in the specified path.
		set tMethod=pRouteMethods.Next(tMethod)
		quit:tMethod=""
		set tRouteMethodData=pRouteMethods.GetAt(tMethod)
		set tMethodOperation=..MakeMethodOperation(tRouteMethodData,pDefintionsArray)
		do tPath.%Set($ZCONVERT(tMethod,"L"),tMethodOperation) //We convert the method to lowercase to conform to swagger naming.
	}
	quit tPath
}

/// Creates a method operation swagger object for the route method's data entry passed pRouteMethodData and <br>
/// adds any schema defintions created during the process to the pDefintionsArray schema defintion array.
Method MakeMethodOperation(pRouteMethodData As %ArrayOfDataTypes, pDefintionsArray As %ArrayOfObjects) As %DynamicObject [ Internal, Private ]
{
	//init
	set tClassMethodName=pRouteMethodData.GetAt("Call")
	set tHTTPMethod=pRouteMethodData.GetAt("Method")
	set tReqMsg=pRouteMethodData.GetAt("ReqMsg")
	set tRspMsg=pRouteMethodData.GetAt("RspMsg")
	set tReqFieldObjects=pRouteMethodData.GetAt("ReqFieldObjects")
	set tRspFieldObjects=pRouteMethodData.GetAt("RspFieldObjects")
	set tHeaders=pRouteMethodData.GetAt("Headers")
	
	//Create defintion prefixes
	//-Segragating request and response prefixes to avoid collisions between their definitions
	set tDefintionRoutePrefix=..MakeRouteDefintionPrefix(..CurrentRouteURL,tHTTPMethod)
	set tParametersDefintionsPrefix=tDefintionRoutePrefix_"Req"
	set tResponseDefintionsPrefix=tDefintionRoutePrefix_"Resp"
	
	//Create method operation
	set tMethodOperation={}
	/*set tMethodOperation.summary=""		// no source at present.
	set tMethodOperation.description=""  	// no source at present.*/
	set tMethodOperation.consumes=["application/json"]
	set tMethodOperation.produces=["application/json"]
	
	#dim tCompiledMethod As %Dictionary.CompiledMethod
	set tCompiledMethod=..FindCompiledClassMethod(tClassMethodName,..CurrentCompiledClass)
	set tMethodOperation.parameters=..MakeOperationParameters(tHTTPMethod,tHeaders,tCompiledMethod,tReqMsg,tReqFieldObjects,pDefintionsArray,tParametersDefintionsPrefix)
	#dim tResponse As %DynamicObject
	set tResponse={}
	
	if tRspMsg'="" {
		do tResponse.%Set("200", {
										"description": "Success",
										"schema": {
											"$ref": ("#/definitions/"_..GenerateDefinitionsAndDefintionReference(tHTTPMethod,tRspMsg,tRspFieldObjects,pDefintionsArray,tResponseDefintionsPrefix))
										}
									})
	} else {
		do tResponse.%Set("200", {
										"description": "Success"
									})
	}
	do tResponse.%Set("400",{"description":"Bad Request"})
	do tResponse.%Set("401",{"description":"Access Denied"})
	do tResponse.%Set("404",{"description":"Not found"})
	do tResponse.%Set("405",{"description":"Method not allowed"})
	set tMethodOperation.responses=tResponse
	quit tMethodOperation
}

/// Finds a compiled class method pClassMethodName in an input compiled class pSourceCompiledClass
Method FindCompiledClassMethod(pClassMethodName As %String, pSourceCompiledClass As %Dictionary.CompiledClass) As %Dictionary.CompiledMethod [ Internal, Private ]
{
	set tResponseCompiledMethod=$$$NULLOREF
	for i=1:1:pSourceCompiledClass.Methods.Count() {
		#dim tCompiledMethod As %Dictionary.CompiledMethod
		set tCompiledMethod=pSourceCompiledClass.Methods.GetAt(i)
		continue:('tCompiledMethod.ClassMethod)
		continue:(tCompiledMethod.Name'=pClassMethodName)
		set tResponseCompiledMethod=tCompiledMethod
		quit
	}
	quit tResponseCompiledMethod
}

/// Creates a Route Defintion prefix out of the full route and the HTTPMethod<br>
/// Used during giving id's to schema defintions to avoid collisions between routes and methods.
Method MakeRouteDefintionPrefix(pFullRoute As %String, pHTTPMethod As %String) As %String [ Internal, Private ]
{
	quit $TR(pFullRoute_"_"_pHTTPMethod,"/{}\#?","______")
}

/// Creates a swagger parameters array for use with a swagger method operation.<br
/// pHTTPMethod - HTTP Method of the route for which parameters are being generated, i.e. GET/PUT/POST/etc.<br>
/// pHeaders - semi-colon delimited string of headers applicable for which parameters need to be generated.<br>
/// pCompiledMethod - compiled method which is run for this rest route when called - used further down the <br>
/// 						execution steps to determine the type of URL path based operation parameters.<br>
/// pReqMsg			- ClassName of the class representing a JSON body in the request.<br>
/// pReqFieldObjects - Corresponse to the ReqFieldObjects XML attribute - used later to override property <br>
/// 						defintions coming out of the pReqMsg class and replace them with defintions defined <br>
/// 						from pReqFieldObjects's content.<br>
/// pDefintionsArray - Array to which new swagger schema defintions supporting parameters are added.<br>
/// pDefinitionPrefix - Prefix appended to front of generated schema defintions to avoid collisions.
Method MakeOperationParameters(pHTTPMethod As %String, pHeaders As %String, pCompiledMethod As %Dictionary.CompiledMethod, pReqMsg As %String, pReqFieldObjects As %String, pDefintionsArray As %ArrayOfObjects, pDefinitionPrefix As %String) As %DynamicArray [ Internal, Private ]
{
	#dim tParameters As %DynamicArray
	set tParameters=[]
	do ..AddHeaderParameters(tParameters, pHeaders)
	do ..AddURLParameters(tParameters, pCompiledMethod)
	do ..AddBodyParameter(tParameters, pHTTPMethod, pReqMsg, pReqFieldObjects, pDefintionsArray,pDefinitionPrefix)
	quit tParameters
}

/// Creates header parameters passed in pHeaders and adds them to the pParameters dynamic array.
Method AddHeaderParameters(pParameters As %DynamicArray, pHeaders As %String) [ Internal, Private ]
{
	if pHeaders'="" {
		for i=1:1:$LENGTH(pHeaders,";"){
			set tHeaderName=$PIECE(pHeaders,";",i)
			continue:tHeaderName="" //just skipping if there is some rogue ; in the begining or end.
			set tHeaderDescription=..FindHeaderDescription(tHeaderName)
			do ..AddHeaderParameter(pParameters,tHeaderName,tHeaderDescription)
		}
	}
}

/// Finds a given header pHeaderName's description in the ..HeaderDescriptionData entries.
Method FindHeaderDescription(pHeaderName As %String) As %String [ Internal, Private ]
{
	set tHeaderDescription=""
	for i=1:1:..HeaderDescriptionData.Count() {
		#dim tHeaderDescriptionDataEntry As %ListOfDataTypes
		set tHeaderDescriptionDataEntry=..HeaderDescriptionData.GetAt(i)
		continue:(tHeaderDescriptionDataEntry.GetAt("Name")'=pHeaderName)
		set tHeaderDescription=tHeaderDescriptionDataEntry.GetAt("Description")
		quit //found it so done.
	}
	quit tHeaderDescription
}

/// Creates a Header parameter and adds it to the pParameters parameters array.<br>
/// pHeaderName - Name of header parameter to be created.<br>
/// pHeaderDescription - Description of the header parameter to be created.
Method AddHeaderParameter(pParameters As %DynamicArray, pHeaderName As %String, pHeaderDescription) [ Internal, Private ]
{
	#dim tParameter As %DynamicObject
	set tParameter={}
	do tParameter.%Set("name",pHeaderName)
	do tParameter.%Set("in","header")
	do tParameter.%Set("description",pHeaderDescription)
	//do tParameter.%Set("required",tIsParameterRequired,"boolean")) - Nothing to indicate if a header is required or not.
	do tParameter.%Set("type","string")
	do pParameters.%Push(tParameter)
}

/// Builds route parameters based on ..CurrentRouteURL and from the Call method's formal spec.<br>
/// The formal spec is used to determine required/datatype. The route is used to determine the <br>
/// parameters to be created and their names respectively.<br>
/// pCompiledMethod which's formal spec will be used.<br>
/// pParameters - array to which created parameters will be added.
Method AddURLParameters(pParameters As %DynamicArray, pCompiledMethod As %Dictionary.CompiledMethod) [ Internal, Private ]
{
	set tCompiledMethodParsedFormalSpec=pCompiledMethod.FormalSpecParsed
	#dim tURLParametersList As %ListOfDataTypes
	set tURLParametersList=..ParseRouteForURLParameters(..CurrentRouteURL)
	for i=1:1:tURLParametersList.Count() {
		set tParameterName=tURLParametersList.GetAt(i)
		
		//create parameter
		set tParameterType=$LG($LG(tCompiledMethodParsedFormalSpec,i),2)
		set tIsParameterRequired=($LG($LG(tCompiledMethodParsedFormalSpec,i),4)="") /*Check if there is a default value or not
																	 - no default value = required*/
		
		set tOpenAPIType=""
		set tOpenAPIFormat=""
		set tOpenAPIMultipleOf=""
		do ..ConvertCacheTypeToOpenAPITypeAndFormat(tParameterType,.tOpenAPIType,.tOpenAPIFormat,.tOpenAPIMultipleOf)
		#dim tParameter As %DynamicObject
		set tParameter={}
		do tParameter.%Set("name",tParameterName)
		do tParameter.%Set("in","path")
		//"description":"", //no description source for arguments
		do tParameter.%Set("required",tIsParameterRequired,"boolean")
		do tParameter.%Set("type",tOpenAPIType)
		if tOpenAPIFormat'="" {
			do tParameter.%Set("format",tOpenAPIFormat)
		}
		if (tOpenAPIMultipleOf '= "") {
			do tParameter.%Set("multipleOf", tOpenAPIMultipleOf)
		}
		//Add parameter to list
		do pParameters.%Push(tParameter)
	}
}

/// Parses a REST route URL pRouteURL for {parm1}/{param2} parameters and returns a list of found parameter names.
Method ParseRouteForURLParameters(pRouteURL As %String) As %ListOfDataTypes [ Internal, Private ]
{
	set tURLParametersList=##class(%ListOfDataTypes).%New()
	for i=2:1:$LENGTH(pRouteURL,"{"){
		set tParameterNamePiece=$PIECE(pRouteURL,"{",i)
		set tParameterName=$PIECE(tParameterNamePiece,"}",1)
		do tURLParametersList.Insert(tParameterName)
	}
	quit tURLParametersList
}

/// Finds and correlates the pParameterTypeClassName data type's to the swagger type/format values.<br>
/// pParameterTypeClassName - Class name of the data type which is to be inspected for a type.<br>
/// 							Type will be converted to a type and format value for the swagger.<br>
/// oOutputOpenAPIType		- Output swagger type value for found type<br>
/// oOutputOpenAPIFormat	- Output swagger format value for found type<br>
Method ConvertCacheTypeToOpenAPITypeAndFormat(pParameterTypeClassName As %String, Output pOutputOpenAPIType, Output pOutputOpenAPIFormat = "string", Output pOutputOpenAPIMultipleOf = "") [ Internal, Private ]
{
	set tCompiledParameterTypeClass=##class(%Dictionary.CompiledClass).%OpenId(pParameterTypeClassName,0)
	set tXSDType=""
	set tScale = ""

	if tCompiledParameterTypeClass.ClassType="datatype" {
		set tXSDTYPE=..FindTYPEParameterDefault(tCompiledParameterTypeClass)
		set tScale = ..FindTYPEParameterDefault(tCompiledParameterTypeClass, "SCALE")
		set tScale = $Get(tScale, 0)
		do ##class(MasterLib.Utils.REST.Swagger.DefinitionHelperUtil).MakePropertyTypeAndFormat(tXSDTYPE,tScale,.pOutputOpenAPIType,.pOutputOpenAPIFormat,.pOutputOpenAPIMultipleOf)
	}
}

/// Finds the default type for the pCompiledDataTypeClass
Method FindTYPEParameterDefault(pCompiledDataTypeClass As %CompiledClass, pType As %String = "XSDTYPE") As %String [ Internal, Private ]
{
	set tTYPEFound=""
	for i=1:1:pCompiledDataTypeClass.Parameters.Count() {
		#dim tCompiledParameter As %Dictionary.CompiledParameter
		set tCompiledParameter=pCompiledDataTypeClass.Parameters.GetAt(i)
		continue:tCompiledParameter.Name'=pType
		set tTYPEFound=tCompiledParameter.Default
		quit
	}
	quit tTYPEFound
}

/// Builds body parameter for the pReqMsg class, adds it to the pParameters parameters array, and adds any<br>
/// supporting schema defintion to the pDefintionsArray.<br>
/// <br>
/// pParameters - array to which created parameters will be added.<br>
/// pHTTPMethod - - HTTP Method of the route for which parameters are being generated, i.e. GET/PUT/POST/etc.<br>
/// pReqMsg - ClassName of the class representing a JSON body in the request.<br>
/// pReqFieldObjects - Corresponse to the ReqFieldObjects XML attribute - used later to override property <br>
/// 						defintions coming out of the pReqMsg class and replace them with defintions defined <br>
/// 						from pReqFieldObjects's content.<br>
/// pDefintionsArray - Array to which new swagger schema defintions supporting parameters are added.<br>
/// pDefinitionPrefix - Prefix appended to front of generated schema defintions to avoid collisions.
Method AddBodyParameter(pParameters As %DynamicArray, pHTTPMethod As %String, pReqMsg As %String, pReqFieldObjects As %String, pDefintionsArray As %ArrayOfObjects, pDefinitionPrefix As %String) [ Internal, Private ]
{
	quit:pReqMsg="" //No body parameter to add.
	set tParameter={}
	
	set tRefName=..GenerateDefinitionsAndDefintionReference(pHTTPMethod,pReqMsg,pReqFieldObjects,
																	pDefintionsArray,pDefinitionPrefix)
	do tParameter.%Set("name",tRefName)
	do tParameter.%Set("in","body")
	do tParameter.%Set("required",1,"boolean")
	do tParameter.%Set("schema",{"$ref": ("#/definitions/"_tRefName)})
	
	do pParameters.%Push(tParameter)
}

/// Retrieves paths and definition data for forwarded routes, passing in unique prefixes so that their defintions do not collide. <br>
/// pForwardingMaps - Forwarded routes from the Url XDATA of the REST Service. <br>
/// pRoutePrefix - existing prefix to be forwarded to recursive itterations of RetrievePathAndDefinitionData as the routes <br>
/// 					tree is walked for path / defintion generation.
Method RetrievePathAndDefinitionDataForForwardMaps(pForwardingMaps As %ListOfObjects, pRoutePrefix As %String) [ Internal, Private ]
{
	for i=1:1:pForwardingMaps.Count() {
		set tRoutePrefix=pRoutePrefix_pForwardingMaps.GetAt(i).GetAt("Prefix") //Extending route prefix.
		set tClassName=pForwardingMaps.GetAt(i).GetAt("Forward")
		
		set tCompiledClass=##class(%Dictionary.CompiledClass).%OpenId(tClassName,0,.sc)
		$$$ThrowOnError(sc)
		//Walk the forwarded route down.
		do ..RetrievePathAndDefinitionData(tCompiledClass,tRoutePrefix)
	}
}

/// Creates a "$ref" reference to be used in the swagger for a defintion it generates based on the specified pMsgClassName, and <br>
/// pOverrideMessageFieldsData override property settings.<br>
/// pHTTPMethod - HTTP Method i.e. GET/PUT/POST - is used to determine if the SerializeEmbeddedPersistentObject parameter is to be<br>
/// 					adhered to by this generated swagger definition or not.<br>
/// pMsgClassName - Class name for which a message class defintion and ref is to be generated.<br>
/// pOverrideMessageFieldsData - data entries corresponding to the XDATA MsgMap's ReqFieldObjects and RspFieldObjects attributes<br>.
/// 									this method is used both for generating the request message and response message defintions.<br>
/// pDefintionsArray - Array to which generated swagger schema defintions are added.<br>
/// pDefinitionPrefix - prefix value passed to swagger schema generator to prefix any schemas generated.
Method GenerateDefinitionsAndDefintionReference(pHTTPMethod As %String, pMsgClassName As %String, pOverrideMessageFieldsData As %String, pDefintionsArray As %ArrayOfObjects, pDefinitionPrefix As %String) As %String [ Internal, Private ]
{
	set tIgnoreSerializeEmbeddedPersistentObjects=$CASE(pHTTPMethod,"POST":1,"PUT":1,:0)
	set sc=$CLASSMETHOD(pMsgClassName,"GenerateSwaggerSchemaDefintions",pOverrideMessageFieldsData,pDefintionsArray,pDefinitionPrefix,tIgnoreSerializeEmbeddedPersistentObjects,.tRefName)
	$$$ThrowOnError(sc)
	quit tRefName
}

/// Captures swagger schema defintions from the pDefinitionsArray into the ..Definitions property for <br>
/// later use during swagger source code generation
Method CaptureGeneratedDefintions(pDefinitionsArray As %Library.ArrayOfObjects) [ Internal, Private ]
{
	set tDefinitionName=""
	for  {
		set tDefinitionName=pDefinitionsArray.Next(tDefinitionName)
		quit:tDefinitionName=""
		do ..Definitions.SetAt(pDefinitionsArray.GetAt(tDefinitionName),tDefinitionName)
	}
}

/// Serializes and stores the values of ..Paths and ..Defintions into a table record of the <br>
/// ..SwaggerClassName persistant table - it is asumed that this table shall be in the image of<br>
/// MasterLib.Tables.SwaggerTemplate
Method StoreSwaggerTemplates() [ Internal, Private ]
{
	#dim tSwaggerTemplate As MasterLib.Tables.SwaggerTemplate
	set tSwaggerTemplate=$CLASSMETHOD(..SwaggerTemplateTableClassName,"%OpenId",..SwaggerClassName)
	set:tSwaggerTemplate=$$$NULLOREF tSwaggerTemplate=$CLASSMETHOD(..SwaggerTemplateTableClassName,"%New")
	set tSwaggerTemplate.Dispatcher=..SwaggerClassName
	do tSwaggerTemplate.Paths.Clear(1)
	do tSwaggerTemplate.Definitions.Clear(1)
	
	
	#dim tPaths As %DynamicArray
	#dim tDefintions As %DynamicArray
	set tPaths=..MakeDynamicObjectFromArrayOfDynamicObjects(..Paths)
	set tDefintions=..MakeDynamicObjectFromArrayOfDynamicObjects(..Definitions)
	
	do tPaths.%ToJSON(tSwaggerTemplate.Paths)
	do tDefintions.%ToJSON(tSwaggerTemplate.Definitions)
	
	$$$ThrowOnError(tSwaggerTemplate.%Save(0))
}

/// Turns an array of dynamic objects pArray into a %DynamicObject where the key's of the original array become properties.
Method MakeDynamicObjectFromArrayOfDynamicObjects(pArray As %ArrayOfObjects) As %DynamicObject
{
	#dim tArrayDynamicObject As %DynamicObject
	set tArrayDynamicObject={}
	set tArrayKey=""
	for  {
		set tArrayKey=pArray.Next(tArrayKey)
		quit:tArrayKey=""
		set tDynamicObject=pArray.GetAt(tArrayKey)
		do tArrayDynamicObject.%Set(tArrayKey,tDynamicObject)
	}
	quit tArrayDynamicObject
}

}
