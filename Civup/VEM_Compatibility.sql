UPDATE Units
SET Cost = ROUND((Cost * 1.2) / 10) * 10
WHERE Cost > 0
AND EXISTS (SELECT LOADED_VEM FROM Defines WHERE Value = 1);

UPDATE Buildings
SET Cost = ROUND((Cost * 1.2) / 10) * 10
WHERE Cost > 0
AND EXISTS (SELECT LOADED_VEM FROM Defines WHERE Value = 1);

UPDATE Buildings
SET NumCityCostMod = ROUND((NumCityCostMod * 1.2) / 10) * 10
WHERE NumCityCostMod > 0
AND EXISTS (SELECT LOADED_VEM FROM Defines WHERE Value = 1);

UPDATE Projects
SET Cost = ROUND((Cost * 1.2) / 10) * 10
WHERE Cost > 0
AND EXISTS (SELECT LOADED_VEM FROM Defines WHERE Value = 1);

UPDATE Units
SET ExtraMaintenanceCost = 1
WHERE Cost > 0 AND (Combat = 0 AND RangedCombat = 0)
AND EXISTS (SELECT LOADED_VEM FROM Defines WHERE Value = 1);

UPDATE Units
SET ExtraMaintenanceCost = MAX(1, ROUND(Cost / 50 + MAX(Combat, RangedCombat) / 5 - 1, 0))
WHERE Cost > 0 AND (Combat > 0 OR RangedCombat > 0)
AND EXISTS (SELECT LOADED_VEM FROM Defines WHERE Value = 1);

UPDATE Units
SET ExtraMaintenanceCost = MAX(1, ROUND(0.5 * ExtraMaintenanceCost, 0))
WHERE ExtraMaintenanceCost > 0 AND (
	Domain = 'DOMAIN_AIR'
)
AND EXISTS (SELECT LOADED_VEM FROM Defines WHERE Value = 1);

UPDATE Units
SET ExtraMaintenanceCost = MAX(1, ROUND(0.67 * ExtraMaintenanceCost, 0))
WHERE ExtraMaintenanceCost > 0 AND (
	CombatClass = 'UNITCOMBAT_RECON'
	OR Domain = 'DOMAIN_SEA'
)
AND EXISTS (SELECT LOADED_VEM FROM Defines WHERE Value = 1);