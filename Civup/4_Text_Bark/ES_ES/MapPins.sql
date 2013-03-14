--· ES_ES/MapPins.sql
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-03-14'), 'TXT_KEY_MAPPINS_CONTEXT_EDIT', 'Editar.', '', '');
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-03-14'), 'TXT_KEY_MAPPINS_CONTEXT_MOVE', 'Mover.', '', '');
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-03-14'), 'TXT_KEY_MAPPINS_CONTEXT_DELETE', 'Eliminar.', '', '');
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-03-14'), 'TXT_KEY_MAPPINS_POPUP_EDIT_TITLE', 'Ingrese detalles al marcador.', '', '');
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-03-14'), 'TXT_KEY_MAPPINS_POPUP_DELETE_TITLE', '¿Eliminar este marcador?', '', '');
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-03-14'), 'TXT_KEY_MAPPINS_LIST_TT', 'Clic para ver, clic-derecho para editar, shift-clic-derecho para eliminar.', '', '');
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-03-14'), 'TXT_KEY_MAPPINS_LIST_TYPE', 'Tipo.', '', '');
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-03-14'), 'TXT_KEY_MAPPINS_LIST_SORT_TYPE', 'Ordenar por tipo.', '', '');
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-03-14'), 'TXT_KEY_MAPPINS_LIST_TEXT', 'Notas.', '', '');
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-03-14'), 'TXT_KEY_MAPPINS_LIST_SORT_TEXT', 'Ordenar por notas.', '', '');
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-03-14'), 'TXT_KEY_MAPPINS_LIST_TOGGLE_TT', 'Mostrar/Ocultar marcadores.', '', '');
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-03-14'), 'TXT_KEY_TERRAIN_MAP_PINS_ADV_QUEST', '¿Como puedo ingresar notas en el mapa?', '', '');
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-03-14'), 'TXT_KEY_TERRAIN_MAP_PINS_HEADING3_BODY', 'Los marcadores permiten agregar notas a los mapas (tanto en la vista principal como en la estratégica). [NEWLINE] [NEWLINE] Pulse Control-X y, a continuación, haga clic en el mapa para colocar uno o más marcadores. Pulse Control-X de nuevo para volver al modo mapa normal. [NEWLINE] [NEWLINE] Pase el ratón sobre un marcador para leer su nota. Haga clic-derecho sobre el marcador para editarlo, moverlo o borraro. [NEWLINE] [NEWLINE] Pulse Shift-X para activar o desactivar todos los marcadores.', '', '');
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-03-14'), 'TXT_KEY_TERRAIN_MAP_PINS_HEADING3_TITLE', 'Marcadores de mapa.', '', '');
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-03-14'), 'TXT_KEY_MAPPINS_FLAG_UNKNOWN', '[ICON_TEAM_11]', '', '');
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-03-14'), 'TXT_KEY_MAPPINS_FLAG_1', '[ICON_TEAM_2]', '', '');
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-03-14'), 'TXT_KEY_MAPPINS_FLAG_2', '[ICON_TEAM_3]', '', '');
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-03-14'), 'TXT_KEY_MAPPINS_FLAG_3', '[ICON_TEAM_9]', '', '');
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-03-14'), 'TXT_KEY_MAPPINS_FLAG_4', '[ICON_TEAM_5]', '', '');
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-03-14'), 'TXT_KEY_MAPPINS_FLAG_5', '[ICON_TEAM_7]', '', '');
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-03-14'), 'TXT_KEY_MAPPINS_FLAG_6', '[ICON_WAR]', '', '');
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-03-14'), 'TXT_KEY_MAPPINS_FLAG_7', '[ICON_CITY_STATE]', '', '');
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-03-14'), 'TXT_KEY_MAPPINS_FLAG_8', '[ICON_CAPITAL]', '', '');
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-03-14'), 'TXT_KEY_MAPPINS_FLAG_9', '[ICON_HAPPINESS_1]', '', '');
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-03-14'), 'TXT_KEY_MAPPINS_FLAG_10', '[ICON_STAR]', '', '');


UPDATE LoadedFile SET Value=1 WHERE Type='Civup_MapPins.sql';
