package edu.ucentral.plantacert.common.excepciones;

import edu.ucentral.plantacert.common.respuesta.ResponseApi;
import edu.ucentral.plantacert.common.respuesta.ResponseApiError;
import jakarta.ws.rs.core.Context;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.core.UriInfo;
import jakarta.ws.rs.ext.ExceptionMapper;
import jakarta.ws.rs.ext.Provider;

import java.time.Instant;
import java.util.List;

@Provider
public class NegocioExceptionMapper implements ExceptionMapper<NegocioException> {

    @Context
    UriInfo uriInfo;

    @Override
    public Response toResponse(NegocioException exception) {
        var respuesta = new ResponseApi();
        respuesta.setStatus(exception.getStatus());
        respuesta.setTimestamp(Instant.now().toString());
        respuesta.setPath(uriInfo.getPath());
        respuesta.setExito(false);
        respuesta.setCodigo("Regla de negocio");
        respuesta.setMensaje(exception.getMessage());
        respuesta.setError(ResponseApiError.builder()
                .mensaje(exception.getMessage())
                .codigo(exception.getCodigo())
                .detalles(List.of(exception.getMessage()))
                .build());

        return Response.status(exception.getStatus())
                .entity(respuesta)
                .build();
    }
}
