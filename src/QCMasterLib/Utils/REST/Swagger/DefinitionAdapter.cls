/// Adapter class for Cache classes to allow them to be converted to swagger objects.<br>
/// This class needs to be extended to provide the BlockSwaggerProjection property paramter<br>
/// functionality to suppress the projection of certain properties to the swagger definition.
Class QCMasterLib.Utils.REST.Swagger.DefinitionAdapter [ Abstract, PropertyClass = QCMasterLib.Utils.REST.Swagger.DefinitionAdapterParameters ]
{

/// Generates an array of definitions from the pCompiledClassName with its sub objects.
ClassMethod GenerateDefinitions(pPrefix As %String = "", pCompiledClassName As %String, pDefinitionArray As %ArrayOfObjects, Output pDefinitionName As %String, pIgnoreSerializeEmbeddedPersistentObject As %Boolean) As %Status
{
   	set sc=$$$OK
   	set tArr=$$$NULLOREF
   	try {   	
	   	set tCompiledClass=##class(%Dictionary.CompiledClass).%OpenId(pCompiledClassName,0)
	   	set tDefinitionGenerator=##class(QCMasterLib.Utils.REST.Swagger.DefinitionGenerator).%New()
		set sc=tDefinitionGenerator.Generate(tCompiledClass,pPrefix,pIgnoreSerializeEmbeddedPersistentObject,.pDefinitionName,pDefinitionArray)
		set tArr=pDefinitionArray
   	} catch(ex) {
   		set sc=$SYSTEM.Status.AppendStatus(ex.AsStatus(),sc)
   	}
   	quit sc
}

}
