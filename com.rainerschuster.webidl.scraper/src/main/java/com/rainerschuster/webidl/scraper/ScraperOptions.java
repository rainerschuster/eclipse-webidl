package com.rainerschuster.webidl.scraper;

import org.apache.commons.cli.BasicParser;
import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.OptionBuilder;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;

public class ScraperOptions {

	private Options options;
	private CommandLine commandLine;

	public void defineOptions() {
		options = new Options();

		final Option fileOption = OptionBuilder.withArgName( "file" )
			.hasArg()
	        .withDescription(  "output file" )
	        .create("o");
		options.addOption(fileOption);

		final Option modeOption = OptionBuilder.withArgName( "mode" )
			.hasArg()
	        .withDescription("parse mode")
	        .create("m");
		
		final Option recursiveOption = OptionBuilder.withArgName( "recursive" )
				.withDescription("recursive")
				.create("r");

		options.addOption(fileOption);
		options.addOption(modeOption);
		options.addOption(recursiveOption);
	}

	public void parseOptions(String[] args) throws ParseException {
		final CommandLineParser parser = new BasicParser();
		commandLine = parser.parse(options, args);
	}

	public void printUsage() {
		final HelpFormatter formatter = new HelpFormatter();
		formatter.printHelp(Scraper.class.getName(), options);
	}

	public Options getOptions() {
		return options;
	}

	public void setOptions(Options options) {
		this.options = options;
	}

	public CommandLine getCommandLine() {
		return commandLine;
	}

	public void setCommandLine(CommandLine commandLine) {
		this.commandLine = commandLine;
	}

}
