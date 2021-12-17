/// The audit history table of the User table
Class QCMasterLib.Tables.SystemUserHistory extends QCMasterLib.Tables.TableHistoryBase {

/// Allows for switching to a mode that outputs the content of a embeded persistant object instead of it's Id
Parameter SerializeEmbeddedPersistentObjects = 1;

/// The system the user belongs to. This can be local or an external system
Property UserSource As %Integer(VALUELIST=",1,2,3", DISPLAYLIST=",Cache,Active Directory,System Managed");

/// An identifier of the user on the source specified.
Property UserIdentifier As %String(MAXLEN=100);

/// Indicates whether this user is enabled or not
Property Enabled As QCMasterLib.DataTypes.Boolean [ InitialExpression = 1 ];

/// Hashed user password
Property PasswordHash As %String(MAXLEN="");

/// Date that the current password expires on
Property PasswordExpiryDate AS QCMasterLib.DataTypes.Date;

/// The PoPI classification clearance level of this user, which will control the visible data
Property PoPIClassificationLevel As %Integer(VALUELIST=",1,6,11,16", DISPLAYLIST=",Public,Sensitive,Highly Sensitive,Crown Jewel") ;

}