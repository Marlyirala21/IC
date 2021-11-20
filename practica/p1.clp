(defclass JUEGO (is-a USER) 
        (slot tipo (type SYMBOL) (allowed-values oca rayuela))
        (slot elemento (type SYMBOL) (allowed-values dado piedra))
        (slot max-casillas (type INTEGER))
		(slot max-rondas (type INTEGER) (default 0)))

(defclass ELEMENTO (is-a USER)
		(slot valor (type INTEGER)))

(defclass JUGADOR (is-a USER) 
        (slot nombre (type SYMBOL) (allowed-values niño robot))
        (slot personalidad (type SYMBOL) (allowed-values torpe tramposo robot impaciente))
        (slot posicion (type INTEGER) (default 0))
		(slot turno (type SYMBOL) (allowed-values si no) (default no))
		(slot num-rondas(type INTEGER)(default 0))
		(slot num-haceMal (type INTEGER))
		(slot num-haceMal-max (type INTEGER)))

(defclass CASILLA (is-a USER) 
        (slot tipo (type SYMBOL) (allowed-values oca puente muerte))
        (slot inicio (type INTEGER))
        (slot fin (type INTEGER)))
		
(defclass HACEMAL (is-a USER) 
        (slot personalidad (type SYMBOL) (allowed-values torpe tramposo))
		(slot accion (type STRING)))
		
(defclass CORRIGE (is-a USER) 
        (slot jugador(type SYMBOL) (allowed-values niño))
		(slot accion (type STRING))
        (slot respuesta (type STRING)))


(definstances juego
        (of JUEGO (tipo oca) (elemento dado) (max-casillas 62) (max-rondas 1))
        
		(of JUGADOR (nombre niño) (personalidad tramposo) (posicion 0) (turno si) (num-haceMal 0)(num-haceMal-max 5))
		(of JUGADOR (nombre robot) (personalidad robot) (posicion 0) (num-haceMal 0)(num-haceMal-max 5))
		
		(of HACEMAL (personalidad tramposo) (accion " moverse una casilla de más"))
		
		(of CORRIGE (jugador niño) (accion " moverse una casilla de más") (respuesta "Uy que te he pillado, vuelve a tu casilla y no hagas trampas 👀"))
		(of HACEMAL (personalidad tramposo) (accion " tirar dos veces el dado"))
		(of CORRIGE (jugador niño) (accion " tirar dos veces el dado") (respuesta "Oyee, el dado se tiene que tirar una sola vez, la próxima te tocará un número mejor ¡ya verás!"))
		(of CASILLA (tipo oca ) (inicio 5) (fin 14))
		(of CASILLA (tipo oca ) (inicio 15) (fin 24))
		(of CASILLA (tipo oca ) (inicio 25) (fin 34))
		(of CASILLA (tipo oca ) (inicio 35) (fin 44))
		(of CASILLA (tipo oca ) (inicio 45) (fin 54))
		(of CASILLA (tipo oca ) (inicio 55) (fin 62))
		(of CASILLA (tipo puente ) (inicio 12) (fin 26))
		(of CASILLA (tipo puente ) (inicio 27) (fin 39))
		(of CASILLA (tipo puente ) (inicio 27) (fin 12))
		(of CASILLA (tipo puente ) (inicio 40) (fin 26))
		(of CASILLA (tipo muerte ) (inicio 58) (fin 0))
		(of ELEMENTO (valor 1)) (of ELEMENTO (valor 2))	(of ELEMENTO (valor 3))(of ELEMENTO (valor 4))(of ELEMENTO (valor 5))(of ELEMENTO (valor 6))	
)


(defrule ini
  (declare (salience 200))
  =>
  (set-strategy random))

(defrule bienvenida
	(declare (salience 20))
	(not (inicio))
	(object (is-a JUGADOR) (nombre niño) (personalidad ?pers) (posicion 0)(turno ?turno) (num-rondas 0)(num-haceMal 0)(num-haceMal-max ?max))
	(object (is-a JUEGO) (tipo ?tipo) (elemento ?elem) (max-casillas ?mc) (max-rondas ?mr))
	=>
	(printout t "El juego elegido para la sesión es: " ?tipo crlf)
	(printout t "El niño se caracteriza por ser: " ?pers crlf)
	(assert (inicio)))

(defrule características
	(declare (salience 15))
	(object (is-a HACEMAL) (personalidad ?pers) (accion ?accion))
	=>
	(printout t "El niño " ?pers " puede: " ?accion crlf))
	
;si solo hace falta que el niño haga una cosa mal en cada prueba se puede meter esto en la regla de bienvenida
	
(defrule tirarElemento 
	(not (tirado ?valor))
	(object (is-a ELEMENTO)(valor ?valor))
	=>
	(assert (tirado ?valor))
)
 
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
	(printout t crlf "El dado ha caido en la casilla: "?valor crlf)
	(printout t "Estaba en la casilla " ?pos1 " y se mueve hasta la casilla " (+ ?valor ?pos1)   crlf))
		

;para facilitar el juego se ha hecho que salgan numeros aleatorios
; al principio habiamos hecho dos reglas pero al no avanzar de 1 en 1 no tenia sentido hacer dos reglas, asiq lo hacemos en una 
(defrule moverRayuela  
	?t <- (tirado ?valor)
	(object (is-a JUEGO) (tipo rayuela) (elemento piedra) (max-casillas ?mc)(max-rondas ?mr))
	?jugador1 <- (object (is-a JUGADOR)(nombre ?nombre1) (personalidad ?per1) (posicion 0) (turno si) (num-rondas ?rondas1) (num-haceMal ?num1)(num-haceMal-max ?max1))
	?jugador2 <- (object (is-a JUGADOR)(nombre ?nombre2) (personalidad ?per2) (posicion ?pos2) (turno no)(num-rondas ?rondas2)(num-haceMal ?num2)(num-haceMal-max ?max2))
	=>
	(printout t "«Es turno del "?nombre1 "»" crlf)
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
	(printout t "Ha caido en una casilla de tipo " ?tipo "!"  crlf)
	(printout t "Estaba en la casilla " ?pos1 " y se mueve hasta la casilla " ?fin crlf))
	
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
	(printout t crlf "El elemento " ?elem " ha caido en la casilla: "?valor crlf)
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
	?jugador <- (object (is-a JUGADOR)(nombre ?nombre) (personalidad ?pers) (posicion ?pos) (turno ?turno)(num-rondas ?rondas)(num-haceMal ?num)(num-haceMal-max ?max))
	(object (is-a JUEGO) (tipo ?tipo) (elemento ?elem) (max-casillas ?mc) (max-rondas ?mr))
	(test (>= ?pos ?mc))
	=>
	(printout t crlf "El " ?nombre " ha llegado hasta la casilla final." crlf)
	(modify-instance ?jugador (num-rondas (+ ?rondas 1))))



