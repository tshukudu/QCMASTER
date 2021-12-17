/// History table for SystemRole
Class QCMasterLib.Tables.SystemRoleHistory Extends QCMasterLib.Tables.TableHistoryBase
{
/// Allows for switching to a mode that outputs the content of a embedded persistent object instead of it's Id
Parameter SerializeEmbeddedPersistentObjects = 1;

/// Role Description
Property Description As %String(MAXLEN=250);

/// Reference to System applicable to this role.
Property System As QCMasterLib.Tables.System;

/// Indicated whether this resource is enabled or not.
Property Enabled As QCMasterLib.DataTypes.Boolean;

/// System Resources assigned to this role.
Property SystemResource As Array of QCMasterLib.Tables.SystemResource;


}