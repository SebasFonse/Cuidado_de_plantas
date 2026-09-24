package edu.ucentral.plantacert.aplicacion;

import edu.ucentral.plantacert.common.excepciones.NegocioException;
import edu.ucentral.plantacert.dominio.Usuario;
import edu.ucentral.plantacert.dominio.UsuarioRepositorio;
import edu.ucentral.plantacert.infraestructura.dto.RegistroUsuarioPayLoad;
import edu.ucentral.plantacert.infraestructura.dto.UsuarioRespuesta;
import io.quarkus.elytron.security.common.BcryptUtil;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import org.jboss.logging.Logger;

import java.time.LocalDateTime;

@ApplicationScoped
public class UsuarioServicio {

    private static final Logger LOG = Logger.getLogger(UsuarioServicio.class);

    @Inject
    UsuarioRepositorio usuarioRepositorio;

    /**
     * RQ1-HU01: registra un usuario nuevo.
     * - Normaliza el correo (minúsculas, sin espacios).
     * - Rechaza correos ya registrados (409).
     * - Guarda la contraseña cifrada con BCrypt.
     */
    @Transactional
    public UsuarioRespuesta registrar(RegistroUsuarioPayLoad payLoad) {
        String correo = payLoad.correo().trim().toLowerCase();

        if (usuarioRepositorio.existePorCorreo(correo)) {
            LOG.warnf("Intento de registro con correo existente: %s", correo);
            throw new NegocioException(409, "CERT-ERR-U1",
                    "El correo electrónico ya se encuentra registrado");
        }

        Usuario usuario = new Usuario(
                payLoad.nombre().trim(),
                correo,
                BcryptUtil.bcryptHash(payLoad.contrasena()),
                LocalDateTime.now());

        usuarioRepositorio.persist(usuario);
        LOG.infof("Usuario registrado correctamente: %s", correo);

        return new UsuarioRespuesta(usuario.id, usuario.nombre, usuario.correo,
                "Registro exitoso. Ahora puedes iniciar sesión.");
    }
}
