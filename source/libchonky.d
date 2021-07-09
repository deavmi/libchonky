module libchonky;

/**
* libchonky
*
*
*/

import std.socket;
import core.sys.posix.sys.socket;

public final class ChonkReader
{
	/* The socket to read from */
	private Socket socket;
	private ptrdiff_t chunkSize;

	this(Socket socket)
	{
		/* THe socket must in STREAM mode */
		/* TODO */
		
		this.socket = socket;
	}

	/**
	* Read the amount given by the size of the buffer
	* This uses MSG_WAITALL and will only return when
	* the full amount bytes requested is fulfilled,
	* not just the currently available amount in the
	* kernel network queue
	*
	* Number of bytes received `0` if socket closed
	* (follow the normal D-standard) or Socket.ERROR
	*
	* ptrdiff_t is signed (long -> int, depending on arch (compiler time))
	*/
	public ptrdiff_t receiveAll(byte[] buffer)
	{
		/* Enable `MSG_WAITALL` flag */
		SocketFlags flags = cast(SocketFlags)MSG_WAITALL;


		return socket.receive(buffer, flags);
	} 


	/**
	* Some applications have no header for length but
	* demarcate the data ending by closing the socket
	* here one would want to chunk read as making
	* an assumption about how much data is sent would
	* be futile
	*
	* This will read in chunks of `chunkSize` whilst
	* stiching an array toghether. It will take in
	* a pointer to (len, ptr) (a.k.a. an array)
	* and set those for you.
	*
	* The total number of bytes is returned
	*/
	public ulong receiveUntilClose(ref byte[] buffer)
	{
		/* Temporary array */
		byte[] temp;
		temp.length=chunkSize;
		ulong bytesReceived;

		while(true)
		{
			/* Receive chunk many bytes */
			ptrdiff_t byteCount = receiveAll(temp);

			/* Ending (0 is closed socket, and I believe anything less would then be other errors) */
			if(byteCount <= 0)
			{
				break;
			}
			else
			{
				buffer ~= temp[0..byteCount];
				bytesReceived = bytesReceived + byteCount;
			}
		}
		/* TODO: Implement me */
		return bytesReceived;
	}
}