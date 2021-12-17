/// A Basic User table containing Cache Users as well as users from other authentication domains, to assist with their PoPI classification clearance level. It may be expanded in the future.
Class QCMasterLib.Tables.SystemUser Extends (QCMasterLib.Tables.TableBase, QCMasterLib.Utils.REST.Swagger.MessageAdapter) [ CompileAfter = QCMasterLib.Tables.SystemUserHistory ]
{

/// Allows for switching to a mode that outputs the content of a embeded persistant object instead of it's Id
Parameter SerializeEmbeddedPersistentObjects = 1;

/// Index on User Source and User Identifier
Index UserSourceUserIdentifierIndex On (UserSource, UserIdentifier) [ Unique ];

/// The system the user belongs to. This can be local or an external system
Property UserSource As %Integer(DISPLAYLIST = ",Cache,Active Directory,System Managed", VALUELIST = ",1,2,3") [ Required ];

/// An identifier of the user on the source specified.
Property UserIdentifier As %String(MAXLEN = 100) [ Required ];

/// Indicates whether this user is enabled or not
Property Enabled As QCMasterLib.DataTypes.Boolean [ InitialExpression = 1, Required ];

/// User Password
Property Password As QCMasterLib.DataTypes.Password(BlockDOProjection = 1, BlockSwaggerProjection = 1, XMLPROJECTION = "NONE") [ Transient ];

/// Encrypted user password
Property PasswordHash As %String(BlockDOProjection = 1, BlockSwaggerProjection = 1, MAXLEN = "", XMLPROJECTION = "NONE");

/// Date that the current password expires on
Property PasswordExpiryDate As QCMasterLib.DataTypes.Date;

/// The PoPI classification clearance level of this user, which will control the visible data
Property PoPIClassificationLevel As %Integer(DISPLAYLIST = ",Public,Sensitive,Highly Sensitive,Crown Jewel", VALUELIST = ",1,6,11,16") [ Required ];

/// Validates dependent fields
Method %OnValidateObject() As %Status [ Private ]
{
	set sc = $$$OK
	if (..%Id() = "") {
    	if (..UserSource = $$$SystemUserSourceSystemManaged){
    		if (..Password = ""){
    			set esc = $$$ERROR($$$GeneralError, "Password is required when User Code is System Managed (3).")
    			set sc = $$$ADDSC(sc,esc)
    		}
    		if (..PasswordExpiryDate = ""){
    			set esc = $$$ERROR($$$GeneralError, "PasswordExpiryDate is required when User Code is System Managed (3).")
    			set sc = $$$ADDSC(sc,esc)
    		}
    	}
    }
    quit sc
}

/// Overwrites TableBase's method of the same name in order to encrypt the password
Method %OnAddToSaveSet(depth As %Integer, insert As %Integer, callcount As %Integer) As %Status [ Private ]
{
	set sc = $$$OK
	try {
		set ..DateTimeStamp = $$$Now
		set ..RecordPID = $JOB
		set ..RecordUserIdentifier = ##class(QCMasterLib.Utils.Security).GetUserIdentifier()
		set ..RecordEnsHost = $get(%Ensemble("ConfigName"),"")
		if (..Password '= "") {
			set sc = ##class(QCMasterLib.Utils.Security).HashPassword(..Password, .tPasswordHash)
			if $$$ISERR(sc){ throw }
			set ..PasswordHash = tPasswordHash
			set ..PasswordExpiryDate = $$$CurrentDate
		}
	}catch tEx {
		if (sc = $$$OK) {
			set sc = tEx.AsStatus()
		}
	}
	quit sc
}

}
