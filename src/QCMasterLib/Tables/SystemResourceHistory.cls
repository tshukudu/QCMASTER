/// History Table for SystemResorce.
Class QCMasterLib.Tables.SystemResourceHistory Extends QCMasterLib.Tables.TableHistoryBase
{

/// Reference to System Table - the system this resource is assigned to.
Property System As QCMasterLib.Tables.System;

/// Resource name
Property ResourceIdentifier AS %String(MAXLEN = "");

/// Indicated whether this resource is enabled or not.
Property Enabled As QCMasterLib.DataTypes.Boolean;

}