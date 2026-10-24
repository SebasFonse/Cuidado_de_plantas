package edu.ucentral.plantacert.infraestructura.dto;

import edu.ucentral.plantacert.dominio.Cuidado;

import java.time.LocalDate;
import java.time.LocalDateTime;

public record CuidadoRespuesta(
        Long id,
        String tipo,
        Integer frecuenciaDias,
        LocalDate fechaUltimoCuidado,
        String notas,
        LocalDateTime fechaRegistro,
        Long plantaId
) {
    public static CuidadoRespuesta desde(Cuidado cuidado) {
        return new CuidadoRespuesta(
                cuidado.id,
                cuidado.tipo != null ? cuidado.tipo.name() : null,
                cuidado.frecuenciaDias,
                cuidado.fechaUltimoCuidado,
                cuidado.notas,
                cuidado.fechaRegistro,
                cuidado.planta != null ? cuidado.planta.id : null);
    }
}
