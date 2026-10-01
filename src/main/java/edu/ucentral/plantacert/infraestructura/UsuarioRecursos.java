package edu.ucentral.plantacert.infraestructura;

import edu.ucentral.plantacert.aplicacion.UsuarioServicio;
import edu.ucentral.plantacert.infraestructura.dto.RegistroUsuarioPayLoad;
import edu.ucentral.plantacert.infraestructura.dto.UsuarioRespuesta;
import jakarta.inject.Inject;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponse;
import org.eclipse.microprofile.openapi.annotations.tags.Tag;

@Path("/usuarios")
@Tag(name = "Usuarios", description = "Registro y gestión de cuentas")
public class UsuarioRecursos {

    @Inject
    UsuarioServicio usuarioServicio;

    @POST
    @Path("/registro")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    @Operation(summary = "Registrar un usuario nuevo (RQ1-HU01)",
               description = "Crea la cuenta con nombre completo, correo y contraseña (mínimo 8 caracteres)")
    @APIResponse(responseCode = "201", description = "Usuario registrado")
    @APIResponse(responseCode = "400", description = "Datos de entrada inválidos")
    @APIResponse(responseCode = "409", description = "El correo ya está registrado")
    public Response registrar(@Valid @NotNull RegistroUsuarioPayLoad payLoad) {
        UsuarioRespuesta respuesta = usuarioServicio.registrar(payLoad);
        return Response.status(Response.Status.CREATED).entity(respuesta).build();
    }
}
