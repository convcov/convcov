module convcov.converters.html;

import convcov.converters.iconverter;
import convcov.utils;
import convcov.coverage;
import convcov.metadata;

final class HtmlConverter : IConverter
{
	this(ref InputMetadata metadata) {
		super(metadata);
	}

	override Coverage read()
	{
		throw new UnsupportedException("Not yet implemented!");
	}
}
