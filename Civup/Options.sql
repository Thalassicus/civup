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
-- Options --
-------------


/*
Play Combat Animations
1 = play animations (no quick combat)
0 = skip animations (quick combat)

This modded approach to "quick combat" solves bugs with the vanilla version:
http://forums.civfanatics.com/showthread.php?p=10901714#post10901714
*/
INSERT INTO Civup (Type, Value)
VALUES ('PLAY_COMBAT_ANIMATIONS', 1);


/*
CityState Diplomacy Mod Compatibility
Change this ONLY before starting a game, NOT mid-game.
0 = not using CSD and VEM
1 = using CSD and VEM
*/
INSERT INTO Civup (Type, Value)
VALUES ('USING_CSD', 0);


/*
Barbarians Upgrade
1 = barbarians upgrade in camps
0 = barbarians do not upgrade
INSERT INTO Civup (Type, Value)
VALUES ('BARBARIANS_UPGRADE', 1); 
*/


/*
Barbarians Heal
1 = barbarians heal when fortified
0 = barbarians do not heal
INSERT INTO Civup (Type, Value)
VALUES ('BARBARIANS_HEAL', 1);
*/


/*
Minimum distance (in tiles) between cities.
UPDATE Defines
SET Value = 2
WHERE Name = 'MIN_CITY_RANGE';
*/


/*
These add information to tooltips about how important the AI considers
building specific units/buildings and choosing particular policies/techs.
1 = display priorities
0 = hide priorities
*/
INSERT INTO Civup (Type, Value)
VALUES ('SHOW_AI_PRIORITY_UNITS', 0);

INSERT INTO Civup (Type, Value)
VALUES ('SHOW_AI_PRIORITY_BUILDINGS', 0);

INSERT INTO Civup (Type, Value)
VALUES ('SHOW_AI_PRIORITY_POLICIES', 0);

INSERT INTO Civup (Type, Value)
VALUES ('SHOW_AI_PRIORITY_TECHS', 0);


/*
Human-vs-barbarian combat bonus.
UPDATE HandicapInfos SET BarbarianBonus = 150 WHERE Type = 'HANDICAP_SETTLER';
UPDATE HandicapInfos SET BarbarianBonus =  50 WHERE Type = 'HANDICAP_CHIEFTAIN';
UPDATE HandicapInfos SET BarbarianBonus =  20 WHERE Type = 'HANDICAP_WARLORD';
UPDATE HandicapInfos SET BarbarianBonus =  15 WHERE Type = 'HANDICAP_PRINCE';
UPDATE HandicapInfos SET BarbarianBonus =  15 WHERE Type = 'HANDICAP_KING';
UPDATE HandicapInfos SET BarbarianBonus =  15 WHERE Type = 'HANDICAP_EMPEROR';
UPDATE HandicapInfos SET BarbarianBonus =  15 WHERE Type = 'HANDICAP_IMMORTAL';
UPDATE HandicapInfos SET BarbarianBonus =  15 WHERE Type = 'HANDICAP_DEITY';
*/


/*
Unit Movement Animation Duration
The animation time required for a unit to visually move between tiles.
The default VEM values are 50% of vanilla (half duration, twice as fast).
*/
UPDATE MovementRates SET
TotalTime			= 0.5 * TotalTime,
EaseIn				= 0.5 * EaseIn,
EaseOut				= 0.5 * EaseOut,
IndividualOffset	= 0.5 * IndividualOffset,
RowOffset			= 0.5 * RowOffset;