--· ES_ES/Opportunities.sql
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-04-09'), 'TXT_KEY_USER_EVENT_OPTION_SELECT', 'Seleccionar', '', '');
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-04-09'), 'TXT_KEY_USER_EVENT_OPTION_OK', 'Esta bien', '', '');
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-04-09'), 'TXT_KEY_DISTANT_PLAYER', 'un jugador insatisfecho', '', '');
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-04-09'), 'TXT_KEY_DISTANT_CITY', 'una ciudad distante', '', '');
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-04-09'), 'TXT_KEY_DISTANT_UNIT', 'unidad distante', '', '');
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-03-14'), 'TXT_KEY_TRIGGER_YIELD_COST', '{1_iconstring} Coste: {2_sign}{3_num}', '', '');
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-03-14'), 'TXT_KEY_TRIGGER_YIELD_PER_TURN', '{1_iconstring} {2_yieldname}: {3_sign}{4_yield}', '', '');

UPDATE LoadedFile SET Value=1 WHERE Type='Civup_Opportunities.sql';
