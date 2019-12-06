/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package practica1;

import java.io.FileInputStream;
import java.security.KeyFactory;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.security.Security;
import java.security.spec.PKCS8EncodedKeySpec;
import java.security.spec.X509EncodedKeySpec;
import javax.crypto.KeyGenerator;
import javax.crypto.SecretKey;
import org.bouncycastle.jce.provider.BouncyCastleProvider;

/**
 *
 * @author Armind
 */
public class MetodosClaves {

    public static byte[] getKeyFromFile(String keyFileName) throws Exception {
        byte[] buffer = new byte[5000];
        FileInputStream in = new FileInputStream(keyFileName);
        in.read(buffer, 0, 5000);
        in.close();

        return buffer;
    }

    public static PrivateKey getPrivateKey(String keyFileName) throws Exception {
        byte[] buffer = getKeyFromFile(keyFileName);
        Security.addProvider(new BouncyCastleProvider());
        KeyFactory keyFactoryRSA = KeyFactory.getInstance("RSA", "BC");
        PKCS8EncodedKeySpec clavePrivadaSpec = new PKCS8EncodedKeySpec(buffer);
        PrivateKey clavePrivada = keyFactoryRSA.generatePrivate(clavePrivadaSpec);

        return clavePrivada;
    }

    public static PublicKey getPublicKey(String keyFileName) throws Exception {
        byte[] buffer = getKeyFromFile(keyFileName);
        Security.addProvider(new BouncyCastleProvider());
        KeyFactory keyFactoryRSA = KeyFactory.getInstance("RSA", "BC");
        X509EncodedKeySpec clavePublicaSpec = new X509EncodedKeySpec(buffer);
        PublicKey clavePublica = keyFactoryRSA.generatePublic(clavePublicaSpec);

        return clavePublica;
    }

    public static SecretKey getSecretKey() throws Exception {
        KeyGenerator generadorDES = KeyGenerator.getInstance("DES");
        generadorDES.init(56); // clave de 56 bits
        SecretKey claveAleatoria = generadorDES.generateKey();

        return claveAleatoria;
    }

}
