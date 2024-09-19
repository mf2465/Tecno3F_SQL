-- resolución del Ejercicio 1 del Test Autodidacta #2
select count(T.idMedico) as Total_de_turnos , E.nombre as Especialidad
from turno as T
RIGHT OUTER JOIN medico as M
on T.idMedico = M.idMedico
RIGHT OUTER JOIN especialidad as E
on M.idEspecialidad = E.idEspecialidad
group by E.nombre
order by Total_de_turnos desc, E.nombre desc
;

-- resolución del Ejercicio 2 del Test Autodidacta #2
select count(T.idMedico) as Total_de_turnos , CONCAT(M.nombre,' ', M.apellido, ' - ', E.nombre) AS Medico
from Medico as M
inner JOIN especialidad as E
on M.idEspecialidad = E.idEspecialidad
LEFT outer JOIN turno as T
on T.idMedico = M.idMedico
group by M.idMedico
order by Total_de_turnos desc
;

-- resolución del Ejercicio 3 del Test Autodidacta #2
select count(T.idMedico) as Total_de_turnos , CONCAT(P.nombre,' ', P.apellido, ' DNI ', P.dni) AS Datos_Paciente , CONCAT(OS.razonSocial,' - ', POS.plan) AS Cobertura
from paciente as P
left join turno as T
on P.idPaciente = T.idPaciente
inner JOIN planobrasocial as POS
on P.idPlanObraSocial = POS.idPlanObraSocial
inner JOIN obrasocial as OS
on POS.idObraSocial = OS.idObraSocial
group by P.idpaciente
order by Total_de_turnos desc, P.nombre desc
;