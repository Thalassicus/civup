-- This AT_BuildingStats.sql data from:
-- BuildingStats tab of Civup_Details.xls spreadsheet (in mod folder).

-- Header --

INSERT INTO BuildingFields(ID, Section, Priority, Dynamic, Type, Value) VALUES (0, 0,  1, 1, 'Name'                        , 'Game.GetDefaultBuildingFieldText');


-- Special Abilities --

INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 78, 0, 'Capital'                            , 'civup_BuildingInfo.Capital');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 77, 0, 'GoldenAge'                          , 'civup_BuildingInfo.GoldenAge');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 76, 0, 'FreeGreatPeople'                    , 'civup_BuildingInfo.FreeGreatPeople');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 75, 0, 'FreeUnits'                          , 'Game.HasValue({BuildingType=civup_BuildingInfo.Type}, GameInfo.Building_FreeUnits)');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 74, 0, 'FreeBuildingThisCity'               , 'civup_BuildingInfo.FreeBuildingThisCity');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 73, 0, 'FreeBuilding'                       , 'civup_BuildingInfo.FreeBuilding');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 72, 0, 'FreeResources'                      , 'Game.HasValue({BuildingType=civup_BuildingInfo.Type}, GameInfo.Building_ResourceQuantity)');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 71, 0, 'TrainedFreePromotion'               , 'civup_BuildingInfo.TrainedFreePromotion and Locale.ConvertTextKey(GameInfo.UnitPromotions[civup_BuildingInfo.TrainedFreePromotion].Help) or false');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 70, 0, 'MapCentering'                       , 'civup_BuildingInfo.MapCentering');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 69, 0, 'AllowsWaterRoutes'                  , 'civup_BuildingInfo.AllowsWaterRoutes');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 68, 0, 'ExtraLuxuries'                      , 'civup_BuildingInfo.ExtraLuxuries');

INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 67, 0, 'DiplomaticVoting'                   , 'civup_BuildingInfo.DiplomaticVoting');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 66, 0, 'GreatGeneralRateModifier'           , 'civup_BuildingInfo.GreatGeneralRateModifier');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 65, 0, 'GoldenAgeModifier'                  , 'civup_BuildingInfo.GoldenAgeModifier');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 64, 0, 'UnitUpgradeCostMod'                 , 'civup_BuildingInfo.UnitUpgradeCostMod');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 63, 0, 'CityCountUnhappinessMod'            , 'civup_BuildingInfo.CityCountUnhappinessMod');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 62, 0, 'WorkerSpeedModifier'                , 'civup_BuildingInfo.WorkerSpeedModifier');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 61, 0, 'CapturePlunderModifier'             , 'civup_BuildingInfo.CapturePlunderModifier');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 60, 0, 'PolicyCostModifier'                 , 'civup_BuildingInfo.PolicyCostModifier');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 59, 0, 'GlobalInstantBorderRadius'          , 'civup_BuildingInfo.GlobalInstantBorderRadius');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 58, 0, 'PlotCultureCostModifier'            , 'civup_BuildingInfo.PlotCultureCostModifier');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 57, 0, 'PlotBuyCostModifier'                , 'civup_BuildingInfo.PlotBuyCostModifier');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 56, 0, 'GlobalPlotCultureCostModifier'      , 'civup_BuildingInfo.GlobalPlotCultureCostModifier');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 55, 0, 'GlobalPlotBuyCostModifier'          , 'civup_BuildingInfo.GlobalPlotBuyCostModifier');

INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 54, 0, 'FoundsReligion'                     , 'civup_BuildingInfo.FoundsReligion');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 53, 0, 'IsReligious'                        , 'civup_BuildingInfo.IsReligious');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 52, 0, 'Airlift'                            , 'civup_BuildingInfo.Airlift');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 51, 0, 'NukeExplosionRand'                  , 'civup_BuildingInfo.NukeExplosionRand');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 50, 0, 'ExtraMissionarySpreads'             , 'civup_BuildingInfo.ExtraMissionarySpreads');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 49, 0, 'EspionageModifier'                  , 'civup_BuildingInfo.EspionageModifier');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 48, 0, 'GlobalEspionageModifier'            , 'civup_BuildingInfo.GlobalEspionageModifier');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 47, 0, 'ExtraSpies'                         , 'civup_BuildingInfo.ExtraSpies');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 46, 0, 'SpyRankChange'                      , 'civup_BuildingInfo.SpyRankChange');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 45, 0, 'InstantSpyRankChange'               , 'civup_BuildingInfo.InstantSpyRankChange');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 44, 0, 'ProhibitedCityTerrain'              , 'civup_BuildingInfo.ProhibitedCityTerrain');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 43, 0, 'ReplacementBuildingClass'           , 'civup_BuildingInfo.ReplacementBuildingClass');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 42, 0, 'SpecialistExtraCulture'             , 'civup_BuildingInfo.SpecialistExtraCulture		');

INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 41, 0, 'GlobalPopulationChange'             , 'civup_BuildingInfo.GlobalPopulationChange');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 40, 0, 'TechShare'                          , 'civup_BuildingInfo.TechShare');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 39, 0, 'FreeTechs'                          , 'civup_BuildingInfo.FreeTechs');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 38, 0, 'FreePolicies'                       , 'civup_BuildingInfo.FreePolicies');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 37, 0, 'MinorFriendshipChange'              , 'civup_BuildingInfo.MinorFriendshipChange');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 36, 0, 'MinorFriendshipFlatChange'          , 'civup_BuildingInfo.MinorFriendshipFlatChange');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 35, 0, 'VictoryPoints'                      , 'civup_BuildingInfo.VictoryPoints');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 34, 0, 'BorderObstacle'                     , 'civup_BuildingInfo.BorderObstacle');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 33, 0, 'PlayerBorderObstacle'               , 'civup_BuildingInfo.PlayerBorderObstacle');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 32, 0, 'HealRateChange'                     , 'civup_BuildingInfo.HealRateChange');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 31, 0, 'MountainImprovement'                , 'civup_BuildingInfo.MountainImprovement and Locale.ConvertTextKey(GameInfo.Improvements[civup_BuildingInfo.MountainImprovement].Description) or false');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 30, 0, 'FreePromotion'                      , 'civup_BuildingInfo.FreePromotion and Locale.ConvertTextKey(GameInfo.UnitPromotions[civup_BuildingInfo.FreePromotion].Help) or false');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 29, 0, 'FreePromotionAllCombatUnits'        , 'civup_BuildingInfo.FreePromotionAllCombatUnits and Locale.ConvertTextKey(GameInfo.UnitPromotions[civup_BuildingInfo.FreePromotionAllCombatUnits].Help) or false');

INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 28, 0, 'TradeDealModifier'                  , 'civup_BuildingInfo.TradeDealModifier');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 27, 0, 'GlobalGreatPeopleRateModifier'      , 'civup_BuildingInfo.GlobalGreatPeopleRateModifier');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 26, 1, 'UnmoddedHappiness'                  , 'Game.GetDefaultBuildingFieldText');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 25, 1, 'Happiness'                          , 'Game.GetDefaultBuildingFieldText');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 24, 0, 'HappinessPerCity'                   , 'civup_BuildingInfo.HappinessPerCity');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 23, 0, 'HappinessPerXPolicies'              , 'civup_BuildingInfo.HappinessPerXPolicies');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 22, 0, 'UnhappinessModifier'                , 'civup_BuildingInfo.UnhappinessModifier');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 21, 0, 'NoOccupiedUnhappiness'              , 'civup_BuildingInfo.NoOccupiedUnhappiness');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 20, 0, 'InstantHappiness'                   , 'civup_BuildingInfo.InstantHappiness');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 19, 0, 'GoldenAgePoints'                    , 'civup_BuildingInfo.GoldenAgePoints');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 18, 0, 'Experience'                         , 'civup_BuildingInfo.Experience');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 17, 0, 'ExperienceDomain'                   , 'Game.HasValue({BuildingType=civup_BuildingInfo.Type}, GameInfo.Building_DomainFreeExperiences)');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 16, 0, 'ExperienceCombat'                   , 'Game.HasValue({BuildingType=civup_BuildingInfo.Type}, GameInfo.Building_UnitCombatFreeExperiences)');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 15, 0, 'ExperiencePerTurn'                  , 'civup_BuildingInfo.ExperiencePerTurn		');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 14, 0, 'GlobalExperience'                   , 'civup_BuildingInfo.GlobalExperience');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 13, 0, 'Defense'                            , 'civup_BuildingInfo.Defense / 100');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 12, 0, 'GlobalDefenseMod'                   , 'civup_BuildingInfo.GlobalDefenseMod');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 11, 0, 'ExtraCityHitPoints'                 , 'civup_BuildingInfo.ExtraCityHitPoints');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1, 10, 0, 'AirModifier'                        , 'civup_BuildingInfo.AirModifier');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1,  9, 0, 'NukeModifier'                       , 'civup_BuildingInfo.NukeModifier');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1,  8, 0, 'YieldModInAllCities'                , 'Game.HasValue({BuildingType=civup_BuildingInfo.Type}, GameInfo.Building_GlobalYieldModifiers)');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1,  7, 0, 'YieldFromUsingGreatPeople'          , 'civup_BuildingInfo.GreatPersonExpendGold');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1,  6, 0, 'YieldModHurry'                      , 'Game.HasValue({BuildingType=civup_BuildingInfo.Type}, GameInfo.Building_HurryModifiers)');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1,  5, 0, 'TradeRouteModifier'                 , 'civup_BuildingInfo.TradeRouteModifier');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1,  4, 0, 'MedianTechPercentChange'            , 'civup_BuildingInfo.MedianTechPercentChange * 2');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1,  3, 0, 'InstantBorderRadius'                , 'civup_BuildingInfo.InstantBorderRadius');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1,  2, 0, 'InstantBorderPlots'                 , 'Game.HasValue({BuildingType=civup_BuildingInfo.Type}, GameInfo.Building_PlotsYieldChanges)');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1,  1, 0, 'ReligiousPressureModifier'          , 'civup_BuildingInfo.ReligiousPressureModifier');


-- Abilities --

INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (2,  2, 0, 'SpecialistType'                     , 'civup_BuildingInfo.SpecialistType');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (2,  1, 0, 'GreatGeneralRateChange'             , 'civup_BuildingInfo.GreatGeneralRateChange');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (2,  1, 0, 'GreatPeopleRateModifier'            , 'civup_BuildingInfo.GreatPeopleRateModifier');

-- Yields --
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (3, 23, 0, 'YieldPerPop'                        , 'Game.HasValue({BuildingType=civup_BuildingInfo.Type}, GameInfo.Building_YieldChangesPerPop)');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (3, 22, 1, 'YieldInstant'                       , 'Game.GetDefaultBuildingFieldText');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (3, 21, 1, 'YieldChange'                        , 'Game.GetDefaultBuildingFieldText');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (3, 20, 0, 'YieldFromPlots'                     , 'Game.HasValue({BuildingType=civup_BuildingInfo.Type}, GameInfo.Building_PlotYieldChanges)');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (3, 19, 0, 'YieldFromSea'                       , 'Game.HasValue({BuildingType=civup_BuildingInfo.Type}, GameInfo.Building_SeaPlotYieldChanges)');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (3, 18, 0, 'YieldFromLakes'                     , 'Game.HasValue({BuildingType=civup_BuildingInfo.Type}, GameInfo.Building_LakePlotYieldChanges)');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (3, 17, 0, 'YieldFromTerrain'                   , 'Game.HasValue({BuildingType=civup_BuildingInfo.Type}, GameInfo.Building_TerrainYieldChanges)');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (3, 16, 0, 'YieldFromRivers'                    , 'Game.HasValue({BuildingType=civup_BuildingInfo.Type}, GameInfo.Building_RiverPlotYieldChanges)');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (3, 15, 0, 'YieldFromFeatures'                  , 'Game.HasValue({BuildingType=civup_BuildingInfo.Type}, GameInfo.Building_FeatureYieldChanges)');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (3, 14, 0, 'YieldFromResources'                 , 'Game.HasValue({BuildingType=civup_BuildingInfo.Type}, GameInfo.Building_ResourceYieldChanges)');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (3, 13, 0, 'YieldFromSpecialists'               , 'Game.HasValue({BuildingType=civup_BuildingInfo.Type}, GameInfo.Building_SpecialistYieldChanges)');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (3, 12, 0, 'YieldFromTech'                      , 'Game.HasValue({BuildingType=civup_BuildingInfo.Type}, GameInfo.Building_TechEnhancedYieldChanges)');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (3, 11, 0, 'YieldFromBuildings'                 , 'Game.HasValue({BuildingType=civup_BuildingInfo.Type}, GameInfo.Building_BuildingClassYieldChanges)');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (3, 10, 1, 'YieldMod'                           , 'Game.GetDefaultBuildingFieldText');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (3,  9, 0, 'YieldModFromBuildings'              , 'Game.HasValue({BuildingType=civup_BuildingInfo.Type}, GameInfo.Building_BuildingClassYieldModifiers)');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (3,  8, 0, 'YieldModMilitary'                   , 'civup_BuildingInfo.MilitaryProductionModifier');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (3,  7, 0, 'YieldModDomain'                     , 'Game.HasValue({BuildingType=civup_BuildingInfo.Type}, GameInfo.Building_DomainProductionModifiers)');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (3,  6, 0, 'YieldModCombat'                     , 'Game.HasValue({BuildingType=civup_BuildingInfo.Type}, GameInfo.Building_UnitCombatProductionModifiers)');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (3,  5, 0, 'YieldModBuilding'                   , 'civup_BuildingInfo.BuildingProductionModifier');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (3,  4, 0, 'YieldModWonder'                     , 'civup_BuildingInfo.WonderProductionModifier');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (3,  3, 0, 'YieldModSpace'                      , 'civup_BuildingInfo.SpaceProductionModifier');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (3,  2, 0, 'YieldModSurplus'                    , 'Game.HasValue({BuildingType=civup_BuildingInfo.Type}, GameInfo.Building_YieldSurplusModifiers)');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (3,  1, 0, 'YieldStorage'                       , 'civup_BuildingInfo.FoodKept');

INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (4,  1, 1, 'Replaces'                           , 'Game.GetDefaultBuildingFieldText');


-- Requirements --

INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (5, 30, 1, 'Cost'                               , 'Game.GetDefaultBuildingFieldText');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (5, 29, 1, 'NumCityCostMod'                     , 'Game.GetDefaultBuildingFieldText');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (5, 28, 1, 'PopCostMod'                         , 'Game.GetDefaultBuildingFieldText');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (5, 27, 1, 'HurryCostModifier'                  , 'Game.GetDefaultBuildingFieldText');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (5, 26, 1, 'GoldMaintenance'                    , 'Game.GetDefaultBuildingFieldText');

INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (5, 25, 0, 'NotFeature'                         , 'civup_BuildingInfo.NotFeature');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (5, 24, 0, 'NearbyTerrainRequired'              , 'civup_BuildingInfo.NearbyTerrainRequired');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (5, 23, 0, 'Water'                              , 'civup_BuildingInfo.Water');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (5, 22, 0, 'River'                              , 'civup_BuildingInfo.River');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (5, 21, 0, 'FreshWater'                         , 'civup_BuildingInfo.FreshWater and (civup_BuildingInfo.BuildingClass ~= "BUILDINGCLASS_GARDEN")');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (5, 20, 0, 'Mountain'                           , 'civup_BuildingInfo.Mountain');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (5, 19, 0, 'NearbyMountainRequired'             , 'civup_BuildingInfo.NearbyMountainRequired');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (5, 18, 0, 'Hill'                               , 'civup_BuildingInfo.Hill');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (5, 17, 0, 'Flat'                               , 'civup_BuildingInfo.Flat');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (5, 16, 0, 'HolyCity'                           , 'civup_BuildingInfo.HolyCity');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (5, 15, 0, 'RequiresTech'                       , 'Game.HasValue({BuildingType=civup_BuildingInfo.Type}, GameInfo.Building_TechAndPrereqs)');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (5, 14, 0, 'RequiresBuilding'                   , 'Game.HasValue({BuildingType=civup_BuildingInfo.Type}, GameInfo.Building_ClassesNeededInCity) and not civup_BuildingInfo.OnlyAI');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (5, 13, 0, 'RequiresBuildingInCities'           , 'Game.HasValue({BuildingType=civup_BuildingInfo.Type}, GameInfo.Building_PrereqBuildingClasses)');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (5, 12, 0, 'RequiresBuildingInPercentCities'    , 'Game.HasValue({BuildingType=civup_BuildingInfo.Type}, GameInfo.Building_PrereqBuildingClassesPercentage)');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (5, 11, 0, 'RequiresNearAll'                    , 'Game.HasValue({BuildingType=civup_BuildingInfo.Type}, GameInfo.Building_LocalResourceAnds)');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (5, 10, 0, 'RequiresNearAny'                    , 'Game.HasValue({BuildingType=civup_BuildingInfo.Type}, GameInfo.Building_LocalResourceOrs)');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (5,  9, 0, 'RequiresResourceConsumption'        , 'Game.HasValue({BuildingType=civup_BuildingInfo.Type}, GameInfo.Building_ResourceQuantityRequirements)');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (1,  1, 0, 'UnlockedByBelief'                   , 'civup_BuildingInfo.UnlockedByBelief');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (5,  8, 0, 'ObsoleteTech'                       , 'civup_BuildingInfo.ObsoleteTech and Locale.ConvertTextKey(GameInfo.Technologies[civup_BuildingInfo.ObsoleteTech].Description)');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (5,  7, 1, 'AlreadyBuilt'                       , 'Game.GetDefaultBuildingFieldText');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (5,  6, 0, 'MinAreaSize'                        , '(civup_BuildingInfo.MinAreaSize ~= -1) and civup_BuildingInfo.MinAreaSize');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (5,  5, 0, 'CitiesPrereq'                       , 'civup_BuildingInfo.CitiesPrereq');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (5,  4, 0, 'LevelPrereq'                        , 'civup_BuildingInfo.LevelPrereq');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (5,  3, 0, 'NationalLimit'                      , 'civup_BuildingClassInfo.MaxPlayerInstances');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (5,  2, 0, 'TeamLimit'                          , 'civup_BuildingClassInfo.MaxTeamInstances');
INSERT INTO BuildingFields(Section, Priority, Dynamic, Type, Value) VALUES (5,  1, 0, 'WorldLimit'                         , 'civup_BuildingClassInfo.MaxGlobalInstances');
