--

--
-- Units
--

UPDATE Units SET Help = NULL WHERE Type IN (
	'UNIT_SETTLER'				,
	'UNIT_SPEARMAN'				,
	'UNIT_HORSEMAN'				,
	'UNIT_SWORDSMAN'			,
	'UNIT_COMPOSITE_BOWMAN'		,
	'UNIT_PIKEMAN'				,
	'UNIT_KNIGHT'				,
	'UNIT_CROSSBOWMAN'			,
	'UNIT_LONGSWORDSMAN'		,
	'UNIT_MUSKETMAN'			,
	'UNIT_LANCER'				,
	'UNIT_CAVALRY'				,
	'UNIT_RIFLEMAN'				,
	'UNIT_GREAT_WAR_INFANTRY'	,
	'UNIT_WWI_TANK'				,
	'UNIT_WWI_BOMBER'			,
	'UNIT_ANTI_AIRCRAFT_GUN'	,
	'UNIT_ANTI_TANK_GUN'		,
	'UNIT_MACHINE_GUN'			,
	'UNIT_INFANTRY'				,
	'UNIT_MARINE'				,
	'UNIT_TANK'					,
	'UNIT_FIGHTER'				,
	'UNIT_BOMBER'				,
	'UNIT_MOBILE_SAM'			,
	'UNIT_HELICOPTER_GUNSHIP'	,
	'UNIT_MECHANIZED_INFANTRY'	,
	'UNIT_MODERN_ARMOR'			,
	'UNIT_JET_FIGHTER'			,
	'UNIT_STEALTH_BOMBER'		,
	'UNIT_MECH'					,
	'UNIT_GUIDED_MISSILE'		,
	'UNIT_ATOMIC_BOMB'			,
	'UNIT_NUCLEAR_MISSILE'		
);

INSERT OR REPLACE INTO UnitCombatInfos(Type, Description)
VALUES ('UNITCOMBAT_COMMAND', 'TXT_KEY_UNITCOMBAT_COMMAND');

INSERT OR REPLACE INTO UnitCombatInfos(Type, Description)
VALUES ('UNITCOMBAT_CIVILIAN', 'TXT_KEY_UNITCOMBAT_CIVILIAN');

INSERT OR REPLACE INTO UnitCombatInfos(Type, Description)
VALUES ('UNITCOMBAT_SUBMARINE', 'TXT_KEY_UNITCOMBAT_SUBMARINE');

INSERT OR REPLACE INTO UnitCombatInfos(Type, Description)
VALUES ('UNITCOMBAT_MOUNTED_ARCHER', 'TXT_KEY_UNITCOMBAT_MOUNTED_ARCHER');

INSERT OR REPLACE INTO UnitCombatInfos(Type, Description)
VALUES ('UNITCOMBAT_MACHINE_GUN', 'TXT_KEY_UNITCOMBAT_MACHINE_GUN');

UPDATE Units
SET CombatClass = 'UNITCOMBAT_COMMAND'
WHERE Class IN (
	'UNITCLASS_GREAT_GENERAL',
	'UNITCLASS_GREAT_ADMIRAL'
);

UPDATE Units
SET CombatClass = 'UNITCOMBAT_CIVILIAN'
WHERE CombatClass IS NULL;

INSERT INTO UnitCombatInfos				(Type, Description)
SELECT									'UNITCOMBAT_DIPLOMACY', 'TXT_KEY_UNITCOMBAT_DIPLOMACY'
WHERE NOT EXISTS						(SELECT * FROM UnitCombatInfos WHERE Type='UNITCOMBAT_DIPLOMACY' );

UPDATE Units
SET DontShowYields = 1
WHERE Class = 'UNITCLASS_GREAT_GENERAL';

UPDATE Units
SET CombatClass = 'UNITCOMBAT_MOUNTED_ARCHER'
WHERE CombatClass = 'UNITCOMBAT_ARCHER' AND Class NOT IN (
	'UNITCLASS_ARCHER',
	'UNITCLASS_COMPOSITE_BOWMAN',
	'UNITCLASS_CROSSBOWMAN',
	'UNITCLASS_GATLINGGUN',
	'UNITCLASS_MACHINE_GUN'
);

--
-- Buildings
--

INSERT INTO Building_ResourceYieldChanges	(BuildingType, ResourceType, YieldType, Yield)
SELECT DISTINCT								BuildingType, 'RESOURCE_FISH', YieldType, Yield
FROM Building_SeaResourceYieldChanges;

INSERT INTO Building_ResourceYieldChanges	(BuildingType, ResourceType, YieldType, Yield)
SELECT DISTINCT								BuildingType, 'RESOURCE_WHALE', YieldType, Yield
FROM Building_SeaResourceYieldChanges;

INSERT INTO Building_ResourceYieldChanges	(BuildingType, ResourceType, YieldType, Yield)
SELECT DISTINCT								BuildingType, 'RESOURCE_PEARLS', YieldType, Yield
FROM Building_SeaResourceYieldChanges;

INSERT INTO Building_ResourceYieldChanges	(BuildingType, ResourceType, YieldType, Yield)
SELECT DISTINCT								BuildingType, 'RESOURCE_CRAB', YieldType, Yield
FROM Building_SeaResourceYieldChanges;
DELETE FROM Building_SeaResourceYieldChanges;

INSERT INTO Building_GlobalYieldModifiers	(BuildingType, YieldType, Yield)
SELECT DISTINCT								Type, 'YIELD_CULTURE', GlobalCultureRateModifier
FROM Buildings								WHERE GlobalCultureRateModifier <> 0;
UPDATE Buildings SET GlobalCultureRateModifier = 0;

/*
INSERT INTO Belief_BuildingClassYieldChanges	(BeliefType, BuildingClassType, YieldType, YieldChange)
SELECT DISTINCT									BeliefType, BuildingClassType, 'YIELD_HAPPINESS_CITY', Happiness
FROM Belief_BuildingClassHappiness;
DELETE FROM Belief_BuildingClassHappiness;
*/

/*
INSERT INTO Building_YieldChanges			(BuildingType, YieldType, Yield)
SELECT DISTINCT								Type, 'YIELD_HAPPINESS_CITY', Happiness
FROM Buildings								WHERE Happiness <> 0;
UPDATE Buildings SET Happiness = 0;
*/


--
-- Flavors
--

INSERT INTO Flavors (Type) VALUES ('FLAVOR_SOLDIER');
INSERT INTO Flavors (Type) VALUES ('FLAVOR_SIEGE');
INSERT INTO Flavors (Type) VALUES ('FLAVOR_ANTI_MOBILE');
INSERT INTO Flavors (Type) VALUES ('FLAVOR_NAVAL_BOMBARDMENT');
INSERT INTO Flavors (Type) VALUES ('FLAVOR_HEALING');
INSERT INTO Flavors (Type) VALUES ('FLAVOR_PILLAGE');
INSERT INTO Flavors (Type) VALUES ('FLAVOR_VANGUARD');

INSERT INTO Leader_Flavors (LeaderType, FlavorType, Flavor)
SELECT offense.LeaderType, flavor.Type, offense.Flavor
FROM Leader_Flavors offense, Flavors flavor
WHERE offense.FlavorType = 'FLAVOR_OFFENSE' AND flavor.Type IN (
	'FLAVOR_SOLDIER'		,
	'FLAVOR_SIEGE'			
);

INSERT INTO Leader_Flavors (LeaderType, FlavorType, Flavor)
SELECT offense.LeaderType, flavor.Type, offense.Flavor
FROM Leader_Flavors offense, Flavors flavor
WHERE offense.FlavorType = 'FLAVOR_DEFENSE' AND flavor.Type IN (
	'FLAVOR_ANTI_MOBILE'	
);

INSERT INTO Leader_Flavors (LeaderType, FlavorType, Flavor)
SELECT offense.LeaderType, flavor.Type, offense.Flavor
FROM Leader_Flavors offense, Flavors flavor
WHERE offense.FlavorType = 'FLAVOR_NAVAL' AND flavor.Type IN (
	'FLAVOR_NAVAL_BOMBARDMENT'		
);


--
-- Misc
--

UPDATE HurryInfos SET YieldType = 'YIELD_'||SUBSTR(Type, 7);

UPDATE Defines SET Value=1 WHERE Name='QUEST_DISABLED_INVEST' AND EXISTS 
(SELECT Value FROM Civup WHERE Type='DISABLE_GOLD_GIFTS' AND Value=1);

UPDATE Civilizations SET DawnOfManAudio = "" WHERE EXISTS 
(SELECT Value FROM Civup WHERE Type='PLAY_SPEECH_START' AND Value=0);

UPDATE Buildings SET WonderSplashAudio = "" WHERE EXISTS 
(SELECT Value FROM Civup WHERE Type='PLAY_SPEECH_WONDERS' AND Value=0);

UPDATE Technologies SET AudioIntroHeader = "" WHERE EXISTS 
(SELECT Value FROM Civup WHERE Type='PLAY_SPEECH_TECHS' AND Value=0);

UPDATE Technologies SET AudioIntro = "" WHERE EXISTS 
(SELECT Value FROM Civup WHERE Type='PLAY_SPEECH_TECHS' AND Value=0);


--
-- Done
--
UPDATE LoadedFile SET Value=1 WHERE Type='Civup_Misc.sql';