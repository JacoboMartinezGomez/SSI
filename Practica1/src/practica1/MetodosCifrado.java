/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package practica1;

import java.security.Key;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.security.Security;
import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;
import org.bouncycastle.jce.provider.BouncyCastleProvider;
import org.bouncycastle.util.encoders.Base64;

/**
 *
 * @author Armind
 */
public class MetodosCifrado {
    
    protected static byte[] cryptDES(int mode, Key clave, byte[] datos) throws Exception {
        Cipher cipher = Cipher.getInstance("DES/ECB/PKCS5Padding");
        cipher.init(mode, clave);
        byte[] buffer = cipher.doFinal(datos);
        
        return buffer;
    }
      
    protected static byte[] cryptRSA(int mode, Key clave, byte[] datos) throws Exception {
	Security.addProvider(new BouncyCastleProvider());
	Cipher cipher = Cipher.getInstance("RSA", "BC");
	cipher.init(mode, clave);
	byte[] buffer = cipher.doFinal(datos);
        
        return buffer;
    }
    
    //Cifra datos con DES
    public static byte[] encryptDES(SecretKey clave, byte[] datos) throws Exception {
        return cryptDES(Cipher.ENCRYPT_MODE, clave, datos);
    }
    
    public static byte[] decryptDES(SecretKey clave, byte[] datos) throws Exception {
        return cryptDES(Cipher.DECRYPT_MODE, clave, datos);
    }
        
    public static byte[] encryptRSAPublic(PublicKey clave, byte[] datos) throws Exception {
        return cryptRSA(Cipher.ENCRYPT_MODE, clave, datos);
    }
    
    //Cifra datos cunha Clave Privada
    public static byte[] encryptRSAPrivate(PrivateKey clave, byte[] datos) throws Exception {
        return cryptRSA(Cipher.ENCRYPT_MODE, clave, datos);
    }

    public static byte[] decryptRSAPublic(PublicKey clave, byte[] datos) throws Exception {
        return cryptRSA(Cipher.DECRYPT_MODE, clave, datos);
    }
        
    public static byte[] decryptRSAPrivate(PrivateKey clave, byte[] datos) throws Exception {
        return cryptRSA(Cipher.DECRYPT_MODE, clave, datos);
    }
    
    
     public static byte[] cifrarClaveSecreta(String clavePublicaFile, SecretKey claveSecreta)  throws Exception {
	
        PublicKey clavePublica = MetodosClaves.getPublicKey(clavePublicaFile); 
                
	byte[] encodedKey = Base64.encode(claveSecreta.getEncoded());
        byte[] claveSecretaCifrada = encryptRSAPublic(clavePublica, encodedKey);
        
        return claveSecretaCifrada;
    }
        
    public static SecretKey descifrarClaveSecreta(String clavePrivadaFile, byte[] claveSecretaCifrada) throws Exception {
        
        PrivateKey clavePrivadaOficina = MetodosClaves.getPrivateKey(clavePrivadaFile);
        
        byte[] buffer = decryptRSAPrivate(clavePrivadaOficina, claveSecretaCifrada);
	byte[] encodedKey = Base64.decode(buffer);
	SecretKey claveSecreta = new SecretKeySpec(encodedKey, 0, encodedKey.length, "DES");
        
        return claveSecreta;	
    }

}
