module convcov.utils;

import std.exception : basicExceptionCtors;


class UnsupportedException : Exception
{
    ///
    mixin basicExceptionCtors;
}

class ParsingException : Exception
{
    ///
    mixin basicExceptionCtors;
}
