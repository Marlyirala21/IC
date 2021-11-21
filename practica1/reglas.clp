(defrule bienvenida
	(declare (salience 20))
	(not (inicio))
	(object (is-a JUGADOR) (nombre niño) (personalidad ?pers) (posicion 0)(turno ?turno) (num-rondas 0)(num-haceMal 0)(num-haceMal-max ?max))
	(object (is-a JUEGO) (tipo ?tipo) (elemento ?elem) (max-casillas ?mc) (max-rondas ?mr))
	=>
	(printout t "El juego elegido para la sesión es: " ?tipo crlf)
	(printout t "El niño se caracteriza por ser: " ?pers crlf)
	(assert (inicio)))

(defrule acciones
	(declare (salience 15))
	(object (is-a HACEMAL) (personalidad ?pers) (accion ?accion))
	=>
	(printout t "El niño " ?pers " puede: " ?accion crlf))
	
;si solo hace falta que el niño haga una cosa mal en cada prueba se puede meter esto en la regla de bienvenida
	
(defrule tirarElemento 
	(not (tirado ?valor))
	(object (is-a ELEMENTO)(valor ?valor))
	=>
	(assert (tirado ?valor)))
 
(defrule moverOca
	?t <- (tirado ?valor)
	?jugador1 <- (object (is-a JUGADOR)(nombre ?nombre1) (personalidad ?pers1) (posicion ?pos1) (turno si) (num-rondas ?rondas1)(num-haceMal ?num1)(num-haceMal-max ?max1))
	?jugador2 <- (object (is-a JUGADOR)(nombre ?nombre2) (personalidad ?pers2) (posicion ?pos2) (turno no) (num-rondas ?rondas2)(num-haceMal ?num2)(num-haceMal-max ?max2))
	(object (is-a JUEGO)(tipo oca)(elemento dado)(max-casillas ?max)(max-rondas ?mr))
	(test (<= ?pos1 ?max))
	=>
	(modify-instance ?jugador1 (posicion (+ ?valor ?pos1)) (turno no))
	(modify-instance ?jugador2 (turno si))
	(retract ?t)
	(printout t crlf "«Es turno del "?nombre1 "»" crlf)
	(printout t "El dado ha caido en la casilla: "?valor crlf)
	(printout t "Estaba en la casilla " ?pos1 " y se mueve hasta la casilla " (+ ?valor ?pos1)   crlf))
		
 
(defrule moverRayuela  
	?t <- (tirado ?valor)
	(object (is-a JUEGO) (tipo rayuela) (elemento piedra) (max-casillas ?mc)(max-rondas ?mr))
	?jugador1 <- (object (is-a JUGADOR)(nombre ?nombre1) (personalidad ?per1) (posicion 0) (turno si) (num-rondas ?rondas1) (num-haceMal ?num1)(num-haceMal-max ?max1))
	?jugador2 <- (object (is-a JUGADOR)(nombre ?nombre2) (personalidad ?per2) (posicion ?pos2) (turno no)(num-rondas ?rondas2)(num-haceMal ?num2)(num-haceMal-max ?max2))
	=>
	(printout t crlf "«Es turno del "?nombre1 "»" crlf)
	(printout t "La piedra ha caido en la casilla: "?valor crlf)
	(printout t "El " ?nombre1 " avanza hasta la posicion " (- ?valor 1) ", salta la piedra que esta en la posicion " ?valor " y sigue hasta la casilla " ?mc crlf)
	(printout t "El " ?nombre1 " vuelve desde la casilla " ?mc ", se para en la casilla " ?valor " para coger la piedra y vuelve hasta la posición inicial"  crlf)
	(printout t "El " ?nombre1 " ha completado una vuelta, le queda " (- ?mr (+ ?rondas1 1)) " para ganar la partida"  crlf)
	(modify-instance ?jugador1 (turno no) (num-rondas (+ ?rondas1 1)))
	(modify-instance ?jugador2 (turno si))
	(retract ?t))
	
(defrule moverCasillaEspecial
	?t <- (tirado ?valor)
	?jugador1 <- (object (is-a JUGADOR)(nombre ?nombre1) (personalidad ?pers1) (posicion ?pos1) (turno si) (num-rondas ?rondas1)(num-haceMal ?num1)(num-haceMal-max ?max1))
	?jugador2 <- (object (is-a JUGADOR)(nombre ?nombre2) (personalidad ?pers2) (posicion ?pos2) (turno no) (num-rondas ?rondas2)(num-haceMal ?num2)(num-haceMal-max ?max2))
	(object (is-a JUEGO)(tipo ?tipo) (elemento ?elem) (max-casillas ?max)(max-rondas ?mr))
	(object (is-a CASILLA)(tipo ?tipo ) (inicio ?inicio) (fin ?fin))
	(test (eq (+ ?pos1 ?valor) ?inicio))
	=>
	(modify-instance ?jugador1 (posicion ?fin) (turno no))
	(modify-instance ?jugador2 (turno si))
	(printout t crlf "«Es turno del "?nombre1 "»" crlf "La piedra ha caido en la casilla: "?valor crlf)
	(printout t "¡Ha caido en una casilla de tipo " ?tipo "!"  crlf)
	(printout t "Avanza hasta la casilla " ( + ?pos1 ?valor) " y se mueve hasta la casilla " ?fin crlf))
	
(defrule elNiñoHaceAlgoMal 
	?t <- (tirado ?valor)
	(object (is-a JUEGO) (tipo ?tipo) (elemento ?elem) (max-casillas ?mc)(max-rondas ?mr))
	?jugador1 <- (object (is-a JUGADOR)(nombre ?nombre1) (personalidad ?pers1) (posicion ?pos1) (turno si)(num-rondas ?rondas1)(num-haceMal ?num1)(num-haceMal-max ?max1))
	?jugador2 <- (object (is-a JUGADOR)(nombre ?nombre2) (personalidad ?pers2) (posicion ?pos2) (turno no)(num-rondas ?rondas2)(num-haceMal ?num2)(num-haceMal-max ?max2))
	?a <- (object (is-a HACEMAL)(personalidad ?pers1) (accion ?accion))
	(object (is-a CORRIGE) (jugador ?nombre1) (accion ?accion) (respuesta ?respuesta))
	(test ( < ?num1 ?max1))
	=>
	(modify-instance ?jugador1 (turno no))
	(modify-instance ?jugador2 (turno si))
	(modify-instance ?jugador1 (num-haceMal (+ ?num1 1)))
	(printout t crlf "«Es turno del "?nombre1 "»" crlf)
	(printout t "El elemento " ?elem " ha caido en la casilla: "?valor crlf)
	(printout t "El " ?nombre1 " realiza:" ?accion  crlf)
	(printout t "El robot le corrige diciendo: " ?respuesta  crlf)
	(retract ?t))


(defrule seAcabaElJuegoLimiteHaceMal
	(declare (salience 20))
	?jugador <- (object (is-a JUGADOR)(nombre ?nombre) (personalidad ?pers) (posicion ?pos) (turno ?turno)(num-rondas ?rondas)(num-haceMal ?max)(num-haceMal-max ?max))
	=>
	(printout t crlf "FIN DEL JUEGO"  crlf)
	(printout t crlf "El robot dice: Vamos a acabar la partida esta vez, ¡ya jugaremos otra vez!"   crlf)
	(halt))

(defrule seAcabaElJuego 
	(declare (salience 20))
	(object (is-a JUEGO)(tipo ?tipo) (elemento ?elem) (max-casillas ?max)(max-rondas ?mr))
	(object (is-a JUGADOR)(nombre ?nombre) (personalidad ?pers) (posicion ?pos) (turno ?turno)(num-rondas ?mr) (num-haceMal ?num)(num-haceMal-max ?maxHaceMal))
	=>
	(printout t crlf "FIN DEL JUEGO"  crlf)
	(printout t "El ganador es el " ?nombre " ¡enhorabuena! 🎉" crlf)
	(halt))
	

(defrule acabarOca
	?jugador1 <- (object (is-a JUGADOR)(nombre ?nombre1) (personalidad ?pers1) (posicion ?pos1) (turno ?turno1)(num-rondas ?rondas1)(num-haceMal ?num1)(num-haceMal-max ?max1))
	?jugador2 <- (object (is-a JUGADOR)(nombre ?nombre2) (personalidad ?pers2) (posicion ?pos2) (turno ?turno2)(num-rondas ?rondas2)(num-haceMal ?num2)(num-haceMal-max ?max2))
	(object (is-a JUEGO) (tipo ?tipo) (elemento ?elem) (max-casillas ?mc) (max-rondas ?mr))
	(test (>= ?pos1 ?mc))
	=>
	(printout t crlf "El " ?nombre1 " ha completado una vuelta." crlf)
	(modify-instance ?jugador1 (num-rondas (+ ?rondas1 1)) (posicion 0))
	(modify-instance ?jugador2 (posicion 0)))



