#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>

// varianthax_t m_Value
#define Union_Val_offset      	view_as<Address>(0x00)
#define fieldType_offset      	view_as<Address>(0x10)


// CBaseEntityOutput
#define m_Value_offset        	view_as<Address>(0x00)
#define m_ActionList_offset   	view_as<Address>(0x14)


// CEventAction
#define m_iTarget_offset        view_as<Address>(0x00)
#define m_iTargetInput_offset   view_as<Address>(0x04)
#define m_iParameter_offset     view_as<Address>(0x08)
#define m_flDelay_offset        view_as<Address>(0x0C)
#define m_nTimesToFire_offset   view_as<Address>(0x10)
#define m_iIDStamp_offset       view_as<Address>(0x14)
#define m_pNext_offset          view_as<Address>(0x18)


enum
{
	FIELD_VOID = 0,			// No type or value
	FIELD_FLOAT,			// Any floating point value
	FIELD_STRING,			// A string ID (return from ALLOC_STRING)
	FIELD_VECTOR,			// Any vector, QAngle, or AngularImpulse
	FIELD_QUATERNION,		// A quaternion
	FIELD_INTEGER,			// Any integer or enum
	FIELD_BOOLEAN,			// boolean, implemented as an int, I may use this as a hint for compression
	FIELD_SHORT,			// 2 byte integer
	FIELD_CHARACTER,		// a byte
	FIELD_COLOR32,			// 8-bit per channel r,g,b,a (32bit color)
	FIELD_EMBEDDED,			// an embedded object with a datadesc, recursively traverse and embedded class/structure based on an additional typedescription
	FIELD_CUSTOM,			// special type that contains function pointers to it's read/write/parse functions

	FIELD_CLASSPTR,			// CBaseEntity *
	FIELD_EHANDLE,			// Entity handle
	FIELD_EDICT,			// edict_t *

	FIELD_POSITION_VECTOR,	// A world coordinate (these are fixed up across level transitions automagically)
	FIELD_TIME,				// a floating point time (these are fixed up automatically too!)
	FIELD_TICK,				// an integer tick count( fixed up similarly to time)
	FIELD_MODELNAME,		// Engine string that is a model name (needs precache)
	FIELD_SOUNDNAME,		// Engine string that is a sound name (needs precache)

	FIELD_INPUT,			// a list of inputed data fields (all derived from CMultiInputVar)
	FIELD_FUNCTION,			// A class function pointer (Think, Use, etc)

	FIELD_VMATRIX,			// a vmatrix (output coords are NOT worldspace)

	// NOTE: Use float arrays for local transformations that don't need to be fixed up.
	FIELD_VMATRIX_WORLDSPACE,// A VMatrix that maps some local space to world space (translation is fixed up on level transitions)
	FIELD_MATRIX3X4_WORLDSPACE,	// matrix3x4_t that maps some local space to world space (translation is fixed up on level transitions)

	FIELD_INTERVAL,			// a start and range floating point interval ( e.g., 3.2->3.6 == 3.2 and 0.4 )
	FIELD_MODELINDEX,		// a model index
	FIELD_MATERIALINDEX,	// a material index (using the material precache string table)
	
	FIELD_VECTOR2D,			// 2 floats

	FIELD_TYPECOUNT,		// MUST BE LAST
};

Handle g_hDeleteElement;

public Plugin myinfo =
{
	name		= "OutputInfo",
	author		= "Dolly (Credits to Botox & Addie)",
	description	= "Read entity outputs",
	version		= "1.0.0",
	url			= "https://nide.gg"	
};

public APLRes AskPluginLoad2(Handle myPlugin, bool late, char[] error, int err_max)
{
	CreateNative("GetOutputCount", Native_GetOutputCount);
	CreateNative("GetOutputTarget", Native_GetOutputTarget);
	CreateNative("GetOutputTargetInput", Native_GetOutputTargetInput);
	CreateNative("GetOutputParameter", Native_GetOutputParameter);
	CreateNative("GetOutputDelay", Native_GetOutputDelay);
	CreateNative("GetOutputRefires", Native_GetOutputRefires);
	CreateNative("GetOutputValue", Native_GetOutputValue);
	CreateNative("GetOutputValueFloat", Native_GetOutputValueFloat);
	CreateNative("GetOutputValueString", Native_GetOutputValueString);
	CreateNative("GetOutputValueVector", Native_GetOutputValueVector);
	CreateNative("FindOutput", Native_FindOutput);
	CreateNative("DeleteOutput", Native_DeleteOutput);
	CreateNative("DeleteAllOutputs", Native_DeleteAllOutputs);
}

int Native_GetOutputCount(Handle plugin, int params)
{
	int entity = GetNativeCell(1);

	char output[256];
	GetNativeString(2, output, sizeof(output));

	return GetOutputCount(entity, output);
}

int Native_GetOutputTarget(Handle plugin, int params)
{
	int entity = GetNativeCell(1);

	char output[256];
	GetNativeString(2, output, sizeof(output));

	int index = GetNativeCell(3);

	int maxlen = GetNativeCell(5);

	char[] target = new char[maxlen];
	GetNativeString(4, target, maxlen);

	int len = GetOutputTarget(entity, output, index, target, maxlen);
	if (len)
	{
		SetNativeString(4, target, maxlen);
	}

	return len;
}

int Native_GetOutputTargetInput(Handle plugin, int params)
{
	int entity = GetNativeCell(1);

	char output[256];
	GetNativeString(2, output, sizeof(output));

	int index = GetNativeCell(3);

	int maxlen = GetNativeCell(5);

	char[] targetInput = new char[maxlen];
	GetNativeString(4, targetInput, maxlen);

	int len = GetOutputTargetInput(entity, output, index, targetInput, maxlen);
	if (len)
	{
		SetNativeString(4, targetInput, maxlen);
	}

	return len;
}

int Native_GetOutputParameter(Handle plugin, int params)
{
	int entity = GetNativeCell(1);

	char output[256];
	GetNativeString(2, output, sizeof(output));

	int index = GetNativeCell(3);

	int maxlen = GetNativeCell(5);

	char[] parameter = new char[maxlen];
	GetNativeString(4, parameter, maxlen);

	int len = GetOutputTargetInput(entity, output, index, parameter, maxlen);
	if (len)
	{
		SetNativeString(4, parameter, maxlen);
	}

	return len;
}

any Native_GetOutputDelay(Handle plugin, int params)
{
	int entity = GetNativeCell(1);

	char output[256];
	GetNativeString(2, output, sizeof(output));

	int index = GetNativeCell(3);

	return GetOutputDelay(entity, output, index);
}

int Native_GetOutputRefires(Handle plugin, int params)
{
	int entity = GetNativeCell(1);

	char output[256];
	GetNativeString(2, output, sizeof(output));

	int index = GetNativeCell(3);

	return GetOutputRefires(entity, output, index);
}

int Native_GetOutputValue(Handle plugin, int params)
{
	int entity = GetNativeCell(1);

	char output[256];
	GetNativeString(2, output, sizeof(output));

	return GetOutputValue(entity, output);
}

any Native_GetOutputValueFloat(Handle plugin, int params)
{
	int entity = GetNativeCell(1);

	char output[256];
	GetNativeString(2, output, sizeof(output));

	return GetOutputValueFloat(entity, output);
}

int Native_GetOutputValueString(Handle plugin, int params)
{
	int entity = GetNativeCell(1);

	char output[256];
	GetNativeString(2, output, sizeof(output));

	int maxlen = GetNativeCell(4);

	char[] value = new char[maxlen];
	GetNativeString(3, value, maxlen);

	int len = GetOutputValueString(entity, output, value, maxlen);
	if (len)
	{
		SetNativeString(3, value, maxlen);
	}
	
	return len;
}

int Native_GetOutputValueVector(Handle plugin, int params)
{
	int entity = GetNativeCell(1);

	char output[256];
	GetNativeString(2, output, sizeof(output));

	float value[3];
	int res = view_as<int>(GetOutputValueFloat(entity, output, true, value));
	if (res)
	{
		SetNativeArray(3, value, sizeof(value));
	}
	
	return res;
}

int Native_FindOutput(Handle plugin, int params)
{
	int entity = GetNativeCell(1);

	char output[256];
	GetNativeString(2, output, sizeof(output));

	int startIndex = GetNativeCell(3);

	char target[256];
	GetNativeString(4, target, sizeof(target));

	char targetInput[256];
	GetNativeString(5, targetInput, sizeof(targetInput));

	char parameter[256];
	GetNativeString(6, parameter, sizeof(parameter));

	float delay = view_as<float>(GetNativeCell(7));
	int refires = GetNativeCell(8);

	return FindOutput(entity, output, startIndex, target, targetInput, parameter, delay, refires);
}

int Native_DeleteOutput(Handle plugin, int params)
{
	int entity = GetNativeCell(1);

	char output[256];
	GetNativeString(2, output, sizeof(output));

	int index = GetNativeCell(3);

	return DeleteOutput(entity, output, index);
}

int Native_DeleteAllOutputs(Handle plugin, int params)
{
	int entity = GetNativeCell(1);

	char output[256];
	GetNativeString(2, output, sizeof(output));

	return DeleteAllOutputs(entity, output);
}

public void OnPluginStart()
{
	RegConsoleCmd("sm_outputtest", Command_Test);

	GameData gd = new GameData("outputinfo.games");
	if (gd == null)
	{
		LogError("[OutputInfo] Could not find gamedata file, some features may be negelcted!");
	}
	else
	{
		StartPrepSDKCall(SDKCall_Raw);
		PrepSDKCall_SetFromConf(gd, SDKConf_Signature, "CEventAction__operator_delete");
		PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Pointer);

		g_hDeleteElement = EndPrepSDKCall();
		if (g_hDeleteElement == null)
		{
			LogError("[OutputInfo] Could not get a good SDKCall handle for CEventAction__operator_delete, DeleteElement will not work.");
		}

		delete gd;
	}
}

Action Command_Test(int client, int args)
{
	if (args <= 0)
		return Plugin_Handled;

	char classname[32];
	GetCmdArg(1, classname, sizeof(classname));
	int entity = FindEntityByClassname(-1, classname);

	if (entity == -1)
	{
		PrintToChatAll("No entity");
		return Plugin_Handled;
	}

	int count = GetOutputCount(entity, "m_OnHitMax");

	PrintToChatAll("*****m_OnHitMax******");
	PrintToChatAll("Count: %d", count);

	char target[32];
	char targetInput[32];
	char parameter[128];

	for (int i = 0; i < count; i++)
	{
		GetOutputTarget(entity, "m_OnHitMax", i, target, sizeof(target));
		GetOutputTargetInput(entity, "m_OnHitMax", i, targetInput, sizeof(targetInput));
		GetOutputParameter(entity, "m_OnHitMax", i, parameter, sizeof(parameter));
	
		float delay = GetOutputDelay(entity, "m_OnHitMax", i);
	
		PrintToChatAll("Target: %s\nTargetInput: %s", target, targetInput);
		PrintToChatAll("Parameter: %s\nDelay: %.2f", parameter, delay);
		PrintToChatAll("Refires: %d", GetOutputRefires(entity, "m_OnHitMax", i));
	}

	if (args > 1)
	{
		PrintToChatAll("Deleting all outputs: m_OnHitMax");
		DeleteAllOutputs(entity, "m_OnHitMax");
	}

	return Plugin_Handled;
}

Address GetOutputAddress(int entity, const char[] output)
{
	int outputOffset = FindDataMapInfo(entity, output);
	if (outputOffset == -1)
		return view_as<Address>(0x0);

	Address outputAddr = GetEntityAddress(entity) + view_as<Address>(outputOffset);
	if (!outputAddr)
		return view_as<Address>(0x0);
	
	return outputAddr;
}

Address GetOutputActionList(Address outputAddr)
{
	return LoadFromAddress(outputAddr + m_ActionList_offset, NumberType_Int32);
}

int GetOutputCount(int entity, const char[] output)
{
	Address outputAddr = GetOutputAddress(entity, output);
	if (!outputAddr)
		return 0;

	//PrintToChatAll("Found output address: %X", outputAddr);

	Address actionList = GetOutputActionList(outputAddr);
	if (!actionList)
	{
		//PrintToChatAll("Invalid action list...");
		return 0;
	}

	//PrintToChatAll("Found actionList address: %X", actionList);

	int count = 0;
	while (actionList)
	{
		actionList = LoadFromAddress(actionList + m_pNext_offset, NumberType_Int32);
		count++;
	}

	return count;
}

int GetOutputTarget(int entity, const char[] output, int index, char[] target, int maxlen)
{
	Address outputAddr = GetOutputAddress(entity, output);
	if (!outputAddr)
		return 0;

	Address actionList = GetOutputActionList(outputAddr);
	if (!actionList)
		return 0;

	int count = 0;
	while (actionList)
	{
		if (count == index)
		{
			Address m_iTarget = LoadFromAddress(actionList + m_iTarget_offset, NumberType_Int32);
			return StringtToCharArray(m_iTarget, target, maxlen, true);
		}

		actionList = LoadFromAddress(actionList + m_pNext_offset, NumberType_Int32);
		count++;
	}

	return 0;
}

int GetOutputTargetInput(int entity, const char[] output, int index, char[] targetInput, int maxlen)
{
	Address outputAddr = GetOutputAddress(entity, output);
	if (!outputAddr)
		return 0;

	Address actionList = GetOutputActionList(outputAddr);
	if (!actionList)
		return 0;

	int count = 0;
	while (actionList)
	{
		if (count == index)
		{
			Address m_iTargetInput = LoadFromAddress(actionList + m_iTargetInput_offset, NumberType_Int32);
			return StringtToCharArray(m_iTargetInput, targetInput, maxlen, true);
		}

		actionList = LoadFromAddress(actionList + m_pNext_offset, NumberType_Int32);
		count++;
	}

	return 0;
}

int GetOutputParameter(int entity, const char[] output, int index, char[] parameter, int maxlen)
{
	Address outputAddr = GetOutputAddress(entity, output);
	if (!outputAddr)
		return 0;

	Address actionList = GetOutputActionList(outputAddr);
	if (!actionList)
		return 0;

	int count = 0;
	while (actionList)
	{
		if (count == index)
		{
			Address m_iParameter = LoadFromAddress(actionList + m_iParameter_offset, NumberType_Int32);
			return StringtToCharArray(m_iParameter, parameter, maxlen, true);
		}

		actionList = LoadFromAddress(actionList + m_pNext_offset, NumberType_Int32);
		count++;
	}

	return 0;
}

float GetOutputDelay(int entity, const char[] output, int index)
{
	Address outputAddr = GetOutputAddress(entity, output);
	if (!outputAddr)
		return -1.0;

	Address actionList = GetOutputActionList(outputAddr);
	if (!actionList)
		return -1.0;

	int count = 0;
	while (actionList)
	{
		if (count == index)
			return view_as<float>(LoadFromAddress(actionList + m_flDelay_offset, NumberType_Int32));

		actionList = LoadFromAddress(actionList + m_pNext_offset, NumberType_Int32);
		count++;
	}

	return -1.0;
}

int GetOutputRefires(int entity, const char[] output, int index)
{
	Address outputAddr = GetOutputAddress(entity, output);
	if (!outputAddr)
		return 0;

	Address actionList = GetOutputActionList(outputAddr);
	if (!actionList)
		return 0;

	int count = 0;
	while (actionList)
	{
		if (count == index)
			return view_as<int>(LoadFromAddress(actionList + m_nTimesToFire_offset, NumberType_Int32));

		actionList = LoadFromAddress(actionList + m_pNext_offset, NumberType_Int32);
		count++;
	}

	return 0;
}

int GetOutputValue(int entity, const char[] output)
{
	Address outputAddr = GetOutputAddress(entity, output);
	if (!outputAddr)
		return 0;

	int fieldType = LoadFromAddress(outputAddr + fieldType_offset, NumberType_Int32);
	switch (fieldType)
	{
		case 
			FIELD_TICK,
			FIELD_MODELINDEX,
			FIELD_MATERIALINDEX,
			FIELD_INTEGER,
			FIELD_COLOR32,
			FIELD_SHORT,
			FIELD_CHARACTER,
			FIELD_BOOLEAN:
		{
			return LoadFromAddress(outputAddr + Union_Val_offset, NumberType_Int32);
		}
	}

	ThrowError("Entity '%X': %s value is not an integer (%d)", GetEntityAddress(entity), output, fieldType);
	return 0;
}

float GetOutputValueFloat(int entity, const char[] output, bool isVector = false, float vec[3] = {0.0, 0.0, 0.0})
{
	Address outputAddr = GetOutputAddress(entity, output);
	if (!outputAddr)
		return 0.0;

	int fieldType = LoadFromAddress(outputAddr + fieldType_offset, NumberType_Int32);
	switch (fieldType)
	{
		case 
			FIELD_FLOAT,
			FIELD_TIME:
		{
			if (!isVector)
			{
				return LoadFromAddress(outputAddr + Union_Val_offset, NumberType_Int32);
			}
			else
			{
				Address baseAddr = outputAddr + Union_Val_offset;
				vec[0] = LoadFromAddress(baseAddr + view_as<Address>(0x0), NumberType_Int32);
				vec[1] = LoadFromAddress(baseAddr + view_as<Address>(0x4), NumberType_Int32);
				vec[2] = LoadFromAddress(baseAddr + view_as<Address>(0x8), NumberType_Int32);
				return 1.0;
			}
		}
	}

	ThrowError("Entity '%X': %s value is not a float (%d)", GetEntityAddress(entity), output, fieldType);
	return 0.0;
}

int GetOutputValueString(int entity, const char[] output, char[] value, int maxlen)
{
	Address outputAddr = GetOutputAddress(entity, output);
	if (!outputAddr)
		return 0;

	int fieldType = LoadFromAddress(outputAddr + fieldType_offset, NumberType_Int32);
	switch (fieldType)
	{
		case 
			FIELD_CHARACTER,
	 		FIELD_STRING,
	 		FIELD_MODELNAME,
		 	FIELD_SOUNDNAME:
		{
			return StringtToCharArray(outputAddr + Union_Val_offset, value, maxlen, true);
		}
	}

	ThrowError("Entity '%X': %s value is not a string (%d)", GetEntityAddress(entity), output, fieldType);
	return 0;
}

int FindOutput(int entity,
				const char[] output,
				int startIndex,
				const char[] target = "",
				const char[] targetInput = "",
				const char[] parameter = "",
				float delay = -1.0,
				int timesToFire = 0)
{
	Address outputAddr = GetOutputAddress(entity, output);
	if (!outputAddr)
		return -1;

	Address actionList = GetOutputActionList(outputAddr);
	if (!actionList)
		return -1;

	int count = 0;
	while (actionList)
	{
		count++;
		if (startIndex > 0)
		{
			startIndex--;
			continue;
		}

		Address oldActionList = actionList;
		actionList = LoadFromAddress(actionList + m_pNext_offset, NumberType_Int32);

		if (target[0])
		{
			Address m_iTarget = oldActionList + m_iTarget_offset;
	
			char thisTarget[64];
			StringtToCharArray(m_iTarget, thisTarget, sizeof(thisTarget), true);

			if (strcmp(target, thisTarget) != 0)
				continue;
		}
		
		if (targetInput[0])
		{
			Address m_iTargetInput = oldActionList + m_iTargetInput_offset;
	
			char thisTargetInput[64];
			StringtToCharArray(m_iTargetInput, thisTargetInput, sizeof(thisTargetInput), true);

			if (strcmp(targetInput, thisTargetInput) != 0)
				continue;
		}

		if (parameter[0])
		{
			Address m_iParameter = oldActionList + m_iParameter_offset;
	
			char thisParameter[256];
			StringtToCharArray(m_iParameter, thisParameter, sizeof(thisParameter), true);

			if (strcmp(parameter, thisParameter) != 0)
				continue;
		}

		if (delay != -1.0)
		{
			Address m_flDelay = oldActionList + m_flDelay_offset;

			float thisDelay = LoadFromAddress(m_flDelay, NumberType_Int32);
			if (delay != thisDelay)
				continue;
		}

		if (timesToFire != 0)
		{
			Address m_nTimesToFire = oldActionList + m_nTimesToFire_offset;

			int thisTimesToFire = LoadFromAddress(m_nTimesToFire, NumberType_Int32);
			if (timesToFire != thisTimesToFire)
				continue;
		}

		return count - 1;
	}

	return -1;
}

bool DeleteOutput(int entity, const char[] output, int index)
{
	if (g_hDeleteElement == null)
	{
		ThrowError("[OutputInfo] Invalid SDKCall Handle, cannot delete event actions");
	}

	Address outputAddr = GetOutputAddress(entity, output);
	if (!outputAddr)
		return false;

	Address actionList = GetOutputActionList(outputAddr);
	if (!actionList)
		return false;

	Address prevEvent = Address_Null;
	Address curEvent = Address_Null;
	int count = 0;
	while (actionList)
	{
		if (count == index)
		{
			curEvent = actionList;
			break;
		}

		prevEvent = actionList;
		actionList = LoadFromAddress(prevEvent + m_pNext_offset, NumberType_Int32);
		count++;
	}

	if (curEvent == Address_Null)
		return false;

	if (prevEvent != Address_Null)
		StoreToAddress(prevEvent + m_pNext_offset, curEvent + m_pNext_offset, NumberType_Int32);
	else
		StoreToAddress(outputAddr + m_ActionList_offset, curEvent + m_pNext_offset, NumberType_Int32);

	SDKCall(g_hDeleteElement, curEvent, curEvent);
	return false;
}

int DeleteAllOutputs(int entity, const char[] output)
{
	if (g_hDeleteElement == null)
	{
		ThrowError("[OutputInfo] Invalid SDKCall Handle, cannot delete event actions");
		return 0;
	}

	Address outputAddr = GetOutputAddress(entity, output);
	if (!outputAddr)
		return 0;

	Address actionList = GetOutputActionList(outputAddr);
	if (!actionList)
		return 0;

	int count = 0;
	Address nextEvent = actionList;
	StoreToAddress(outputAddr + m_ActionList_offset, 0, NumberType_Int32);

	while (nextEvent)
	{
		Address thisEvent = nextEvent;
		nextEvent = LoadFromAddress(nextEvent + m_pNext_offset, NumberType_Int32);
		SDKCall(g_hDeleteElement, thisEvent, thisEvent);
		count++;
	}

	return count;
}

int StringtToCharArray(Address addr, char[] buffer, int maxlen, bool allowNull = false)
{
	if (addr == Address_Null)
	{
		if (!allowNull)
		{
			ThrowError("[OutputInfo] string_t address is null");
		}
		else
		{
			buffer[0] = '\0';
			return 0;
		}
	}

	if (maxlen <= 0)
		ThrowError("[OutputInfo] Buffer size is negative or zero");

	int max = maxlen-1;
	int i = 0;
	while (i < max)
	{
		char c = view_as<char>(LoadFromAddress(addr + view_as<Address>(i), NumberType_Int8));
		if (c == '\0')
			return i;

		buffer[i++] = c;
	}

	buffer[i] = '\0';
	return i;
}
