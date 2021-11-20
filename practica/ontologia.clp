(defclass JUEGO (is-a USER) 
        (slot tipo (type SYMBOL) (allowed-values oca rayuela))
        (slot elemento (type SYMBOL) (allowed-values dado piedra))
        (slot max-casillas (type INTEGER))
		(slot max-rondas (type INTEGER) (default 0)))

(defclass ELEMENTO (is-a USER)
		(slot valor (type INTEGER)))

(defclass JUGADOR (is-a USER) 
        (slot nombre (type SYMBOL) (allowed-values niño robot))
        (slot personalidad (type SYMBOL) (allowed-values torpe tramposo robot nervioso))
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

