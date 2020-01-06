/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package practica1;

import java.util.HashMap;
import java.util.Map;
import javax.crypto.SecretKey;
import practica1.MetodosCifrado;
import practica1.MetodosFirmaDatos;
import practica1.MetodosClaves;

/**
 *
 * @author Armind
 */
public class DesempaquetarCredencial {

    private static String clavePublicaPeregrino = "peregrino.publica";
    private static String clavePrivadaOficina = "oficina.privada";
    private static String paqueteGen = "paquete.paq";
    private static final String idPregrino = "Peregrino";
    private static final Map<String, String> albergueClavesPublicas = new HashMap<>();
    private static int numAlbergues = 0;

    private static boolean comprobarPeregrino(Paquete paquete, String id, String clavePrivadaOficina, String asinanteClavePublica) throws Exception {

        byte[] claveSecretaCifrada = paquete.getContenidoBloque(id + "_CLAVECIFRADA");
        byte[] bloqueSignature = paquete.getContenidoBloque(id + "_SIGNATURE");
        byte[] bloqueDatos = paquete.getContenidoBloque(id + "_DATOS");
        SecretKey secretKey = MetodosCifrado.descifrarClaveSecreta(clavePrivadaOficina, claveSecretaCifrada);
        String datos = new String(MetodosCifrado.decryptDES(secretKey, bloqueDatos));
        System.out.println(id + ": " + datos);

        return MetodosFirmaDatos.checkSignature(asinanteClavePublica, bloqueSignature, datos);
    }

    private static boolean comprobarAlbergue(Paquete paquete, String id, String clavePrivadaOficina, String asinanteClavePublica) throws Exception {

        byte[] claveSecretaCifrada = paquete.getContenidoBloque(id + "_CLAVECIFRADA");
        byte[] bloqueSinatura = paquete.getContenidoBloque(id + "_SINGATURE");
        byte[] bloqueDatos = paquete.getContenidoBloque(id + "_DATOS");
        byte[] bloqueSignaturePeregrino = paquete.getContenidoBloque(idPregrino + "_SIGNATURE");
        SecretKey secretKey = MetodosCifrado.descifrarClaveSecreta(clavePrivadaOficina, claveSecretaCifrada);
        String datos = new String(MetodosCifrado.decryptDES(secretKey, bloqueDatos));
        System.out.println(id + "-" + datos);
        byte[] buffer[] = {bloqueSignaturePeregrino, datos.getBytes()};

        return MetodosFirmaDatos.checkSignature(asinanteClavePublica, bloqueSinatura, buffer);
    }

    protected static void desempaquetaCreden(String paqueteGen, String clavePrivadaOficina, String clavePublicaPeregrino, int numAlbergues, Map<String, String> albergueClavesPublicas) throws Exception {

        PaqueteDAO paqueteDAO = new PaqueteDAO();
        Paquete paquete = paqueteDAO.leerPaquete(paqueteGen);
        boolean toret = comprobarPeregrino(paquete, idPregrino, clavePrivadaOficina, clavePublicaPeregrino);
        for (String albergueId : albergueClavesPublicas.keySet()) {
            toret = comprobarAlbergue(paquete, albergueId, clavePrivadaOficina, albergueClavesPublicas.get(albergueId));
        }

    }

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {

        String mensaje = "Error el formato deberia ser: DesempaquetarCredencial <fichero paquete> <num. albergues (N)> \n"
                + "<identificador albergue 1> <ficheros claves albergue 1> \n" + "... \n"
                + "<identificador albergue N> <ficheros claves albergue N> \n"
                + "<ficheros con otras claves necesarias> ";

        if (args.length > 5) {
            paqueteGen = args[0];
            numAlbergues = Integer.parseInt(args[1]);
        } else {
            System.out.println(mensaje);
            System.exit(1);
        }

        if (args.length != (4 + numAlbergues * 2)) {
            System.out.println(mensaje);
            System.exit(1);
        }

        for (int i = 0; i < numAlbergues; i++) {
            albergueClavesPublicas.put(args[(i * 2) + 2], args[(i * 2) + 3]);
        }

        clavePrivadaOficina = args[(numAlbergues * 2) + 2];
        clavePublicaPeregrino = args[(numAlbergues * 2) + 3];

        if (!clavePrivadaOficina.endsWith("privada") || !clavePublicaPeregrino.endsWith("publica")) {
            System.out.println(mensaje);
            System.exit(1);
        }

        try {
            desempaquetaCreden(paqueteGen, clavePrivadaOficina, clavePublicaPeregrino, numAlbergues, albergueClavesPublicas);
        } catch (Exception e) {
            System.out.println("Error: " + e);
        }

    }

}
