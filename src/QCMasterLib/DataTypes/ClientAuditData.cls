/// Data type to store Audit Data sent from the client
Class QCMasterLib.DataTypes.ClientAuditData Extends %Library.String [ ClientDataType = VARCHAR, OdbcType = VARCHAR, SqlCategory = STRING ]
{

Parameter MAXLEN = 200;

Parameter XMLNAME = "client_audit_data";

}
