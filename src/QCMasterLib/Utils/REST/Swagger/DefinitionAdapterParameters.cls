/// Parameter class for custom parameters used with the definition adapter.
Class QCMasterLib.Utils.REST.Swagger.DefinitionAdapterParameters [ Abstract ]
{

/// Blocks the projection of a property into a definition object.
Parameter BlockSwaggerProjection;

/// Override the type projected on the swagger
Parameter SwaggerType As %String;

/// Override or set a enum fo the swagger projection
Parameter SwaggerEnum As %String;

}
