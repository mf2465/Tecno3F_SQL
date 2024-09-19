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

