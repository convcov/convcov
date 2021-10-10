module convcov.formatters.html;

import convcov.formatters.iformatter;
import convcov.utils;
import convcov.coverage;
import convcov.metadata;

final class HtmlFormatter : IFormatter
{
	this(ref OutputMetadata metadata) {
		super(metadata);
	}

	override void write()
	{
		throw new UnsupportedException("Not yet implemented!");
	}

	override string toString() const
	{
		throw new UnsupportedException("Not yet implemented!");
	}
}

