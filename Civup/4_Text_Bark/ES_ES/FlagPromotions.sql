--· ES_ES/FlagPromotions.sql
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-03-14'), 'TXT_KEY_MAP_OPTIONS_HIDE_UNIT_ICON', 'Iconos de unidades.', '', '');
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-03-14'), 'TXT_KEY_MAP_OPTIONS_HIDE_UNIT_ICON_TT', 'Mostrar iconos de unidades.', '', '');
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-03-14'), 'TXT_KEY_TOGGLE_FLAG_PROMOTIONS', 'Ascensos de unidades.', '', '');
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-03-14'), 'TXT_KEY_TOGGLE_FLAG_PROMOTIONS_TT', 'Mostrar ascensos de unidades(max 9)[NEWLINE] [NEWLINE][COLOR_POSITIVE_TEXT]CLIC DERECHO[/COLOR] para opciones.', '', '');


UPDATE LoadedFile SET Value=1 WHERE Type='Civup_FlagPromotions.sql';
