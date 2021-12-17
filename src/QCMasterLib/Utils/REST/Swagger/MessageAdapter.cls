/// Adapter class for REST Messages to allow them to be converted to swagger definitions <br>
/// while allowing for their propperties to be overriden with specified types.
Class QCMasterLib.Utils.REST.Swagger.MessageAdapter Extends QCMasterLib.Utils.REST.Swagger.DefinitionAdapter [ Abstract ]
{

/// Generates the SwaggerSchemaDefintions for the class extending QCMasterLib.Utils.REST.Swagger.MessageAdapter, and <br>
/// overrides any fields specified in pOverrideMessageFieldsData which conforms to the the ReqFieldObjects / <br>
/// RspFieldObjects XDATA field format.
ClassMethod GenerateSwaggerSchemaDefintions(pOverrideMessageFieldsData As %String, pDefintionsArray As %ArrayOfObjects, pDefinitionPrefix As %String, pIgnoreSerializeEmbeddedPersistentObjects As %Boolean, Output oOutputReferenceName As %String) As %Status
{
	set sc=$$$OK
	try {
		set sc=..GenerateDefinitions(pDefinitionPrefix,$THIS,pDefintionsArray,.oOutputReferenceName,pIgnoreSerializeEmbeddedPersistentObjects)
		$$$ThrowOnError(sc)
		quit:pOverrideMessageFieldsData="" //done with try, what was produced from std defintion generation is complete
		set tMessageDefintion=pDefintionsArray.GetAt(oOutputReferenceName)
		do ..ReplacePropertyDefintionsWithOverrideValues(tMessageDefintion,pOverrideMessageFieldsData,pDefintionsArray,pDefinitionPrefix,pIgnoreSerializeEmbeddedPersistentObjects)
	} catch(ex) {
		set sc=ex.AsStatus()
	}
	quit sc
}

/// Replaces properties on pTargetedMessageDefintion with the types defined in pOverrideMessageFieldsData<br>
/// pDefintionsArray, pDefinitionPrefix, and pIgnoreSerializeEmbeddedPersistentObjects are input dependacies<br>
/// for GenerateDefinitions when the replaced property's element type needs to be generated and added to the <br>
/// pDefintionsArray.<br>
/// <br>
/// pTargetedMessageDefintion - Message defintion holding the properties to be replaced.
/// <br>
/// pOverrideMessageFieldsData - Combined override data value corresponding to the ReqFieldObjects / RspFieldObjects values<br>
/// <br>
/// pDefintionsArray		 - Defintions array is passed in so that GenerateDefintions call's defintions<br>
/// 								from the pPropertyElementType class can be added to it.<br>
/// <br>
/// pDefinitionPrefix		 - Prefix passed on for GenerateDefintions to create defintions under the same<br>
/// 								prefix as initial call (prefixes used to keep defintion sets unique to route <br>
/// 								method req/resp)<br>
/// <br>
/// pIgnoreSerializeEmbeddedPersistentObjects	- this is set to 1 for POST/PUT so that the defintions generated<br>
/// 													ignore the SerializeEmbeddedPersistentObjects setting and <br>
/// 													default off to 0.
ClassMethod ReplacePropertyDefintionsWithOverrideValues(pTargetedMessageDefintion As %DynamicObject, pOverrideMessageFieldsData As %String, pDefintionsArray As %ArrayOfObjects, pDefinitionPrefix As %String, pIgnoreSerializeEmbeddedPersistentObjects As %Boolean) [ Internal, Private ]
{
	for i=1:1:$LENGTH(pOverrideMessageFieldsData,";") {
		set tOverrideData=$PIECE(pOverrideMessageFieldsData,";",i)
		continue:tOverrideData="" //skipping empty entries due to ; on start or end.
		set tPropertyName=$PIECE(tOverrideData,":",1)
		set tPropertyElementType=$PIECE(tOverrideData,":",2)
		set tArraySingleNativeType=$PIECE(tOverrideData,":",3)
		set:tArraySingleNativeType="" tArraySingleNativeType="single" //defaulting to single since that is the behaviour of CRUDBase
		do pTargetedMessageDefintion."properties".%Remove(tPropertyName)
		do pTargetedMessageDefintion."properties".%Set(tPropertyName,..CreateSWAGGERProperty(tPropertyElementType,tArraySingleNativeType,pDefintionsArray, pDefinitionPrefix,pIgnoreSerializeEmbeddedPersistentObjects))
	}
}

/// Creates swagger property reference for override type and populates pDefintionsArray accordingly<br>
/// with any new definitions needed for it.
/// <br>
/// pPropertyElementType	 - The class type of the replacement type value of the property.<br>
/// 								This is used to generate an additional defintion to reference,<br>
/// 								and in the case of native mode is used to determine the sub <br>
/// 								property name.
/// <br>
/// pArraySingleNativeType	 - The mode of the replacement property:<br>
/// 								single: creates a reference to a pPropertyElementType
/// 								array: creates an array of pPropertyElementType
/// 								native: native is like single, but it puts the element under a sub<br>
/// 										property with the name of the class excluding package being <br>
/// 										referenced.
/// <br>
/// pDefintionsArray		 - Defintions array is passed in so that GenerateDefintions call's defintions<br>
/// 								from the pPropertyElementType class can be added to it.<br>
/// <br>
/// pDefinitionPrefix		 - Prefix passed on for GenerateDefintions to create defintions under the same<br>
/// 								prefix as initial call (prefixes used to keep defintion sets unique to route <br>
/// 								method req/resp)<br>
/// <br>
/// pIgnoreSerializeEmbeddedPersistentObjects	- this is set to 1 for POST/PUT so that the defintions generated<br>
/// 													ignore the SerializeEmbeddedPersistentObjects setting and <br>
/// 													default off to 0.
ClassMethod CreateSWAGGERProperty(pPropertyElementType As %String, pArraySingleNativeType As %String, pDefintionsArray As %ArrayOfObjects, pDefinitionPrefix As %String, pIgnoreSerializeEmbeddedPersistentObjects As %Boolean) As %DynamicObject [ Internal, Private ]
{
	set sc=..GenerateDefinitions(pDefinitionPrefix,pPropertyElementType,pDefintionsArray,.oOutputReferenceName,pIgnoreSerializeEmbeddedPersistentObjects)
	$$$ThrowOnError(sc)
	quit $CASE(pArraySingleNativeType,
					"single":..CreateSingleSwaggerProperty(oOutputReferenceName),
					"native":..CreateNativeSwaggerProperty(pPropertyElementType,oOutputReferenceName),
					"array":..CreateArraySwaggerProperty(oOutputReferenceName),
					:..CreateSingleSwaggerProperty(oOutputReferenceName) //We default to single since this is the CRUD base default.
				)
}

/// Makes a swagger schema property dynamic object representing a reference to another object.<br>
/// pDefinitionReferenceName 	- the name of the reference in #/definitions/'s to use for the reference
ClassMethod CreateSingleSwaggerProperty(pDefinitionReferenceName As %String) As %DynamicAbstractObject [ Internal, Private ]
{
	quit {"$ref" : ("#/definitions/" _ pDefinitionReferenceName)}
}

/// Makes a swagger schema property dynamic object representing a 'native mode' reference to another object.<br>
/// pDefinitionReferenceName 	- the name of the reference in #/definitions/'s to use for the reference<br>
/// pPropertyElementType		- the classname of the element type representing the element - the package<br>
/// 									will be removed from this and the name will be used as the sub property<br>
/// 									name.
ClassMethod CreateNativeSwaggerProperty(pPropertyElementType As %String, pDefinitionReferenceName As %String) As %DynamicAbstractObject [ Internal, Private ]
{
	set tTableName=$PIECE(pPropertyElementType,".",*)
	#dim tProperty As %DynamicObject
	set tProperty={"type":"object",
					"properties":{}}
					
	
	do tProperty."properties".%Set(tTableName,{"$ref" : ("#/definitions/" _ pDefinitionReferenceName)})
	quit tProperty
}

/// Makes a swagger schema property dynamic object representing an array of other objects.<br>
/// pDefinitionReferenceName 	- the name of the defintion in #/definitions/'s used for the elements of the array.
ClassMethod CreateArraySwaggerProperty(pDefinitionReferenceName As %String) As %DynamicAbstractObject [ Internal, Private ]
{
	quit {
		"type":"array",
		"items": {"$ref" : ("#/definitions/" _ pDefinitionReferenceName)}
	}
}

}
