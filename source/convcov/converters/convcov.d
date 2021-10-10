module convcov.converters.convcov;

import convcov.converters.iconverter;
import convcov.utils;
import convcov.coverage;
import convcov.metadata;

final class ConvcovConverter : IConverter
{
	this(ref InputMetadata metadata) {
		super(metadata);
	}

	override Coverage read()
	{
		throw new UnsupportedException("Not yet implemented!");
	}
}
