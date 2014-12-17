package com.rainerschuster.webidl.scraper;

import java.io.IOException
import java.io.PrintStream
import java.net.MalformedURLException
import java.net.URL
import java.util.ArrayList
import java.util.List
import javax.xml.parsers.ParserConfigurationException
import javax.xml.xpath.XPath
import javax.xml.xpath.XPathConstants
import javax.xml.xpath.XPathExpressionException
import javax.xml.xpath.XPathFactory
import org.htmlcleaner.CleanerProperties
import org.htmlcleaner.DomSerializer
import org.htmlcleaner.HtmlCleaner
import org.htmlcleaner.TagNode
import org.w3c.dom.Document
import org.w3c.dom.Node
import org.w3c.dom.NodeList

// TODO precompile xpath expressions for performance
class Scraper {

	def static void main(String[] args) {
		if (args.length == 1) {
			(new Scraper()).mymain(args.get(0));
		} else {
			System.out.println("Usage: Scraper <idlurl>");
		}
	}

	def mymain(String urlString) {
			// see http://stackoverflow.com/questions/9022140/using-xpath-contains-against-html-in-java
			try {
				val URL url = new URL(urlString);
				val TagNode tagNode = new HtmlCleaner().clean(url);

				val Document doc = new DomSerializer(new CleanerProperties()).createDOM(tagNode);

				// "//pre[@class='idl']"
				// "//pre[contains(@class, 'idl')]"
				printNodeContent(System.out, doc, "//pre[contains(@class, 'idl')]");
				printNodeContentSpecial(System.out, doc, "//dl[contains(@class, 'idl')]");
//				printNodeContent(System.out, doc, "//spec-idl[contains(@class, 'idl')]");
			} catch (ParserConfigurationException e) {
				e.printStackTrace();
			} catch (XPathExpressionException e) {
				e.printStackTrace();
			} catch (MalformedURLException e) {
				e.printStackTrace();
			} catch (IOException e) {
				e.printStackTrace();
			}
	}

	private def int printNodeContent(PrintStream out, Document doc, String xpathExpression) throws XPathExpressionException {
		val XPath xpath = XPathFactory.newInstance().newXPath();
		val NodeList nodeList = xpath.evaluate(xpathExpression, doc, XPathConstants.NODESET) as NodeList;
		for (var int i = 0; i < nodeList.getLength(); i++) {
			val Node node = nodeList.item(i);
			out.println(node.getTextContent());
			out.println();
		}
		return nodeList.getLength();
	}

	private def int printNodeContentSpecial(PrintStream out, Document doc, String xpathExpression) throws XPathExpressionException {
		val XPath xpath = XPathFactory.newInstance().newXPath();
		val NodeList nodeList = xpath.evaluate(xpathExpression, doc, XPathConstants.NODESET) as NodeList;
		val List<Node> list = nodeListToList(nodeList);
		for (Node node : list) {
			val String title = node.getAttributes().getNamedItem("title").getTextContent();
			val boolean isEnum = title.startsWith("enum");
			val boolean isCallback = title.startsWith("callback");
			out.print(title);
			if (!isCallback) {
				out.println(" {");
			} else {
				out.println();
			}
			val XPath xpathInner = XPathFactory.newInstance().newXPath();
			val NodeList nodeListInner = xpathInner.evaluate("./dt", node, XPathConstants.NODESET) as NodeList;
			val List<Node> innerList = nodeListToList(nodeListInner);
			// TODO more html replacement!
			val List<String> innerListText = innerList.map[it.textContent.replace("&lt;", "<").replace("&gt;", ">")];

			if (isEnum) {
				out.println(innerListText.map["\"" + it  + "\""].join(','));
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
		return nodeList.getLength();
	}

	private def List<Node> nodeListToList(NodeList nodeList) {
		val List<Node> list = new ArrayList<Node>(nodeList.getLength());
		for (var int i = 0; i < nodeList.getLength(); i++) {
			val Node node = nodeList.item(i);
			list.add(node);
		}
		return list;
	}

}
