module convcov.utils.cinterfacing;

extern(C):

/// Variable that represents an error
__gshared const(char)* convcov_error = null;

/**
 * Initialize convcov global state
 *
 * This is needed before using any function of libconvcov.
 *
 * Returns: 0 on success, -1 otherwise
 */
int convcov_init() @trusted nothrow
{
	import core.runtime : rt_init;

	try return rt_init() ? 0 : -1;
	// catch every exception just to make sure it is nothrow
	catch (Exception ex)
	{
		convcov_error = allocConvcovError(ex.msg);
		return -1;
	}
}

/**
 * Terminate convcov global state
 *
 * This free any memory allocated during the usage of libconvcov.
 *
 * Returns: 0 on success, -1 otherwise
 */
int convcov_terminate() @trusted nothrow
{
	import core.runtime : rt_term;
	try return rt_term() ? 0 : -1;
	// catch every exception just to make sure it is nothrow
	catch (Exception ex)
	{
		convcov_error = allocConvcovError(ex.msg);
		return -1;
	}
}

extern(D) const(char)* allocConvcovError(string str) pure nothrow @trusted
{
	import core.memory : pureMalloc;
	auto p = (cast(char*)pureMalloc(str.length + 1))[0 .. str.length + 1];
	if(p is null) return null;
	import core.stdc.string : memcpy;
	memcpy(p.ptr, str.ptr, p.length);
	p[$ - 1] = '\0';

	return p.ptr;
}
