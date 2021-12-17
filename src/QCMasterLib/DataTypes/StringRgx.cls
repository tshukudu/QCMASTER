/// A string datatype definition which extends <class>%Library.String</class> with additional regex pattern validation. <br>
/// It does not support data population using the regex yet
Class QCMasterLib.DataTypes.StringRgx Extends %Library.String [ ClientDataType = VARCHAR, OdbcType = VARCHAR, SqlCategory = STRING ]
{

/// Set PATTERN TO empty and final as it is noe relevant on
/// this type, but is inherited from <class>%Library.String</class>
Parameter PATTERN [ Final ];

/// Set PATTERN TO empty and final as it is noe relevant on
/// this type, but is inherited from <class>%Library.String</class>
Parameter VALUELIST [ Abstract, Final ];

/// Set PATTERN TO empty and final as it is noe relevant on
/// this type, but is inherited from <class>%Library.String</class>
Parameter DISPLAYLIST [ Final ];

/// Set a valid regex pattern for value validation
Parameter REGEX As %String;

/// The unmasked character values
Parameter PoPIClearChars;

/// The masked character values
Parameter PoPIMaskedChars;

/// Set XML Regex pattern to REGEX
/// Tests if the logical value <var>%val</var>, which is a string, is valid.
/// The validation is based on the class parameter settings used for the class attribute this data type is associated with.
/// In this case, <a href="#MINLEN">MINLEN</a>, <a href="#MAXLEN">MAXLEN</a>, and <a href="#REGEX">REGEX</a>.
ClassMethod IsValid(%val As %CacheString) As %Status [ ServerOnly = 0 ]
{
	// Length checks
	if (..#MAXLEN '= "") {
		if ($length(%val) > ..#MAXLEN) {
			return $$$ERROR($$$DTMaxLen, %val, ..#MAXLEN)
		}
	}
	if (..#MINLEN '= "") {
		if ($length(%val) < ..#MINLEN) {
			return $$$ERROR($$$DTMinLen, %val, ..#MINLEN)
		}
	}
	// Regex check
	if (..#REGEX '= "") {
		try {
			if '$MATCH(%val, ..#REGEX) {
				return $$$ERROR($$$DTPattern, %val, ..#REGEX)
			}
		} catch Ex {
			return $$$ERROR($$$URegexRuleSyntax)
		}
	}
	return $$$OK
}

/// Copied from <class>%Library.String</class> to keep the current cide, and adapted to Sscramble output  
/// Converts the value of <var>%val</var>, which is in logical format, into a display string. Removes all the null characters from the string.
/// <p>Returns the string value of <var>%val</var>.
ClassMethod LogicalToDisplay(%val As %String) As %String [ CodeMode = objectgenerator, ServerOnly = 0 ]
{
	if %parameter("VALUELIST")'="",%parameter("DISPLAYLIST")'="" {
		do GenerateValConv^%occLibrary(%parameter("VALUELIST"),%parameter("DISPLAYLIST"))
	} else {
		set tPCGen = $get(%parameter("PoPICLASSIFICATION"), 1)
		if (tPCGen > 1) {
			do %code.WriteLine("  set tPC = " _ tPCGen)
			do %code.WriteLine("  set tPCCL = ##class(QCMasterLib.Utils.Security).GetUserPoPIClearanceLevel()")
			do %code.WriteLine("  if (tPCCL < tPC) {")
			do %code.WriteLine("    set %val = $translate($zconvert(%val, ""U""), """ _ %parameter("PoPIClearChars") _ """, """ _ %parameter("PoPIMaskedChars") _ """)")
			do %code.WriteLine("  }")
		}
		do %code.WriteLine("  quit $tr(%val,$c(0),"""")")
	}
	quit $$$OK
}

/// Copied from <class>%Library.String</class> to keep the current cide, and adapted to Sscramble output  
/// If XMLLISTPARAMETER is specified, XSDToLogical is generated which exports using the list specified by XMLLISTPARAMETER.
ClassMethod LogicalToXSD(%val As %String) As %String [ CodeMode = objectgenerator, ServerOnly = 1 ]
{
	set tPCGen = $get(%parameter("PoPICLASSIFICATION"), 1)
	if (tPCGen > 1) {
		do %code.WriteLine("  set tPC = " _ tPCGen)
		do %code.WriteLine("  set tPCCL = ##class(QCMasterLib.Utils.Security).GetUserPoPIClearanceLevel()")
		do %code.WriteLine("  if (tPCCL < tPC) {")
		do %code.WriteLine("    set %val = $translate($zconvert(%val, ""U""), """ _ %parameter("PoPIClearChars") _ """, """ _ %parameter("PoPIMaskedChars") _ """)")
		do %code.WriteLine("  }")
		do %code.WriteLine("  quit $tr(%val,$c(0),"""")")
	} else {
		Set %code=0
		Set xmllist=$get(%parameter("XMLLISTPARAMETER"))
		If $case(xmllist,"":0,"VALUELIST":0,:1),%parameter("VALUELIST")'="",$get(%parameter(xmllist))'="",($$$getClassType(%class)=$$$cCLASSCLASSTYPEDATATYPE) || $$$comMemberKeyGet(%class,$$$cCLASSparameter,"XMLENABLED",$$$cPARAMdefault) {
			do GenerateValConv^%occLibrary(%parameter("VALUELIST"),%parameter(xmllist))
		}
	}
	quit $$$OK
}

/// Copied from <class>%Library.String</class> to keep the current cide, and adapted to Sscramble output  
/// Converts the value of <var>%val</var>, which is in logical format, into a Odbc string. This only truncates a single field value to 32749 characters if MAXLEN is longer than 32749.
/// <p>Returns the string value of <var>%val</var>.
ClassMethod LogicalToOdbc(%val As %String) As %String [ CodeMode = objectgenerator, ServerOnly = 1 ]
{
    if %parameter("MAXLEN")'="" { set len=%parameter("MAXLEN") set:len>16374 code="$s($d(%protocol)&&($g(%protocol)<47):$extract(%val,1,16374),1:%val)" }
    set tPCGen = $get(%parameter("PoPICLASSIFICATION"), 1)
	if (tPCGen > 1) {
		do %code.WriteLine("  set tPC = " _ tPCGen)
		do %code.WriteLine("  set tPCCL = ##class(QCMasterLib.Utils.Security).GetUserPoPIClearanceLevel()")
		do %code.WriteLine("  if (tPCCL < tPC) {")
		do %code.WriteLine("    set %val = $translate($zconvert(%val, ""U""), """ _ %parameter("PoPIClearChars") _ """, """ _ %parameter("PoPIMaskedChars") _ """)")
		do %code.WriteLine("  }")
	}
    do %code.WriteLine("  quit %val")
    QUIT $$$OK
}

}
