(* Send a string message via a socket. Doesn't return anything. *)
fun socketSend(sock, msg) = 
	Socket.sendVec(
		sock, 
		Word8VectorSlice.full(Byte.stringToBytes(msg)) 
	);

(* Receives maxbytes bytes from the socket. Returns the string message. *)
fun socketReceive(sock, maxbytes) = 
	Byte.bytesToString(
		Socket.recvVec(sock, maxbytes)
	);

(* Creates a client socket connected to the host and port *)
fun getClientSocket (host, port) = 
	let
		(* Take care of the address *)
		val rawaddr = NetHostDB.addr(valOf(NetHostDB.getByName(host))) (* Get the address from DNS *)
		val addr = INetSock.toAddr(rawaddr, port) (* Create an INetSock-friendly address *)

		val sock = INetSock.TCP.socket() (* Create socket *)
		val _ = Socket.connect(sock, addr) (* Connect it to the desired address *)
	in
		sock
	end;

(* Creates a server socket, bound to a specific port *)
fun getServerSocket port= 
	let
		val sock = INetSock.TCP.socket() (* Create socket *) 
		val _ = Socket.Ctl.setREUSEADDR(sock, true) (* Make sure that we can have multiple connections via the same socket *)
		val _ = Socket.bind(sock, INetSock.any port) (* Bind the socket to the port, accept incoming connections from any interface *)
		val _ = Socket.listen(sock, 1) (* Listen for connections *)
	in
		sock
	end;

(* Sample server implementation. It accepts multiple connections (not in
   parallel) and simply reads a message from the client and replies with the same
   message *)
fun server port = 
	let
		val sock = getServerSocket port (* Get socket *)
		
		(* This function takes care of a particular client *)
		fun respond conn = 
			let 
				val txt = socketReceive(conn, 1000) (* Read the message sent by client *)
			in
				socketSend(conn, txt); (* Send back the same message *)
				Socket.close(conn) (* Close connection *)
			end

		(* This function waits for connections, and feeds them to respond() *)
		fun accept() = 
			let 
				val (conn, conn_addr) = Socket.accept(sock) (* Get the socket of the new connection *)
			in
				respond conn; (* do job *)
				accept() (* loop *)
			end
	in
		accept()
	end;

(* Client implementation working with the server above. Connects to a given
   address (host and port) and sends the message msg to the server, and then prints
   the message it receives back *)
fun client(host, port, msg) = 
	let
		val s2 = getClientSocket(host, port); (* Create client socket *)
	in
		socketSend(s2, msg); (* Send message *)
		print (socketReceive(s2, 10000)); (* Print the server's response *)
		Socket.close(s2) (* Close connection *)
	end;

fun mail(host, port, msg, senderID, sender, recepient, subject, content) = 
	let
		val s2 = getClientSocket(host, port)
	in
		socketSend(s2, msg);
		print(socketReceive(s2, 1000));
		socketSend(s2, senderID);
		print(socketReceive(s2, 1000));
		socketSend(s2, sender);
		print(socketReceive(s2, 1000));
		socketSend(s2, recepient);
		print(socketReceive(s2, 1000));
		socketSend(s2, "data\r\n");
		print(socketReceive(s2, 1000));
		socketSend(s2, subject);
		socketSend(s2, content);
		socketSend(s2, ".\r\n");
		print(socketReceive(s2, 1000));
		socketSend(s2, "quit\r\n");
		print(socketReceive(s2, 1000));
		Socket.close(s2)
	end;

val host = "exchange.jacobs-university.de";
val port = 25;
val msg = "telnet exchange.jacobs-university.de 25\r\n";
val senderID = "helo mailhost.brazzers.com\r\n";
val sender = "mail from: subscriptions@brazzers.com\r\n";
val recepient = "rcpt to: f.stankovski@jacobs-university.de\r\n";
val subject = "subject: Your subscription is about to expire.\r\n\n";
val content = "Dear Customer,\n\nYour annual subscription is about to expire soon. As per the agreement, on April 11th, 2014, we will renew your subscription for EUR 9,99 per month for another year. However, in the unfortunate event that you wish to cancel your subscription, please contact the Brazzers customer support by replying to this email.\n\n Happy Brazzering,\n The Brazzers Team\r\n";

mail(host, port, msg, senderID, sender, recepient, subject, content);


