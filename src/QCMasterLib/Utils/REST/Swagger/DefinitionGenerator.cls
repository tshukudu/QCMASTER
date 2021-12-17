/// Generator class for creating swagger objects from Cache classes.
Class QCMasterLib.Utils.REST.Swagger.DefinitionGenerator Extends %RegisteredObject
{

/// String of array key name of the generated definition and used internally.
Property DefinitionName As %String(MAXLEN = "") [ Private ];

/// String of the prefix for the definition name and used internally.
Property Prefix As %String(MAXLEN = "") [ Private ];

/// Array of the generated definitions and used internally.
Property DefinitionObjectsArray As %ArrayOfObjects [ Private ];

/// String of dynamic object generated and used internaly.
Property DefinitionObject As %DynamicObject [ Private ];

/// Transient internal reference to the compiled property for which output code is currently being generated.
Property CompiledProperty As %Dictionary.CompiledProperty [ Private, Transient ];

/// Boolean indicating if the currently processed property is a data type or not.
Property IsPropertyNotDT As %Boolean [ Private ];

/// Boolean indicating if the currently processed property is a stream or not.
Property IsPropertyStream As %Boolean [ Private ];

/// Indicates the mode in which the generator is currently being run with respect to if<br>
/// embedded persistent objects or one/parent relationship references should be serialized<br>
/// as the id of their object, or as a dynamic object representing the actual object itself <br>
/// with associate properties.
Property IsSerializeEmbeddedObjectsMode As %Boolean [ Private ];

/// Generates definition object to add to the pDefinitionObjectsArray<br>
/// pCompiledClass is the class to be added to the array.<br>
/// pPrefix is appended to the definition object's key value in the ouput array.<br>
/// pIgnoreSerializeEmbeddedPersistentObject boolean value to specify if the generator <br>
/// should read and use the EmbeddedPersistentObjects Parameter.<br>
/// pDefinitionName is the top level definition's key in the array.<br>
/// pDefinitionObjectsArray is the generated output of the Generate method.
Method Generate(
	pCompiledClass As %Dictionary.CompiledClass,
	pPrefix As %String = "",
	pIgnoreSerializeEmbeddedPersistentObject As %Boolean,
	Output pDefinitionName As %String,
	pDefinitionObjectsArray As %ArrayOfObjects) As %Status
{
	set sc=$$$OK
	set tSerializeEmbedded=..FindSerializeEmbeddedPersistentObjectsParameter(pCompiledClass)
	set:pIgnoreSerializeEmbeddedPersistentObject tSerializeEmbedded=0
	set ..IsSerializeEmbeddedObjectsMode=tSerializeEmbedded
	set ..DefinitionName=..MakeDefinitionNameFromClassname(pPrefix,pCompiledClass.Name)
	set pDefinitionName=..DefinitionName
	set ..Prefix=pPrefix
	set ..DefinitionObjectsArray=pDefinitionObjectsArray

	if (..DefinitionObjectsArray.IsDefined(..DefinitionName)) {
		quit sc
	}

	//Type
	set ..DefinitionObject={"type" : "object"}

	#dim tProperties As %DynamicObject
	set tProperties={}

	if ..IsPersistentClass(pCompiledClass) {
		set tID={"type":"string"}
		do tProperties.%Set("ID",tID)
	}

	#dim tRequiredFields As %DynamicArray
	set tRequiredFields=[]
	for i=1:1:pCompiledClass.Properties.Count() {
		#dim tCompiledProperty As %Dictionary.CompiledProperty
		set tCompiledProperty=pCompiledClass.Properties.GetAt(i)

		if ..IsGettableSettableProperty(tCompiledProperty) {
			if (tCompiledProperty.Required) {
				do tRequiredFields.%Push(tCompiledProperty.Name)
			}
			do tProperties.%Set(tCompiledProperty.Name,..GenerateDefinitionObjectProperty(tCompiledProperty))
		}
	}

	//Properties
	if (tProperties.%Size()>0) do ..DefinitionObject.%Set("properties",tProperties)

	//Required
	if (tRequiredFields.%Size()>0) do ..DefinitionObject.%Set("required",tRequiredFields)

	//Add to array
	$$$ThrowOnError(pDefinitionObjectsArray.SetAt(..DefinitionObject,..DefinitionName))

	quit sc
}

/// Finds the default SerializeEmbeddedPersistentObjects for the pCompiledClass
ClassMethod FindSerializeEmbeddedPersistentObjectsParameter(pCompiledClass As %CompiledClass) As %String [ Private ]
{
	set tSerializeEmbedded=""
	for i=1:1:pCompiledClass.Parameters.Count() {
		#dim tCompiledParameter As %Dictionary.CompiledParameter
		set tCompiledParameter=pCompiledClass.Parameters.GetAt(i)
		continue:tCompiledParameter.Name'="SerializeEmbeddedPersistentObjects"
		set tSerializeEmbedded=tCompiledParameter.Default
		quit
	}
	quit tSerializeEmbedded
}

/// Method to create the definition name.
Method MakeDefinitionNameFromClassname(
	pPrefix As %String,
	pName As %String) As %String [ Private ]
{
	set tName=pName
	set tName=$REPLACE(tName,".","_")
	set tName=$REPLACE(tName,"%","")
	quit pPrefix _ tName
}

/// Determines if pCompiledClass is a persistant class which has a %Id() method.
Method IsPersistentClass(pCompiledClass As %Dictionary.CompiledClass) As %Boolean [ Private ]
{
	quit (pCompiledClass.ClassType="persistent")
}

/// Returns true if a property is not a system property not part of the output, it <br>
/// is not an unsettable private property, and finaly it is not a relationship <br>
/// parent/one property. This last relationship condition parent/one property is a <br>
/// catch check to stop infinite recursive looping up and down the same structure<br>
/// from parent to child to parent to child etc.
Method IsGettableSettableProperty(pCompiledProperty As %Dictionary.CompiledProperty) As %Boolean [ Private ]
{
	quit:..IsSystemPercentProperty(pCompiledProperty) 0 //Excluding % start values as "internal"
	quit:pCompiledProperty.Private 0 //Private properties are not settable/gettable.
	quit:pCompiledProperty.Parameters.GetAt("BlockSwaggerProjection")=1 0 //Properties marked for internal use only.
	//quit:..IsOneOrChildRelationShip(pCompiledProperty) 0 //Excluding to stop infinite recursion
	quit 1
}

/// Returns True if the property is to be considered a system property due to it's name starting with a %
Method IsSystemPercentProperty(pCompiledProperty As %Dictionary.CompiledProperty) As %Boolean [ Private ]
{
	quit ($EXTRACT(pCompiledProperty.Name,1,1)="%") //Excluding % start values as "internal"
}

/// Returns whether or not pCompiledProperty is a parent or one relationship.
Method IsOneOrChildRelationShip(pCompiledProperty As %Dictionary.CompiledProperty) As %Boolean [ Private ]
{
	quit ((pCompiledProperty.Cardinality="one") || (pCompiledProperty.Cardinality="parent"))
}

/// Generates the property:{} for the pCompiledProperty compiled property and returns it.
Method GenerateDefinitionObjectProperty(pCompiledProperty As %Dictionary.CompiledProperty) As %DynamicObject [ Private ]
{
	#dim tProperty As %DynamicObject
	set tProperty={}
	set ..CompiledProperty=pCompiledProperty
	set ..IsPropertyNotDT=..IsEmbeddedObjectType(..CompiledProperty)
	set ..IsPropertyStream=..IsStreamObjectType(..CompiledProperty)

	if (..IsManyRelationShip(..CompiledProperty)) {
		//Reference
		quit ..MakeReferenceProperty("array")
	} elseif (..IsArray(..CompiledProperty)) {
		if ..IsPropertyNotDT {
			if (..IsPersistentEmbeddedObjectType(..CompiledProperty) && (('..IsSerializeEmbeddedObjectsMode) || (..IsOneOrChildRelationShip(..CompiledProperty)))) {
				//Embedded persistent objects are converted to ID values
				do tProperty.%Set("type","string")
			} else {
				//Reference
				quit ..MakeReferenceProperty("array")
			}
		} else {
			//Datatype
			do tProperty.%Set("type","array")
			do tProperty.%Set("items",..MakeDataTypeProperty())
		}
	} elseif (..IsList(..CompiledProperty)) {
		if ..IsPropertyNotDT {
			if (..IsPersistentEmbeddedObjectType(..CompiledProperty)&& ('..IsSerializeEmbeddedObjectsMode)) {
				//Embedded persistent objects are converted to ID values
				do tProperty.%Set("type","string")
			} else {
				//Reference
				quit ..MakeReferenceProperty("array")
			}
		} else {
			//Datatype
			do tProperty.%Set("type","array")
			do tProperty.%Set("items",..MakeDataTypeProperty())
		}
	} elseif (..IsPropertyNotDT) {
		//Embedded object
		if (..IsPersistentEmbeddedObjectType(..CompiledProperty) && (('..IsSerializeEmbeddedObjectsMode) || (..IsOneOrChildRelationShip(..CompiledProperty)))) {
			//Embedded persistent objects are converted to ID values
			do tProperty.%Set("type","string")
		} elseif (..IsPropertyStream) {
			//Stream
			do tProperty.%Set("type","string")
		} else {
			//Reference
			quit ..MakeReferenceProperty("object")
		}
	} else {
		//Datatype
		quit ..MakeDataTypeProperty()
	}
	quit tProperty
}

/// Determines if pCompiledProperty is a type of embedded object, i.e. it is not a flat data type<br>
/// i.e. like string
Method IsEmbeddedObjectType(pCompiledProperty As %Dictionary.CompiledProperty) As %Boolean [ Private ]
{
	//We are opening the compiled type of the property to check if it is a data type.
	set tCompiledClass=##class(%Dictionary.CompiledClass).%OpenId(pCompiledProperty.Type,0)
	quit:tCompiledClass=$$$NULLOREF 0 //Relationships tend to compile together with the class, so their compiled classes are unavailable.
	quit tCompiledClass.ClassType'="datatype"
}

/// Determines if pCompiledProperty is a type of stream object
Method IsStreamObjectType(pCompiledProperty As %Dictionary.CompiledProperty) As %Boolean [ Private ]
{
	//We are opening the compiled type of the property to check if it is a data type.
	set tCompiledClass=##class(%Dictionary.CompiledClass).%OpenId(pCompiledProperty.Type,0)
	quit:tCompiledClass=$$$NULLOREF 0 //Relationships tend to compile together with the class, so their compiled classes are unavailable.
	quit tCompiledClass.ClassType="stream"
}

/// Determines if pCompiledProperty is a many/children relationship reference.
Method IsManyRelationShip(pCompiledProperty As %Dictionary.CompiledProperty) As %Boolean [ Private ]
{
	quit ((pCompiledProperty.Cardinality="many") || (pCompiledProperty.Cardinality="children"))
}

/// Determines if pCompiledProperty is a "array of".
Method IsArray(pCompiledProperty As %Dictionary.CompiledProperty) As %Boolean [ Private ]
{
	quit ((pCompiledProperty.Collection="array") && (pCompiledProperty.Cardinality=""))
}

/// Determines if pCompiledProperty is a "list of".
Method IsList(pCompiledProperty As %Dictionary.CompiledProperty) As %Boolean [ Private ]
{
	quit ((pCompiledProperty.Collection="list") && (pCompiledProperty.Cardinality=""))
}

/// Returns true if the compiled property's type is a persistent type.
Method IsPersistentEmbeddedObjectType(pCompiledProperty As %Dictionary.CompiledProperty) As %Boolean [ Private ]
{
	//We are opening the compiled type of the property to check if it is a data type.
	set tCompiledClass=##class(%Dictionary.CompiledClass).%OpenId(pCompiledProperty.Type,0)
	quit:tCompiledClass=$$$NULLOREF 0 //Relationships tend to compile together with the class, so their compiled classes are unavailable.
	quit tCompiledClass.ClassType="persistent"
}

/// Returns the reference property and recursively calls GenerateDefinitions<br>
/// for the referenced property's definition to be added to the array.
Method MakeReferenceProperty(pType As %String) As %DynamicObject [ Private ]
{
	#dim tProperty As %DynamicObject
	set tProperty={}
	set sc=##class(MasterLib.Utils.REST.Swagger.DefinitionAdapter).GenerateDefinitions(
																		..Prefix,
																		..CompiledProperty.Type,
																		..DefinitionObjectsArray,
																		,
																		..IsSerializeEmbeddedObjectsMode)
	$$$ThrowOnError(sc)
	if (pType="object") {
		do tProperty.%Set("$ref","#/definitions/"_..MakeDefinitionNameFromClassname(..Prefix,..CompiledProperty.Type))
	} else {
		do tProperty.%Set("type",pType)
		do tProperty.%Set("items",..MakePropertyReferenceField())
	}
	quit tProperty
}

/// Returns the reference field of a property.
Method MakePropertyReferenceField() As %DynamicObject [ Private ]
{
	#dim tProperty As %DynamicObject
	set tProperty={}
	do tProperty.%Set("$ref","#/definitions/"_..MakeDefinitionNameFromClassname(..Prefix,..CompiledProperty.Type))
	quit tProperty
}

/// Creates and returns a plain data type property.
Method MakeDataTypeProperty() As %DynamicObject [ Private ]
{
	#dim tProperty As %DynamicObject
	set tProperty={}
	set tType=""
	set tFormat=""
	set tMultipleOf=""
	set tCompiledClass=##class(%Dictionary.CompiledClass).%OpenId(..CompiledProperty.Type,0)
	set tXSDType=..FindTYPEParameterDefault(tCompiledClass)
	set tScale = ..FindTYPEParameterDefault(tCompiledClass, "SCALE")
	set tScale = $Get(tScale, 0)
	set tHelperUtil=##class(MasterLib.Utils.REST.Swagger.DefinitionHelperUtil).%New()
	do tHelperUtil.MakePropertyTypeAndFormat(tXSDType,tScale,.tType,.tFormat,.tMultipleOf)

	//Type
	do:tType'="" tProperty.%Set("type",tType)
	//Format
	do:tFormat'="" tProperty.%Set("format",tFormat)

	set tSwaggerType = ..CompiledProperty.Parameters.GetAt("SwaggerType")
	if (tSwaggerType '= "") {
		do tProperty.%Set("type",..CompiledProperty.Parameters.GetAt("SwaggerType"))
	}
	//MultipleOf
	do:tMultipleOf'="" tProperty.%Set("multipleOf", $Normalize(tMultipleOf, 5))
	//Maximum
	if (..IsPropertyParameterSet(..CompiledProperty.Parameters.GetAt("MAXVAL"))) {
		do tProperty.%Set("maximum",..CompiledProperty.Parameters.GetAt("MAXVAL"),"number")
	}
	//Minimum
	if (..IsPropertyParameterSet(..CompiledProperty.Parameters.GetAt("MINVAL"))) {
		do tProperty.%Set("minimum",..CompiledProperty.Parameters.GetAt("MINVAL"),"number")
	}
	//MaxLength
	if (..IsPropertyParameterSet(..CompiledProperty.Parameters.GetAt("MAXLEN"))) {
		do tProperty.%Set("maxLength",..CompiledProperty.Parameters.GetAt("MAXLEN"),"number")
	}
	//MinLength
	if (..IsPropertyParameterSet(..CompiledProperty.Parameters.GetAt("MINLEN"))) {
		do tProperty.%Set("minLength",..CompiledProperty.Parameters.GetAt("MINLEN"),"number")
	}
	//Pattern(Regex)
	//Minimum
	if (..IsPropertyParameterSet(..CompiledProperty.Parameters.GetAt("REGEX"))) {
		do tProperty.%Set("pattern",..CompiledProperty.Parameters.GetAt("REGEX"),"string")
	}
	//Enum
	set tDescription = ""
	if ((..IsPropertyParameterSet(..CompiledProperty.Parameters.GetAt("VALUELIST"))) || (..IsPropertyParameterSet(..CompiledProperty.Parameters.GetAt("SwaggerEnum")))) {
		do tProperty.%Set("enum",..MakeEnumField(.tDescription))
	}
	//Description
	set:(tDescription'="") tDescription = ..CompiledProperty.Description _ $char(13,10) _ tDescription
	set:(tDescription="") tDescription = ..CompiledProperty.Description
	do:..CompiledProperty.Description'="" tProperty.%Set("description",tDescription)

	quit tProperty
}

/// Finds the default type for the pCompiledDataTypeClass
Method FindTYPEParameterDefault(pCompiledClass As %CompiledClass, pType As %String = "XSDTYPE") As %String [ Private ]
{
	set tTYPEFound=""
	for i=1:1:pCompiledClass.Parameters.Count() {
		#dim tCompiledParameter As %Dictionary.CompiledParameter
		set tCompiledParameter=pCompiledClass.Parameters.GetAt(i)
		continue:tCompiledParameter.Name'=pType
		set tTYPEFound=tCompiledParameter.Default
		quit
	}
	quit tTYPEFound
}

/// Validate if the property's parameter has a value set
Method IsPropertyParameterSet(pValue As %String) As %Boolean [ Private ]
{
	if ((pValue=$$$NULLOREF)||(pValue="")) {
		quit 0
	}
	quit 1
}

/// Creates and returns an enum array to be added to a property's fields
Method MakeEnumField(Output pEnumDescription As %String) As %DynamicArray [ Private ]
{
	#dim tArray As %DynamicArray
	set tArray=[]
	set pEnumDescription = ""
	set tHasDisplayList = ..IsPropertyParameterSet(..CompiledProperty.Parameters.GetAt("DISPLAYLIST"))

	set tSwaggerEnum = ..CompiledProperty.Parameters.GetAt("SwaggerEnum")
	if (tSwaggerEnum '= "") {
		set tValueList=$LISTFROMSTRING(tSwaggerEnum,";")
	} else {
		set tValueList = ..CompiledProperty.Parameters.GetAt("VALUELIST")
		set tValueList=$LISTFROMSTRING(tValueList, $EXTRACT(tValueList, 1, 1))
		set:(tHasDisplayList = 1) tDisplayList = ..CompiledProperty.Parameters.GetAt("DISPLAYLIST")
		set:(tHasDisplayList = 1) tDisplayList = $LISTFROMSTRING(..CompiledProperty.Parameters.GetAt("DISPLAYLIST"),",")
	}

	for i = 0:1:$LISTLENGTH(tValueList) {
		set tValue = $LISTGET(tValueList, i)
		continue:tValue=""

		if (tSwaggerEnum '= "") {
			do tArray.%Push($PIECE(tValue,":"))
			set pEnumDescription = pEnumDescription _ $char(13,10) _ " - " _ $PIECE(tValue, ":", 1) _ ": " _ $PIECE(tValue, ":", 2)
		} else  {
			do tArray.%Push(tValue)
			if (tHasDisplayList = 0) {
				set pEnumDescription = pEnumDescription _ $char(13,10) _ " - " _ tValue
			} else {
				set pEnumDescription = pEnumDescription _ $char(13,10) _ " - " _ tValue _ ": " _ $LISTGET(tDisplayList, i)
			}
		}
	}
	quit tArray
}

}
