package practica1;

import java.security.MessageDigest;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.security.Security;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Scanner;
import org.bouncycastle.jce.provider.BouncyCastleProvider;

/**
 *
 * @author Armind
 */
public final class MetodosFirmaDatos {

    public static String getTimestamp() {
        Date dNow = new Date();
        SimpleDateFormat ft = new SimpleDateFormat("dd.MM.yyyy '-' hh.mm.ss");

        return ft.format(dNow);
    }

    public static String getTimestamp(long timeInMillis) {
        Date dNow = new Date(timeInMillis);
        SimpleDateFormat ft = new SimpleDateFormat("dd.MM.yyyy '-' hh.mm.ss");

        return ft.format(dNow);
    }

    public static byte[] getDigest(byte[] datos) throws Exception {
        Security.addProvider(new BouncyCastleProvider());
        MessageDigest md5 = MessageDigest.getInstance("MD5", "BC");

        return md5.digest(datos);
    }

    public static byte[] getDigest(byte[][] datos) throws Exception {
        Security.addProvider(new BouncyCastleProvider());
        MessageDigest md5 = MessageDigest.getInstance("MD5", "BC");
        for (byte[] dato : datos) {
            md5.update(dato);
        }
        return md5.digest();
    }

    public static byte[] signRSA(PrivateKey clavePrivada, byte[] datos) throws Exception {
        byte[] digest = getDigest(datos);
        return MetodosCifrado.encryptRSAPrivate(clavePrivada, digest);
    }

    public static byte[] signRSA(PrivateKey clavePrivada, byte[][] datos) throws Exception {
        byte[] digest = getDigest(datos);
        return MetodosCifrado.encryptRSAPrivate(clavePrivada, digest);
    }

    public static byte[] signature(String clavePrivada, byte[] datos) throws Exception {
        PrivateKey clavePri = MetodosClaves.getPrivateKey(clavePrivada);
        byte[] signature = signRSA(clavePri, datos);
        return signature;
    }

    public static boolean checkSignature(String clavePublica, byte[] signature, String datos) throws Exception {
        PublicKey clavePub = MetodosClaves.getPublicKey(clavePublica);
        //Digest calculado
        byte[] digest = getDigest(datos.getBytes());
        //Digest descifrado
        byte[] digest2 = MetodosCifrado.decryptRSAPublic(clavePub, signature);
        return Arrays.equals(digest, digest2);
    }

    public static boolean checkSignature(String clavePublica, byte[] signature, byte[][] datos) throws Exception {

        PublicKey clavePub = MetodosClaves.getPublicKey(clavePublica);
        //Digest calculado
        byte[] digest = getDigest(datos);
        //Digest descifrado
        byte[] digest2 = MetodosCifrado.decryptRSAPublic(clavePub, signature);
        return Arrays.equals(digest, digest2);
    }

    public static String getData(String id, String[] textos, String[] tags) {
        Map<String, String> datos = new LinkedHashMap<>();
        String entradaTeclado = "";
        Scanner in = new Scanner(System.in);
        for (int i = 0; i < textos.length; i++) {
            System.out.println("Introduce " + textos[i] + " del " + id + ":");
            entradaTeclado = in.nextLine();
            datos.put(tags[i], entradaTeclado);
        }
        in.close();
        datos.put("Fecha_Creacion", getTimestamp());
        String json = JSONUtils.map2json(datos);

        return json;
    }
    
    public static Paquete ReadPackage(String filename) {
        Paquete paquete = PaqueteDAO.leerPaquete(filename);
        return paquete;
    }

    public static void SavePackage(String filename, Paquete paquete) {
        PaqueteDAO paqueteDAO = new PaqueteDAO();
        paqueteDAO.escribirPaquete(filename, paquete);
    }

}
