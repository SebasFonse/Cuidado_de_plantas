package edu.ucentral.plantacert.common.respuesta;

import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
public class ResponseApiError {
    private String mensaje;
    private String codigo;
    private List<String> detalles;
}
