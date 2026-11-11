package edu.ucentral.plantacert.infraestructura.dto;

import edu.ucentral.plantacert.dominio.Especie;

public record EspecieRespuesta(Long id, String nombreCientifico, String nombreComun) {

    public static EspecieRespuesta desde(Especie especie) {
        return new EspecieRespuesta(especie.id, especie.nombreCientifico, especie.nombreComun);
    }
}
