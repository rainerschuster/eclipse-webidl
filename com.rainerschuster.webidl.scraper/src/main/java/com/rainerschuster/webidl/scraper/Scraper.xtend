/*
 * Copyright 2015 Rainer Schuster
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
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
import org.jsoup.nodes.Node
import org.jsoup.nodes.TextNode

// TODO List of specs that use Web IDL https://www.w3.org/wiki/Web_IDL#Dependent_Specifications
// TODO http://stackoverflow.com/questions/19517538/ignoring-ssl-certificate-in-apache-httpclient-4-3
class Scraper {

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

			if (scraper.options.commandLine.args.empty && args.length == 0) {
				println("No URL specified!");
				scraper.options.printUsage();
			} else if (scraper.options.commandLine.args.size > 1 || args.length > 1) {
				println("Unexpected arguments: Exactly one URL is required!");
				scraper.options.printUsage();
			} else {
				// Main code
				SslUtil.disableCertificateValidation();

				if (scraper.options.commandLine.hasOption("r") || args.get(0) == "-r") {
					scraper.refToHref.put("html", "https://html.spec.whatwg.org/");
					scraper.refQueue.add("html");
					scraper.refToHref.put("svg2", "https://svgwg.org/svg2-draft/single-page.html");
					scraper.refQueue.add("svg2");
					scraper.refToHref.put("navigation timing", "http://www.w3.org/TR/navigation-timing/");
					scraper.refQueue.add("navigation timing");
					scraper.refToHref.put("mediasource", "http://w3c.github.io/media-source/");
					scraper.refQueue.add("mediasource");
					scraper.refToHref.put("geometry", "https://drafts.fxtf.org/geometry/");
					scraper.refQueue.add("geometry");
//					scraper.refToHref.put("customelements", "https://w3c.github.io/webcomponents/spec/custom/");
//					scraper.refQueue.add("customelements");
					scraper.refToHref.put("shadowdom", "https://w3c.github.io/webcomponents/spec/shadow/");
					scraper.refQueue.add("shadowdom");
//					scraper.refToHref.put("htmlimports", "https://w3c.github.io/webcomponents/spec/imports/");
//					scraper.refQueue.add("htmlimports");
//					scraper.refToHref.put("cssomview", "https://drafts.csswg.org/cssom-view/");
//					scraper.refQueue.add("cssomview");
					scraper.refToHref.put("sensors", "https://w3c.github.io/sensors/");
					scraper.refQueue.add("sensors");
					scraper.refToHref.put("proximity", "https://w3c.github.io/proximity/");
					scraper.refQueue.add("proximity");
					scraper.refToHref.put("encrypted-media", "https://w3c.github.io/encrypted-media/");
					scraper.refQueue.add("encrypted-media");
					scraper.refToHref.put("webcrypto", "https://w3c.github.io/webcrypto/");
					scraper.refQueue.add("webcrypto");
					scraper.refToHref.put("mediacapture-main", "https://w3c.github.io/mediacapture-main/getusermedia.html");
					scraper.refQueue.add("mediacapture-main");
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
					scraper.scrapeUrl(scraper.options.commandLine.args.get(0), "preCode".equalsIgnoreCase(scraper.mode));
				}
			}
		} catch (ParseException pe) {
			println(pe.message);
			scraper.options.printUsage();
		}
	}

	def void processQueue() {
		while (!refQueue.empty) {
			println("Queue iteration");
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
		println("Scraping " + urlString);
		if (urlString.endsWith(".pdf")) {
			println("Omitting PDF document.");
			return;
		}
		if (urlString.endsWith(".txt")) {
			println("Omitting TXT document.");
			return;
		}
		var out = System.out;
		var outRefs = System.out;
		try {
			if (!outputFilenameBase.nullOrEmpty) {
				val File outFile = new File(outputFilenameBase + ".idl");
				out = new PrintStream(outFile);
//				val File outRefsFile = new File(outputFilenameBase + ".cmd");
//				outRefs = new PrintStream(outRefsFile);
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

//				println("Old scraping:");
				var scrapeCount = 0;
				// Needed for https://dvcs.w3.org/hg/innerhtml/raw-file/tip/index.html
				scrapeCount += printNodeContent(out, doc, "pre.extraidl");
				scrapeCount += printNodeContent(out, doc, "pre.idl");
				scrapeCount += printNodeContent(out, doc, "code.idl");
				scrapeCount += printNodeContent(out, doc, "code.idl-code");
//				// Needed for http://www.w3.org/TR/service-workers/
				if (preCodeMode) {
					scrapeCount += printNodeContent(out, doc, "pre code");
				}
//				println("New scraping:");
				scrapeCount += printNodeContentSpecial(out, doc);

				if (scrapeCount > 0) {
					var referenceCount = 0;
					referenceCount += scrapeReferences(outRefs, doc, "h3#normative + dl", scrapeCount);
					referenceCount += scrapeReferences(outRefs, doc, "dl#ref-list", scrapeCount);
					referenceCount += scrapeReferences(outRefs, doc, "div#anolis-references dl", scrapeCount);
					referenceCount += scrapeReferences(outRefs, doc, "section#normative-references dl.bibliography", scrapeCount);
					referenceCount += scrapeReferences(outRefs, doc, "section#informative-references dl.bibliography", scrapeCount);
					println("Scrape count: " + scrapeCount + ", reference count: " + referenceCount);
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
			if (out !== null) {
				out.close();
			}
//			if (outRefs !== null) {
//				outRefs.close();
//			}
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

	private def int scrapeReferences(PrintStream out, Document doc, String query, int idlCount) {
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
							System.err.println("Same name but different href: " + ref.attr("href") + " vs. " + refToHref.get(refName) + " for ref name " + refName);
						}
					} else if (refToHref.containsValue(ref.attr("href"))) {
						System.err.println("Same href but different name: " + refName);
//						if (/*idlCount > 0 && */!refName.equals(refToHref.getValue(ref.attr("href")))) {
//							System.err.println("Same href but different name: " + refName + " vs. " + refToHref.getValue(ref.attr("href")) + " for ref name " + refName);
//						}
					} else {
						println("Adding ref " + refName + " with href " + ref.attr("href"));
						refToHref.put(refName, ref.attr("href"));
						refQueue.add(refName);
					}
//					out.println("CALL scrape " + ref.attr("href") + " -o " + refName + ".idl");
				}
			}
		}
		return definitionList.size();
	}
	
	private def void recursivePrint(StringBuilder sb, Node node) {
		// if(!ignore.contains(element.className()))
		if (node instanceof TextNode) {
			sb.append(node.wholeText);
		} else if (node instanceof Element) {
			val Element element = node as Element;
			if (element.classNames.contains("dfn-panel")) {
				println("Ignoring node since it is only a dfn-panel.");
			} else {
				for (Node child : element.childNodes()) {
					recursivePrint(sb, child);
				}
			}
		}
	}

	private def int printNodeContent(PrintStream out, Document doc, String query) {
		val StringBuilder sb = new StringBuilder();
		val Elements elements = doc.select(query);
		for (Element element : elements) {
			if (element.classNames.contains("extract")) {
				println("Ignoring node since it is only an extract.");
			} else {
				recursivePrint(sb, element);
				sb.append("\n");
			}
		}
		val String trimmed = sb.toString().trim();
		val String firstHalf = trimmed.substring(0, trimmed.length/2).trim();
		val String secondHalf = trimmed.substring(trimmed.length/2, trimmed.length).trim();
		if (!trimmed.empty) {
			if (firstHalf.equals(secondHalf)) {
				println("Ignoring half");
				out.println(firstHalf);
			} else {
				out.println(trimmed);
			}
		}
		return elements.size();
	}

	private def int printNodeContentSpecial(PrintStream out, Document doc) {
		val Elements elements = doc.select("dl.idl");
		for (Element element : elements) {
			if (element.classNames.contains("extract")) {
				println("Ignoring node since it is only an extract.");
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
