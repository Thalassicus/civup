INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-04-07'), 'TXT_KEY_IMPROVEMENT_TRADING_POST', 'Pueblo', '', '');
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-03-15'), 'TXT_KEY_CIV5_IMPROVEMENTS_TRADING_POST_TEXT', 'Un pueblo es una agrupación de personas en un asentamiento o una comunidad, con una población que van desde unos pocos cientos a unos pocos miles. Estos pequeños asentamientos también agregan a la economía de la sociedad.', '', '');
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-04-07'), 'TXT_KEY_CIV5_IMPROVEMENTS_TRADINGPOST', 'Pueblo', '', '');
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-03-15'), 'TXT_KEY_GOLD_TRADINGPOST_ADV_QUEST', '¿El pueblo proporciona oro?', '', '');
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-03-15'), 'TXT_KEY_GOLD_TRADINGPOST_HEADING3_BODY', 'Construir la mejora “Pueblo” en una casilla para aumentar su producción de oro.', '', '');
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-04-07'), 'TXT_KEY_GOLD_TRADINGPOST_HEADING3_TITLE', 'El pueblo', '', '');
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-03-15'), 'TXT_KEY_WORKERS_TRADINGPOST_HEADING3_BODY', 'Un pueblo aumenta la producción de una casilla en 1 de oro. No tiene acceso a los recursos de la casilla. [NEWLINE] Tecnología necesaria: Caza con trampas. [NEWLINE] Tiempo de construcción: 5 turnos [NEWLINE] Puede ser construido en: Cualquier casilla de tierra excepto el hielo.', '', '');
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-03-15'), 'TXT_KEY_POLICY_FREE_THOUGHT_HELP', '[COLOR_POSITIVE_TEXT]Libre pensamiento[ENDCOLOR][NEWLINE]+1 de ciencia [ICON_RESEARCH] en los pueblos.[NEWLINE]+17% de ciencia [ICON_RESEARCH] por las universidades.', '', '');
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-04-07'), 'TXT_KEY_BUILD_TRADING_POST', 'Construye un [LINK=IMPROVEMENT_TRADING_POST]Pueblo[\LINK]', '', '');
INSERT INTO Civup_Language_ES_ES (DateModified, Tag, Text, Gender, Plurality) VALUES (date('2013-03-15'), 'TXT_KEY_BUILD_GOLD_REC', 'Se aumentará la cantidad de oro [ICON_GOLD] proporcionada por esta casilla, ¡Aumentando la cantidad de dinero que tendrá que gastar!', '', '');

UPDATE LoadedFile SET Value=1 WHERE Type='Civup_Villages.sql';
