package edu.ucentral.plantacert.infraestructura;

import edu.ucentral.plantacert.aplicacion.PlantaServicio;
import edu.ucentral.plantacert.infraestructura.dto.PlantaPayLoad;
import edu.ucentral.plantacert.infraestructura.dto.PlantaRespuesta;
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
 * Por ahora el usuario se indica en la URL. Cuando se implemente el login con JWT (RQ-02),
 * el usuario se tomará del token y la ruta quedará como POST /plantas.
 */
@Path("/plantas")
@Tag(name = "Plantas", description = "Catálogo de plantas del usuario")
public class PlantaRecursos {

    @Inject
    PlantaServicio plantaServicio;

    @POST
    @Path("/usuario/{usuarioId}")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    @Operation(summary = "Agregar una planta al catálogo (RQ4-HU01)",
               description = "Registra nombre, especie, ubicación, descripción y enlace de la foto")
    @APIResponse(responseCode = "201", description = "Planta registrada")
    @APIResponse(responseCode = "400", description = "Datos de entrada inválidos")
    @APIResponse(responseCode = "404", description = "El usuario no existe")
    public Response registrar(@PathParam("usuarioId") Long usuarioId,
                              @Valid @NotNull PlantaPayLoad payLoad) {
        PlantaRespuesta respuesta = plantaServicio.registrar(usuarioId, payLoad);
        return Response.status(Response.Status.CREATED).entity(respuesta).build();
    }

    @GET
    @Path("/usuario/{usuarioId}")
    @Produces(MediaType.APPLICATION_JSON)
    @Operation(summary = "Listar las plantas del usuario")
    @APIResponse(responseCode = "200", description = "Catálogo del usuario")
    @APIResponse(responseCode = "404", description = "El usuario no existe")
    public Response listar(@PathParam("usuarioId") Long usuarioId) {
        List<PlantaRespuesta> plantas = plantaServicio.listarPorUsuario(usuarioId);
        return Response.ok(plantas).build();
    }
}
