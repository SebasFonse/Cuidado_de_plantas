package edu.ucentral.plantacert.infraestructura.dto;

import edu.ucentral.plantacert.dominio.Planta;

import java.time.LocalDateTime;

public record PlantaRespuesta(
        Long id,
        String nombre,
        String especie,
        String ubicacion,
        String descripcion,
        String imagenUrl,
        LocalDateTime fechaRegistro,
        Long usuarioId
) {
    public static PlantaRespuesta desde(Planta planta) {
        return new PlantaRespuesta(
                planta.id,
                planta.nombre,
                planta.especie,
                planta.ubicacion,
                planta.descripcion,
                planta.imagenUrl,
                planta.fechaRegistro,
                planta.usuario != null ? planta.usuario.id : null);
    }
}
