package edu.ucentral.plantacert.infraestructura;

import edu.ucentral.plantacert.aplicacion.EspecieServicio;
import edu.ucentral.plantacert.infraestructura.dto.EspecieRespuesta;
import jakarta.inject.Inject;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.QueryParam;
import jakarta.ws.rs.core.MediaType;
import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponse;
import org.eclipse.microprofile.openapi.annotations.tags.Tag;

import java.util.List;

@Path("/especies")
@Tag(name = "Especies", description = "Base de datos de especies para registrar plantas")
public class EspecieRecursos {

    @Inject
    EspecieServicio especieServicio;

    @GET
    @Produces(MediaType.APPLICATION_JSON)
    @Operation(summary = "Listar especies",
               description = "Devuelve las especies ordenadas por nombre común. "
                       + "Con ?q= filtra por una parte del nombre común o científico")
    @APIResponse(responseCode = "200", description = "Lista de especies")
    public List<EspecieRespuesta> listar(@QueryParam("q") String q) {
        return especieServicio.listar(q);
    }
}
