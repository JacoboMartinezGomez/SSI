/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package practica1;

import java.security.PrivateKey;
import javax.crypto.SecretKey;

/**
 *
 * @author Armind
 */
public class SellarCredencial {
    
    private static String clavePrivadaAlbergue = "albergue.privada";
    private static String clavePublicaOficina = "oficina.publica";
    private static String paqueteGen = "paquete.paq";
    static private String idAlbergue;
    private static final String[] infoAlbergue = {"NOMBRE","FECHA DE CREACION", "LUGAR DE CREACION", "INCIDENCIAS"};
    private static final String[] info2Albergue = {"Nombre","Fecha de creacion", "Lugar de creacion", "Incidencias"};
    
    
    protected static void sellaCreden(String paqueteGen, String idAlbergue, String clavePrivadaAlbergue, String clavePublicaOficina, String datos) throws Exception {
        
        PrivateKey clavePrivada = MetodosClaves.getPrivateKey(clavePrivadaAlbergue); 
                
        PaqueteDAO paqueteDAO = new PaqueteDAO();
        Paquete paq = paqueteDAO.leerPaquete(paqueteGen);
        
        SecretKey secretKey = MetodosClaves.getSecretKey();
        System.out.println("Creada clave secreta para el cifrado de datos");
        
        byte[] bloqueDatos = MetodosCifrado.encryptDES(secretKey, datos.getBytes());
        System.out.println("Cifrados los datos del albergue con la clave secreta");
        
        byte[] bloqueClaveSecreta = MetodosCifrado.cifrarClaveSecreta(clavePublicaOficina, secretKey);
        System.out.println("Cifrada clave secreta con la clave publica de la oficina");
        
        byte[] signaturePeregrino = paq.getContenidoBloque("PELEGRIN_SINATURA");
        byte[] datosAlbergue = datos.getBytes();
        byte[] array_datos[] = {signaturePeregrino, datosAlbergue};
        byte[] bloqueSinatura = MetodosFirmaDatos.signRSA(clavePrivada, array_datos);
        paq.anadirBloque(idAlbergue + "_Datos", bloqueDatos);
        paq.anadirBloque(idAlbergue + "_ClaveCifrada", bloqueClaveSecreta);
        paq.anadirBloque(idAlbergue + "_Signature", bloqueSinatura);        
        MetodosFirmaDatos.SavePackage(paqueteGen, paq);
       
        System.out.println("Proceso finalizado con exito");
    }
    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {                
        if (args.length != 4) {
            System.out.println("Error el formato deberia ser:  sellaCreden<fichero paquete> <id. albergue> <albergue.privada> <oficina.publica>");
            System.exit(1);
	}
        
        paqueteGen = args[0];
        idAlbergue = args[1];
        clavePrivadaAlbergue = args[2];
        clavePublicaOficina = args[3];
                
        if(!clavePrivadaAlbergue.endsWith("privada") || !clavePublicaOficina.endsWith("publica")){
            System.out.println("Error en el formato");
            System.exit(1);
        }
        String datos = MetodosFirmaDatos.getData("albergue", infoAlbergue, info2Albergue);
        try {
            sellaCreden(paqueteGen, idAlbergue, clavePrivadaAlbergue, clavePublicaOficina, datos);
        } catch (Exception e) {
            System.out.println("Error: "+e);
        }
        
    }
    
}
