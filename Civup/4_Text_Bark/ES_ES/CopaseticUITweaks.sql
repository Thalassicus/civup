--· ES_ES/CopaseticUITweaks.sql
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-03-14'), 'TXT_KEY_CITY_CONNECTED', 'Puede comerciar con la [ICON_CAPITAL] Capital por carretaras o rutas marítimas.', '', '');
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-03-14'), 'TXT_KEY_CITY_CONNECTED_RAILROAD', 'Puede comerciar con la [ICON_CAPITAL] Capital por ferrocariles o rutas marítimas.', '', '');

UPDATE LoadedFile SET Value=1 WHERE Type='Civup_CopaseticUITweaks.sql';
