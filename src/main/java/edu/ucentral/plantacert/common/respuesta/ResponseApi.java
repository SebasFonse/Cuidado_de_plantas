package edu.ucentral.plantacert.common.respuesta;

import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Formato estándar de respuesta cuando ocurre un error en la API.
 */
@Data
@NoArgsConstructor
public class ResponseApi {
    private String mensaje;
    private String codigo;
    private String timestamp;
    private String path;
    private int status;
    private boolean exito;
    private ResponseApiError error;
}
