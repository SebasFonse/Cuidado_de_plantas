package edu.ucentral.plantacert.infraestructura.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import org.hibernate.validator.constraints.URL;

/**
 * Datos del formulario para agregar una planta (RQ4-HU01).
 * descripcion e imagenUrl son opcionales.
 */
public record PlantaPayLoad(
        @NotBlank(message = "El nombre de la planta es requerido")
        @Size(max = 100, message = "El nombre no puede superar 100 caracteres")
        String nombre,

        @NotBlank(message = "La especie es requerida")
        @Size(max = 100, message = "La especie no puede superar 100 caracteres")
        String especie,

        @NotBlank(message = "La ubicación es requerida")
        @Size(max = 100, message = "La ubicación no puede superar 100 caracteres")
        String ubicacion,

        @Size(max = 1000, message = "La descripción no puede superar 1000 caracteres")
        String descripcion,

        @URL(regexp = "^$|^(http|https)://.*", message = "La imagen debe ser un enlace válido que empiece por http:// o https://")
        @Size(max = 500, message = "El enlace de la imagen no puede superar 500 caracteres")
        String imagenUrl
) {
}
