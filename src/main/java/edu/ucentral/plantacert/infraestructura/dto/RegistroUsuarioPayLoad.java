package edu.ucentral.plantacert.infraestructura.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/**
 * Datos que envía el formulario de registro (RQ1-HU01).
 */
public record RegistroUsuarioPayLoad(
        @NotBlank(message = "El nombre completo es requerido")
        @Size(max = 100, message = "El nombre no puede superar 100 caracteres")
        String nombre,

        @NotBlank(message = "El correo electrónico es requerido")
        @Email(regexp = ".+@.+\\..+", message = "El correo electrónico no tiene un formato válido")
        @Size(max = 150, message = "El correo no puede superar 150 caracteres")
        String correo,

        @NotBlank(message = "La contraseña es requerida")
        @Size(min = 8, message = "La contraseña debe tener mínimo 8 caracteres")
        String contrasena
) {
}
