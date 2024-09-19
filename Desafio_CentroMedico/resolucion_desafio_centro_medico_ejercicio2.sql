select count(T.idMedico) as Total_de_turnos , M.apellido as Medico
from turno as T
RIGHT OUTER JOIN medico as M
on T.idMedico = M.idMedico
group by T.idMedico
order by Total_de_turnos desc
;

-- select count(T.idMedico) as Total_de_turnos , CONCAT(M.nombre,' ', M.apellido, ' - ', E.nombre) AS Medico
select CONCAT(M.nombre,' ', M.apellido, ' - ', E.nombre) AS Medico
from Medico as M
inner JOIN especialidad as E
on M.idEspecialidad = E.idEspecialidad
/*RIGHT OUTER JOIN turno as T
on T.idMedico = M.idMedico
group by T.idMedico
order by Total_de_turnos desc
*/
;

select count(T.idMedico) as Total_de_turnos , CONCAT(M.nombre,' ', M.apellido, ' - ', E.nombre) AS Medico
from Medico as M
inner JOIN especialidad as E
on M.idEspecialidad = E.idEspecialidad
LEFT outer JOIN turno as T
on T.idMedico = M.idMedico
group by M.idMedico
order by Total_de_turnos desc
;

