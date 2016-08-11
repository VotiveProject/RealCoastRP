#define Operation_AT                   "{4d7198}(Attention) {ffffff}"

enum hInfo
{
Float:hSafePos[6], //position and rotation safe
hSafeObject, //objectid
	hSafeInt,
	hSafeWorld,
	hSafeMoney,
	hSafeGun[4],
	hSafeAmmo[4]
}
new HouseInfo[MAX_HOUSES][hInfo];
new WeapName[47][] =
{
    "Empty","Brass Knuckless","Golf Club","Night Stick","Knife","Basketball Bat","Shovel","Pool Cue",
    "Katana","Chainsaw","Purple Dildo","White Dildo","Long White Dildo","White Dildo 2","Flowers","Cane",
    "Grenades","Tear Gas","Molotovs","Missle1","Missle2","Missle3","Pistol","Silenced Pistol","Desert Eagle","Shotgun",
    "Sawn Off Shotgun","Combat Shotgun","Micro UZI","MP5","AK-47","M4","Tec9","Rifle","Sniper Rifle","RPG",
    "Rocket Launcher","Flame Thrower","Minigun","Sachet Chargers","Detonator","Spry Paint","Fire Extinguer",
    "Camera","Nightvision Goggles","Thermal Goggles","Parachute"
};

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
		SPDHouseSafe(playerid);
	    return true;
	}
	
	return true;
}

stock SPDHouseSafe(playerid)
{
    new houseid = GetPlayerInHouse(playerid);
    if(!GetPlayerInterior(playerid) || houseid == -1) return SendClientMessage(playerid, -1, #Operation_AT"You not in the house!");
	new str[256];
	format(str, sizeof(str), "{ffffff}MONEY\n{ffffff}- \t{AFAFAF}ACCOUNT BALANCE IS %d$\n{ffffff}GUNS", HouseInfo[houseid][hSafeMoney]);
	for(new h = 0;h < 4;h++)
	{
	    if(HouseInfo[houseid][hSafeGun][h] > 0) format(str, sizeof(str), "%s\n{ffffff}-  \t{AFAFAF}%s (%d)", str, WeapName[HouseInfo[houseid][hSafeGun][h]], HouseInfo[houseid][hSafeAmmo][h]);
		else strcat(str, "\n{ffffff}-  \t{AFAFAF}Empty");
	}
	SPD(playerid, DIALOG_HOUSE_SAFE, DIALOG_STYLE_LIST, "House Safe", str, "Select", "Cancel");
	return true;
}
stock GetWData(playerid, gun, task)
{
	new getw, geta;
	GetPlayerWeaponData(playerid, GetGunSlot(gun), getw, geta);
	if(task == 0)
	{
		if (geta > 0 && getw == gun) return true;
		else return 404;
	}
	if(task == 1) RemovePlayerWeapon(playerid, gun);
	if(task == 2) return geta;
	if(task == 3) return getw;
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
		    case 3..6:
		        {
		            new houseid = GetPlayerInHouse(playerid);/*Change on your function*/
		            new index = listitem-3;
					if(HouseInfo[houseid][hSafeGun][index] > 0)
		            {
		                GivePlayerWeapon(playerid, HouseInfo[houseid][hSafeGun][index], HouseInfo[houseid][hSafeAmmo][index]);
		                HouseInfo[houseid][hSafeGun][index] = 0;
		                HouseInfo[houseid][hSafeAmmo][index] = 0;
		                new str[128];
						format(str, sizeof(str), #Operation_AT"You got %s (%d) from the safe", WeapName[HouseInfo[houseid][hSafeGun][index]], HouseInfo[houseid][hSafeAmmo][index]);
						SendClientMessage(playerid, -1, str);
						//You have to make a save system :)
						SPDHouseSafe(playerid);
		            }
		            else
		            {
		                if(GetPlayerWeapon(playerid) == 0) return SendClientMessage(playerid, -1, #Operation_AT"Take up arms");
		                HouseInfo[houseid][hSafeGun][index] = GetPlayerWeapon(playerid);
		                HouseInfo[houseid][hSafeAmmo][index] = GetWData(playerid, GetPlayerWeapon(playerid), 2);
		                RemovePlayerWeapon(playerid, GetPlayerWeapon(playerid));
		                new str[128];
						format(str, sizeof(str), #Operation_AT"You put %s (%d) away in the safe", WeapName[HouseInfo[houseid][hSafeGun][index]], HouseInfo[houseid][hSafeAmmo][index]);
						SendClientMessage(playerid, -1, str);
						//You have to make a save system :)
						SPDHouseSafe(playerid);
		            }
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
		    if(!response) return SPDHouseSafe(playerid);
	        if(!strlen(inputtext)) return SPD(playerid, DIALOG_HOUSE_SAFE3, DIALOG_STYLE_INPUT, "House Safe", "{ffffff}Enter the amount of money you want to put in the safe.", "Put", "Cancel");
	        if(strval(inputtext) > PlayerInfo[playerid][pCash]/*Change it*/) return SPD(playerid, DIALOG_HOUSE_SAFE3, DIALOG_STYLE_INPUT, "House Safe", "{ffffff}You don't have such amount\nEnter the amount of money you want to put in the safe.", "Put", "Cancel");
	        new houseid = GetPlayerInHouse(playerid);/*Change it*/
			HouseInfo[houseid][hSafeMoney] += strval(inputtext);
			PlayerInfo[playerid][pCash] -= strval(inputtext);/*Change it*/
			new str[128];
			format(str, sizeof(str), #Operation_AT"You put it in the safe %d$", strval(inputtext));
			SendClientMessage(playerid, -1, str);
			//You have to make a save system :)
			SPDHouseSafe(playerid);
			return true;
	    }
	case DIALOG_HOUSE_SAFE4:
	    {
		    if(!response) return SPDHouseSafe(playerid);
	        new houseid = GetPlayerInHouse(playerid);
			if(!strlen(inputtext)) return SPD(playerid, DIALOG_HOUSE_SAFE4, DIALOG_STYLE_INPUT, "House Safe", "{ffffff}Enter the amount of money that you want to get out of the safe.", "Take", "Cancel");
	        if(strval(inputtext) > HouseInfo[houseid][hSafeMoney]) return SPD(playerid, DIALOG_HOUSE_SAFE4, DIALOG_STYLE_INPUT, "House Safe", "{ffffff}You don't have such amount\nEnter the amount of money that you want to get out of the safe.", "Take", "Cancel");
	        HouseInfo[houseid][hSafeMoney] -= strval(inputtext);
			PlayerInfo[playerid][pCash] += strval(inputtext);/*Change it*/
			new str[128];
			format(str, sizeof(str), #Operation_AT"You got %d$ from safe", strval(inputtext));
			SendClientMessage(playerid, -1, str);
			//You have to make a save system :)
			SPDHouseSafe(playerid);
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
