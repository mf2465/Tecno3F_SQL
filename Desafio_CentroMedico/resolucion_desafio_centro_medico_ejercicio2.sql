select count(T.idMedico) as Total_de_turnos , M.apellido as Medico
from turno as T
RIGHT OUTER JOIN medico as M
on T.idMedico = M.idMedico
group by T.idMedico
order by Total_de_turnos desc
;

select count(T.idMedico) as Total_de_turnos , CONCAT(M.nombre,' ', M.apellido, ' - ', E.nombre) AS Medico
from turno as T
RIGHT OUTER JOIN medico as M
on T.idMedico = M.idMedico
RIGHT OUTER JOIN especialidad as E
on M.idEspecialidad = E.idEspecialidad
group by T.idMedico
order by Total_de_turnos desc
;