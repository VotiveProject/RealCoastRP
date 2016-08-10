#define Operation_AT                   "{4d7198}(Attention) {ffffff}"

enum hInfo
{
Float:hSafePos[6], //position and rotation safe
hSafeObject, //objectid
	hSafeInt,
	hSafeWorld,
	hSafeMoney
}
new HouseInfo[MAX_HOUSES][hInfo];

//GetPlayerInHouse(playerid) probably GetPlayerVirtualWorld(playerid);

if(StrCmp(cmd, "/housesafe"))
{
	new houseid = GetPlayerInHouse(playerid);/*Change on your function and the condition itself houseid == -1*/
	if(!GetPlayerInterior(playerid) || houseid == -1) return SendClientMessage(playerid, -1, #Operation_AT"You not in the house!");
	if(HouseInfo[houseid][hSafePos][0] == 0.0 && HouseInfo[houseid][hSafePos][1] == 0.0 && HouseInfo[houseid][hSafePos][2] == 0.0)
	{//Home safe installations
	    new Float:x, Float:y, Float:z, Float:rz;
		GetPlayerPos(playerid, x, y, z);
		GetPlayerFacingAngle(playerid, rz);
	    x += 2.5*floatsin(-rz, degrees);
		y += 2.5*floatcos(-rz, degrees);
		new ball = CreatePlayerObject(playerid, 2332, x, y, z, 0.00, 90.00, 0.00);
		EditPlayerObject(playerid, ball);
		SetPVarInt(playerid, "SafeInstallation", 1);
	    return true;
	}
	new str[256];
	format(str, sizeof(str), "{ffffff}MONEY\n{ffffff}- \t{AFAFAF}ACCOUNT BALANCE IS %d$", HouseInfo[houseid][hSafeMoney]);
	SPD(playerid, DIALOG_HOUSE_SAFE, DIALOG_STYLE_LIST, "House Safe", str, "Select", "Cancel");
	return true;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
	case DIALOG_HOUSE_SAFE:
		{
		    if(!response) return true;
		    switch(listitem)
		    {
		    case 1:
		        {
		            SPD(playerid, DIALOG_HOUSE_SAFE2, DIALOG_STYLE_LIST, "House Safe", "{ffffff}- {AFAFAF}PUT MONEY\n{ffffff}- {AFAFAF}TAKE MONEY", "Select", "Cancel");
		        }
		    default: return true;
		    }
		    return true;
		}
	case DIALOG_HOUSE_SAFE2:
	    {
	    	if(!response) return true;
	    	if(listitem == 0) SPD(playerid, DIALOG_HOUSE_SAFE3, DIALOG_STYLE_INPUT, "House Safe", "{ffffff}Enter the amount of money you want to put in the safe.", "Put", "Cancel");
		    else SPD(playerid, DIALOG_HOUSE_SAFE4, DIALOG_STYLE_INPUT, "House Safe", "{ffffff}Enter the amount of money that you want to get out of the safe.", "Take", "Cancel");
			return true;
	    }
	case DIALOG_HOUSE_SAFE3:
	    {
		    if(!response) return true;
	        if(!strlen(inputtext)) return SPD(playerid, DIALOG_HOUSE_SAFE3, DIALOG_STYLE_INPUT, "House Safe", "{ffffff}Enter the amount of money you want to put in the safe.", "Put", "Cancel");
	        if(strval(inputtext) > PlayerInfo[playerid][pCash]/*Change it*/) return SPD(playerid, DIALOG_HOUSE_SAFE3, DIALOG_STYLE_INPUT, "House Safe", "{ffffff}You don't have such amount\nEnter the amount of money you want to put in the safe.", "Put", "Cancel");
	        new houseid = GetPlayerInHouse(playerid);/*Change it*/
			HouseInfo[houseid][hSafeMoney] += strval(inputtext);
			PlayerInfo[playerid][pCash] -= strval(inputtext);/*Change it*/
			new str[128];
			format(str, sizeof(str), #Operation_AT"You put it in the safe %d$", strval(inputtext));
			SendClientMessage(playerid, -1, str);
			//You have to make a save system :)
			return true;
	    }
	case DIALOG_HOUSE_SAFE4:
	    {
		    if(!response) return true;
	        new houseid = GetPlayerInHouse(playerid);
			if(!strlen(inputtext)) return SPD(playerid, DIALOG_HOUSE_SAFE4, DIALOG_STYLE_INPUT, "House Safe", "{ffffff}Enter the amount of money that you want to get out of the safe.", "Take", "Cancel");
	        if(strval(inputtext) > HouseInfo[houseid][hSafeMoney]) return SPD(playerid, DIALOG_HOUSE_SAFE4, DIALOG_STYLE_INPUT, "House Safe", "{ffffff}You don't have such amount\nEnter the amount of money that you want to get out of the safe.", "Take", "Cancel");
	        HouseInfo[houseid][hSafeMoney] -= strval(inputtext);
			PlayerInfo[playerid][pCash] += strval(inputtext);/*Change it*/
			new str[128];
			format(str, sizeof(str), #Operation_AT"You got %d$ from safe", strval(inputtext));
			SendClientMessage(playerid, -1, str);
			//You have to make a save system :)
			return true;
	    }
	}
	return true;
}

public OnPlayerEditObject(playerid, playerobject, objectid, response, Float:fX, Float:fY, Float:fZ, Float:fRotX, Float:fRotY, Float:fRotZ)
{
	if(GetPVarInt(playerid, "SafeInstallation"))
	{
	    new houseid = GetPlayerInHouse(playerid);/*Change on your function and the condition itself houseid == -1*/
		if(!GetPlayerInterior(playerid) || houseid == -1)
		{
			SendClientMessage(playerid, -1, #Operation_AT"You not in the house!");
			SetPVarInt(playerid, "SafeInstallation", 0);
			DestroyPlayerObject(playerid, objectid);
			return true;
	    }
		if(response == EDIT_RESPONSE_FINAL)
		{
			SetPVarInt(playerid, "SafeInstallation", 0);
			DestroyPlayerObject(playerid, objectid);
			SendClientMessage(playerid, -1, #Operation_AT"Successful!");
			HouseInfo[houseid][hSafeObject] = CreateDynamicObject(2332, fX, fY, fZ, fRotX, fRotY, fRotZ, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid));
			HouseInfo[houseid][hSafePos][0] = fX;
			HouseInfo[houseid][hSafePos][1] = fY;
			HouseInfo[houseid][hSafePos][2] = fZ;
			HouseInfo[houseid][hSafePos][3] = fRotX;
			HouseInfo[houseid][hSafePos][4] = fRotY;
			HouseInfo[houseid][hSafePos][5] = fRotZ;
			HouseInfo[houseid][hSafeInt] = GetPlayerInterior(playerid);
			HouseInfo[houseid][hSafeWorld] = GetPlayerVirtualWorld(playerid);
			HouseInfo[houseid][hSafeMoney] = 0;
			Streamer_Update(playerid); // Comment out this if you are not using a streamer
			//You have to make a save system :)
		}
		else if(response == EDIT_RESPONSE_CANCEL)
		{
			SetPVarInt(playerid, "SafeInstallation", 0);
			DestroyPlayerObject(playerid, objectid);
		}
		return true;
	}
	return true;
}
