--· ES_ES/FreeResearchBalance.sql
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-03-14'), 'TXT_KEY_MISSION_DISCOVER_ME', 'Investigación de Tecnología.', '', '');
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-03-14'), 'TXT_KEY_MISSION_DISCOVER_ME_HELP', 'Agrega {1_num} [ICON_RESEARCH] de ciencia a su [COLOR_POSITIVE_TEXT] actual [ENDCOLOR] investigación de tecnología, sin [COLOR_NEGATIVE_TEXT] desbordamiento [ENDCOLOR] para la próxima tecnología.', '', '');
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-03-14'), 'TXT_KEY_MISSION_DISCOVER_ME_DISABLED_HELP', 'No se puede generar más investigación por {1_num} turnos.', '', '');

UPDATE LoadedFile SET Value=1 WHERE Type='Civup_FreeResearchBalance.sql';
