/// Data type for return code
Class QCMasterLib.DataTypes.ReturnCode Extends %Library.Integer [ ClientDataType = INTEGER, OdbcType = INTEGER, SqlCategory = INTEGER ]
{

Parameter MINVAL = 0;

Parameter MAXVAL = 99999;

Parameter XMLNAME = "return_code";

}
