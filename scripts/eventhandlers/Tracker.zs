/*
 * Copyright (c) 2021 AFADoomer
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
**/

class DamageInfo
{
	PlayerInfo player;
	Actor attacker;
	String infoname;
	Vector3 attackerpos;
	int distance;
	int angle;
	int timeout;
	double alpha;
	Color clr;
}

class DamageTracker : EventHandler
{
	Array<DamageInfo> events;
	Color blend[players.Size()];
	Color oldblend[players.Size()];
	int lasttick;
	AchievementTracker achievements;

	override void WorldThingDamaged(WorldEvent e)
	{
		let player = e.thing.player;

		if (!player) { return; }

		if (player.mo)
		{
			Actor attacker = null;
			String infoname = "";
			Color flashclr = player.mo.GetPainFlash();

			if (flashclr.a != 0) { return; }

			// If the attacker is still alive (and not the player), use their data
			if (player.attacker)
			{
				if (player.attacker == player.mo)
				{
					infoname = "Player " .. player.mo.PlayerNumber();
				}
				else { attacker = player.attacker; }
			}
			else // Otherwise, treat it as world-induced damage
			{
				infoname = "World";
			}

			DamageInfo info;

			// Save information about a new attacker if it isn't already being tracked
			int attackerindex = FindAttacker(player, attacker, infoname);
			if (attackerindex == events.Size())
			{
				info = New("DamageInfo");
				info.attacker = attacker;
				info.infoname = infoname;
				info.player = player;
				info.alpha = 0.0;

				events.Push(info);
			}
			else { info = events[attackerindex]; }

			// And save additional information
			if (info)
			{
				info.clr = flashclr;

				if (attacker)
				{
					info.attackerpos = attacker.pos;
					info.angle = int(360 - player.mo.deltaangle(player.mo.angle, player.mo.AngleTo(attacker)));
				}
				else  // If no attacker actor, assume it was something behind the player's current movement direction that caused the damage (e.g., explosion)
				{
					info.attackerpos = player.mo.pos - player.mo.vel;
					info.angle = int(360 - player.mo.deltaangle(player.mo.angle, atan2(-player.mo.vel.y, -player.mo.vel.x)));
				}
				info.distance = clamp(int(56 - level.Vec3Diff(player.mo.pos, info.attackerpos).length() / 64), 0, 64);
				info.timeout = level.time + min(e.damage * 4, 100);
			}

			if (achievements) { achievements.damaged[player.mo.PlayerNumber()] = true; }
		}
	}

	override void WorldTick()
	{
		if (!achievements) { achievements = AchievementTracker(EventHandler.Find("AchievementTracker")); }

		for (int i = 0; i < events.Size(); i++)
		{
			if (events[i].timeout < level.time) { events.Delete(i); }
			else if (events[i].timeout < level.time + 35) { events[i].alpha = (events[i].timeout - level.time) / 35.0; }
			else if (events[i].alpha < 1.0) { events[i].alpha = min(1.0, events[i].alpha + 0.1); }
			else { events[i].alpha = 1.0; }
		}

		lasttick = level.time;
	}

	int FindAttacker(PlayerInfo player, Actor attacker, String infoname = "")
	{
		for (int i = 0; i < events.Size(); i++)
		{
			if (events[i].player != player) { continue; }

			if (attacker && events[i].attacker == attacker) { return i; }
			else if (infoname.length() && events[i].infoname ~== infoname) { return i; }
		}

		return events.Size();
	}

	// Lifted from https://github.com/coelckers/gzdoom/blob/4bcea0ab783c667940008a5cab6910b7a826f08c/src/rendering/2d/v_blend.cpp#L59
	static const uint DamageToAlpha[] =
	{
		0,   8,  16,  23,  30,  36,  42,  47,  53,  58,  62,  67,  71,  75,  79,
		83,  87,  90,  94,  97, 100, 103, 107, 109, 112, 115, 118, 120, 123, 125,
		128, 130, 133, 135, 137, 139, 141, 143, 145, 147, 149, 151, 153, 155, 157,
		159, 160, 162, 164, 165, 167, 169, 170, 172, 173, 175, 176, 178, 179, 181,
		182, 183, 185, 186, 187, 189, 190, 191, 192, 194, 195, 196, 197, 198, 200,
		201, 202, 203, 204, 205, 206, 207, 209, 210, 211, 212, 213, 214, 215, 216,
		217, 218, 219, 220, 221, 221, 222, 223, 224, 225, 226, 227, 228, 229, 229,
		230, 231, 232, 233, 234, 235, 235, 236, 237
	};

	static Color, double, int GetDamageBlend(PlayerInfo player)
	{
		DamageTracker damagehandler = DamageTracker(EventHandler.Find("DamageTracker"));

		if (!damagehandler) { return 0x0, 0.0, 1; }

		String temp;
		int pnum = player.mo.PlayerNumber();
		Color clr = damagehandler.blend[pnum];

		int damageamount = 0;
		for (int i = 0; i < damagehandler.events.Size(); i++)
		{
			if (damagehandler.events[i].player == player)
			{
				damageamount += damagehandler.GetAmount(i);
			}
		}

		if (!damageamount)
		{
			damagehandler.blend[pnum] = 0x0;
			damagehandler.oldblend[pnum] = 0x0;
			return 0x0, 0.0, 1; // If no damage found, return early
		}

		damagehandler.oldblend[pnum] = damagehandler.blend[pnum];

		double blendalpha = clamp((DamageTracker.DamageToAlpha[clamp(damageamount, 0, 113)] / 255.0) * blood_fade_scalar * 1.25, 0.0, 1.0);
		
		for (int i = 0; i < damagehandler.events.Size(); i++)
		{
			if (damagehandler.events[i].player == player)
			{
				let d = damagehandler.events[i];

				double percentage = damagehandler.GetAmount(i) * 1.0 / damageamount;
				clr = damagehandler.AddBlend(clr, d.clr, percentage);

				if (boa_debugscreenblends)
				{
					String attackername = "World/Player";
					if (d.attacker) { attackername = d.attacker.getclassname(); }
					if (temp.length()) { temp = temp .. ",\n"; }
					temp = temp .. string.format("> Damage from %s: %x (%.2f) => %x", attackername, d.clr, percentage, clr);
				}
			}
		}

		damagehandler.blend[pnum] = clr;
		if (!clr) { blendalpha = 0.0; }

		if (boa_debugscreenblends) { console.printF("%s\nFinal blend: %x at %.2f", temp, damagehandler.blend[pnum], blendalpha); }

		return damagehandler.blend[pnum], blendalpha, max(1, damageamount);
	}

	// See V_AddBlend in v_blend.cpp
	static Color AddBlend (Color base, Color add, double alpha)
	{
		if (alpha <= 0) { return base; }

		double a2 = base.a + (1 - base.a) * alpha;
		double a3 = base.a / a2;

		int r = int(base.r * a3 + add.r * (1 - a3));
		int g = int(base.g * a3 + add.g * (1 - a3));
		int b = int(base.b * a3 + add.b * (1 - a3));

		return r * 0x10000 + g * 0x100 + b;
	}

	int GetAmount(int i)
	{
		if (events[i] && events[i].timeout) { return max(0, events[i].timeout - level.time); }
		
		return 0;
	}
}

class ThingTracker : EventHandler
{
	Array<Actor> grenades;

	override void WorldThingSpawned(WorldEvent e)
	{
		let grenade = GrenadeBase(e.thing);

		if (!grenade) { return; }

		grenades.Push(grenade);
	}

	override void WorldThingDestroyed(WorldEvent e)
	{
		let grenade = GrenadeBase(e.thing);

		if (!grenade) { return; }

		int g = grenades.Find(grenade);
		grenades.Delete(g);
	}

	static Actor LookForGrenades(Actor mo)
	{
		if (mo.bBoss) { return null; }

		ThingTracker tracker = ThingTracker(EventHandler.Find("ThingTracker"));
		if (!tracker) { return null; }

		Actor closest = null;

		for (int g = 0; g < tracker.grenades.Size(); g++)
		{
			let grenade = tracker.grenades[g];

			int feardistance = int(grenade.radius + (GrenadeBase(grenade) ? GrenadeBase(grenade).feardistance : mo.radius * 2));

			if (!mo.CheckSight(grenade)) { continue; }
			if (grenade.bMissile && (grenade.target == mo || (grenade.target is "PlayerPawn" && Actor.absangle(grenade.angle + 180, mo.AngleTo(grenade.target)) > 30))) { continue; } // Ignore missiles fired from self and any from a player that aren't aimed at you
			if (mo.Distance3d(grenade) > (grenade.bMissile ? feardistance * max(grenade.Speed, grenade.vel.length()) : feardistance)) { continue; }
			if (grenade.pos.z > mo.pos.z + mo.height || grenade.pos.z + grenade.height < mo.pos.z) { continue; }
			if (closest && mo.Distance3d(grenade) > mo.Distance3d(closest)) { continue; }

			closest = grenade;
		}

		return closest;
	}
}

class InventoryTracker : EventHandler
{
	InventoryHolder[MAXPLAYERS] inventories;

	static void Save(Actor mo)
	{
		int pnum = mo.PlayerNumber();
		if (pnum < 0) { return; }

		InventoryTracker tracker = InventoryTracker(EventHandler.Find("InventoryTracker"));
		if (!tracker) { return; }

		tracker.inventories[pnum] = New("InventoryHolder");
		tracker.inventories[pnum].HoldInventory(mo.Inv);
	}

	static void Restore(Actor mo)
	{
		int pnum = mo.PlayerNumber();
		if (pnum < 0) { return; }

		InventoryTracker tracker = InventoryTracker(EventHandler.Find("InventoryTracker"));
		if (!tracker) { return; }

		tracker.inventories[pnum].RestoreInventory(mo);
		tracker.inventories[pnum].Destroy();
	}

	static void Clear(Actor mo)
	{
		int pnum = mo.PlayerNumber();
		if (pnum < 0) { return; }

		InventoryTracker tracker = InventoryTracker(EventHandler.Find("InventoryTracker"));
		if (!tracker) { return; }

		tracker.inventories[pnum].Destroy();
	}
}

class AchievementTracker : EventHandler
{
	transient CVar recordvar;
	int record;
	Array<bool> records;

	int pistolshots[MAXPLAYERS];
	int knifekills[MAXPLAYERS];
	int levelstats[MAXPLAYERS][3];
	int damaged[MAXPLAYERS];

	enum Achievements
	{
		ACH_GUNSLINGER,		// Fire 1000 pistol shots
		ACH_PERFECTIONIST,	// Finish a map with 100% kills/treasure/secrets
		ACH_SPEEDRUNNER,
		ACH_SLIKSTER,
		ACH_IMPENETRABLE,	// Finish a map without taking damage
		ACH_DISGRACE,		// Finish off a boss enemy with kicks
		ACH_PACIFIST,		// Finish a level without killing any enemies
		ACH_CLEARSHOT,		// Use the Kar98k to snipe an enemy over 6000 units away
		ACH_WATCHYOURSTEP,
		ACH_CHEVALIER,		// Kill a loper with only the primary fire of the Firebrand
		ACH_1915,			// Complete C3M4 with no gas mask
		ACH_ASSASSIN,		// Stealth kill 10 enemies
		ACH_NAUGHTY,		// Use the 'give' cheat
	};

	override void OnRegister()
	{
		recordvar = CVar.FindCVar("boa_achievementrecord");

		String value = recordvar.GetString();

		if (value.length()) 
		{
			Array<String> parse;
			value = Decode(value, 667);
			value.Split(parse, "|");

			for (int a = 0; a < parse.Size(); a++)
			{
				records.Push(parse[a] != "0");
			}
		}
	}

	override void WorldTick()
	{
		CheckStats();
	}

	override void WorldThingSpawned(WorldEvent e)
	{
		if (e.Thing is "PlayerTracer" && PlayerTracer(e.Thing).target.player)
		{
			int pnum = PlayerTracer(e.Thing).target.PlayerNumber();
			if (e.Thing is "LugerTracer") { CheckAchievement(pnum, ACH_GUNSLINGER); }
		}
	}

	override void WorldLinePreActivated(WorldEvent e) 
	{
		let line = e.activatedline;

		if ( // This doesn't cover all level exits due to scripting, unfortunately; more handling in the StatistBarkeeper Used function, but still not perfect
			line.special == 243 || // Exit_Normal
			line.special == 244 || // Exit_Secret
			line.special == 74 // Teleport_NewMap
		)
		{
			CheckAchievement(consoleplayer, ACH_IMPENETRABLE);
			CheckAchievement(consoleplayer, ACH_PACIFIST);
			CheckAchievement(consoleplayer, ACH_1915);
		}
	}

	override void NetworkProcess(ConsoleEvent e)
	{
		if (e.Name == "achievement")
		{
			UpdateRecord(e.args[0]);
		}
		else if (e.Name == "printachievements")
		{
			for (int a = 0; a < records.Size(); a++)
			{
				console.printf("%i %i", a, records[a]);
			}
		}
	}

	void CheckStats()
	{
		if (
			levelstats[consoleplayer][0] != players[consoleplayer].killcount ||
			levelstats[consoleplayer][1] != players[consoleplayer].itemcount ||
			levelstats[consoleplayer][2] != players[consoleplayer].secretcount
		)
		{
			levelstats[consoleplayer][0] = players[consoleplayer].killcount;
			levelstats[consoleplayer][1] = players[consoleplayer].itemcount;
			levelstats[consoleplayer][2] = players[consoleplayer].secretcount;

			CheckAchievement(consoleplayer, ACH_PERFECTIONIST);
		}
	}

	static void CheckAchievement(int pnum, int a)
	{
		if (pnum < 0) { return; }

		AchievementTracker achievements = AchievementTracker(EventHandler.Find("AchievementTracker"));
		if (!achievements) { return; }

		if (a < achievements.records.Size() && achievements.records[a]) { return; }

		switch (a)
		{
			case AchievementTracker.ACH_GUNSLINGER:
				if (++achievements.pistolshots[pnum] >= 1000) { achievements.UpdateRecord(AchievementTracker.ACH_GUNSLINGER); }
				break;
			case AchievementTracker.ACH_PERFECTIONIST:
				if (
					players[pnum].killcount == level.total_monsters &&
					players[pnum].itemcount == level.total_items &&
					players[pnum].secretcount == level.total_secrets
				)
				{
					achievements.UpdateRecord(AchievementTracker.ACH_PERFECTIONIST);
				}
				break;
			case AchievementTracker.ACH_SPEEDRUNNER:
				// TODO
				break;
			case AchievementTracker.ACH_SLIKSTER:
				// TODO
				break;
			case AchievementTracker.ACH_IMPENETRABLE:
				if (!achievements.damaged[consoleplayer]) { achievements.UpdateRecord(AchievementTracker.ACH_IMPENETRABLE); }
				break;
			case AchievementTracker.ACH_PACIFIST: // Currently includes all counted kills!
				if (players[consoleplayer].killcount == 0) { achievements.UpdateRecord(AchievementTracker.ACH_PACIFIST); }
				break;
			case AchievementTracker.ACH_WATCHYOURSTEP:
				// TODO
				break;
			case AchievementTracker.ACH_1915:
				if (level.mapname == "C3M4" && !players[consoleplayer].mo.FindInventory("ZyklonMask")) { achievements.UpdateRecord(AchievementTracker.ACH_1915); }
				break;
			case AchievementTracker.ACH_ASSASSIN: // Set up in the Nazi class's DamageMobj function
				if (++achievements.knifekills[consoleplayer] >= 10) { achievements.UpdateRecord(AchievementTracker.ACH_ASSASSIN); }
				break;
			case AchievementTracker.ACH_DISGRACE: // Set up in the Nazi class's Die function
			case AchievementTracker.ACH_CLEARSHOT: // Set up in the Nazi class's Die function
			case AchievementTracker.ACH_CHEVALIER: // Set up in the Nazi class's Die function, with handling in DamageMobj to flag the enemy to not allow the achievement if any other weapon was used
			case AchievementTracker.ACH_NAUGHTY: // Set up in the BoAPlayer class's give cheat handling
			default:
				achievements.UpdateRecord(a);
				break;
		}
	}

	void UpdateRecord(int a)
	{
		if (a >= records.Size()) { records.Insert(a, true); } // Make the array bigger if it's not already big enough
		else if (records[a]) { return; } // Only let the player get an achievement once
		else { records[a] = true; } // Set the achievement as complete

		String bits = "";
		for (int b = 0; b < records.Size(); b++)
		{
			if (b > 0) { bits = bits .. "|"; }
			bits = String.Format("%s%c", bits, records[b] + 0x30);
		}

		recordvar.SetString(Encode(bits, 667));

		String lookup = String.Format("ACHIEVEMENT%i", a);
		String text = StringTable.Localize(lookup, false);
		if (lookup ~== text) { text = String.Format("Completed achievement %i", a); }

		String image = String.Format("ACHVMT%02i", a);

		AchievementMessage.Init(players[consoleplayer].mo, text, image, "menu/change");
	}

	// Algorithms adapted from https://en.wikibooks.org/wiki/Algorithm_Implementation/Miscellaneous/Base64
	// Pass in v value as an offset to slightly obfuscate the encoded value (added ROT cipher, effectively)
	String Encode(String s, int v = 0)
	{
		String base64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
		String r = ""; 
		String p = ""; 
		int c = s.Length() % 3;

		if (c)
		{
			for (; c < 3; c++)
			{ 
				p = p .. '='; 
				s = s .. "\0"; 
			} 
		}

		for (c = 0; c < s.Length(); c += 3)
		{
			int m = (s.ByteAt(c) + v << 16) + (s.ByteAt(c + 1) + v << 8) + s.ByteAt(c + 2) + v;
			int n[] = { (m >>> 18) & 63, (m >>> 12) & 63, (m >>> 6) & 63, m & 63 };
			r = r .. base64chars.Mid(n[0], 1) .. base64chars.Mid(n[1], 1) .. base64chars.Mid(n[2], 1) .. base64chars.Mid(n[3], 1);
		}

		return r.Mid(0, r.Length() - p.Length()) .. p;
	}

	String Decode(String s, int v = 0)
	{
		String base64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

		String p = (s.ByteAt(s.Length() - 1) == 0x3D ? (s.ByteAt(s.Length() - 2) == 0x3D ? "AA" : "A") : ""); 
		String r = ""; 
		s = s.Mid(0, s.Length() - p.Length()) .. p;

		for (int c = 0; c < s.Length(); c += 4)
		{
			int c1 = base64chars.IndexOf(String.Format("%c", s.ByteAt(c))) << 18;
			int c2 = base64chars.IndexOf(String.Format("%c", s.ByteAt(c + 1))) << 12;
			int c3 = base64chars.IndexOf(String.Format("%c", s.ByteAt(c + 2))) << 6;
			int c4 = base64chars.IndexOf(String.Format("%c", s.ByteAt(c + 3)));

			int n = (c1 + c2 + c3 + c4);
			r = r .. String.Format("%c%c%c", ((n >>> 16) - v) & 127, ((n >>> 8) - v) & 127, (n - v) & 127); // Sorry extened ASCII and Unicode...  No support for you here.
		}

		return r.Mid(0, r.Length() - p.Length());
	}
}