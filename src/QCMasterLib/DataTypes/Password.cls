/// Datatype for password values
Class QCMasterLib.DataTypes.Password Extends QCMasterLib.DataTypes.StringRgx [ ClientDataType = VARCHAR, OdbcType = VARCHAR, SqlCategory = STRING ]
{

Parameter MAXLEN = "50";

Parameter REGEX = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[$@$!%*?&])[A-Za-z\d$@$!%*?&]{8,}$";

Parameter XMLNAME = "password"; 

Parameter XMLPATTERN = {..#REGEX};

}