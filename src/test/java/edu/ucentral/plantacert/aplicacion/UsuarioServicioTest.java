package edu.ucentral.plantacert.aplicacion;

import edu.ucentral.plantacert.common.excepciones.NegocioException;
import edu.ucentral.plantacert.dominio.Usuario;
import edu.ucentral.plantacert.dominio.UsuarioRepositorio;
import edu.ucentral.plantacert.infraestructura.dto.RegistroUsuarioPayLoad;
import edu.ucentral.plantacert.infraestructura.dto.UsuarioRespuesta;
import io.quarkus.test.InjectMock;
import io.quarkus.test.junit.QuarkusTest;
import jakarta.inject.Inject;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

@QuarkusTest
public class UsuarioServicioTest {

    @Inject
    UsuarioServicio usuarioServicio;

    @InjectMock
    UsuarioRepositorio usuarioRepositorio;

    @Test
    public void testRegistrarUsuarioGuardaUnaVez() {
        when(usuarioRepositorio.existePorCorreo(anyString())).thenReturn(false);
        var payLoad = new RegistroUsuarioPayLoad("Valeria Gómez", "valeria@correo.com", "clave1234");

        UsuarioRespuesta respuesta = usuarioServicio.registrar(payLoad);

        verify(usuarioRepositorio, times(1)).persist(any(Usuario.class));
        assertEquals("valeria@correo.com", respuesta.correo());
        assertEquals("Valeria Gómez", respuesta.nombre());
    }

    @Test
    public void testRegistrarUsuarioCifraLaContrasena() {
        when(usuarioRepositorio.existePorCorreo(anyString())).thenReturn(false);
        var payLoad = new RegistroUsuarioPayLoad("Valeria", "valeria@correo.com", "clave1234");

        usuarioServicio.registrar(payLoad);

        ArgumentCaptor<Usuario> captor = ArgumentCaptor.forClass(Usuario.class);
        verify(usuarioRepositorio).persist(captor.capture());
        Usuario guardado = captor.getValue();
        assertNotEquals("clave1234", guardado.contrasenaHash, "La contraseña no debe guardarse en texto plano");
        assertTrue(guardado.contrasenaHash.startsWith("$2"), "La contraseña debe guardarse en formato BCrypt");
    }

    @Test
    public void testRegistrarUsuarioNormalizaCorreo() {
        when(usuarioRepositorio.existePorCorreo(anyString())).thenReturn(false);
        var payLoad = new RegistroUsuarioPayLoad("  Valeria  ", "  VALERIA@Correo.com ", "clave1234");

        UsuarioRespuesta respuesta = usuarioServicio.registrar(payLoad);

        assertEquals("valeria@correo.com", respuesta.correo());
        assertEquals("Valeria", respuesta.nombre());
    }

    @Test
    public void testRegistrarCorreoDuplicadoLanzaError() {
        when(usuarioRepositorio.existePorCorreo("valeria@correo.com")).thenReturn(true);
        var payLoad = new RegistroUsuarioPayLoad("Valeria", "valeria@correo.com", "clave1234");

        NegocioException error = assertThrows(NegocioException.class,
                () -> usuarioServicio.registrar(payLoad));

        assertEquals(409, error.getStatus());
        verify(usuarioRepositorio, never()).persist(any(Usuario.class));
    }
}
