package edu.ucentral.plantacert.infraestructura;

import edu.ucentral.plantacert.dominio.Usuario;
import edu.ucentral.plantacert.dominio.UsuarioRepositorio;
import io.quarkus.narayana.jta.QuarkusTransaction;
import io.quarkus.test.junit.QuarkusTest;
import io.restassured.http.ContentType;
import jakarta.inject.Inject;
import org.junit.jupiter.api.Test;

import java.time.LocalDateTime;

import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.*;

@QuarkusTest
public class PlantaRecursosTest {

    @Inject
    UsuarioRepositorio usuarioRepositorio;

    /** Crea un usuario directamente en BD para no depender del endpoint de registro. */
    private Long crearUsuarioDePrueba() {
        return QuarkusTransaction.requiringNew().call(() -> {
            Usuario usuario = new Usuario("Valeria Prueba",
                    "valeria" + System.nanoTime() + "@correo.com",
                    "hash-de-prueba", LocalDateTime.now());
            usuarioRepositorio.persist(usuario);
            return usuario.id;
        });
    }

    private String json(String nombre, String especie, String ubicacion, String descripcion, String imagenUrl) {
        return """
               {
                 "nombre": "%s",
                 "especie": "%s",
                 "ubicacion": "%s",
                 "descripcion": "%s",
                 "imagenUrl": "%s"
               }
               """.formatted(nombre, especie, ubicacion, descripcion, imagenUrl);
    }

    @Test
    public void testRegistrarPlantaExitoso() {
        Long usuarioId = crearUsuarioDePrueba();
        given()
                .contentType(ContentType.JSON)
                .body(json("Monstera", "Monstera deliciosa", "Sala", "Hojas grandes",
                        "https://ejemplo.com/monstera.jpg"))
        .when()
                .post("/plantas/usuario/" + usuarioId)
        .then()
                .statusCode(201)
                .body("id", notNullValue())
                .body("nombre", is("Monstera"))
                .body("especie", is("Monstera deliciosa"))
                .body("usuarioId", equalTo(usuarioId.intValue()));
    }

    @Test
    public void testRegistrarPlantaCamposVacios() {
        Long usuarioId = crearUsuarioDePrueba();
        given()
                .contentType(ContentType.JSON)
                .body(json("", "", "", "", ""))
        .when()
                .post("/plantas/usuario/" + usuarioId)
        .then()
                .statusCode(400)
                .body("error.detalles", hasSize(3));
    }

    @Test
    public void testRegistrarPlantaUrlInvalida() {
        Long usuarioId = crearUsuarioDePrueba();
        given()
                .contentType(ContentType.JSON)
                .body(json("Monstera", "Monstera deliciosa", "Sala", "", "no-es-un-enlace"))
        .when()
                .post("/plantas/usuario/" + usuarioId)
        .then()
                .statusCode(400)
                .body("error.detalles", hasItem(containsString("enlace válido")));
    }

    @Test
    public void testRegistrarPlantaUsuarioInexistente() {
        given()
                .contentType(ContentType.JSON)
                .body(json("Monstera", "Monstera deliciosa", "Sala", "", ""))
        .when()
                .post("/plantas/usuario/999999")
        .then()
                .statusCode(404)
                .body("error.codigo", is("CERT-ERR-P1"));
    }

    @Test
    public void testListarPlantasDelUsuario() {
        Long usuarioId = crearUsuarioDePrueba();
        for (String nombre : new String[]{"Helecho", "Suculenta"}) {
            given().contentType(ContentType.JSON)
                    .body(json(nombre, "Especie", "Balcón", "", ""))
                    .when().post("/plantas/usuario/" + usuarioId)
                    .then().statusCode(201);
        }

        given()
        .when()
                .get("/plantas/usuario/" + usuarioId)
        .then()
                .statusCode(200)
                .body("$", hasSize(2))
                .body("nombre", hasItems("Helecho", "Suculenta"));
    }
}
