--

CREATE TABLE IF NOT EXISTS Civup(Type text, Value);

CREATE TABLE IF NOT EXISTS LoadedFile(Type text, Value);
INSERT INTO LoadedFile(Type, Value) VALUES ('Civup_Misc.sql'		, 0);
INSERT INTO LoadedFile(Type, Value) VALUES ('Civup_Promotions.sql'	, 0);
INSERT INTO LoadedFile(Type, Value) VALUES ('Civup_Options.sql'		, 0);
INSERT INTO LoadedFile(Type, Value) VALUES ('Civup_AlterTables.sql'	, 0);
INSERT INTO LoadedFile(Type, Value) VALUES ('YL_General.xml'		, 0);

--
-- Table Changes
--

ALTER TABLE Buildings		ADD AlwaysShowHelp						boolean; -- Use this to force the help text to display for a building.
ALTER TABLE Buildings		ADD FreePromotionAllCombatUnits			text;
ALTER TABLE Buildings		ADD CulturePerPop						integer default 0;
ALTER TABLE Buildings		ADD InstantBorderRadius					integer default 0;
ALTER TABLE Buildings		ADD GlobalInstantBorderRadius			integer default 0;
ALTER TABLE Buildings		ADD MinorFriendshipFlatChange			integer default 0;
ALTER TABLE Buildings		ADD MountainImprovement					text;
ALTER TABLE Buildings		ADD NoOccupiedUnhappinessFixed			boolean;
ALTER TABLE Buildings		ADD OnlyAI								boolean;
ALTER TABLE Buildings		ADD IsVisible							boolean default 1;
ALTER TABLE Buildings		ADD ShowInPedia							boolean default 1;
ALTER TABLE Buildings		ADD CityCaptureCulture					integer default 0;
ALTER TABLE Buildings		ADD CityCaptureCulturePerPop			integer default 0;
ALTER TABLE Buildings		ADD CityCaptureCulturePerEra			integer default 0;
ALTER TABLE Buildings		ADD CityCaptureCulturePerEraExponent	variant default 1;
ALTER TABLE Buildings		ADD GreatGeneralRateChange				integer default 0;
ALTER TABLE Buildings		ADD IsBuildingAddon						integer default 0;
ALTER TABLE Buildings		ADD IsMarketplace						integer default 0;
ALTER TABLE	Buildings		ADD	AddonParent							text;
ALTER TABLE Buildings		ADD ShortDescription					text;
ALTER TABLE Buildings		ADD TradeDealModifier					integer default 0;
ALTER TABLE Buildings		ADD InstantHappiness					integer default 0;
ALTER TABLE Buildings		ADD GoldenAgePoints						integer default 0;
ALTER TABLE Buildings		ADD ExperiencePerTurn					integer default 0;
ALTER TABLE Buildings		ADD OneShot								boolean;
ALTER TABLE Buildings		ADD GlobalExperienceFixed				integer default 0;
ALTER TABLE Buildings		ADD AIAvailability						integer default 0;
ALTER TABLE Buildings		ADD NotFeature							text;

ALTER TABLE Builds			ADD AIAvailability						integer default 0;

ALTER TABLE Eras			ADD TriggerRatePercent					integer default 0;

ALTER TABLE Flavors			ADD Description							text;
ALTER TABLE Flavors			ADD IconString							text;
ALTER TABLE Flavors			ADD PurchasePriority					variant default 0;

ALTER TABLE GameOptions		ADD Reverse								boolean;

ALTER TABLE HandicapInfos	ADD AIFreeXP							integer default 0;
ALTER TABLE HandicapInfos	ADD AIFreeXPPerEra						integer default 0;
ALTER TABLE HandicapInfos	ADD AIFreePromotion						text;
ALTER TABLE HandicapInfos	ADD AIResearchPercent					variant default 0;
ALTER TABLE HandicapInfos	ADD AIResearchPercentPerEra				variant default 0;
ALTER TABLE HandicapInfos	ADD AIProductionPercentPerEra			variant default 0;
ALTER TABLE HandicapInfos	ADD AIGold								integer default 0;
ALTER TABLE HandicapInfos	ADD AICapitalRevealRadius				integer default 0;
ALTER TABLE HandicapInfos	ADD AICapitalYieldPeaceful				integer default 0;
ALTER TABLE HandicapInfos	ADD AICapitalYieldMilitaristic			integer default 0;

ALTER TABLE Leaders			ADD Personality							text default 'PERSONALITY_COALITION';
ALTER TABLE Leaders			ADD AIBonus								boolean;

ALTER TABLE Policies		ADD BorderObstacle						boolean;
ALTER TABLE Policies		ADD GoldFromKillsCostBased				variant default 0;
ALTER TABLE Policies		ADD ExtraSpies							integer default 0;
ALTER TABLE Policies		ADD MilitaristicCSExperience			integer default 0;
ALTER TABLE Policies		ADD GarrisonedExperience				variant default 0;
ALTER TABLE Policies		ADD CityCaptureCulture					integer default 0;
ALTER TABLE Policies		ADD CityCaptureCulturePerPop			integer default 0;
ALTER TABLE Policies		ADD CityCaptureCulturePerEra			integer default 0;
ALTER TABLE Policies		ADD CityCaptureCulturePerEraExponent	variant default 1;
ALTER TABLE Policies		ADD MinorInfluence						integer default 0;
ALTER TABLE Policies		ADD MinorGreatPeopleRate				integer default 0;
ALTER TABLE Policies		ADD GlobalExperience					integer default 0;
ALTER TABLE Policies		ADD OpenBordersGoldModifier				integer default 0;
ALTER TABLE Policies		ADD FirstSpecialistYieldChange			integer default 0;
ALTER TABLE Policies		ADD CityResistTimeMod					integer default 0;
ALTER TABLE Policies		ADD CitystateCaptureYieldTurns			integer default 0;

ALTER TABLE Resources		ADD NumPerTerritory						variant default 0;
ALTER TABLE Resources		ADD MutuallyExclusiveGroup				integer default -1;

ALTER TABLE Traits			ADD LandBarbarianCapturePercent			integer default 0;
ALTER TABLE Traits			ADD MinorCivCaptureBonus				integer default 0;
ALTER TABLE Traits			ADD CityGoldPerLuxuryPercent			integer default 0;
ALTER TABLE Traits			ADD HappinessFromKills					integer default 0;
ALTER TABLE Traits			ADD MilitaristicCSFreePromotion			text;
ALTER TABLE Traits			ADD FreeShip							text;
ALTER TABLE Traits			ADD NoWarrior							boolean;
ALTER TABLE Traits			ADD NaturalWonderConstant				integer default 0;
ALTER TABLE Traits			ADD NaturalWonderMultiplier				integer default 0;
ALTER TABLE Traits			ADD NaturalWonderExponent				variant default 1;
ALTER TABLE Traits			ADD SeaBarbarianCapturePercent			integer default 0;
ALTER TABLE Traits			ADD OpenBordersGoldModifier				integer default 0;

ALTER TABLE Specialists		ADD IconString							text;

ALTER TABLE Units			ADD BarbUpgradeType						text;
ALTER TABLE UnitCombatInfos	ADD PromotionCategory					text;

ALTER TABLE UnitPromotions	ADD IsFirst								boolean;
ALTER TABLE UnitPromotions	ADD IsAttack							boolean;
ALTER TABLE UnitPromotions	ADD IsDefense							boolean;
ALTER TABLE UnitPromotions	ADD IsRanged							boolean;
ALTER TABLE UnitPromotions	ADD IsMelee								boolean;
ALTER TABLE UnitPromotions	ADD IsMove								boolean;
ALTER TABLE UnitPromotions	ADD SimpleHelpText						boolean;
ALTER TABLE UnitPromotions	ADD FullMovesAfterAttack				boolean;
ALTER TABLE UnitPromotions	ADD GoldenPoints						integer default 0;
ALTER TABLE UnitPromotions	ADD Class								text default 'PROMOTION_CLASS_PERSISTANT';

ALTER TABLE Worlds			ADD AICapitalRevealRadius				integer default 0;
ALTER TABLE Worlds			ADD ResourceMod							integer default 100;

ALTER TABLE Yields			ADD IsTileYield							boolean;
ALTER TABLE Yields			ADD TileTexture							text;
ALTER TABLE Yields			ADD GoldenAgeSurplusYieldMod			integer default 0;
ALTER TABLE Yields			ADD PlayerThreshold						integer default 0;
ALTER TABLE Yields			ADD YieldFriend							integer default 0;
ALTER TABLE Yields			ADD YieldAlly							integer default 0;
ALTER TABLE Yields			ADD MinPlayer							integer default 0;
ALTER TABLE Yields			ADD Color								text default 'COLOR_WHITE';


ALTER TABLE Natural_Wonder_Placement ADD Type text;
UPDATE Natural_Wonder_Placement SET Type = ID;

ALTER TABLE Units			ADD PopCostMod integer default 0;
ALTER TABLE Buildings		ADD PopCostMod integer default 0;
ALTER TABLE Projects		ADD PopCostMod integer default 0;

ALTER TABLE Units			ADD ListPriority integer default -1;
ALTER TABLE Domains			ADD ListPriority integer default -1;
ALTER TABLE Buildings		ADD ListPriority integer default -1;
ALTER TABLE Projects		ADD ListPriority integer default -1;
ALTER TABLE Processes		ADD ListPriority integer default -1;
ALTER TABLE Flavors			ADD ListPriority integer default -1;


--
-- Create Tables
--

CREATE TABLE IF NOT EXISTS Civup_Language_EN_US (DateModified integer, Tag text, Text text, Gender text, Plurality text);
CREATE TABLE IF NOT EXISTS Civup_Language_DE_DE (DateModified integer, Tag text, Text text, Gender text, Plurality text);
CREATE TABLE IF NOT EXISTS Civup_Language_ES_ES (DateModified integer, Tag text, Text text, Gender text, Plurality text);
CREATE TABLE IF NOT EXISTS Civup_Language_FR_FR (DateModified integer, Tag text, Text text, Gender text, Plurality text);
CREATE TABLE IF NOT EXISTS Civup_Language_IT_IT (DateModified integer, Tag text, Text text, Gender text, Plurality text);
CREATE TABLE IF NOT EXISTS Civup_Language_JA_JP (DateModified integer, Tag text, Text text, Gender text, Plurality text);
CREATE TABLE IF NOT EXISTS Civup_Language_PL_PL (DateModified integer, Tag text, Text text, Gender text, Plurality text);
CREATE TABLE IF NOT EXISTS Civup_Language_RU_RU (DateModified integer, Tag text, Text text, Gender text, Plurality text);
CREATE TABLE IF NOT EXISTS Civup_Language_ZH_CN (DateModified integer, Tag text, Text text, Gender text, Plurality text);
CREATE TABLE IF NOT EXISTS Language_ZH_CN (ID integer PRIMARY KEY, Tag text, Text text, Gender text, Plurality text);

CREATE TABLE IF NOT EXISTS
	Personalities (
	Type			text
);
	
CREATE TABLE IF NOT EXISTS
	Build_Flavors (
	BuildType		text REFERENCES Builds(Type),
	FlavorType		text REFERENCES Flavors(Type),
	Flavor			integer
);
	
CREATE TABLE IF NOT EXISTS
	Plots (
	ID				integer PRIMARY KEY,
	Type			text NOT NULL UNIQUE ,
	Description		text,
	Civilopedia		text
);
	
CREATE TABLE IF NOT EXISTS
	Building_Addons (
	BuildingType		text REFERENCES Buildings(Type),
	ParentBuildingClass	text REFERENCES BuildingClasses(Type)
);
	
CREATE TABLE IF NOT EXISTS
	Building_InstantYield (
	BuildingType	text REFERENCES Buildings(Type),
	YieldType		text,
	Yield			integer NOT NULL 
);
	
CREATE TABLE IF NOT EXISTS
	Building_NearestPlotYieldChanges (
	BuildingType	text REFERENCES Buildings(Type),
	PlotType		text,
	YieldType		text REFERENCES Yields(Type),
	Yield			integer NOT NULL 
);
	
CREATE TABLE IF NOT EXISTS
	Building_PlotsYieldChanges (
	BuildingType	text REFERENCES Buildings(Type),
	PlotType		text,
	YieldType		text REFERENCES Yields(Type),
	Yield			integer NOT NULL 
);
	
CREATE TABLE IF NOT EXISTS
	Building_PrereqBuildingClassesPercentage (
	BuildingType			text REFERENCES Buildings(Type),
	BuildingClassType		text REFERENCES BuildingClasses(Type),
	PercentBuildingNeeded	integer default 0
);
	
CREATE TABLE IF NOT EXISTS
	PromotionClasses (
	ID				integer PRIMARY KEY,
	Type			text NOT NULL UNIQUE ,
	Description		text
);
	
CREATE TABLE IF NOT EXISTS
	Trait_FreePromotionUnitTypes (
	TraitType		text REFERENCES Traits(Type),
	UnitType		text REFERENCES Units(Type),
	PromotionType	text REFERENCES UnitPromotions(Type)
);
	
CREATE TABLE IF NOT EXISTS
	Trait_FreeExperience_Domains (
	TraitType		text REFERENCES Traits(Type),
	DomainType		text REFERENCES Domains(Type),
	Experience		integer default 0
);
	
CREATE TABLE IF NOT EXISTS
	Trait_FreeUnitAtTech (
	TraitType		text REFERENCES Traits(Type),
	TechType		text REFERENCES Technologies(Type),
	UnitClassType	text REFERENCES UnitClasses(Type)
);
	
CREATE TABLE IF NOT EXISTS
	Trait_GoldenAgeYieldModifier (
	TraitType		text REFERENCES Traits(Type),
	YieldType		text,
	YieldMod		integer default 0
);
	
CREATE TABLE IF NOT EXISTS
	Trait_LuxuryYieldModifier (
	TraitType		text REFERENCES Traits(Type),
	YieldType		text,
	YieldMod		integer default 0
);
	
CREATE TABLE IF NOT EXISTS
	Trait_YieldFromConstructionInCapital (
	TraitType		text REFERENCES Traits(Type),
	BuildingType	text REFERENCES Buildings(Type),
	YieldType		text,
	Yield			integer default 0,
	YieldMod		integer default 0
);
	
CREATE TABLE IF NOT EXISTS
	Trait_YieldFromConstruction (
	TraitType		text REFERENCES Traits(Type),
	BuildingType	text REFERENCES Buildings(Type),
	YieldType		text,
	Yield			integer default 0
);
	
CREATE TABLE IF NOT EXISTS
	Handicap_Yield (
	HandicapType	text REFERENCES HandicapInfos(Type),
	YieldType		text,
	Yield			integer default 0
);
	
CREATE TABLE IF NOT EXISTS
	Policy_FreePromotionUnitClasses (
	PolicyType		text REFERENCES Policies(Type),
	UnitClass		text REFERENCES UnitClasses(Type),
	PromotionType	text REFERENCES UnitPromotions(Type)
);
	
CREATE TABLE IF NOT EXISTS
	Policy_FreeBuildingFlavor (
	PolicyType		text REFERENCES Policies(Type),
	FlavorType		text,
	NumCities		integer default 0
);
	
CREATE TABLE IF NOT EXISTS
	Policy_FreeBuildingClass (
	PolicyType		text REFERENCES Policies(Type),
	BuildingClass	text REFERENCES BuildingClasses(Type),
	NumCities		integer default 0
);
	
CREATE TABLE IF NOT EXISTS
	Policy_FreeUnitFlavor (
	PolicyType		text REFERENCES Policies(Type),
	FlavorType		text,
	Count			integer default 0
);
	
CREATE TABLE IF NOT EXISTS
	Policy_InstantYield (
	PolicyType		text REFERENCES Policies(Type),
	YieldType		text,
	Yield			integer NOT NULL 
);
	
CREATE TABLE IF NOT EXISTS
	Policy_InstantYieldEra (
	PolicyType		text REFERENCES Policies(Type),
	YieldType		text,
	Yield			integer NOT NULL 
);
	
CREATE TABLE IF NOT EXISTS
	Policy_InstantYieldTurns (
	PolicyType		text REFERENCES Policies(Type),
	YieldType		text,
	Turns			integer NOT NULL 
);
	
CREATE TABLE IF NOT EXISTS
	Policy_PlayerYieldModifiers (
	PolicyType		text REFERENCES Policies(Type),
	YieldType		text,
	YieldMod		integer NOT NULL 
);
	
CREATE TABLE IF NOT EXISTS
	Policy_CityWithSpecialistYieldChanges (
	PolicyType		text REFERENCES Policies(Type),
	SpecialistType	text REFERENCES Specialists(Type),
	SpecialistCount	integer default 1,
	YieldType		text REFERENCES Yields(Type),
	Yield			integer NOT NULL 
);
	
CREATE TABLE IF NOT EXISTS
	Policy_SpecialistYieldChanges (
	PolicyType		text REFERENCES Policies(Type),
	SpecialistType	text REFERENCES Specialists(Type),
	YieldType		text REFERENCES Yields(Type),
	Yield			integer NOT NULL 
);
	
CREATE TABLE IF NOT EXISTS
	Policy_ReligiousCityYieldChanges (
	PolicyType		text REFERENCES Policies(Type),
	YieldType		text REFERENCES Yields(Type),
	Yield			integer NOT NULL 
);
	
CREATE TABLE IF NOT EXISTS
	Policy_UnitClassProductionModifiers (
	PolicyType			text REFERENCES Policies(Type),
	UnitClassType		text REFERENCES UnitClasses(Type),
	ProductionModifier	integer
);
	
	
CREATE TABLE IF NOT EXISTS
	UnitPromotions_Equivilancy (
	Melee			text,
	Ranged			text,
	Vanguard		text
);
	
CREATE TABLE IF NOT EXISTS
	UnitPromotions_Grid (
	PromotionType	text REFERENCES UnitPromotions(Type),
	UnitCombatType	text REFERENCES UnitCombatInfos(Type),
	Base			boolean default true,
	GridX			integer,
	GridY			integer
);
	
CREATE TABLE IF NOT EXISTS
	Resource_TerrainWeights (
	ResourceType	text REFERENCES Resources(Type),
	TerrainType		text REFERENCES Terrains(Type),
	FeatureType		text default NULL,
	PlotType		text default NULL,
	Freshwater		boolean default false,
	NotLake			boolean default false,
	Weight			variant default 1
);
	
CREATE TABLE IF NOT EXISTS
	Technology_DomainPromotion (
	TechType		text REFERENCES Technologies(Type),
	DomainType		text REFERENCES Domains(Type),
	PromotionType	text REFERENCES UnitPromotions(Type)
);




--
-- Done
--
UPDATE LoadedFile SET Value=1 WHERE Type='Civup_AlterTables.sql';