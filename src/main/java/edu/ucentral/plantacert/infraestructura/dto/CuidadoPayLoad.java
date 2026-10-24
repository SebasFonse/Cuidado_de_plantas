package edu.ucentral.plantacert.infraestructura.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PastOrPresent;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

import java.time.LocalDate;

/**
 * HU08: datos del formulario para agregar un cuidado periódico a una planta.
 * El tipo llega como texto para poder devolver un mensaje claro si no está en la lista.
 */
public record CuidadoPayLoad(
        @NotBlank(message = "El tipo de cuidado es requerido")
        @Pattern(regexp = "RIEGO|FERTILIZACION|PODA|EXPOSICION_LUZ|TRASPLANTE|OTRO",
                 message = "El tipo de cuidado debe ser: RIEGO, FERTILIZACION, PODA, EXPOSICION_LUZ, TRASPLANTE u OTRO")
        String tipo,

        @NotNull(message = "La frecuencia es requerida")
        @Min(value = 1, message = "La frecuencia debe ser de al menos 1 día")
        @Max(value = 365, message = "La frecuencia no puede superar 365 días")
        Integer frecuenciaDias,

        @NotNull(message = "La fecha del último cuidado es requerida")
        @PastOrPresent(message = "La fecha del último cuidado no puede ser una fecha futura")
        LocalDate fechaUltimoCuidado,

        @Size(max = 500, message = "Las notas no pueden superar 500 caracteres")
        String notas
) {
}
