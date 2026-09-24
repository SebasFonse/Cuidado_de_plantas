package edu.ucentral.plantacert.common.excepciones;

import edu.ucentral.plantacert.common.respuesta.ResponseApi;
import edu.ucentral.plantacert.common.respuesta.ResponseApiError;
import jakarta.validation.ConstraintViolationException;
import jakarta.ws.rs.core.Context;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.core.UriInfo;
import jakarta.ws.rs.ext.ExceptionMapper;
import jakarta.ws.rs.ext.Provider;

import java.time.Instant;
import java.util.List;

/**
 * Convierte los errores de validación (@NotBlank, @Email, @Size...) en una respuesta 400 legible.
 */
@Provider
public class ValidationExceptionMapper implements ExceptionMapper<ConstraintViolationException> {

    @Context
    UriInfo uriInfo;

    @Override
    public Response toResponse(ConstraintViolationException exception) {
        List<String> errores = exception.getConstraintViolations()
                .stream()
                .map(violacion -> {
                    String campo = violacion.getPropertyPath().toString();
                    if (campo.contains(".")) {
                        campo = campo.substring(campo.lastIndexOf('.') + 1);
                    }
                    return String.format("%s: %s", campo, violacion.getMessage());
                })
                .toList();

        var respuesta = new ResponseApi();
        respuesta.setStatus(Response.Status.BAD_REQUEST.getStatusCode());
        respuesta.setTimestamp(Instant.now().toString());
        respuesta.setPath(uriInfo.getPath());
        respuesta.setExito(false);
        respuesta.setCodigo("Petición inválida");
        respuesta.setMensaje("Error de validación en los datos de entrada");
        respuesta.setError(ResponseApiError.builder()
                .mensaje("Uno o más campos no son válidos")
                .codigo("CERT-ERR-V1")
                .detalles(errores)
                .build());

        return Response.status(Response.Status.BAD_REQUEST)
                .entity(respuesta)
                .build();
    }
}
