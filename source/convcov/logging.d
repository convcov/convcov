module convcov.logging;

import std.experimental.logger;

version(Convcov_logger)
{
	version(Convcov_app)
	{
		/// Logging instance
		Logger logger;
	}
	else {
		/// Logging instance (defaults to NullLogger)
		Logger logger = new NullLogger();
	}
}

pragma(inline, true)
void log(string level, Args...)(Args args)
{
	version(Convcov_logger) with(LogLevel)
		logger.log(mixin(level), args);
}

pragma(inline, true)
void logf(string level, Args...)(Args args)
{
	version(Convcov_logger) with(LogLevel)
		logger.logf(mixin(level), args);
}
