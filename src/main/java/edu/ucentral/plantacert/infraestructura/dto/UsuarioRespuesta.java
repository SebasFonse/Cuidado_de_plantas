package edu.ucentral.plantacert.infraestructura.dto;

/**
 * Respuesta del registro. Nunca incluye la contraseña.
 */
public record UsuarioRespuesta(
        Long id,
        String nombre,
        String correo,
        String mensaje
) {
}
