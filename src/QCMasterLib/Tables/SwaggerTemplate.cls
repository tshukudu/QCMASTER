/// Table holding paths / defintions template for swagger routes.
Class QCMasterLib.Tables.SwaggerTemplate Extends (QCMasterLib.Tables.TableBase) 
{

/// Allows for switching to a mode that outputs the content of a embeded persistant object instead of it's Id
Parameter SerializeEmbeddedPersistentObjects = 1;

/// Class name of the %CSP.REST class which extends QCMasterLib.Utils.REST.Swagger.RouteAdapter<br>
/// This is also the primary key of the class.
Property Dispatcher As %String(MAXLEN = "") [ Required ];

/// Index for making Dispatcher unique and allowing %OpenId via the ClassName it holds.
Index DispatcherIndex On Dispatcher [ IdKey, PrimaryKey, Unique ];

/// Serialized Paths swagger entries.
Property Paths As %GlobalCharacterStream;

/// Serialized Defintions swagger entries.
Property Definitions As %GlobalCharacterStream;

}
