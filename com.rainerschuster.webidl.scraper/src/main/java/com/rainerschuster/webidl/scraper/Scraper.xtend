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
import com.google.common.collect.Maps
import java.util.Queue
import com.google.common.collect.Queues

// TODO http://stackoverflow.com/questions/19517538/ignoring-ssl-certificate-in-apache-httpclient-4-3
class Scraper {

//	XPathFactory xPathFactory = XPathFactory.newInstance();
	String outputFilenameBase = "";
	String mode = "";
	Map<String, String> refToHref = Maps.newHashMap();
	Queue<String> refQueue = Queues.newLinkedBlockingQueue();

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

				if (scraper.options.commandLine.hasOption("r")) {
					scraper.refToHref.put("html", "https://html.spec.whatwg.org/");
					scraper.refQueue.add("html");
					scraper.refToHref.put("svg2", "https://svgwg.org/svg2-draft/single-page.html");
					scraper.refQueue.add("svg2");
					scraper.refToHref.put("navigation timing", "http://www.w3.org/TR/navigation-timing/");
					scraper.refQueue.add("navigation timing");
					scraper.refToHref.put("requestanimationframe", "https://dvcs.w3.org/hg/webperf/raw-file/tip/specs/RequestAnimationFrame/Overview.html");
					scraper.refQueue.add("requestanimationframe");
					scraper.refToHref.put("mediasource", "http://w3c.github.io/media-source/");
					scraper.refQueue.add("mediasource");
//					scraper.refToHref.put("customelements", "http://w3c.github.io/webcomponents/spec/custom/");
//					scraper.refQueue.add("customelements");
					scraper.refToHref.put("shadowdom", "http://w3c.github.io/webcomponents/spec/shadow/");
					scraper.refQueue.add("shadowdom");
//					scraper.refToHref.put("htmlimports", "http://w3c.github.io/webcomponents/spec/imports/");
//					scraper.refQueue.add("htmlimports");
					scraper.processQueue();
				} else {
					if (scraper.options.commandLine.hasOption("o")) {
						scraper.outputFilenameBase = scraper.options.commandLine.getOptionValue("o");
						if (scraper.outputFilenameBase.endsWith(".idl")) {
							scraper.outputFilenameBase = scraper.outputFilenameBase.substring(0, scraper.outputFilenameBase.length - ".idl".length);
						}
					}
					if (scraper.options.commandLine.hasOption("m")) {
						scraper.mode = scraper.options.commandLine.getOptionValue("m");
					}
				}
				scraper.scrapeUrl(scraper.options.commandLine.args.get(0), "preCode".equalsIgnoreCase(scraper.mode));
			}
		} catch (ParseException pe) {
			System.out.println(pe.message);
			scraper.options.printUsage();
		}
	}

	def void processQueue() {
		while (!refQueue.empty) {
			System.out.println("Queue iteration");
			val String next = refQueue.poll();
			val href = refToHref.get(next);
			outputFilenameBase = next;
			scrapeUrl(href);
		}
	}


	def scrapeUrl(String urlString) {
		scrapeUrl(urlString, false);
	}
	// see http://stackoverflow.com/questions/9022140/using-xpath-contains-against-html-in-java
	def scrapeUrl(String urlString, boolean preCodeMode) {
		System.out.println("Scraping " + urlString);
		var out = System.out;
		var outRefs = System.out;
		try {
			if (!outputFilenameBase.nullOrEmpty) {
				val File outFile = new File(outputFilenameBase + ".idl");
				out = new PrintStream(outFile);
				val File outRefsFile = new File(outputFilenameBase + ".cmd");
				outRefs = new PrintStream(outRefsFile);
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
				var scrapeCount = 0;
				// Needed for https://dvcs.w3.org/hg/innerhtml/raw-file/tip/index.html
				scrapeCount += printNodeContent(out, doc, "pre.extraidl");
				scrapeCount += printNodeContent(out, doc, "pre.idl");
				scrapeCount += printNodeContent(out, doc, "code.idl-code");
//				// Needed for http://www.w3.org/TR/service-workers/
				if (preCodeMode) {
					scrapeCount += printNodeContent(out, doc, "pre code");
				}
//				System.out.println("New scraping:");
				scrapeCount += printNodeContentSpecial(out, doc);

				if (scrapeCount > 0) {
					var referenceCount = 0;
					referenceCount += printReferences(outRefs, doc, "dl#ref-list", scrapeCount);
					referenceCount += printReferences(outRefs, doc, "div#anolis-references dl", scrapeCount);
					referenceCount += printReferences(outRefs, doc, "section#normative-references dl.bibliography", scrapeCount);
					referenceCount += printReferences(outRefs, doc, "section#informative-references dl.bibliography", scrapeCount);
					System.out.println("Scrape count: " + scrapeCount + ", reference count: " + referenceCount);
					if (referenceCount == 0) {
						System.err.println("Found IDL fragments, but no references!");
					}
				}
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
			if (outRefs != null) {
				outRefs.close();
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

	private def int printReferences(PrintStream out, Document doc, String query, int idlCount) {
		val Elements elementsQuery = doc.select(query);
		if (elementsQuery.isEmpty()) {
			return 0;
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
					if (refToHref.containsKey(refName)) {
						if (idlCount > 0 && !ref.attr("href").equals(refToHref.get(refName))) {
							System.err.println("Same name but different href: " + ref.attr("href") + " vs. " + refToHref.get(refName));
						}
					} else {
						refToHref.put(refName, ref.attr("href"));
						refQueue.add(refName);
					}
					out.println("CALL scrape " + ref.attr("href") + " -o " + refName + ".idl");
				}
			}
		}
		return definitionList.size();
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
				val definitionList = definitionList(element);
				val String title = element.attr("title");
				val boolean isEnum = title.startsWith("enum");
				val boolean isCallback = title.startsWith("callback");
				val boolean isTypedef = title.startsWith("typedef");

				// TODO filter other EAs!
				val eas = definitionList.keySet().filter[it.text().startsWith("Constructor")].toList();
				if (eas.size() > 0) {
					out.println("[" + eas.map[it.text()].join(",") + "]");
				}
				out.print(title);
				if (!isCallback && !isTypedef) {
					out.println(" {");
				} else {
					out.println();
				}

				val members = definitionList.keySet().filter[!eas.contains(it)].toList();
				val List<String> innerListText = members.map[it.text()];

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
