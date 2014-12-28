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
import org.apache.commons.cli.ParseException
import org.eclipse.xtend.lib.annotations.Accessors
import com.google.common.collect.LinkedListMultimap
import com.google.common.collect.ListMultimap
import java.util.Map

// TODO http://stackoverflow.com/questions/19517538/ignoring-ssl-certificate-in-apache-httpclient-4-3
class Scraper {

//	XPathFactory xPathFactory = XPathFactory.newInstance();

	@Accessors
	ScraperOptions options = new ScraperOptions();

	def static void main(String[] args) {
		val Scraper scraper = new Scraper();
		scraper.options.defineOptions();
		try {
			scraper.options.parseOptions(args);

			if (scraper.options.commandLine.args.empty) {
				System.out.println("No URL specified!");
				scraper.options.printUsage();
			} else if (scraper.options.commandLine.args.size > 1) {
				System.out.println("Unexpected arguments: Exactly one URL is required!");
				scraper.options.printUsage();
			} else {
				// Main code
				SslUtil.disableCertificateValidation();
				scraper.scrapeUrl(scraper.options.commandLine.args.get(0));
			}
		} catch (ParseException pe) {
			System.out.println(pe.message);
			scraper.options.printUsage();
		}
	}

	// see http://stackoverflow.com/questions/9022140/using-xpath-contains-against-html-in-java
	def scrapeUrl(String urlString) {
		var out = System.out;
		try {
			if (options.commandLine.hasOption("o")) {
				val outputFilename = options.commandLine.getOptionValue("o");
				out = new PrintStream(outputFilename);
			}
			try {
				var Document doc = null;
				if (urlString.startsWith("http")) {
					val String response = SslUtil.request(urlString);
					doc = Jsoup.parse(response);
				} else {
					// Assume url is a file
					val File response = new File(urlString);
					doc = Jsoup.parse(response, StandardCharsets.UTF_8.name);
				}

//				System.out.println("Old scraping:");
//				printNodeContent(out, doc, "pre.idl");
//				printNodeContent(out, doc, "code.idl-code");
//				// Needed for http://www.w3.org/TR/service-workers/
//				printNodeContent(out, doc, "pre code");
//				System.out.println("New scraping:");
//				printNodeContentSpecial(out, doc);
				printReferences(out, doc, "dl#ref-list");
				printReferences(out, doc, "div#anolis-references dl");
				printReferences(out, doc, "section#normative-references dl.bibliography");
				printReferences(out, doc, "section#informative-references dl.bibliography");
			} catch (ParserConfigurationException e) {
				e.printStackTrace();
			} catch (MalformedURLException e) {
				e.printStackTrace();
			} catch (IOException e) {
				e.printStackTrace();
			}
		} finally {
			if (out != null) {
				out.close();
			}
		}
	}

	private def definitionList(Element root) {
		val LinkedListMultimap<Element, Element> listMultimap = LinkedListMultimap.create();

		var Element dt = null;
		for (Element element : root.children) {
			switch (element.tagName) {
				case "dt": {dt = element;}
				case "dd": {listMultimap.put(dt, element);}
				default: {System.err.println("Unexpected child element!");}
			}
		}
		return listMultimap;
	}

	private def void printReferences(PrintStream out, Document doc, String query) {
		val Elements elementsQuery = doc.select(query);
		if (elementsQuery.isEmpty()) {
			return;
		}
		val Element root = elementsQuery.get(0);
		val ListMultimap<Element, Element> definitionList = definitionList(root);
		
		for (Element dt : definitionList.keySet) {
			val String refNameText = dt.text();
			val String refName = refNameText.substring(1, refNameText.length - 1).toLowerCase();

			val List<Element> dds = definitionList.get(dt);
			for (Element dd : dds) {
				val Elements refs = dd.select("a");
				if (refs.size() != 1) {
					System.err.println("Unexpected number of links " + refs.size() + "!");
				}
				for (Element ref : refs) {
					out.println("CALL scrape " + ref.attr("href") + " -o " + refName + ".idl");
				}
			}
		}

//		val Elements elements = elementsQuery.get(0).children;
//		var Element dt = null;
//		var String refNameText = null;
//		var String refName = null;
//		var boolean first = true;
//		var int index = 0;
//		for (Element element : elements) {
//			if ("dt".equals(element.tagName)) {
//				dt = element;
//				refNameText = dt.text();
//				refName = refNameText.substring(1, refNameText.length - 1).toLowerCase();
//				first = true;
//				index = 0;
//			} else if ("dd".equals(element.tagName)) {
//				val Elements refs = element.select("a");
//				if (refs.size() != 1) {
//					System.err.println("Unexpected number of links " + refs.size() + "!");
//				}
//				for (Element ref : refs) {
//					out.println("CALL scrape " + ref.attr("href") + " -o " + refName + ".idl");
//				}
//				if (first) {
//					first = false;
//				} else {
//					index++;
//					System.err.println("More than one link for " + refNameText + "!");
//				}
//			} else {
//				System.err.println("Unexpected child element!");
//			}
//		}
	}

	private def int printNodeContent(PrintStream out, Document doc, String query) {
		val Elements elements = doc.select(query);
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
				val boolean isTypedef = title.startsWith("typedef");
				out.print(title);
				if (!isCallback && !isTypedef) {
					out.println(" {");
				} else {
					out.println();
				}

				val Elements nodeListInner = element.select("dt");
				val List<String> innerListText = nodeListInner.map[it.text()];
	
				if (isEnum) {
					out.println(innerListText.map["\"" + it  + "\""].join(", "));
				} else if (isCallback) {
					out.println("(" + innerListText.join(", ") + ")");
				} else {
					innerListText.forEach[out.println(it + ";")];
				}

				if (!isCallback && !isTypedef) {
					out.print("}");
				}
				out.println(";");
			}
		}
		return elements.size();
	}

}
