package edu.ucentral.plantacert.infraestructura;

import io.quarkus.test.junit.QuarkusTest;
import io.restassured.http.ContentType;
import org.junit.jupiter.api.Test;

import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.*;

@QuarkusTest
public class UsuarioRecursosTest {

    private String correoUnico() {
        return "valeria" + System.nanoTime() + "@correo.com";
    }

    private String json(String nombre, String correo, String contrasena) {
        return """
               { "nombre": "%s", "correo": "%s", "contrasena": "%s" }
               """.formatted(nombre, correo, contrasena);
    }

    @Test
    public void testRegistroExitoso() {
        String correo = correoUnico();
        given()
                .contentType(ContentType.JSON)
                .body(json("Valeria Gómez", correo, "clave1234"))
        .when()
                .post("/usuarios/registro")
        .then()
                .statusCode(201)
                .body("id", notNullValue())
                .body("correo", is(correo))
                .body("mensaje", containsString("Registro exitoso"))
                .body("$", not(hasKey("contrasena")))
                .body("$", not(hasKey("contrasenaHash")));
    }

    @Test
    public void testRegistroCamposVacios() {
        given()
                .contentType(ContentType.JSON)
                .body(json("", "", ""))
        .when()
                .post("/usuarios/registro")
        .then()
                .statusCode(400)
                .body("error.codigo", is("CERT-ERR-V1"));
    }

    @Test
    public void testRegistroContrasenaCorta() {
        given()
                .contentType(ContentType.JSON)
                .body(json("Valeria", correoUnico(), "123"))
        .when()
                .post("/usuarios/registro")
        .then()
                .statusCode(400)
                .body("error.detalles", hasItem(containsString("mínimo 8 caracteres")));
    }

    @Test
    public void testRegistroCorreoInvalido() {
        given()
                .contentType(ContentType.JSON)
                .body(json("Valeria", "correo-sin-arroba", "clave1234"))
        .when()
                .post("/usuarios/registro")
        .then()
                .statusCode(400);
    }

    @Test
    public void testRegistroCorreoDuplicado() {
        String correo = correoUnico();
        given().contentType(ContentType.JSON).body(json("Valeria", correo, "clave1234"))
                .when().post("/usuarios/registro")
                .then().statusCode(201);

        given().contentType(ContentType.JSON).body(json("Otra Persona", correo, "otraClave99"))
                .when().post("/usuarios/registro")
                .then()
                .statusCode(409)
                .body("error.codigo", is("CERT-ERR-U1"));
    }
}
