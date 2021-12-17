Class QCMasterLib.Services.REST.UIBaseTables Extends (%CSP.REST, QCMasterLib.Services.REST.UIBaseTables.System, QCMasterLib.Services.REST.UIBaseTables.SystemResource, QCMasterLib.Services.REST.UIBaseTables.SystemRole, QCMasterLib.Services.REST.UIBaseTables.SystemUser, QCMasterLib.Services.REST.UIBaseTables.SystemUserWorkspace, QCMasterLib.Services.REST.UIBaseTables.SystemUserLoginLog, QCMasterLib.Services.REST.UIBaseTables.ExeceptionLog)
{

Parameter UseSession = 0;

/// Enable CORS
Parameter HandleCorsRequest = 1;

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
	<Route Url="/workspace"								Method="GET"			Call="GetWorkspaceList"/>
	<Route Url="/workspace"								Method="POST"			Call="CreateWorkspace"/>
	<Route Url="/workspace/:id"		 					Method="PUT"			Call="UpdateWorkspace"/>
	<Route Url="/workspace/:id"							Method="GET"			Call="GetInstitutionDetail"/>
	<Route Url="/system"								Method="GET"			Call="GetSystem"/>
	<Route Url="/system"								Method="POST"			Call="CreateSystem"/>
	<Route Url="/system/:id"							Method="PUT"			Call="UpdateSystem"/>
	<Route Url="/system/:id"							Method="GET"			Call="GetSystemDetail"/>
	<Route Url="/systemresource"						Method="GET"			Call="GetSystemResource"/>
	<Route Url="/systemresource"						Method="POST"			Call="CreateSystemResource"/>
	<Route Url="/systemresource/:id"					Method="PUT"			Call="UpdateSystemResource"/>
	<Route Url="/systemresource/:id"					Method="GET"			Call="GetSystemResourceDetail"/>
	<Route Url="/systemrole"							Method="GET"			Call="GetSystemRole"/>
	<Route Url="/systemrole"							Method="POST"			Call="CreateSystemRole"/>
	<Route Url="/systemrole/:id"						Method="PUT"			Call="UpdateSystemRole"/>
	<Route Url="/systemrole/:system/:description"		Method="GET"			Call="GetSystemRoleDetailOnSystemDescription"/>
	<Route Url="/systemrole/:id"						Method="GET"			Call="GetSystemRoleDetail"/>
	<Route Url="/systemuser"							Method="GET"			Call="GetSystemUser"/>
	<Route Url="/systemuser"							Method="POST"			Call="CreateSystemUser"/>
	<Route Url="/systemuser/:id"						Method="PUT"			Call="UpdateSystemUser"/>
	<Route Url="/systemuser/:id"						Method="GET"			Call="GetSystemUserDetail"/>
	<Route Url="/systemuserworkspace"					Method="GET"			Call="GetSystemUserWorkspace"/>
	<Route Url="/systemuserworkspace"					Method="POST"			Call="CreateSystemUserWorkspace"/>
	<Route Url="/systemuserworkspace/:id"				Method="PUT"			Call="UpdateSystemUserWorkspace"/>
	<Route Url="/systemuserworkspace/:id"				Method="GET"			Call="GetSystemUserWorkspacenDetail"/>
	<Route Url="/systemuserworkspace/:id"				Method="DELETE"			Call="DeleteSystemUserWorkspace"/>
	<Route Url="/systemuserloginlog"					Method="GET"			Call="GetSystemUserLoginLog"/>
	<Route Url="/systemuserloginlog/:id"				Method="GET"			Call="GetSystemUserLoginLogDetail"/>
	<Route Url="/systemresourceuicontrol"				Method="GET"			Call="GetSystemResourceUIControl"/>
	<Route Url="/systemresourceuicontrol"				Method="POST"			Call="CreateSystemResourceUIControl"/>
	<Route Url="/systemresourceuicontrol/:id"			Method="PUT"			Call="UpdateSystemResourceUIControl"/>
	<Route Url="/systemresourceuicontrol/:id"			Method="GET"			Call="GetSystemResourceUIControlDetail"/>
	<Route Url="/systemresourceuicontrol/:id"			Method="DELETE"			Call="DeleteSystemResourceUIControl"/>
</Routes>
}

XData MsgMap
{
<Routes>
	<Route 	Url="/workspace" 							Method="GET" 	RspMsg="QCMasterLib.Messages.Rsp.GenericUIRsp"				RspFieldObjects="Data:QCMasterLib.Tables.Institution:jsonarray"                     Headers="X-UI-FILTER;X-UI-SORT;X-UI-PAGE;X-UI-UID;X-UI-UIDSOURCE"/>
	<Route 	Url="/workspace" 							Method="POST" 	ReqMsg="QCMasterLib.Messages.Req.GenericUIReq" 				RspMsg="QCMasterLib.Messages.Rsp.GenericUIRsp" 										ReqFieldObjects="Data:QCMasterLib.Tables.Institution" RspFieldObjects="Data:QCMasterLib.Tables.Institution:single"    											Headers="X-UI-UID;X-UI-UIDSOURCE"/>
	<Route 	Url="/workspace/:id" 						Method="PUT" 	ReqMsg="QCMasterLib.Messages.Req.GenericUIReq" 				RspMsg="QCMasterLib.Messages.Rsp.GenericUIRsp" 										ReqFieldObjects="Data:QCMasterLib.Tables.Institution" RspFieldObjects="Data:QCMasterLib.Tables.Institution:single"    											Headers="X-UI-UID;X-UI-UIDSOURCE"/>
	<Route 	Url="/workspace/:id" 						Method="GET" 	RspMsg="QCMasterLib.Messages.Rsp.GenericUIRsp"				RspFieldObjects="Data:QCMasterLib.Tables.Institution:single"                        Headers="X-UI-FILTER;X-UI-SORT;X-UI-PAGE;X-UI-UID;X-UI-UIDSOURCE"/>
	<Route Url="/system"								Method="GET"	RspMsg="QCMasterLib.Messages.Rsp.GenericUIRsp"				RspFieldObjects="Data:QCMasterLib.Tables.System:jsonarray"							Headers="X-UI-FILTER;X-UI-SORT;X-UI-PAGE;X-UI-UID;X-UI-UIDSOURCE"/>
	<Route Url="/system"								Method="POST"	ReqMsg="QCMasterLib.Messages.Req.GenericUIReq"				RspMsg="QCMasterLib.Messages.Rsp.GenericUIRsp"										ReqFieldObjects="Data:QCMasterLib.Tables.System"							RspFieldObjects="Data:QCMasterLib.Tables.System:single"						Headers="X-UI-UID;X-UI-UIDSOURCE"/>
	<Route Url="/system/:id"							Method="PUT"	ReqMsg="QCMasterLib.Messages.Req.GenericUIReq"				RspMsg="QCMasterLib.Messages.Rsp.GenericUIRsp"										ReqFieldObjects="Data:QCMasterLib.Tables.System"							RspFieldObjects="Data:QCMasterLib.Tables.System:single"						Headers="X-UI-UID;X-UI-UIDSOURCE"/>
	<Route Url="/system/:id"							Method="GET"	RspMsg="QCMasterLib.Messages.Rsp.GenericUIRsp"				RspFieldObjects="Data:QCMasterLib.Tables.System:single"								Headers="X-UI-FILTER;X-UI-SORT;X-UI-PAGE;X-UI-UID;X-UI-UIDSOURCE"/>
	<Route Url="/systemresource"						Method="GET"	RspMsg="QCMasterLib.Messages.Rsp.GenericUIRsp"				RspFieldObjects="Data:QCMasterLib.Tables.SystemResource:jsonarray"					Headers="X-UI-FILTER;X-UI-SORT;X-UI-PAGE;X-UI-UID;X-UI-UIDSOURCE"/>
	<Route Url="/systemresource"						Method="POST"	ReqMsg="QCMasterLib.Messages.Req.GenericUIReq"				RspMsg="QCMasterLib.Messages.Rsp.GenericUIRsp"										ReqFieldObjects="Data:QCMasterLib.Tables.SystemResource"							RspFieldObjects="Data:QCMasterLib.Tables.SystemResource:single"						Headers="X-UI-UID;X-UI-UIDSOURCE"/>
	<Route Url="/systemresource/:id"					Method="PUT"	ReqMsg="QCMasterLib.Messages.Req.GenericUIReq"				RspMsg="QCMasterLib.Messages.Rsp.GenericUIRsp"										ReqFieldObjects="Data:QCMasterLib.Tables.SystemResource"							RspFieldObjects="Data:QCMasterLib.Tables.SystemResource:single"						Headers="X-UI-UID;X-UI-UIDSOURCE"/>
	<Route Url="/systemresource/:id"					Method="GET"	RspMsg="QCMasterLib.Messages.Rsp.GenericUIRsp"				RspFieldObjects="Data:QCMasterLib.Tables.SystemResource:single"						Headers="X-UI-FILTER;X-UI-SORT;X-UI-PAGE;X-UI-UID;X-UI-UIDSOURCE"/>
	<Route Url="/systemrole"							Method="GET"	RspMsg="QCMasterLib.Messages.Rsp.GenericUIRsp"				RspFieldObjects="Data:QCMasterLib.Tables.SystemRole:jsonarray"						Headers="X-UI-FILTER;X-UI-SORT;X-UI-PAGE;X-UI-UID;X-UI-UIDSOURCE"/>
	<Route Url="/systemrole"							Method="POST"	ReqMsg="QCMasterLib.Messages.Req.GenericUIReq"				RspMsg="QCMasterLib.Messages.Rsp.GenericUIRsp"										ReqFieldObjects="Data:QCMasterLib.Tables.SystemRole"							RspFieldObjects="Data:QCMasterLib.Tables.SystemRole:single"						Headers="X-UI-UID;X-UI-UIDSOURCE"/>
	<Route Url="/systemrole/:id"						Method="PUT"	ReqMsg="QCMasterLib.Messages.Req.GenericUIReq"				RspMsg="QCMasterLib.Messages.Rsp.GenericUIRsp"										ReqFieldObjects="Data:QCMasterLib.Tables.SystemRole"							RspFieldObjects="Data:QCMasterLib.Tables.SystemRole:single"						Headers="X-UI-UID;X-UI-UIDSOURCE"/>
	<Route Url="/systemrole/:system/:description"		Method="GET"	RspMsg="QCMasterLib.Messages.Rsp.GenericUIRsp"				RspFieldObjects="Data:QCMasterLib.Tables.SystemRole:single"							Headers="X-UI-FILTER;X-UI-SORT;X-UI-PAGE;X-UI-UID;X-UI-UIDSOURCE"/>
	<Route Url="/systemrole/:id"						Method="GET"	RspMsg="QCMasterLib.Messages.Rsp.GenericUIRsp"				RspFieldObjects="Data:QCMasterLib.Tables.SystemRole:single"							Headers="X-UI-FILTER;X-UI-SORT;X-UI-PAGE;X-UI-UID;X-UI-UIDSOURCE"/>
	<Route Url="/systemuser"							Method="GET"	RspMsg="QCMasterLib.Messages.Rsp.GenericUIRsp"				RspFieldObjects="Data:QCMasterLib.Tables.SystemUser:jsonarray"						Headers="X-UI-FILTER;X-UI-SORT;X-UI-PAGE;X-UI-UID;X-UI-UIDSOURCE"/>
	<Route Url="/systemuser"							Method="POST"	ReqMsg="QCMasterLib.Messages.Req.GenericUIReq"				RspMsg="QCMasterLib.Messages.Rsp.GenericUIRsp"										ReqFieldObjects="Data:QCMasterLib.Tables.SystemUser"							RspFieldObjects="Data:QCMasterLib.Tables.SystemUser:single"						Headers="X-UI-UID;X-UI-UIDSOURCE"/>
	<Route Url="/systemuser/:id"						Method="PUT"	ReqMsg="QCMasterLib.Messages.Req.GenericUIReq"				RspMsg="QCMasterLib.Messages.Rsp.GenericUIRsp"										ReqFieldObjects="Data:QCMasterLib.Tables.SystemUser"							RspFieldObjects="Data:QCMasterLib.Tables.SystemUser:single"						Headers="X-UI-UID;X-UI-UIDSOURCE"/>
	<Route Url="/systemuser/:id"						Method="GET"	RspMsg="QCMasterLib.Messages.Rsp.GenericUIRsp"				RspFieldObjects="Data:QCMasterLib.Tables.SystemUser:single"							Headers="X-UI-FILTER;X-UI-SORT;X-UI-PAGE;X-UI-UID;X-UI-UIDSOURCE"/>
	<Route Url="/systemuserinstitution"					Method="GET"	RspMsg="QCMasterLib.Messages.Rsp.GenericUIRsp"				RspFieldObjects="Data:QCMasterLib.Tables.SystemUserInstitution:jsonarray"			Headers="X-UI-FILTER;X-UI-SORT;X-UI-PAGE;X-UI-UID;X-UI-UIDSOURCE"/>
	<Route Url="/systemuserinstitution"					Method="POST"	ReqMsg="QCMasterLib.Messages.Req.GenericUIReq"				RspMsg="QCMasterLib.Messages.Rsp.GenericUIRsp"										ReqFieldObjects="Data:QCMasterLib.Tables.SystemUserInstitution"							RspFieldObjects="Data:QCMasterLib.Tables.SystemUserInstitution:single"						Headers="X-UI-UID;X-UI-UIDSOURCE"/>
	<Route Url="/systemuserinstitution/:id"				Method="PUT"	ReqMsg="QCMasterLib.Messages.Req.GenericUIReq"				RspMsg="QCMasterLib.Messages.Rsp.GenericUIRsp"										ReqFieldObjects="Data:QCMasterLib.Tables.SystemUserInstitution"							RspFieldObjects="Data:QCMasterLib.Tables.SystemUserInstitution:single"						Headers="X-UI-UID;X-UI-UIDSOURCE"/>
	<Route Url="/systemuserinstitution/:id"				Method="GET"	RspMsg="QCMasterLib.Messages.Rsp.GenericUIRsp"				RspFieldObjects="Data:QCMasterLib.Tables.SystemUserInstitution:single"				Headers="X-UI-FILTER;X-UI-SORT;X-UI-PAGE;X-UI-UID;X-UI-UIDSOURCE"/>
	<Route Url="/systemuserinstitution/:id"				Method="DELETE"	RspMsg="QCMasterLib.Messages.Rsp.GenericUIRsp"				Headers="X-UI-FILTER;X-UI-SORT;X-UI-PAGE;X-UI-UID;X-UI-UIDSOURCE"/>
	<Route Url="/systemuserloginlog"					Method="GET"	RspMsg="QCMasterLib.Messages.Rsp.GenericUIRsp"				RspFieldObjects="Data:QCMasterLib.Tables.SystemUserLoginLog:jsonarray"				Headers="X-UI-FILTER;X-UI-SORT;X-UI-PAGE;X-UI-UID;X-UI-UIDSOURCE"/>
	<Route Url="/systemuserloginlog/:id"				Method="GET"	RspMsg="QCMasterLib.Messages.Rsp.GenericUIRsp"				RspFieldObjects="Data:QCMasterLib.Tables.SystemUserLoginLog:single"					Headers="X-UI-FILTER;X-UI-SORT;X-UI-PAGE;X-UI-UID;X-UI-UIDSOURCE"/>
	<Route Url="/systemresourceuicontrol"				Method="GET"	RspMsg="QCMasterLib.Messages.Rsp.GenericUIRsp"				RspFieldObjects="Data:QCMasterLib.Tables.SystemResourceUIControl:jsonarray"			Headers="X-UI-FILTER;X-UI-SORT;X-UI-PAGE;X-UI-UID;X-UI-UIDSOURCE"/>
	<Route Url="/systemresourceuicontrol"				Method="POST"	ReqMsg="QCMasterLib.Messages.Req.GenericUIReq"				RspMsg="QCMasterLib.Messages.Rsp.GenericUIRsp"										ReqFieldObjects="Data:QCMasterLib.Tables.SystemResourceUIControl"							RspFieldObjects="Data:QCMasterLib.Tables.SystemResourceUIControl:single"						Headers="X-UI-UID;X-UI-UIDSOURCE"/>
	<Route Url="/systemresourceuicontrol/:id"			Method="PUT"	ReqMsg="QCMasterLib.Messages.Req.GenericUIReq"				RspMsg="QCMasterLib.Messages.Rsp.GenericUIRsp"										ReqFieldObjects="Data:QCMasterLib.Tables.SystemResourceUIControl"							RspFieldObjects="Data:QCMasterLib.Tables.SystemResourceUIControl:single"						Headers="X-UI-UID;X-UI-UIDSOURCE"/>
	<Route Url="/systemresourceuicontrol/:id"			Method="GET"	RspMsg="QCMasterLib.Messages.Rsp.GenericUIRsp"				RspFieldObjects="Data:QCMasterLib.Tables.SystemResourceUIControl:single"			Headers="X-UI-FILTER;X-UI-SORT;X-UI-PAGE;X-UI-UID;X-UI-UIDSOURCE"/>
	<Route Url="/systemresourceuicontrol/:id"			Method="DELETE"	RspMsg="QCMasterLib.Messages.Rsp.GenericUIRsp"				Headers="X-UI-FILTER;X-UI-SORT;X-UI-PAGE;X-UI-UID;X-UI-UIDSOURCE"/>
</Routes>
}

/// This is the CORS request handler. User should override this method in their subclass
/// if they don't want the default behavior
ClassMethod OnHandleCorsRequest(pUrl As %String) As %Status
{
    #dim sc As %Status = $$$OK
    #dim tEx As %Exception.AbstractException
    Try {
        #; Get request origin and compare to loaded origins
        set tCO = $get(^corsconfig("origins"),"")
        set tOrigin=$Get(%request.CgiEnvs("HTTP_ORIGIN"))
        if ($listlength(tCO) = 0) {
	        do ..SetResponseHeaderIfEmpty("Access-Control-Allow-Origin","*")
        } else {
	        if ($listfind(tCO,tOrigin) = 0) {
	        	do ..SetResponseHeaderIfEmpty("Access-Control-Allow-Origin","")
	        } else {
		        do ..SetResponseHeaderIfEmpty("Access-Control-Allow-Origin",tOrigin)
    		}
        }

        #; Set allow credentials to be true
        do ..SetResponseHeaderIfEmpty("Access-Control-Allow-Credentials",$get(^corsconfig("allowcredentials"),"true"))

        #; Allow requested headers
        set tHeaders = $Get(%request.CgiEnvs("HTTP_ACCESS_CONTROL_REQUEST_HEADERS"))
        do ..SetResponseHeaderIfEmpty("Access-Control-Allow-Headers",tHeaders)

        #; Allow requested method
        set tMethod = $get(%request.CgiEnvs("HTTP_ACCESS_CONTROL_REQUEST_METHOD"))
        Do ..SetResponseHeaderIfEmpty("Access-Control-Allow-Methods",tMethod)

    } Catch (tEx) {
        Set sc = tEx.AsStatus()
    }
    Quit sc
}

}
