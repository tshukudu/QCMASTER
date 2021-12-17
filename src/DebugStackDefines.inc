ROUTINE DebugStackDefines [Type=INC]
#Include %occIO

#define InitialiseDebugStack	Set tDebugStack = $get(tDebugStack, ##class(MasterLib.Utils.Exception.DebugStack).%New())
#define AddDebugInfo(%Value)	Do:($get(^debugoff,0) = 0) tDebugStack.AddInfoToStack($$$CurrentClass, $$$CurrentMethod, %Value)  if ($get(%gOutputDebAsAdded)=1) {  w %Value,!  }
#define AddDebugObjDump(%Obj)	Do:($get(^debugoff,0) = 0) tDebugStack.AddObjectToStack($$$CurrentClass, $$$CurrentMethod, %Obj)
#define AddDebugStack(%Stack)	Do:($get(^debugoff,0) = 0) tDebugStack.AddStackToStack(%Stack)
#define DebugStackToString		tDebugStack.ToString()
#define DebugStackVariableName	tDebugStack
#define DebugVerbosityOff set %gOutputDebAsAdded=1
#define DebugVerbosityOn kill %gOutputDebAsAdded
