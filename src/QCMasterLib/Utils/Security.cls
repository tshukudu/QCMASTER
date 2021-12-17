Include (DebugStackDefines, ExceptionDefines, ErrorCodes, MasterLibDefines, PoPIDefines)

/// /// Helper functions that will get the  signed in user or UI user - whether it is a cache user or other user
Class QCMasterLib.Utils.Security
{

ClassMethod GetUserIdentifier() As %String
{
	set tUserIdentifier = $username
	set tSession = $get(%CSP, "")
	if (tSession '= "") {
		set tUserIdentifier = $get(%gUser(%CSP.Session.SessionId, "UID"), $username)
	}
	return tUserIdentifier
}

/// Gets the PoPI classification level of a user signed into a session from the System User table
ClassMethod GetUserPoPIClearanceLevel() As %Integer
{
	set tResult = 0
	try {
		set tUserSource = $$$SystemUserSourceCache
		set tSession = $get(%CSP, "")
		if (tSession '= "") {
			set tUserSource = $get(%gUser(%CSP.Session.SessionId, "Source"), $$$SystemUserSourceCache)
		}
		set tUserId = ..GetUserIdentifier()
		if (tSession = "") {
			set tSession = tUserId
		}
		// Check if already calculated to decrease db hits and processing
		if ($get(%gUser(tSession, "PCCL"), "") '= "") {
			return %gUser(tSession, "PCCL")
		}
		set tSU = ##class(QCMasterLib.Tables.SystemUser).UserSourceUserIdentifierIndexOpen(tUserSource, tUserId,0)
		if (tSU = "") {
			throw
		}
		set %gUser(tSession, "PCCL") = tSU.PoPIClassificationLevel 
		set tResult = tSU.PoPIClassificationLevel
	} catch tEx {
		///
	}
	quit tResult
}

/// Method used to check a user's system access <br>
/// pClientIdentifier: Institution Client Identifier to check against. <br>
/// pSystemResouceIdentifier: This will be used for Intranet access control and any other users that are not Cache Users with its own set of roles OR AD/TIM users on which the roles are controlled by an external system.
/// pSystemResourceSystem: The external System that pSystemResouceIdentifier is assigned to.
/// pAllowed: Output value calculated in the method. Indicates whether the User has access or not 
ClassMethod ValidateUserAccess(pClientIdentifier As %Integer, pUserIdentifier As %String(MAXLEN="") = "", pSystemResouceIdentifier As %String = "", pSystemResourceSystem As %Integer = "", Output pAllowed As %Boolean) As %Status
{
	set sc = $$$OK
	$$$InitialiseDebugStack
	try {
		set pAllowed = 0
		set tUserSource = $$$SystemUserSourceCache
		set tSession = $get(%CSP, "")
		if (tSession '= "") {
			set tUserSource = $get(%gUser(%CSP.Session.SessionId, "Source"), $$$SystemUserSourceCache)
		}
		if (pUserIdentifier = "") {
			set tUserId = ..GetUserIdentifier()
		} else {
			set tUserId = pUserIdentifier
		}
		set tInst = ##class(QCMasterLib.Tables.Institution).ClientIdentifierIndexOpen(pClientIdentifier,0)
		if ((tInst '= "") && (tUserSource '= "")){
			set tSystemUser = ##class(QCMasterLib.Tables.SystemUser).UserSourceUserIdentifierIndexOpen(tUserSource,tUserId,0)
			if (tSystemUser '= ""){
				if (tSystemUser.Enabled = 1){
					set tSystemUserInst = ##class(QCMasterLib.Tables.SystemUserInstitution).InstitutionSystemUserIndexOpen(tInst.%Id(),tSystemUser.%Id(),0)
					if (tSystemUserInst '= ""){
						if (pSystemResouceIdentifier = ""){
							set pAllowed = 1
						} else {
							set tSUInstId = tSystemUserInst.%Id()
							set tResCount = 0
							&sql(SELECT COUNT(SRes.ID)
								INTO :tResCount  
								FROM QCMasterLib_Tables.SystemUserInstitution SUI
								JOIN QCMasterLib_Tables.SystemUserInstitution_SystemRoles SUISRole ON (SUISRole.SystemUserInstitution = SUI.ID)
								JOIN QCMasterLib_Tables.SystemRole SRole ON (SRole.ID = SUISRole.SystemRoles)
								JOIN QCMasterLib_Tables.SystemRole_SystemResource SRoleSRes ON (SRoleSRes.SystemRole = SRole.ID)
								JOIN QCMasterLib_Tables.SystemResource SRes ON (SRes.ID = SRoleSRes.SystemResource)
								WHERE SUI.ID = :tSUInstId
								AND SRole.Enabled = 1
								AND SRes.Enabled = 1
								AND SRes.System = :pSystemResourceSystem
								AND SRes.ResourceIdentifier = :pSystemResouceIdentifier)
							if ((SQLCODE '= 0)&&(SQLCODE '= 100)) {
								throw ##class(%Exception.StatusException).%New("SystemResource select error", SQLCODE, $$$CurrentLocation, $$$DebugStackVariableName)
							}	
							if (tResCount > 0){
								set pAllowed = 1
							}
						}
					}
				}
			}
		}		
	} catch tEx {
		if ($classname(tEx) = "QCMasterLib.Utils.Security.Exception") {
			do tEx.LogException()
			set sc = $$$OK
		} else {
			set sc = tEx.AsStatus()
		}		
	}
	quit sc
}

ClassMethod HashPassword(pPassword As %String(MAXLEN=""), Output pPasswordHash As %String(MAXLEN=""))
{
	set sc = $$$OK
	$$$InitialiseDebugStack
	try {
		set tKey = "+?m4$t3r71b5uP3rS3crEth@$hK3y*!"		
		set tPasswordHashNonB64 = $System.Encryption.HMACSHA1(pPassword, tKey)
		set pPasswordHash = $System.Encryption.Base64Encode(tPasswordHashNonB64,1)		
	} catch tEx {
		if ($classname(tEx) = "QCMasterLib.Utils.Security.Exception") {
			do tEx.LogException()
			set sc = $$$OK
		} else {
			set sc = tEx.AsStatus()
		}		
	}
	quit sc
}

// set sc = ##class(QCMasterLib.Utils.Security).PopulateSystemUserInstit()

ClassMethod PopulateSystemUserInstit() As %Status
{
	set sc = $$$OK
	$$$InitialiseDebugStack
	try {
		tstart
		set tStarted = 1
		// Get list of InstitutionCacheUser entries
		&sql(DECLARE ICULST CURSOR FOR
				SELECT ID
				INTO :tICUId
				FROM QCMasterLib_Tables.InstitutionCacheUser)		
		&sql(open ICULST)
		&sql(fetch ICULST)
		while (SQLCODE = 0){
			set tICU = ##class(QCMasterLib.Tables.InstitutionCacheUser).%OpenId(tICUId,0)
			// Check if in SystemUser
			w "Get SystemUser",!
			set tSystemUser = ##class(QCMasterLib.Tables.SystemUser).UserSourceUserIdentifierIndexOpen($$$SystemUserSourceCache,tICU.CacheUser,0)
			if (tSystemUser = ""){
				w "Create New SystemUser",!
				set tSystemUser = ##class(QCMasterLib.Tables.SystemUser).%New()
				set tSystemUser.UserSource = $$$SystemUserSourceCache
				set tSystemUser.UserIdentifier = tICU.CacheUser
				set tSystemUser.PoPIClassificationLevel = $$$DataClassificationCrownJewel
				set tSystemUser.Enabled = 1
				set sc = tSystemUser.%Save(0)
				if $$$ISERR(sc){
					throw ##class(QCMasterLib.Utils.Security.Exception).%New("Error saving new System User ICU Id:"_ tICUId _ " with Error:" _ $System.Status.GetErrorText(sc), $$$RcCMOSDBTableUpdateError, $$$CurrentLocation, $$$DebugStackVariableName)
				}
			}
			// Create SystemUserInstitution entry	
			set tSUI = ##class(QCMasterLib.Tables.SystemUserInstitution).InstitutionSystemUserIndexOpen(tICU.Institution.%Id(),tSystemUser.%Id(),0)
			if (tSUI = ""){
				set tSUI = ##class(QCMasterLib.Tables.SystemUserInstitution).%New()
				do tSUI.InstitutionSetObjectId(tICU.Institution.%Id())
				do tSUI.SystemUserSetObjectId(tSystemUser.%Id())
				
				set sc = tSUI.%Save(0)
				if $$$ISERR(sc){
					throw ##class(QCMasterLib.Utils.Security.Exception).%New("Error saving new System User Institution for ICU Id:"_ tICUId _ " with Error:" _ $System.Status.GetErrorText(sc), $$$RcCMOSDBTableUpdateError, $$$CurrentLocation, $$$DebugStackVariableName)
				}
			}
			// Delete the ICU entry
			set sc = ##class(QCMasterLib.Tables.InstitutionCacheUser).%DeleteId(tICUId)
			if $$$ISERR(sc){
				throw ##class(QCMasterLib.Utils.Security.Exception).%New("Error deleting ICU Id:"_ tICUId _ " with Error:" _ $System.Status.GetErrorText(sc), $$$RcCMOSDBTableUpdateError, $$$CurrentLocation, $$$DebugStackVariableName)
			}
			&sql(fetch ICULST)
		} // End While
		&sql(close ICULST)
		tcommit		
	} catch tEx {
		if (tStarted = 1){
			trollback
		}
		if ($classname(tEx) = "QCMasterLib.Utils.Security.Exception") {
			do tEx.LogException()
			set sc = $$$OK
		} else {
			set sc = tEx.AsStatus()
		}		
	}	
	quit sc
}

}
