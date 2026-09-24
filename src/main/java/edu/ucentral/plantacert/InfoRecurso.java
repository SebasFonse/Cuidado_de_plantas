package edu.ucentral.plantacert;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponse;

@Path("/info")
public class InfoRecurso {

    @GET
    @Path("/version")
    @Produces(MediaType.TEXT_PLAIN)
    @Operation(summary = "Consultar versión del aplicativo",
               description = "Devuelve la versión de la API de Plantacert AI")
    @APIResponse(responseCode = "200", description = "Información de la versión")
    public String version() {
        return "Plantacert AI - API Quarkus v1.0 - Grupo 5";
    }
}
