-- Insert SQL Rules Here 

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

UPDATE Era_NewEraVOs SET VOScript = "" WHERE EXISTS
(Select Value FROM Civup Where Type='PLAY_SPEECH_ERAS' AND Value=0);

