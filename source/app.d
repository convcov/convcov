import std.stdio;

import convcov.convert;
import convcov.logging;
import std.experimental.logger;

version(unittest) {}
else
int main(string[] args)
{
	ConvertOptions opt;
	string logfile;
	bool verbose;
	LogLevel loglevel = LogLevel.info;

	import std.getopt : getopt, defaultGetoptPrinter;
	static import std.getopt;
	auto helpInfo = getopt(
		args,
		"t|to", "Output file type format (default: convcov)", &opt.to,
		"f|from", "Input file type format (default: automatic)", &opt.from,
		"i|input", "Input file path", &opt.inputPath,
		"o|output", "Output file path of analysis report", &opt.outputPath,
		"s|sourcePath", "Source code path", &opt.sourcePath,
		"logfile", "Specify a log file to log into (default: stderr)", &logfile,
		"loglevel", "Specify the logging level (default: info)", &loglevel,
		std.getopt.config.bundling,
		"m|minify", "Minify ouput format, if possible (default: false)", &opt.minify,
		"I|indexing", "Index output folder (implies output to be a folder)", &opt.indexing,
		"v|verbose", "Verbose output (implies loglevel=all)", &verbose,
	);

	// if --help prompted
	if(helpInfo.helpWanted)
	{
		defaultGetoptPrinter(
			"Some information about the program\n",
			helpInfo.options
		);
		return 0;
	}

	if(verbose) loglevel = LogLevel.all;

	version(Convcov_logger)
	{
		import std.stdio : stderr;
		logger = logfile
			? new FileLogger(logfile, loglevel)
			: new FileLogger(stderr, loglevel);
	}

	log!"trace"("Start conversion");
	opt.convert();

	return 0;
}
