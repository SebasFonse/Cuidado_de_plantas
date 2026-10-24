package edu.ucentral.plantacert.infraestructura;

import edu.ucentral.plantacert.aplicacion.CuidadoServicio;
import edu.ucentral.plantacert.infraestructura.dto.CuidadoPayLoad;
import edu.ucentral.plantacert.infraestructura.dto.CuidadoRespuesta;
import jakarta.inject.Inject;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponse;
import org.eclipse.microprofile.openapi.annotations.tags.Tag;

import java.util.List;

/**
 * Igual que en PlantaRecursos, por ahora el usuario va en la URL.
 * Cuando exista el login con JWT se tomará del token.
 */
@Path("/cuidados")
@Tag(name = "Cuidados", description = "Cuidados periódicos de las plantas")
public class CuidadoRecursos {

    @Inject
    CuidadoServicio cuidadoServicio;

    @POST
    @Path("/usuario/{usuarioId}/planta/{plantaId}")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    @Operation(summary = "Agregar un cuidado periódico a una planta (HU08)",
               description = "Registra tipo, frecuencia en días, fecha del último cuidado y notas opcionales")
    @APIResponse(responseCode = "201", description = "Cuidado registrado")
    @APIResponse(responseCode = "400", description = "Datos de entrada inválidos")
    @APIResponse(responseCode = "404", description = "La planta no existe o no pertenece al usuario")
    public Response registrar(@PathParam("usuarioId") Long usuarioId,
                              @PathParam("plantaId") Long plantaId,
                              @Valid @NotNull CuidadoPayLoad payLoad) {
        CuidadoRespuesta respuesta = cuidadoServicio.registrar(usuarioId, plantaId, payLoad);
        return Response.status(Response.Status.CREATED).entity(respuesta).build();
    }

    @GET
    @Path("/usuario/{usuarioId}/planta/{plantaId}")
    @Produces(MediaType.APPLICATION_JSON)
    @Operation(summary = "Listar los cuidados de una planta")
    @APIResponse(responseCode = "200", description = "Cuidados de la planta")
    @APIResponse(responseCode = "404", description = "La planta no existe o no pertenece al usuario")
    public Response listar(@PathParam("usuarioId") Long usuarioId,
                           @PathParam("plantaId") Long plantaId) {
        List<CuidadoRespuesta> cuidados = cuidadoServicio.listarPorPlanta(usuarioId, plantaId);
        return Response.ok(cuidados).build();
    }
}
