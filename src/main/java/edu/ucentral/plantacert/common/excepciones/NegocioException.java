package edu.ucentral.plantacert.common.excepciones;

/**
 * Excepción para reglas de negocio (correo duplicado, usuario inexistente, etc.).
 * Lleva el código HTTP y un código interno de error.
 */
public class NegocioException extends RuntimeException {

    private final int status;
    private final String codigo;

    public NegocioException(int status, String codigo, String mensaje) {
        super(mensaje);
        this.status = status;
        this.codigo = codigo;
    }

    public int getStatus() {
        return status;
    }

    public String getCodigo() {
        return codigo;
    }
}
