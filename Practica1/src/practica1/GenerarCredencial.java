/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package practica1;

import javax.crypto.SecretKey;

/**
 *
 * @author Armind
 */
public class GenerarCredencial {

    private static String clavePrivadaPeregrino = "peregrino.privada";
    private static String clavePublicaOficina = "oficina.publica";
    private static String paqueteGen = "paquete.paq";
    private static final String idPregrino = "Peregrino";
    private static final String[] infoPeregrino = {"NOMBRE", "DNI", "DOMICILIO", "FECHA DE CREACION", "LUGAR DE CREACION", "MOTIVACIONES DEL PEREGRINAJE"};
    private static final String[] info2Peregrino = {"Nombre", "DNI", "Domicilio", "Fecha de creacion", "Lugar de creacion", "Motivaciones del peregrinaje"};

    protected static void crearCredencial(String paqueteGen, String clavePrivadaPeregrino, String clavePublicaOficina, String datos) throws Exception {

        SecretKey secretKey = MetodosClaves.getSecretKey();
        System.out.println("Creada clave secreta para cifrado dos datos...");
        byte[] bloqueDatos = MetodosCifrado.encryptDES(secretKey, datos.getBytes());
        System.out.println("Cifrados datos do peregrino coa clave secreta...");
        byte[] bloqueClaveSecreta = MetodosCifrado.cifrarClaveSecreta(clavePublicaOficina, secretKey);
        System.out.println("Cifrada clave secreta coa clave publica da Oficina do Peregrino...");
        byte[] bloqueSinatura = MetodosFirmaDatos.signature(clavePrivadaPeregrino, datos.getBytes());
        System.out.println("Creada firma dos datos coa clave privada do Peregrino...");
        Paquete paquete = new Paquete();
        paquete.anadirBloque(idPregrino + "_Datos", bloqueDatos);
        paquete.anadirBloque(idPregrino + "_ClaveCifrada", bloqueClaveSecreta);
        paquete.anadirBloque(idPregrino + "_Sinatura", bloqueSinatura);
        MetodosFirmaDatos.SavePackage(paqueteGen, paquete);
        System.out.println("Generado con exito");
    }

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        if (args.length != 3) {
            System.out.println("Error el formato deberia ser: GenerarCredencial <nombre paquete> <peregrino.privada> <oficina.publica>");
            System.exit(1);
        }
        paqueteGen = args[0];
        clavePrivadaPeregrino = args[1];
        clavePublicaOficina = args[2];

        if (!clavePrivadaPeregrino.endsWith("privada") || !clavePublicaOficina.endsWith("publica")) {
            System.out.println("Error de formato");
            System.exit(1);
        }

        String datos = MetodosFirmaDatos.getData("peregrino", infoPeregrino, info2Peregrino);
        System.out.println("Datos del peregrino: " + datos);

        try {
            crearCredencial(paqueteGen, clavePrivadaPeregrino, clavePublicaOficina, datos);
        } catch (Exception e) {
            System.out.println("Error: " + e);
        }

    }

}
