# Libreto final de la charla: UNIMAP

Duracion objetivo: 20 minutos de exposicion + 5 minutos de preguntas.

Enfoque: presentar un problema real de orientacion universitaria, mostrar una solucion funcional construida con Flutter y defender decisiones tecnicas con argumentos claros.

## Diapositiva 1. Portada

Tiempo sugerido: 1 minuto

Que decir:

"Hola, soy Jean Aucapina y hoy les presento UNIMAP, una aplicacion desarrollada con Flutter para resolver un problema cotidiano en campus universitarios: llegar a un aula con claridad, sin perdida de tiempo ni incertidumbre."

"La propuesta conecta mapa general, busqueda de aulas, planos por planta y funciones de apoyo academico en una sola experiencia multiplataforma."

## Diapositiva 2. Una escena demasiado conocida

Tiempo sugerido: 1.5 minutos

Que decir:

"El escenario inicial es simple: llegas al campus, identificas un bloque, pero aun no sabes planta, acceso ni aula exacta. En ese momento, casi siempre toca preguntar."

"Esa friccion, aunque parezca pequena, afecta puntualidad, confianza y experiencia de llegada. Ese fue el punto de partida del proyecto."

## Diapositiva 3. Lo dificil no es ubicar un punto, sino llegar con certeza

Tiempo sugerido: 1.5 minutos

Que decir:

"El problema real no era mostrar un punto en un mapa. Era guiar con certeza desde una escala amplia de campus hasta una escala fina de planta y aula."

"Por eso la app integra orientacion espacial y contexto de uso: visitante para llegada rapida, estudiante para continuidad academica."

## Diapositiva 4. Del nombre de un aula a una ruta entendible

Tiempo sugerido: 1.5 minutos

Que decir:

"La solucion se diseno como un flujo continuo: entrar, buscar, ubicar bloque, abrir planta y reconocer aula."

"La clave de producto es que la busqueda no termine en un punto muerto. Debe convertirse en una accion de llegada."

## Diapositiva 5. De la seleccion de perfil al aula en pasos

Tiempo sugerido: 1.5 minutos

Que decir:

"Existe una base comun para todos los usuarios: perfil, busqueda, mapa, planta, aula."

"Sobre esa base, el estudiante agrega continuidad con favoritos, horario, tareas y acceso a siguiente clase, sin romper el flujo principal de orientacion."

## Diapositiva 6. Lo que construi con Flutter

Tiempo sugerido: 2 minutos

Que decir:

"UNIMAP integra mapa interactivo del campus, busqueda de aulas, geolocalizacion, planos por planta, rutas e informacion de distancia y direccion."

"Para el perfil estudiante, la app incorpora ademas favoritos, horario editable y tareas, de modo que responda no solo a donde estoy, sino a que debo hacer ahora."

## Diapositiva 7. Una misma base, dos recorridos distintos

Tiempo sugerido: 1.5 minutos

Que decir:

"Una decision central fue evitar dos aplicaciones separadas. Se construyo una sola base tecnica con adaptacion por perfil."

"Esto reduce complejidad de mantenimiento y mantiene coherencia en experiencia y navegacion."

## Diapositiva 8. Del campus completo al detalle de una planta

Tiempo sugerido: 1.5 minutos

Que decir:

"UNIMAP conecta dos escalas: macro orientacion en campus y micro orientacion dentro de cada planta."

"Ese salto se sostiene con datos editables en JSON y con un editor visual de pisos, lo que permite ampliar cobertura sin reescribir toda la interfaz."

## Diapositiva 9. Lo que de verdad cambio la experiencia

Tiempo sugerido: 1.5 minutos

Que decir:

"Las decisiones de mayor impacto fueron: priorizar busqueda, separar perfiles, mantener datos editables, publicar en web y simplificar la pantalla inicial."

"Cuando el problema es espacial, la interfaz debe reducir carga cognitiva antes de agregar funciones avanzadas."

## Diapositiva 10. Por que Flutter

Tiempo sugerido: 1.5 minutos

Que decir:

"Flutter permitio una sola base de codigo para web, movil y escritorio, con interfaz consistente y ciclos de iteracion rapidos."

"El ecosistema fue suficiente para el caso: flutter_map para mapa, geolocator para ubicacion, provider para estado y shared_preferences para persistencia local."

## Diapositiva 11. Buenas practicas

Tiempo sugerido: 1.5 minutos

Que decir:

"La estructura de lib se organizo por responsabilidades: screens para vistas, services para logica, search para indexacion y busqueda, widgets para componentes reutilizables y models para entidades."

"Se aplicaron reglas operativas simples: widgets pequenos, const cuando aplica, logica fuera de build, y cierre tecnico con analyze, test y format."

## Diapositiva 12. Aprendizajes

Tiempo sugerido: 1.5 minutos

Que decir:

"Un aprendizaje clave fue que un problema local y bien definido puede generar alto valor practico."

"Tambien se confirmo que en productos de navegacion la calidad de datos es tan importante como la calidad visual."

## Diapositiva 13. Siguiente paso

Tiempo sugerido: 1.5 minutos

Que decir:

"Las siguientes lineas de trabajo son ampliar edificios y plantas, mejorar onboarding, refinar indicaciones y medir uso real para priorizar mejoras."

"El objetivo es consolidar una capa de orientacion universitaria robusta y extensible."

## Diapositiva 14. Cierre

Tiempo sugerido: 1 minuto

Que decir:

"Flutter no solo sirve para prototipos visuales. Tambien permite resolver problemas reales de movilidad y acceso a informacion en contexto universitario."

"Muchas gracias. Quedo atento a sus preguntas."

## Recomendaciones de exposicion

- Mantener tono conversacional y evitar lectura literal.
- En diapositivas 5 a 9, narrar el flujo como historia de usuario.
- En diapositiva 10, explicar Flutter desde impacto en producto.
- En diapositiva 11, enfatizar mantenibilidad antes que complejidad.
- Si el tiempo es corto, compactar diapositivas 9 y 11.

## Preguntas que pueden hacerte (con respuesta breve sugerida)

1. Por que no usar Google Maps directamente para todo?
Respuesta: porque el problema no termina en la calle. Necesitamos navegar interiores por planta y aula, y eso requiere datos propios y una vista especializada que Google Maps no ofrece de forma directa para este caso.

2. Por que Flutter y no nativo o React Native?
Respuesta: por velocidad de desarrollo, consistencia visual y cobertura multiplataforma con una sola base. Para este alcance, el costo-beneficio de Flutter fue mejor.

3. Que parte fue la mas dificil del proyecto?
Respuesta: mantener coherencia entre mapa exterior e interiores, especialmente en legibilidad de etiquetas y flujo continuo hasta aula.

4. Como se almacenan los datos de aulas y plantas?
Respuesta: en archivos JSON dentro de assets/data, con planos en assets/plans. El enfoque es guiado por datos para facilitar mantenimiento.

5. Como se manejan permisos de ubicacion?
Respuesta: con geolocator y manejo explicito de estados: servicio apagado, permiso denegado y denegado permanente.

6. La app funciona sin internet?
Respuesta: gran parte de la experiencia local si, porque los datos principales viven en assets y hay persistencia local. Servicios externos pueden variar segun plataforma y despliegue.

7. Que pruebas tienes actualmente?
Respuesta: pruebas de widget y pruebas de logica de ruta, incluyendo distancia, formato e instrucciones basicas.

8. Escala para otros campus?
Respuesta: si. Al estar guiado por datos y separacion por servicios, ampliar cobertura es principalmente trabajo de datos y validacion visual.

9. Por que usar Provider para estado?
Respuesta: porque el dominio actual requiere estado claro y simple. Provider permite buena legibilidad y bajo costo cognitivo para este tamano de proyecto.

10. Como evitaste que el proyecto se vuelva dificil de mantener?
Respuesta: separando responsabilidades, evitando logica de negocio en widgets y manteniendo pruebas de regresion sobre rutas.

## Preguntas tecnicas dificiles que deberias poder defender

1. Como conectas coordenadas del plano con una UI responsive?
Punto clave: usar posiciones normalizadas en el editor de pisos, no pixeles fijos. Asi se mantiene consistencia al cambiar tamano de pantalla o zoom.

2. Como justificas el modelo de rutas interior?
Punto clave: en esta version se prioriza claridad visual y control de datos sobre optimizacion algoritmica extrema. Es una base estable para evolucionar luego a pathfinding mas complejo.

3. Que trade-off hiciste al usar datos locales en JSON?
Punto clave: ganamos simplicidad, control y funcionamiento local; perdemos actualizacion centralizada en tiempo real. Es una decision adecuada para fase actual.

4. Como manejas saturacion visual en zonas con muchas aulas?
Punto clave: reglas de visibilidad dependientes de zoom y prioridad del aula objetivo para proteger legibilidad.

5. Como evitas jank o reconstrucciones costosas en Flutter?
Punto clave: componentes pequenos, const en widgets estables y separacion de estado para evitar repintados innecesarios.

6. Como argumentas que la arquitectura es mantenible?
Punto clave: separacion por capas funcionales, servicios dedicados y posibilidad de ampliar datos sin rehacer UI.

7. Que riesgos tecnicos reconoces hoy?
Punto clave: precision de geolocalizacion en interiores, crecimiento de dataset y necesidad futura de sincronizacion remota. Tener estos riesgos identificados transmite madurez tecnica.

8. Que mediria en una siguiente fase?
Punto clave: tiempo promedio para encontrar aula, tasa de busqueda exitosa al primer intento, pantallas con mayor abandono y aulas mas consultadas.

9. Si te piden migrar a una arquitectura mas robusta, cual seria el camino?
Punto clave: mantener contratos de servicios y migrar gradualmente estado a una solucion mas estructurada, sin romper UI ni flujo de usuario.

10. Que respuesta dar si cuestionan que no hay backend aun?
Punto clave: el objetivo inicial fue validar experiencia y flujo de orientacion. Con valor probado, el backend se incorpora para sincronizacion, analitica y administracion centralizada.

## Frases de cierre para preguntas complejas

- "En esta fase priorice coherencia de experiencia y mantenibilidad. La arquitectura ya deja preparado el camino para evolucion tecnica sin rehacer la base."
- "La decision no fue solo tecnica; fue de producto: reducir incertidumbre de llegada con una solucion util desde el primer uso."
- "Prefiero una base simple, medible y extensible antes que una complejidad temprana sin validacion de uso real."
