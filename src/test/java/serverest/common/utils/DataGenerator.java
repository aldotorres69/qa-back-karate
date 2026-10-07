package serverest.common.utils;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ThreadLocalRandom;

/**
 * Helper de generación de datos de prueba para la API de Usuarios.
 * Se invoca desde los features con: Java.type('serverest.common.utils.DataGenerator')
 */
public final class DataGenerator {

    private static final List<String> NOMBRES =
            List.of("Ana", "Luis", "Carla", "Jorge", "Sofia", "Diego", "Valeria", "Mateo");
    private static final List<String> APELLIDOS =
            List.of("Torres", "Garcia", "Lopez", "Martinez", "Rojas", "Flores", "Vargas");

    private DataGenerator() {
    }

    private static String sufijoUnico(int longitud) {
        return UUID.randomUUID().toString().replace("-", "").substring(0, longitud);
    }

    private static String elegir(List<String> valores) {
        return valores.get(ThreadLocalRandom.current().nextInt(valores.size()));
    }

    /** Email único para evitar colisiones con datos de otros usuarios de la API pública. */
    public static String email() {
        return "qa.karate." + sufijoUnico(12) + "@test.com";
    }

    public static String nombre() {
        return elegir(NOMBRES) + " " + elegir(APELLIDOS) + " QA";
    }

    public static String password() {
        return "Pwd_" + sufijoUnico(10);
    }

    /** Usuario válido con perfil administrador aleatorio. */
    public static Map<String, Object> usuario() {
        return usuario(ThreadLocalRandom.current().nextBoolean());
    }

    /** Usuario válido con el perfil de administrador indicado. */
    public static Map<String, Object> usuario(boolean administrador) {
        Map<String, Object> u = new HashMap<>();
        u.put("nome", nombre());
        u.put("email", email());
        u.put("password", password());
        u.put("administrador", String.valueOf(administrador));
        return u;
    }

    /** _id con formato válido (16 caracteres alfanuméricos) que no existe en la base. */
    public static String idInexistente() {
        return "zz" + sufijoUnico(12) + "zz";
    }
}
