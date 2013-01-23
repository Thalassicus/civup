/*

You can change most options in this file at any time, unless indicated otherwise.
Changes take effect the next time you start or load a game with CiVUP/VEM.

For example, if you are using the "Citystate Diplomacy" mod change the lines that read:

	INSERT INTO Civup (Type, Value)
	VALUES ('USING_CSD', 0);

...change to...

	INSERT INTO Civup (Type, Value)
	VALUES ('USING_CSD', 1);

Then start a new game.

*/

-------------
-- OPTIONS --
-------------

/*
-- LANGUAGE --

Set your language.
The text defaults to English when the English version is more recent than the local language.

Code	Language	 
-----	--------
DE_DE	Deutsch			German
EN_US	English			English (US)
ES_ES	Espanol			Spanish
FR_FR	Francais		French
IT_IT	Italiano		Italian
JA_JP	Nihongo			Japanese
PL_PL	Polski			Polish
RU_RU	Russkij Jazyk	Russian
ZH_CN	Jiantizi		Chinese (Simplified)

*/
INSERT INTO Civup (Type, Value) VALUES ('LANGUAGE', 'EN_US');

/*
Play Combat Animations
1 = play animations (no quick combat)
0 = skip animations (quick combat)

This modded approach to "quick combat" solves bugs with the vanilla version:
http://forums.civfanatics.com/showthread.php?p=10901714#post10901714
*/
INSERT INTO Civup (Type, Value) VALUES ('PLAY_COMBAT_ANIMATIONS', 1);


/*
CityState Diplomacy Mod Compatibility
Change this ONLY before starting a game, NOT mid-game.
0 = not using CSD and GEM
1 = using CSD and GEM
*/
INSERT INTO Civup (Type, Value) VALUES ('USING_CSD', 0);


/*
These add information to tooltips about how important
the AI considers units, buildings, policies, and techs.
This can be helpful for players new to the game.
1 = display power
0 = hide power
*/

INSERT INTO Civup (Type, Value) VALUES ('SHOW_POWER_FOR_UNITS', 0);
INSERT INTO Civup (Type, Value) VALUES ('SHOW_POWER_FOR_BUILDINGS', 0);
INSERT INTO Civup (Type, Value) VALUES ('SHOW_POWER_FOR_POLICIES', 0);
INSERT INTO Civup (Type, Value) VALUES ('SHOW_POWER_FOR_TECHS', 0);
INSERT INTO Civup (Type, Value) VALUES ('SHOW_POWER_FOR_BUILDS', 0);
INSERT INTO Civup (Type, Value) VALUES ('SHOW_POWER_RAW_NUMBERS', 0);


/*
Unit Movement Animation Duration
The animation time required for a unit to visually move between tiles.
The default VEM values are 50% of vanilla (half duration = twice as fast).
*/
UPDATE MovementRates SET
TotalTime			= 0.5 * TotalTime,
EaseIn				= 0.5 * EaseIn,
EaseOut				= 0.5 * EaseOut,
IndividualOffset	= 0.5 * IndividualOffset,
RowOffset			= 0.5 * RowOffset;

/*
Aircraft Move Speed
The speed of aircraft movement.
The default VEM values are 400% of vanilla (four times as fast).
*/

UPDATE ArtDefine_UnitMemberCombats
SET MoveRate = 4 * MoveRate;

UPDATE ArtDefine_UnitMemberCombats
SET TurnRateMin = 4 * TurnRateMin
WHERE MoveRate > 0;

UPDATE ArtDefine_UnitMemberCombats
SET TurnRateMax = 4 * TurnRateMax
WHERE MoveRate > 0;

/*
Use FlagPromotion Visibility Defaults
1 = each game resets visible promotions to defaults
0 = customize visible promotions
*/
INSERT INTO Civup (Type, Value) VALUES ('USE_FLAG_PROMOTION_DEFAULTS', 1);

/*
Highlight Worked City Tiles
2 = always highlight tiles worked by city citizens
1 = highlight tiles when hovering over city hex
0 = highlight tiles when pressing SHIFT key
*/
INSERT INTO Civup (Type, Value) VALUES ('HIGHLIGHT_WORKED_CITY_TILES', 1);

/*
Show City Limits
1 = Show a 3-tile radius around cities
0 = Do not show city limits
*/
INSERT INTO Civup (Type, Value) VALUES ('SHOW_CITY_LIMITS', 0);

/*
Debug Timer Level
This prints timing information to lua.log to identify sources of lag.
0 = no timers
1 = basic timers
2 = detailed timers
3 = YieldLibrary timers
*/
INSERT INTO Civup (Type, Value) VALUES ('DEBUG_TIMER_LEVEL', 0);
















--
-- Do not change this
UPDATE LoadedFile SET Value=1 WHERE Type='Civup_Options.sql';