(defrule bienvenida
	(declare (salience 20))
	(object (is-a JUGADOR) (nombre niño) (personalidad ?pers) (posicion 0)(turno ?turno) (contador 0))
	(object (is-a JUEGO) (tipo ?tipo) (elemento ?elem) (max-casillas ?mc) (max-rondas ?mr))
	(test ( neq ?pers robot))
	=>
	(printout t "El juego elegido para la sesión es: " ?tipo crlf)
	(printout t "El niño se caracteriza por ser: " ?pers crlf)
	(printout t "¡Vamos a jugar!" crlf))
	
;si solo hace falta que el niño haga una cosa mal en cada prueba se puede meter esto en la regla de bienvenida
	
(defrule características
	(declare (salience 15))
	(object (is-a HACEMAL) (personalidad ?pers) (accion ?accion) (num-veces ?n) (num-veces-max ?max))
	=>
	(printout t "El niño " ?pers " puede realizar: " ?accion crlf))

(defrule moverOca
	?jugador1 <- (object (is-a JUGADOR)(nombre ?nombre1) (personalidad ?pers1) (posicion ?pos1) (turno si) (contador ?cnt1))
	?jugador2 <- (object (is-a JUGADOR)(nombre ?nombre2) (personalidad ?pers2) (posicion ?pos2) (turno no) (contador ?cnt2))
	(object (is-a JUEGO)(tipo oca) (elemento dado) (max-casillas ?max)(max-rondas ?mr))
	(object (is-a ELEMENTO)(valor ?v))
	(test (<= ?pos1 ?max))
	=>
	(modify-instance ?jugador1 (posicion (+ ?v ?pos1)) (turno no))
	(modify-instance ?jugador2 (turno si))
	(printout t "Turno del: " ?nombre1 ", estaba en la casilla " ?pos1 " y avanza hasta la casilla " (+ ?v ?pos1)   crlf))

;para facilitar el juego se ha hecho que salgan numeros aleatorios
; al principio habiamos hecho dos reglas pero al no avanzar de 1 en 1 no tenia sentido hacer dos reglas, asiq lo hacemos en una 
(defrule moverRayuela   												
	(object (is-a JUEGO) (tipo rayuela) (elemento piedra) (max-casillas ?mc)(max-rondas ?mr))
	?jugador1 <- (object (is-a JUGADOR)(nombre ?nombre1) (personalidad ?per1) (posicion 0) (turno si) (contador ?cnt1))
	?jugador2 <- (object (is-a JUGADOR)(nombre ?nombre2) (personalidad ?per2) (posicion ?pos2) (turno no)(contador ?cnt2))
	(object (is-a ELEMENTO)(valor ?v))
	=>
	(printout t "Es turno del: "?nombre1 crlf)
	(printout t "La piedra ha caido en la casilla: "?v crlf)
	(printout t "El " ?nombre1 " avanza hasta la posicion " (- ?v 1) ", salta la piedra que esta en la posicion " ?v " y sigue hasta la casilla " ?mc crlf)
	(printout t "El " ?nombre1 " vuelve desde la casilla " ?mc ", se para en la casilla " ?v " para coger la piedra y vuelve hasta la posición inicial"  crlf)
	(printout t "El " ?nombre1 " ha completado una vuelta, le quedan " (- ?mr (+ ?cnt1 1)) " para ganar la partida"  crlf)
	(modify-instance ?jugador1 (turno no) (contador (+ ?cnt1 1)))
	(modify-instance ?jugador2 (turno si)))
	
(defrule moverCasillaEspecial
	?jugador1 <- (object (is-a JUGADOR)(nombre ?nombre1) (personalidad ?pers1) (posicion ?pos1) (turno si) (contador ?cnt1))
	?jugador2 <- (object (is-a JUGADOR)(nombre ?nombre2) (personalidad ?pers2) (posicion ?pos2) (turno no) (contador ?cnt2))
	(object (is-a JUEGO)(tipo ?tipo) (elemento ?elem) (max-casillas ?max) (valor-elemento ?valor)(max-rondas ?mr))
	(object (is-a CASILLA)(tipo ?t ) (inicio ?pos1) (fin ?fin))
	=>
	(modify-instance ?jugador1 (posicion ?fin) (turno no))
	(modify-instance ?jugador2 (turno si))
	(printout t "¡El " ?nombre1 " ha caido en una casilla de tipo " ?t "!"  crlf)
	(printout t "Turno del " ?nombre1 ", estaba en la casilla " ?pos1 " y avanza hasta la casilla " ?fin crlf))
	
(defrule elNiñoHaceAlgoMal 
	?jugador1 <- (object (is-a JUGADOR)(nombre ?nombre1) (personalidad ?pers1) (posicion ?pos1) (turno si)(contador ?cnt1))
	?jugador2 <- (object (is-a JUGADOR)(nombre ?nombre2) (personalidad ?pers2) (posicion ?pos2) (turno no)(contador ?cnt2))
	?a <- (object (is-a HACEMAL)(personalidad ?pers1) (accion ?accion) (num-veces ?num) (num-veces-max ?max))
	(object (is-a CORRIGE) (jugador ?nombre1) (accion ?accion) (respuesta ?respuesta))
	(test ( < ?num ?max))
	=>
	(modify-instance ?jugador1 (turno no))
	(modify-instance ?jugador2 (turno si))
	(modify-instance ?a (num-veces (+ ?num 1)))
	(printout t "El " ?nombre1 " realiza: " ?accion  crlf)
	(printout t "El robot le corrige diciendo: " ?respuesta  crlf))

;asi se puede poner las rondas que se quiera jugar a la rayuela

(defrule seAcabaElJuegoLimiteHaceMal
	(object (is-a HACEMAL)(personalidad ?pers) (accion ?accion) (num-veces ?num) (num-veces-max ?num))
	=>
	(printout t "Vamos a acabar la partida esta vez, ¡ya jugaremos otra vez!"   crlf)
	(halt))

(defrule seAcabaElJuego 
	(declare (salience 20))
	(object (is-a JUEGO)(tipo ?tipo) (elemento ?elem) (max-casillas ?max) (valor-elemento ?valor)(max-rondas ?mr))
	(object (is-a JUGADOR)(nombre ?nombre) (personalidad ?pers) (posicion ?pos) (turno ?turno)(contador ?cnt))
	(test (eq ?mr ?cnt))
	=>
	(printout t "FIN DEL JUEGO"  crlf)
	(printout t "El ganador es el " ?nombre " ¡enhorabuena!" crlf)
	(halt))
	

(defrule acabarOca
	?jugador <- (object (is-a JUGADOR)(nombre ?nombre) (personalidad ?pers) (posicion ?pos) (turno ?turno)(contador ?cont))
	(object (is-a JUEGO) (tipo ?tipo) (elemento ?elem) (max-casillas ?mc) (max-rondas ?mr))
	(test (>= ?pos ?mc))
	=>
	(modify-instance ?jugador (contador (+ ?cont 1))))



