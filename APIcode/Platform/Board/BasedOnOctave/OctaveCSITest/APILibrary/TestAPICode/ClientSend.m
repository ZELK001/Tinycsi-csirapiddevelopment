function ClientSend(message) 

   import java.net.Socket
   import java.io.*

   global client_socket
   global IsSocketOpened

   host = '127.0.0.1';  %%Android设备的IP地址
   port = 8099;           %%端口号
   fprintf(1, 'connecting to %s:%d\n', host, port); 

     try
       if IsSocketOpened == 0     
           client_socket = Socket(host, port);
           fprintf(1, 'create socket\n');
           IsSocketOpened = 1;
       else
            fprintf(1, 'not create socket\n');
       end
       
       output_stream   = client_socket.getOutputStream;            
       d_output_stream = PrintStream(output_stream);   
       fprintf(1, 'Writing %d bytes\n', length(message))
       d_output_stream.println(message);   
    catch
       if ~isempty(client_socket)
           client_socket.close;
       end 
       client_socket.close;
       s = lasterror
       pause(1);
    end
end