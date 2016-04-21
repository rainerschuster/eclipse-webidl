package com.rainerschuster.webidl.scraper.util;

import javax.net.ssl.*;

import org.apache.http.HttpEntity;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.conn.ssl.NoopHostnameVerifier;
import org.apache.http.conn.ssl.SSLConnectionSocketFactory;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;

import java.io.IOException;
import java.security.KeyManagementException;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.security.cert.X509Certificate;

public class SslUtil {
	public static void disableCertificateValidation() {
		// Create a trust manager that does not validate certificate chains
		TrustManager[] trustAllCerts = new TrustManager[] { new X509TrustManager() {
			public X509Certificate[] getAcceptedIssuers() {
				return new X509Certificate[0];
			}

			public void checkClientTrusted(X509Certificate[] certs, String authType) {
			}

			public void checkServerTrusted(X509Certificate[] certs, String authType) {
			}
		} };

		// Install the all-trusting trust manager
		try {
			SSLContext sc = SSLContext.getInstance("SSL");
			sc.init(null, trustAllCerts, new SecureRandom());
			HttpsURLConnection.setDefaultSSLSocketFactory(sc.getSocketFactory());
			HttpsURLConnection.setDefaultHostnameVerifier(NoopHostnameVerifier.INSTANCE);
		} catch (Exception e) {
		}
	}

	/** see http://stackoverflow.com/questions/14608481/how-to-ignore-self-signed-certificate-and-supress-peer-not-authenticated-error */
	public static String request(final String request) throws ClientProtocolException, IOException, NoSuchAlgorithmException, KeyManagementException  {
	    String result = null;
//	    SSLContextBuilder builder = new SSLContextBuilder();
	    SSLContext sslContext = SSLContext.getInstance("SSL");

	    // set up a TrustManager that trusts everything
	    sslContext.init(null, new TrustManager[] { new X509TrustManager() {
	                public X509Certificate[] getAcceptedIssuers() {
//	                        System.out.println("getAcceptedIssuers =============");
	                        return null;
	                }

	                public void checkClientTrusted(X509Certificate[] certs, String authType) {
//	                        System.out.println("checkClientTrusted =============");
	                }

	                public void checkServerTrusted(X509Certificate[] certs, String authType) {
//	                        System.out.println("checkServerTrusted =============");
	                }
	    } }, new SecureRandom());

	    SSLConnectionSocketFactory sslConnectionSocketFactory = new SSLConnectionSocketFactory(sslContext, NoopHostnameVerifier.INSTANCE);
//	    SSLConnectionSocketFactory sslConnectionSocketFactory = new SSLConnectionSocketFactory(builder.build(), NoopHostnameVerifier.INSTANCE);
	    CloseableHttpClient httpClient = HttpClients.custom().setSSLSocketFactory(sslConnectionSocketFactory).build();
	    HttpGet httpGet = new HttpGet(request);
	    CloseableHttpResponse response = httpClient.execute(httpGet);
	    try {
	    	HttpEntity entity = response.getEntity();
	        result = EntityUtils.toString(entity);
	        EntityUtils.consume(entity);
	    } finally {
	        response.close();
	    }
	    return result;
	}

}
