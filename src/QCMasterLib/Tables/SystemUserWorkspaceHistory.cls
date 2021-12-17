/// History Table for SystemUserWorkspace.
Class QCMasterLib.Tables.SystemUserWorkspaceHistory Extends QCMasterLib.Tables.TableHistoryBase
{

/// Allows for switching to a mode that outputs the content of a embedded persistent object instead of it's Id
Parameter SerializeEmbeddedPersistentObjects = 1;

/// SystemUser Connected to the Workspace.
Property SystemUser As QCMasterLib.Tables.SystemUser;

/// Allowed Workspace.
Property Workspace As QCMasterLib.Tables.Workspace;

/// System roles this user is entitled to.
Property SystemRoles As Array of QCMasterLib.Tables.SystemRole;

}