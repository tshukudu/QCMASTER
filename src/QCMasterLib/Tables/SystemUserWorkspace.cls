/// Contains enabled System users and the Workspace they may access.
Class QCMasterLib.Tables.SystemUserWorkspace Extends QCMasterLib.Tables.TableBase [ CompileAfter = QCMasterLib.Tables.SystemUserWorkspaceHistory ]
{

/// Allows for switching to a mode that outputs the content of a embedded persistent object instead of it's Id
Parameter SerializeEmbeddedPersistentObjects = 1;

Index InstitutionSystemUserIndex on (Workspace, SystemUser) [ Unique ];

/// Foreign Keys
ForeignKey WorkspaceFK(Workspace) References QCMasterLib.Tables.Workspace();

ForeignKey SystemUserFk(SystemUser) References QCMasterLib.Tables.SystemUser();

/// SystemUser Connected to the Workspace.
Property SystemUser As QCMasterLib.Tables.SystemUser [ Required ];

/// Allowed Workspace.
Property Workspace As QCMasterLib.Tables.Workspace [ Required ];

/// System roles this user is entitled to.
Property SystemRoles As Array of QCMasterLib.Tables.SystemRole;

}