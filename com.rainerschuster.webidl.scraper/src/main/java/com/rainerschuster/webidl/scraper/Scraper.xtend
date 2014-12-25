package com.rainerschuster.webidl.scraper;

import java.io.IOException
import java.io.PrintStream
import java.net.MalformedURLException
import java.util.List
import javax.xml.parsers.ParserConfigurationException
import org.jsoup.Jsoup
import org.jsoup.nodes.Document
import org.jsoup.nodes.Element
import org.jsoup.select.Elements
import java.io.File
import java.nio.charset.StandardCharsets
import com.rainerschuster.webidl.scraper.util.SslUtil

// TODO precompile inner xpath expressions for performance
// TODO http://stackoverflow.com/questions/19517538/ignoring-ssl-certificate-in-apache-httpclient-4-3
class Scraper {

//	XPathFactory xPathFactory = XPathFactory.newInstance();

	def static void main(String[] args) {
		if (args.length == 1) {
			SslUtil.disableCertificateValidation();
			(new Scraper()).scrapeUrl(args.get(0));
		} else {
			System.out.println("Usage: Scraper <idlurl>");
		}
	}

	// see http://stackoverflow.com/questions/9022140/using-xpath-contains-against-html-in-java
	def scrapeUrl(String urlString) {
		try {
//			val URL url = new URL(urlString);
//			val Document doc = Jsoup.parse(url, 0);

			var Document doc = null;
			if (urlString.startsWith("http")) {
				val String response = SslUtil.request(urlString);
				doc = Jsoup.parse(response);
			} else {
				// Assume url is a file
				val File response = new File(urlString);
				doc = Jsoup.parse(response, StandardCharsets.UTF_8.name);
			}

			// Note: [@class='idl'] vs. [contains(@class, 'idl')] vs. [contains(concat(' ', normalize-space(@class), ' '), ' idl ')]
//			val XPath xpathPreIdl = xPathFactory.newXPath();
//			val XPathExpression xpathExpressionPreIdl = xpathPreIdl.compile("//pre[contains(concat(' ', normalize-space(@class), ' '), ' idl ')]");
//			val XPath xpathDlIdl = xPathFactory.newXPath();
//			val XPathExpression xpathExpressionDlIdl = xpathDlIdl.compile("//dl[contains(concat(' ', normalize-space(@class), ' '), ' idl ')]");
//			val XPath xpathSpecIdlIdl = xPathFactory.newXPath();
//			val XPathExpression xpathExpressionSpecIdlIdl = xpathSpecIdlIdl.compile("//spec-idl[contains(@class, 'idl')]");

//			System.out.println("Old scraping:");
			printNodeContent(System.out, doc);
//			System.out.println("New scraping:");
			printNodeContentSpecial(System.out, doc);
//			printNodeContent(System.out, doc, xpathExpressionSpecIdlIdl);
		} catch (ParserConfigurationException e) {
			e.printStackTrace();
		} catch (MalformedURLException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	private def int printNodeContent(PrintStream out, Document doc) {
		val Elements elements = doc.select("pre.idl");
		for (Element element : elements) {
			// TODO check if this is also necessary in "new", i.e., printNodeContentSpecial version
			if (element.classNames.contains("extract")) {
//				System.out.println("Ignoring node since it is only an extract.");
			} else {
				out.println(element.text());
				out.println();
			}
		}
		return elements.size();
	}

	private def int printNodeContentSpecial(PrintStream out, Document doc) {
		val Elements elements = doc.select("dl.idl");
		for (Element element : elements) {
			// TODO check if this is also necessary in "new", i.e., printNodeContentSpecial version
			if (element.classNames.contains("extract")) {
//				System.out.println("Ignoring node since it is only an extract.");
			} else {

			val String title = element.attr("title");
			val boolean isEnum = title.startsWith("enum");
			val boolean isCallback = title.startsWith("callback");
			out.print(title);
			if (!isCallback) {
				out.println(" {");
			} else {
				out.println();
			}
			
			val Elements nodeListInner = element.select("dt");
			// TODO more html replacement!
			val List<String> innerListText = nodeListInner.map[it.text()];

			if (isEnum) {
				out.println(innerListText.map["\"" + it  + "\""].join(", "));
			} else if (isCallback) {
				out.println("(" + innerListText.join(", ") + ")");
			} else {
				innerListText.forEach[out.println(it + ";")];
			}

			if (!isCallback) {
				out.print("}");
			}
			out.println(";");
				
			}
		}
		return elements.size();
	}

//	private def int printNodeContent(PrintStream out, Document doc, XPathExpression xpathExpression) throws XPathExpressionException {
//		val NodeList nodeList = xpathExpression.evaluate(doc, XPathConstants.NODESET) as NodeList;
//		val List<Node> list = nodeListToList(nodeList);
//		for (Node node : list) {
//			// TODO check if this is also necessary in "new", i.e., printNodeContentSpecial version
//			if (node.attributes.getNamedItem("class").textContent.split(" ").contains("extract")) {
//				System.out.println("Ignoring node since it is only an extract.");
//			} else {
//				out.println(node.textContent);
//				out.println();
//			}
//		}
//		return nodeList.getLength();
//	}
//
//	private def int printNodeContentSpecial(PrintStream out, Document doc, XPathExpression xpathExpression) throws XPathExpressionException {
//		val NodeList nodeList = xpathExpression.evaluate(doc, XPathConstants.NODESET) as NodeList;
//		val List<Node> list = nodeListToList(nodeList);
//		for (Node node : list) {
//			val String title = node.getAttributes().getNamedItem("title").textContent;
//			val boolean isEnum = title.startsWith("enum");
//			val boolean isCallback = title.startsWith("callback");
//			out.print(title);
//			if (!isCallback) {
//				out.println(" {");
//			} else {
//				out.println();
//			}
//			val XPath xpathInner = xPathFactory.newXPath();
//			val NodeList nodeListInner = xpathInner.evaluate("./dt", node, XPathConstants.NODESET) as NodeList;
//			val List<Node> innerList = nodeListToList(nodeListInner);
//			// TODO more html replacement!
//			val List<String> innerListText = innerList.map[it.textContent.replace("&lt;", "<").replace("&gt;", ">")];
//
//			if (isEnum) {
//				out.println(innerListText.map["\"" + it  + "\""].join(", "));
//			} else if (isCallback) {
//				out.println("(" + innerListText.join(", ") + ")");
//			} else {
//				innerListText.forEach[out.println(it + ";")];
//			}
//
//			if (!isCallback) {
//				out.print("}");
//			}
//			out.println(";");
//		}
//		return nodeList.getLength();
//	}
//
//	private def List<Node> nodeListToList(NodeList nodeList) {
//		val List<Node> list = new ArrayList<Node>(nodeList.getLength());
//		for (var int i = 0; i < nodeList.getLength(); i++) {
//			val Node node = nodeList.item(i);
//			list.add(node);
//		}
//		return list;
//	}

}
