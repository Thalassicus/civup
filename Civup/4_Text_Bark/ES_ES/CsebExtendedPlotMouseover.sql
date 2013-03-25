--· ES_ES/CsebExtendedPlotMouseover.sql
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-03-14'), 'TXT_KEY_CSB_PLOTROLL_IMPROVEMENTS_REQUIRED_FOR_RESOURCE', '(con {1})', '', '');
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-03-14'), 'TXT_KEY_CSB_PLOTROLL_IMPROVEMENT_UNDER_CONSTRUCTION', '[COLOR_YELLOW]{1} ([ENDCOLOR][COLOR_POSITIVE_TEXT]{2}[ENDCOLOR][COLOR_YELLOW])[ENDCOLOR]', '', '');
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-03-14'), 'TXT_KEY_CSB_PLOTROLL_LABEL_DEFENSE', 'Defensa.', '', '');
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-03-14'), 'TXT_KEY_CSB_PLOTROLL_LABEL_DEFENSE_BLOCK_SIMPLE', '[COLOR_POSITIVE_TEXT]Modif. Defensa[ENDCOLOR] : {1}%', '', '');
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-03-14'), 'TXT_KEY_CSB_PLOTROLL_LABEL_YIELDS_ACTUAL', '[COLOR_POSITIVE_TEXT]Rendimientos[ENDCOLOR] : {1}', '', '');
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-03-14'), 'TXT_KEY_CSB_PLOTROLL_LABEL_YIELDS_WITHOUTFEATURE', '{2} [COLOR_YELLOW]sin {1}[ENDCOLOR]', '', '');
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-03-14'), 'TXT_KEY_CSB_PLOTROLL_LABEL_YIELDS_WITHIMPROVEMENT', '{2} [COLOR_YELLOW]con {1}[ENDCOLOR]', '', '');
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-03-14'), 'TXT_KEY_CSB_PLOTROLL_HELP_PRESS_FOR_MORE', '[COLOR_GREY](presione ALT para más info.)[ENDCOLOR]', '', '');
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-03-14'), 'TXT_KEY_CSB_PLOTROLL_LABEL_DEFENSE_BLOCK_PLUS', 'Modif. Defensa : [COLOR_GREEN]+{1}%[ENDCOLOR]', '', '');
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-03-14'), 'TXT_KEY_CSB_PLOTROLL_LABEL_DEFENSE_BLOCK_MINUS', 'Modif. Defensa : [COLOR_RED]{1}%[ENDCOLOR]', '', '');
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-03-14'), 'TXT_KEY_PLOTROLL_REQUIRES_TECH_TO_USE', '[COLOR_WARNING_TEXT]({@1_TechName} para comerciar)[ENDCOLOR]', '', '');


UPDATE LoadedFile SET Value=1 WHERE Type='Civup_CsebExtendedPlotMouseover.sql';
