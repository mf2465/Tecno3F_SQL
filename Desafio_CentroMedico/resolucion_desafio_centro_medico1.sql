/*
select T.idMedico , E.nombre
from turno as T
inner join especialidad as E
on T.idMedico = E.idMedico
;
*/
select count(idPaciente), idMedico
from turno
group by idMedico;

select count(T.idMedico) as Total_de_turnos , E.nombre as Especialidad
from turno as T
RIGHT OUTER JOIN medico as M
on T.idMedico = M.idMedico
RIGHT OUTER JOIN especialidad as E
on M.idEspecialidad = E.idEspecialidad
group by E.nombre
order by Total_de_turnos desc, E.nombre desc
;
