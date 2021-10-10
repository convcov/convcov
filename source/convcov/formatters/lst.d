module convcov.formatters.lst;

import convcov.formatters.iformatter;
import convcov.utils;
import convcov.coverage;
import convcov.metadata;

final class LstFormatter : IFormatter
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

