package com.rainerschuster.webidl.scraper.util;

import javax.net.ssl.*;

import org.apache.http.HttpEntity;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
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

		// Ignore differences between given hostname and certificate hostname
		HostnameVerifier hv = new HostnameVerifier() {
			public boolean verify(String hostname, SSLSession session) {
				return true;
			}
		};

		// Install the all-trusting trust manager
		try {
			SSLContext sc = SSLContext.getInstance("SSL");
			sc.init(null, trustAllCerts, new SecureRandom());
			HttpsURLConnection.setDefaultSSLSocketFactory(sc.getSocketFactory());
			HttpsURLConnection.setDefaultHostnameVerifier(hv);
		} catch (Exception e) {
		}
	}

	/** see http://stackoverflow.com/questions/14608481/how-to-ignore-self-signed-certificate-and-supress-peer-not-authenticated-error */
	public static String request(final String request) throws ClientProtocolException, IOException, NoSuchAlgorithmException, KeyManagementException  {
	    String result = null;
//	    final SSLContextBuilder builder = new SSLContextBuilder();
	    final SSLContext sslContext = SSLContext.getInstance("SSL");

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

	    final SSLConnectionSocketFactory sslConnectionSocketFactory = new SSLConnectionSocketFactory(sslContext, SSLConnectionSocketFactory.ALLOW_ALL_HOSTNAME_VERIFIER);
//	    final SSLConnectionSocketFactory sslConnectionSocketFactory = new SSLConnectionSocketFactory(builder.build(), SSLConnectionSocketFactory.ALLOW_ALL_HOSTNAME_VERIFIER);
	    final CloseableHttpClient httpClient = HttpClients.custom().setSSLSocketFactory(sslConnectionSocketFactory).build();
	    final HttpGet httpGet = new HttpGet(request);
	    final CloseableHttpResponse response = httpClient.execute(httpGet);
	    try {
	    	final HttpEntity entity = response.getEntity();
	        result = EntityUtils.toString(entity);
	        EntityUtils.consume(entity);
	    } finally {
	        response.close();
	    }
	    return result;
	}

}
